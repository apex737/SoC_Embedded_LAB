module buf_ctrl (
	input clk,
	input reset_n,
	// Data Input + Strobe (valid HS)
	input i_strb,
	input [7:0] i_data,
	// MEM I/F
	input mem_rd,
	input [15:0] rd_addr,
	output [7:0] rd_data
	// operation valid strobe
	output reg start
);

reg [7:0] cnt_x, cnt_y;
always@(posedge clk or negedge reset_n) begin
	if(~reset_n) begin 
		cnt_x <= 255; cnt_y <= 255; 
	end else begin
		if(i_strb) begin
			cnt_x <= (cnt_x == 255) ? 0 : cnt_x+1;
			if(cnt_x == 255)
				cnt_y <= (cnt_y == 255) ? 0 : cnt_y+1;
		end
	end
end

/*	mode0; buf0: store, buf1: process
	mode1; buf1: store, buf0: process */
reg mode;
wire mode_change;
assign mode_change = (mem_wr == 1'b1) && (cnt_x == 255) && (cnt_y == 255);
always@(posedge clk or negedge reset_n) begin
	if(~reset_n) begin
		mode <= 1'b0; start <= 1'b0;
	end	else begin
		if(mode_change) mode <= ~mode;
		start <= mode_change;
	end
end

reg mem_wr; 		// Registered i_strb (valid HS)
reg [7:0] wr_data;  // Registered i_data
always@(posedge clk or negedge reset_n) begin
	if(~reset_n) begin
		mem_wr <= 1'b0; 
		wr_data <= 8'b0;
	end else begin
		mem_wr <= i_strb;
		wr_data <= i_data;
	end
end

// Mode Arbiter
wire [15:0] wr_addr = cnt_y*256 + cnt_x;
wire cs0 = (mode == 1'b0) ? mem_wr : mem_rd;
wire we0 = (mode == 1'b0) ? mem_wr : 1'b0;
wire [15:0] addr0 = (mode == 1'b0) ? wr_addr : rd_addr;
wire [7:0] din0 = (mode == 1'b0) ? wr_data : 1'b0;
wire [7:0] dout0;

wire cs1 = (mode == 1'b1) ? mem_wr : mem_rd;
wire we1 = (mode == 1'b1) ? mem_wr : 1'b0;
wire [15:0] addr1 = (mode == 1'b1) ? wr_addr : rd_addr;
wire [7:0] din1 = (mode == 1'b1) ? wr_data : 1'b0;
wire [7:0] dout1;
assign rd_data = (mode == 1'b0) ? dout1 : dout0;

mem_single #(
	.WD(8),
	.DEPTH(256*256)
) i_buf0 (
	.clk(clk),
	.cs(cs0),
	.we(we0),
	.addr(addr0),
	.din(din0),
	.dout(dout0)
);
mem_single #(
	.WD(8),
	.DEPTH(256*256)
) i_buf1 (
	.clk(clk),
	.cs(cs1),
	.we(we1),
	.addr(addr1),
	.din(din1),
	.dout(dout1)
);
endmodule