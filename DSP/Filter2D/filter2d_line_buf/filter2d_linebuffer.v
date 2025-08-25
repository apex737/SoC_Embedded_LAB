module filter2d #(parameter WIDTH = 256) 
(
	input clk,
	input reset_n,
	// Input I/F
	input i_strb, // tick
	input [7:0] i_data,
	// Output I/F
	output reg o_strb,
	output reg [7:0] o_data,
	// Kernel I/F
	input h_write,
	input [3:0] h_idx,
	input [7:0] h_data
);

reg signed [7:0] h[0:8];
always@(posedge clk or negedge reset_n) begin
	if(~reset_n) begin
		h[0] <= 8'h08;
		h[1] <= 8'h10;
		h[2] <= 8'h08;
		h[3] <= 8'h10;
		h[4] <= 8'h20;
		h[5] <= 8'h10;
		h[6] <= 8'h08;
		h[7] <= 8'h10;
		h[8] <= 8'h08;
	end 
	else if(h_write) h[h_idx] <= h_data;
end

reg valid; // 3×3 윈도가 채워졌음을 의미
reg [3:0] cnt;
reg [7:0] cnt_x, cnt_y;
reg [7:0] i_data_d;

always@(posedge clk or negedge reset_n) begin
	/* 	새로운 img의 첫째 픽셀이 읽히는 경우
		이전 img의 마지막 프레임의 연산이 끝난 상태가 자연스럽다
		마지막 프레임의 center 값은 (254,254) 이므로 
		(cnt_x, cnt_y)의 IDLE 값은 (254,254) */
	if(~reset_n) begin
		valid <=  0; 
		cnt <= 7; // IDLE 7 (cnt 0-6까지 값이 전부 FSM의 유의미한 State)
		cnt_x <= 254; 
		cnt_y <= 254;
		i_data_d <= 0;
	end	else begin
		// cnt setting
		if(i_strb) begin
			cnt_x <= (cnt_x == WIDTH - 1) ? 0 : cnt_x+1;
			if(cnt_x == WIDTH - 1) begin
				cnt_y <= (cnt_y == WIDTH - 1) ? 0 : cnt_y+1;
				if(cnt_y == WIDTH - 1) valid <= 1; // 첫 프레임 다 돌면 유효
			end
		end
		// cnt7(IDLE) -> cnt0
		if(i_strb) begin 
			cnt <= 0;
			i_data_d <= i_data;
		end
		else if(cnt < 7) cnt <= cnt+1;
	end
end

// Data Reuse Buffer (cnt: 0~2)
reg [7:0] ibuf[2:0][2:0]; 	// 3x3 픽셀 윈도
wire [7:0] dout;		   	// 라인버퍼(SRAM) 읽은 값
always@(posedge clk or negedge reset_n) begin
	if(~reset_n) begin
		for(int i=0;i<3;i++) 
			for(int j=0;j<3;j++) 
				ibuf[i][j] <= 0;
	end else begin
		// ibuf LShift
		if(cnt == 0) begin
			for(int i=0;i<3;i++)
				for(int j=0;j<2;j++)
					ibuf[i][j] <= ibuf[i][j+1];
			ibuf[2][2] <= i_data_d; // 현재 읽는 위치의 값 (l) 
		end
		if(cnt == 1) ibuf[0][2] <= dout; // 1cycle에 line-buffer에서 읽은 j대입
		if(cnt == 2) ibuf[1][2] <= dout; // 2cycle에 line-buffer에서 읽은 k대입
	end
end

wire mem_rd = (cnt == 0) || (cnt == 1); // cnt0,1에서 읽어야 1,2에서 쓸수있음
wire mem_wr = (cnt == 2);
reg [8:0] wptr; // Line Buffer wptr 
// wire [8:0] rptr0 = (wptr < 2*WIDTH) ? (wptr-2*WIDTH+BUF_LEN) : wptr-2*WIDTH;
// wptr은 항상 2*WIDTH보다 작고, BUF_LEN은 2*WIDTH로 고정
wire [8:0] rptr0 = wptr;  // rptr0 자리를 wptr로 읽은 값으로 override
// wire [8:0] rptr0 = (wptr < WIDTH) ? (wptr-*WIDTH+BUF_LEN) : wptr-WIDTH;
wire [8:0] rptr1 = (wptr < WIDTH) ? wptr+WIDTH : wptr-WIDTH;  // Line Buffer rptr1
wire [8:0] rptr = (cnt == 0) ? rptr0 : rptr1;

