module DE(
	// input 
	input CLK, RSTN, DEFlush,
	input [1:0] SelWB_D,
	input WEN_D, Load_D, 
	input DRW_D, DREQ_D, RS1Used_D, RS2Used_D, Sel1_D,
	input [2:0] Sel2_D, 
	input [3:0] ALUOP_D,
	input [4:0] RA0_D, RA1_D, WA_D,
	input [31:0] DOUT0_D, DOUT1_D, PCADD4_D,
	input [31:0] JPC_D, zeroExt_D, Iext_D, shamtExt_D,
	// output
	output reg [1:0] SelWB_E,
	output reg WEN_E, Load_E,
	output reg DRW_E, DREQ_E, RS1Used_E, RS2Used_E, Sel1_E,
	output reg [2:0] Sel2_E, 
	output reg [3:0] ALUOP_E,
	output reg [4:0] RA0_E, RA1_E, WA_E,
	output reg [31:0] DOUT0_E, DOUT1_E, PCADD4_E,
	output reg [31:0] JPC_E, zeroExt_E, Iext_E, shamtExt_E
);
always@(posedge CLK or negedge RSTN) begin
	if(~RSTN) begin
		WEN_E <= 1; DREQ_E <= 1; SelWB_E <= 0; Load_E <= 0; DRW_E <= 0; RS1Used_E <= 0; RS2Used_E <= 0; 
		Sel1_E <= 0; Sel2_E <= 0; ALUOP_E <= 0; WA_E <= 0;  RA0_E <= 0; RA1_E <= 0;
		DOUT0_E <= 0; DOUT1_E <= 0; PCADD4_E <= 0; JPC_E <= 0; zeroExt_E <= 0; Iext_E <= 0; shamtExt_E <= 0;
	end
	else if(DEFlush) begin
		WEN_E <= 1; DREQ_E <= 1; SelWB_E <= 0; Load_E <= 0; DRW_E <= 0; RS1Used_E <= 0; RS2Used_E <= 0; 
		Sel1_E <= 0; Sel2_E <= 0; ALUOP_E <= 0; WA_E <= 0;  RA0_E <= 0; RA1_E <= 0;
		DOUT0_E <= 0; DOUT1_E <= 0; PCADD4_E <= 0; JPC_E <= 0; zeroExt_E <= 0; Iext_E <= 0; shamtExt_E <= 0;
	end
	else begin
		WEN_E <= WEN_D; SelWB_E <= SelWB_D; Load_E <= Load_D; DRW_E <= DRW_D; DREQ_E <= DREQ_D;
		Sel1_E <= Sel1_D; Sel2_E <= Sel2_D; ALUOP_E <= ALUOP_D; shamtExt_E <= shamtExt_D;
		DOUT0_E <= DOUT0_D; DOUT1_E <= DOUT1_D; WA_E <= WA_D; RA0_E <= RA0_D; RA1_E <= RA1_D;
		JPC_E <= JPC_D; zeroExt_E <= zeroExt_D; Iext_E <= Iext_D; PCADD4_E <= PCADD4_D;
		RS1Used_E <= RS1Used_D; RS2Used_E <= RS2Used_D; 
	end
end
endmodule
