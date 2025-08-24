module filter2d #(parameter WIDTH = 256)
/*	Memory Map
	0 ~ 256*256-1 : Read
	256*256 ~ 	  : Write
*/
(
	input clk,
	input reset_n,
	// I/O Strobes
	input start,
	output reg finish,
	// SRAM I/F
	output cs,
	output we,
	output [16:0] addr, // clog2(256*256*2) = 17
	output [7:0] din,
	input [7:0] dout,
	// Kernel I/F
	input h_write,
	input [3:0] h_idx,
	input [7:0] h_data
);

// Kernel Handler
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

reg on_proc;
reg [3:0] cnt;	 // 0~11 (MEM -> MAC -> OUT)
reg [7:0] cnt_x; // 0~255
reg [7:0] cnt_y; // 0~255

// cnt setting
always@(posedge clk or negedge reset_n) begin
	if(~reset_n) begin
		on_proc <= 1'b0;
		cnt <= 0;
		cnt_x <= 0;
		cnt_y <= 0;
		finish <= 1'b0;
	end 
	else begin
		if(start) on_proc <= 1'b1;
		else if((cnt == 11) && (cnt_x == WIDTH - 1) && (cnt_y == WIDTH - 1)) on_proc <= 1'b0;
		
		if(on_proc) begin
			cnt <= (cnt == 11) ? 0 : cnt+1;
			if(cnt == 11) begin
				cnt_x <= (cnt_x == WIDTH - 1) ? 0 : cnt_x+1;
				if(cnt_x == WIDTH - 1)
					cnt_y <= (cnt_y == WIDTH - 1) ? 0 : cnt_y+1;
			end
		end
		finish <= ((cnt == 11) && (cnt_x == WIDTH - 1) && (cnt_y == WIDTH - 1));
	end
end

// mem_read (cnt: 0 ~ 8) -> dout (cnt: 1 ~ 9)
reg [16:0] rd_addr;
always@(*) begin
	case(cnt) // 예외처리는 acc_en으로 수행
		4'd0: rd_addr = (cnt_y-1)*WIDTH + cnt_x-1;
		4'd1: rd_addr = (cnt_y-1)*WIDTH + cnt_x;
		4'd2: rd_addr = (cnt_y-1)*WIDTH + cnt_x+1;
		4'd3: rd_addr = (cnt_y )*WIDTH + cnt_x-1;
		4'd4: rd_addr = (cnt_y )*WIDTH + cnt_x;
		4'd5: rd_addr = (cnt_y )*WIDTH + cnt_x+1;
		4'd6: rd_addr = (cnt_y+1)*WIDTH + cnt_x-1;
		4'd7: rd_addr = (cnt_y+1)*WIDTH + cnt_x;
		4'd8: rd_addr = (cnt_y+1)*WIDTH + cnt_x+1;
		default: rd_addr = 0;
	endcase
end

// dout (cnt: 1 ~ 9) -> pd (cnt: 2 ~ 10)
reg [7:0] pd;
wire pd_en = (cnt >= 1) && (cnt <= 9);
always@(posedge clk or negedge reset_n) begin
	if(~reset_n)pd <= 0; 
	else if(pd_en) pd <= dout;		
end

// pd (cnt: 2 ~ 10) -> acc (cnt: 3 ~ 11)
wire signed [7:0] coeff = h[cnt-2];
wire signed [15:0] mul = pd * coeff; 
reg signed [19:0] acc; 
// (cnt == 1): 이전 픽셀의 11cycle 값을 들고 있는 acc를 초기화
wire signed [19:0] acc_in = (cnt == 1) ? 0 : mul + acc;
reg acc_en; 
always@(*) begin
	acc_en = 1'b0;
	case(cnt)
		4'd1: acc_en = 1'b1;
		4'd2: if((cnt_y > 0) && (cnt_x > 0)) acc_en = 1'b1;
		4'd3: if((cnt_y > 0) ) acc_en = 1'b1;
		4'd4: if((cnt_y > 0) && (cnt_x < WIDTH - 1)) acc_en = 1'b1;
		4'd5: if(cnt_x > 0) acc_en = 1'b1;
		4'd6: acc_en = 1'b1;
		4'd7: if(cnt_x < WIDTH - 1) acc_en = 1'b1;
		4'd8: if((cnt_y < WIDTH - 1) && (cnt_x > 0)) acc_en = 1'b1;
		4'd9: if((cnt_y < WIDTH - 1) ) acc_en = 1'b1;
		4'd10: if((cnt_y < WIDTH - 1) && (cnt_x < WIDTH - 1)) acc_en = 1'b1;
		default: acc_en = 1'b0;
	endcase
end

always@(posedge clk or negedge reset_n) begin
	if(~reset_n) acc <= 0;
	else if(acc_en) acc <= acc_in;
end

// rounding & clamping
wire [19:0] pd_rnd_1 = acc + (1<<6);
// Fixed-Point (20,7)에서 정수부 추출 
wire [12:0] pd_rnd = pd_rnd_1[19:7]; 
// 정수부의 하위 8bit 추출 
wire [7:0] pd_out = (pd_rnd < 0) ? 0 : (pd_rnd > WIDTH - 1) ? WIDTH - 1 : pd_rnd[7:0];
wire mem_rd = (cnt >= 0) && (cnt <= 8) && (on_proc == 1'b1);
wire mem_wr = (cnt == 11);

wire [16:0] wr_addr = ( cnt_y * WIDTH + cnt_x ) + WIDTH*WIDTH;
assign din = pd_out; 
assign cs = mem_rd | mem_wr;
assign we = mem_wr;
assign addr = (mem_rd == 1'b1) ? rd_addr : wr_addr;
endmodule