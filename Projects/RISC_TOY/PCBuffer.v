module PCBuffer(
	input CLK, RSTN, IMREAD,
	input [31:0] PCADD4_F1,
	output reg [31:0] PCADD4_F2
);
always@(posedge CLK or negedge RSTN) begin
	if(~RSTN) PCADD4_F2 <= 0;
	else if(IMREAD) PCADD4_F2 <= PCADD4_F1;
end
endmodule
