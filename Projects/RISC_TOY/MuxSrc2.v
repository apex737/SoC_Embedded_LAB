module MuxSrc2(
	input [2:0] Sel2_E,
	input [31:0] DOUT1_E, Iext_E, shamtExt_E, zeroExt_E, JPC_E,
	output reg [31:0] SRC2
);
always@* begin
	SRC2 = DOUT1_E;
	case(Sel2_E)
		1: SRC2 = Iext_E;
		2: SRC2 = shamtExt_E;
		3: SRC2 = zeroExt_E;
		4: SRC2 = JPC_E;
	endcase
end
endmodule
