module FD(
	input CLK, RSTN, FDWrite,
	input [31:0] INSTR_i, PCadd4_F,
	output reg [31:0] INSTR_o, PCadd4_D
);

always@(posedge CLK or negedge RSTN) begin
	if(~RSTN) begin INSTR_o <= 0; PCadd4_D <= 0; end
	else if (FDWrite) begin 
		INSTR_o <= INSTR_i; 
		PCadd4_D <= PCadd4_F;
	end
end
endmodule
