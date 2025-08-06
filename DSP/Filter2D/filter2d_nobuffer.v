module filter2d (
	input clk,
	input n_reset,
	input start,
	output reg finish,
	output cs,
	output we,
	output [16:0] addr,
	output [7:0] din,
	input [7:0] dout,
	input h_write,
	input [3:0] h_idx,
	input [7:0] h_data
);
reg on_proc;
reg [3:0] cnt;
reg [7:0] cnt_x;
reg [7:0] cnt_y;

// cnt setting
always@(posedge clk or negedge n_reset) begin
	if(n_reset == 1'b0) begin
		on_proc <= 1'b0;
		cnt <= 0;
		cnt_x <= 0;
		cnt_y <= 0;
		finish <= 1'b0;
	end 
	else begin
		if(start == 1'b1) on_proc <= 1'b1;
		else if((cnt == 11) && (cnt_x == 255) && (cnt_y == 255)) on_proc <= 1'b0;
		
		if(on_proc == 1'b1) begin
			cnt <= (cnt == 11) ? 0 : cnt+1;
			if(cnt == 11) begin
				cnt_x <= (cnt_x == 255) ? 0 : cnt_x+1;
				if(cnt_x == 255) begin
					cnt_y <= (cnt_y == 255) ? 0 : cnt_y+1;
				end
		end
	end
	finish <= ((cnt == 11) && (cnt_x == 255) && (cnt_y == 255));
end

// memory read
// 9cycle
reg [16:0] rd_addr;
always@(*) begin
	// cnt_x/y
	// verilog -> Ignore Garbage at acc-stage
	case(cnt)
		4'd0: rd_addr = (cnt_y-1)*256 + cnt_x-1;
		4'd1: rd_addr = (cnt_y-1)*256 + cnt_x;
		4'd2: rd_addr = (cnt_y-1)*256 + cnt_x+1;
		4'd3: rd_addr = (cnt_y )*256 + cnt_x-1;
		4'd4: rd_addr = (cnt_y )*256 + cnt_x;
		4'd5: rd_addr = (cnt_y )*256 + cnt_x+1;
		4'd6: rd_addr = (cnt_y+1)*256 + cnt_x-1;
		4'd7: rd_addr = (cnt_y+1)*256 + cnt_x;
		4'd8: rd_addr = (cnt_y+1)*256 + cnt_x+1;
		default: rd_addr = 1'bx;
	endcase
end

// SRAM(DOUT) -> pd
reg [7:0] pd;
// SRAM에서 0-8cycle에서 값을 출력
// pd는 1-9cycle에서 값을 출력
wire pd_en = (cnt >= 1) && (cnt <= 9);
always@(posedge clk or negedge n_reset) begin
	if(~n_reset)pd <= 0; 
	else 
		if(pd_en) pd <= dout;
end

// Kernel Handler
reg signed [7:0] h[0:8];
always@(posedge clk or negedge n_reset) begin
	if(~n_reset) begin
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
	else 
		if(h_write) h[h_idx] <= h_data;	
end

// acc-stage인 2-10cycle에서 값 생성
wire signed [7:0] coeff = h[cnt-2];
wire signed [15:0] mul = pd * coeff; 
reg signed [19:0] acc;
// cnt 1에서 acc 0 초기화
wire signed [19:0] acc_in = (cnt == 1) ? 0 : mul + acc;
reg acc_en; 
always@(*) begin
	acc_en = 1'b0;
	// cnt 0: reading
	// cnt 11: writing
	case(cnt)
		4'd1: acc_en = 1'b1;
		4'd2: if((cnt_y > 0) && (cnt_x > 0)) acc_en = 1'b1;
		4'd3: if((cnt_y > 0) ) acc_en = 1'b1;
		4'd4: if((cnt_y > 0) && (cnt_x < 255)) acc_en = 1'b1;
		4'd5: if(cnt_x > 0) acc_en = 1'b1;
		4'd6: acc_en = 1'b1;
		4'd7: if(cnt_x < 255) acc_en = 1'b1;
		4'd8: if((cnt_y < 255) && (cnt_x > 0)) acc_en = 1'b1;
		4'd9: if((cnt_y < 255) ) acc_en = 1'b1;
		4'd10: if((cnt_y < 255) && (cnt_x < 255)) acc_en = 1'b1;
		default: acc_en = 1'b0;
	endcase
end

// final acc-output
always@(posedge clk or negedge n_reset) begin
	if(~n_reset) acc <= 0;
	else 
		if(acc_en) acc <= acc_in;
end

// rounding & sat for acc-output
wire [19:0] pd_rnd_1 = acc + (1<<6);
wire [12:0] pd_rnd = pd_rnd_1[19:7];
wire [7:0] pd_out = (pd_rnd < 0) ? 0 
								 : (pd_rnd > 255) ? 255 
												  : pd_rnd[7:0];
assign din = pd_out; // filter_out => img_buf_in
wire mem_rd = (cnt >= 0) && (cnt <= 8) && (on_proc == 1'b1);
wire mem_wr = (cnt == 11);
// 0 ~ 256*256-1 : Read
// 256*256 ~ 	 : Write
wire [16:0] wr_addr = ( cnt_y * 256 + cnt_x ) + 256*256;
assign cs = mem_rd | mem_wr;
assign we = mem_wr;
assign addr = (mem_rd == 1'b1) ? rd_addr : wr_addr;
endmodule