module SignExt(
	input [16:0] Imm17,
	input [21:0] Imm22,
	input [4:0] shamt,
	output [31:0] Iext_D, Jext, zeroExt_D, shamtExt_D
);
assign shamtExt_D = {27'b0, shamt};
assign zeroExt_D = {15'b0, Imm17};
assign Iext_D = {{15{Imm17[16]}}, Imm17};
assign Jext = {{10{Imm22[21]}}, Imm22};
endmodule
