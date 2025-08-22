module filter2d #(parameter WIDTH = 256) 
(
	input clk,
	input n_reset,
	input i_strb,
	input [7:0] i_data,
	output reg o_strb,
	output reg [7:0] o_data,
	input h_write,
	input [3:0] h_idx,
	input [7:0] h_data
);

reg garbage;
reg [3:0] cnt;
reg [7:0] cnt_x;
reg [7:0] cnt_y;
reg [7:0] i_data_d;

always@(posedge clk or negedge n_reset) begin
	// 새로운 img의 첫째 픽셀이 읽히는 경우
	// 이전 img의 마지막 프레임의 연산이 끝난 상태가 자연스럽다
	// 마지막 프레임의 center 값은 (254,254) 이므로
	// cnt_x/y의 IDLE 값은 (254,254)
	if(n_reset == 1'b0) begin
		garbage <= 1'b1; // 현재 값이 유효한지를 나타내는 FLAG
		cnt <= 7; // IDLE 7 (0-6까지 값이 전부 FSM의 유의미한 State)
		cnt_x <= 254; 
		cnt_y <= 254;
		i_data_d <=1'b0;
	end
	else begin
		if(i_strb == 1'b1) begin
			cnt_x <= (cnt_x == WIDTH - 1) ? 0 : cnt_x+1;
			if(cnt_x == WIDTH - 1) begin
				cnt_y <= (cnt_y == WIDTH - 1) ? 0 : cnt_y+1;
				if(cnt_y == WIDTH - 1) garbage <= 1'b0;
			end
		end
		
		if(i_strb == 1'b1) cnt <= 0;
		// cnt 7 ?
		// 
		else if(cnt < 7) cnt <= cnt+1;
		
		if(i_strb == 1'b1) i_data_d <= i_data;
	end
end

reg [7:0] ibuf[2:0][2:0]; // Data Reuse를 위한 buffer
wire [7:0] dout;
always@(posedge clk or negedge n_reset) begin
	if(n_reset == 1'b0) begin
		for(int i=0;i<3;i++) begin
			for(int j=0;j<3;j++) begin
				ibuf[i][j] <=1'b0;
			end
		end
	end 
	else begin
		// ibuf의 RShift
		if(cnt == 0) begin
			for(int i=0;i<3;i++) begin
				for(int j=0;j<2;j++) begin
					ibuf[i][j] <= ibuf[i][j+1];
				end
			end
			ibuf[2][2] <= i_data_d; // 현재 읽는 위치의 값 (c) 
		end
		if(cnt == 1) ibuf[0][2] <= dout; // 1cycle에 line-buffer에서 읽은 a대입
		if(cnt == 2) ibuf[1][2] <= dout; // 2cycle에 line-buffer에서 읽은 b대입
	end
end

// WIDTH = 256
wire mem_rd = (cnt == 0) || (cnt == 1); 
wire mem_wr = (cnt == 2);
reg [8:0] wr_addr; // c의 주소 (우측 하단)
// wire [8:0] rd_addr0 = (wr_addr < 2*WIDTH) ? (wr_addr-2*WIDTH+BUF_LEN) 
									 //  : wr_addr-2*WIDTH;

wire [8:0] rd_addr0 = wr_addr; // a의 주소
wire [8:0] rd_addr1 = (wr_addr < WIDTH) ? wr_addr+WIDTH : wr_addr-WIDTH; // b의 주소
wire [8:0] rd_addr = (cnt == 0) ? rd_addr0 : rd_addr1;

always@(posedge clk or negedge n_reset) begin
	if(n_reset == 1'b0) begin
		wr_addr <= 0;
	end 
	else begin
		if(mem_wr == 1'b1) begin
			wr_addr <= (wr_addr == 2*WIDTH-1) ? 0 : wr_addr + 1;
		end
	end
end
wire cs = mem_rd | mem_wr;
wire we = mem_wr;
wire [8:0] addr = (mem_wr == 1'b1) ? wr_addr : rd_addr;
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

reg signed [7:0] h[0:8];
always@(posedge clk or negedge n_reset) begin
	if(n_reset == 1'b0) begin
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
	else begin
		if(h_write == 1'b1) begin
			h[h_idx] <= h_data;
		end
	end
end

reg signed [15:0] mul[2:0][2:0];
always@(posedge clk or negedge n_reset) begin
	if(n_reset == 1'b0) begin
		for(int i=0;i<3;i++) begin
			for(int j=0;j<3;j++) begin
				mul[i][j] <=1'b0;
			end
		end
	end 
	else begin
		// ibuf의 외곽 픽셀이 경계를 넘어가는 경우 zero-padding
		if((cnt == 3) && (garbage == 1'b0)) begin
			mul[0][0] <= ((cnt_y > 0) && (cnt_x > 0)) ? ibuf[0][0] * h[0] :1'b0;
			mul[0][1] <= ((cnt_y > 0) ) ? ibuf[0][1] * h[1] :1'b0;
			mul[0][2] <= ((cnt_y > 0) && (cnt_x < WIDTH - 1)) ? ibuf[0][2] * h[2] :1'b0;
			mul[1][0] <= (cnt_x > 0) ? ibuf[1][0] * h[3] :1'b0;
			mul[1][1] <= ibuf[1][1] * h[4];
			mul[1][2] <= (cnt_x < WIDTH - 1) ? ibuf[1][2] * h[5] :1'b0; 
			mul[2][0] <= ((cnt_y < WIDTH - 1) && (cnt_x > 0)) ? ibuf[2][0] * h[6] :1'b0;
			mul[2][1] <= ((cnt_y < WIDTH - 1) ) ? ibuf[2][1] * h[7] :1'b0;
			mul[2][2] <= ((cnt_y < WIDTH - 1) && (cnt_x < WIDTH - 1)) ? ibuf[2][2] * h[8] :1'b0;
		end
	end
end
reg signed [19:0] sum_in;
reg signed [19:0] sum;
always@(*) begin
	sum_in = 0;
	for(int i=0;i<3;i++) begin
		for(int j=0;j<3;j++) begin
			sum_in = sum_in + mul[i][j];
		end
	end
end

always@(posedge clk or negedge n_reset) begin
	if(n_reset == 1'b0) begin
		sum <=1'b0;
	end 
	else begin
		if((cnt == 4) && (garbage == 1'b0)) begin
			sum <= sum_in;
		end
	end
end
wire [19:0] pd_rnd_1 = sum + (1<<6);
wire [12:0] pd_rnd = pd_rnd_1[19:7];
wire [7:0] pd_out = 
(pd_rnd < 0) ? 0 : (pd_rnd > WIDTH-1) ? WIDTH-1 : pd_rnd[7:0];

always@(posedge clk or negedge n_reset) begin
	if(n_reset == 1'b0) begin
		o_strb <= 1'b0;
		o_data <=1'b0;
	end 
	else begin
		o_strb <= ((cnt == 5) && (garbage == 1'b0));
		if((cnt == 5) && (garbage == 1'b0)) begin
			o_data <= pd_out;
		end
	end
end
endmodule