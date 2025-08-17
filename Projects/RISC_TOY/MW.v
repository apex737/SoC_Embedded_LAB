module MW(
	// input
	input CLK, RSTN,
	input [1:0] SelWB_M2,
	input WEN_M2, 
	input [31:0] ALUOUT_M2, LoadData_M, PCADD4_M2,
	input [4:0] WA_M2,
	// output
	output reg [1:0] SelWB_W,
	output reg WEN_W, 
	output reg [31:0] ALUOUT_W, LoadData_W, PCADD4_W,
	output reg [4:0] WA_W
);
always@(posedge CLK or negedge RSTN) begin
	if(~RSTN) begin
		WEN_W <= 1; SelWB_W <= 0; WA_W <= 0; 
		ALUOUT_W <= 0; LoadData_W <= 0; PCADD4_W <= 0;
	end
	else begin
		SelWB_W <= SelWB_M2; WEN_W <= WEN_M2; WA_W <= WA_M2; 
		PCADD4_W <= PCADD4_M2; ALUOUT_W <= ALUOUT_M2;
		LoadData_W <= LoadData_M; 
	end
end
endmodule
