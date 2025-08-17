module MemBuffer(
	// input
	input CLK, RSTN,
	input [1:0] SelWB_M1,
	input WEN_M1,
	input [31:0] ALUOUT_M1, PCADD4_M1,
	input [4:0] WA_M1,
	// output
	output reg [1:0] SelWB_M2,
	output reg WEN_M2, 
	output reg [31:0] ALUOUT_M2, PCADD4_M2,
	output reg [4:0] WA_M2
);

always@(posedge CLK or negedge RSTN) begin
	if(~RSTN) begin
		SelWB_M2 <= 0;  WEN_M2 <= 0;  ALUOUT_M2 <= 0; 
		PCADD4_M2 <= 0;  WA_M2 <= 0;
	end
	else begin
		SelWB_M2 <= SelWB_M1;  WEN_M2 <= WEN_M1; ALUOUT_M2 <= ALUOUT_M1; 
		PCADD4_M2 <= PCADD4_M1;  WA_M2 <= WA_M1;
	end
end
endmodule