// wptr은 0 ~ 2*WIDTH-1를 순환하며 단순 증가
always@(posedge clk or negedge reset_n) begin
	if(~reset_n) wptr <= 0;
	else if(mem_wr)
		wptr <= (wptr == 2*WIDTH-1) ? 0 : wptr + 1;
end

wire cs = mem_rd | mem_wr;
wire we = mem_wr;
// line buffer에서 읽어야하면 rptr0, rptr1 자리에서 dout을 가져오고 
// line buffer에 써야하면 wptr(이전 rptr0) 자리에 din을 전달함
wire [8:0] addr = (mem_wr) ? wptr : rptr;
wire [7:0] din = i_data_d;

mem_single #(
	.WD(8),
	.DEPTH(2*WIDTH)
) i_buf0 (
	.clk(clk),
	.cs(cs),
	.we(we),
	.addr(addr),
	.din(din),
	.dout(dout)
);

reg signed [15:0] mul[2:0][2:0];
always@(posedge clk or negedge reset_n) begin
	if(~reset_n) begin
		for(int i=0;i<3;i++) 
			for(int j=0;j<3;j++) 
				mul[i][j] <= 0;
	end else begin
		// ibuf의 외곽 픽셀이 경계를 넘어가는 경우 zero-padding
		if((cnt == 3) && valid) begin
			mul[0][0] <= ((cnt_y > 0) && (cnt_x > 0)) ? ibuf[0][0] * h[0] : 0;
			mul[0][1] <= ((cnt_y > 0) ) ? ibuf[0][1] * h[1] : 0;
			mul[0][2] <= ((cnt_y > 0) && (cnt_x < WIDTH - 1)) ? ibuf[0][2] * h[2] : 0;
			mul[1][0] <= (cnt_x > 0) ? ibuf[1][0] * h[3] : 0;
			mul[1][1] <= ibuf[1][1] * h[4];
			mul[1][2] <= (cnt_x < WIDTH - 1) ? ibuf[1][2] * h[5] : 0; 
			mul[2][0] <= ((cnt_y < WIDTH - 1) && (cnt_x > 0)) ? ibuf[2][0] * h[6] : 0;
			mul[2][1] <= ((cnt_y < WIDTH - 1) ) ? ibuf[2][1] * h[7] : 0;
			mul[2][2] <= ((cnt_y < WIDTH - 1) && (cnt_x < WIDTH - 1)) ? ibuf[2][2] * h[8] : 0;
		end
	end
end

reg signed [19:0] sum_in;
reg signed [19:0] sum;
always@(*) begin
	sum_in = 0;
	for(int i=0;i<3;i++)
		for(int j=0;j<3;j++)
			sum_in = sum_in + mul[i][j];
end

always@(posedge clk or negedge reset_n) begin
	if(~reset_n) sum <= 0;
	else if((cnt == 4) && valid)
		sum <= sum_in;
end

// Round & Clamp
wire signed [19:0] pd_rnd_1 = sum + (1<<6);
wire signed [12:0] pd_rnd = pd_rnd_1[19:7];
wire signed [7:0] pd_out = (pd_rnd < 0) ? 0 : (pd_rnd > WIDTH-1) ? WIDTH-1 : pd_rnd[7:0];

always@(posedge clk or negedge reset_n) begin
	if(~reset_n) begin
		o_strb <=  0;
		o_data <= 0;
	end else begin
		o_strb <= ((cnt == 5) && valid);
		if((cnt == 5) && valid) 
			o_data <= pd_out;
	end
end

endmodule