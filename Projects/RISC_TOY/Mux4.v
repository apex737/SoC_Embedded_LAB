module Mux4(
	input [31:0] I0, I1, I2, I3, 
	input [1:0] Sel,
	output reg [31:0] Out
);
always@* begin
	case(Sel)
		2'd0: Out = I0;
		2'd1: Out = I1;
		2'd2: Out = I2;
		2'd3: Out = I3;
	endcase
end
endmodule
