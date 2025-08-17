module ALU(
	input [3:0] ALUOP_E,
	input signed [31:0] ALUSRC1, ALUSRC2,
	output reg [31:0] ALUOUT_E
);
wire [4:0] shamt = ALUSRC2[4:0];
wire [31:0] ROR = (ALUSRC1 >> shamt) | (ALUSRC1 << (5'd32 - shamt));
always@* begin
	ALUOUT_E = 0;
	case(ALUOP_E)
		4'd0: ALUOUT_E = 0;
		4'd1: ALUOUT_E = ALUSRC1 + ALUSRC2;
		4'd2: ALUOUT_E = ALUSRC1 - ALUSRC2;
		4'd3: ALUOUT_E = (-ALUSRC2);
		4'd4: ALUOUT_E = (~ALUSRC2);
		4'd5: ALUOUT_E = ALUSRC1 & ALUSRC2;
		4'd6: ALUOUT_E = ALUSRC1 | ALUSRC2;
		4'd7: ALUOUT_E = ALUSRC1 ^ ALUSRC2;
		4'd8: ALUOUT_E = ALUSRC1 >> shamt;
		4'd9: ALUOUT_E = ALUSRC1 >>> shamt;
		4'd10: ALUOUT_E = ALUSRC1 << shamt;
		4'd11: ALUOUT_E = ROR;
		4'd12: ALUOUT_E = ALUSRC2;
	endcase
end

endmodule
