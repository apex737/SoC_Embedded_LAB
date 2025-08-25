module top (
	input clk,
	input reset_n,
	input i_strb,
	input [7:0] i_data,
	output o_strb,
	output [7:0] o_data
);
wire start;
wire mem_rd;
wire [15:0] rd_addr;
wire [7:0] rd_data;

buf_ctrl i_buf (
	.clk(clk),
	.reset_n(reset_n),
	.i_strb(i_strb),
	.i_data(i_data),
	.start(start),
	.mem_rd(mem_rd),
	.rd_addr(rd_addr),
	.rd_data(rd_data)
);

filter2d_op i_op(
	.clk(clk),
	.reset_n(reset_n),
	.start(start),
	.mem_rd(mem_rd),
	.rd_addr(rd_addr),
	.rd_data(rd_data),
	.o_strb(o_strb),
	.o_data(o_data)
);

endmodule

