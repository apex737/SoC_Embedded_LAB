module PC(
	input PCWrite, CLK, RSTN,
	input [31:0] NextPC,
	output reg [29:0] IADDR
);
always@(posedge CLK or negedge RSTN) begin
	if(~RSTN) IADDR <= 0;
	else if (PCWrite) IADDR <= NextPC[29:0]; // NextPC >> 2 (word)
end
endmodule
