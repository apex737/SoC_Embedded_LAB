module EM(
	// input
	input CLK, RSTN,
	input WEN_E, DRW_E, DREQ_E, Load_E,
	input [1:0] SelWB_E,
	input [4:0] WA_E, 
	input [31:0] PCADD4_E, ALUOUT_E, DOUT0_E, 
	// output
	output reg WEN_M1, DRW_M1, DREQ_M1, Load_M1,
	output reg [1:0] SelWB_M1,
	output reg [4:0] WA_M1,
	output reg [31:0] PCADD4_M1, ALUOUT_M1, DOUT0_M1
);
always@(posedge CLK or negedge RSTN) begin
	if(~RSTN) begin
		WEN_M1 <= 1; DREQ_M1 <= 1; DRW_M1 <= 0;  Load_M1 <= 0; SelWB_M1 <= 0;
		PCADD4_M1 <= 0; WA_M1 <= 0; ALUOUT_M1 <= 0; DOUT0_M1 <= 0;
	end
	else begin
		WEN_M1 <= WEN_E; DRW_M1 <= DRW_E; DREQ_M1 <= DREQ_E;   Load_M1 <= Load_E;
		PCADD4_M1 <= PCADD4_E; WA_M1 <= WA_E; ALUOUT_M1 <= ALUOUT_E; 
		DOUT0_M1 <= DOUT0_E; SelWB_M1 <= SelWB_E;
	end
end
endmodule
