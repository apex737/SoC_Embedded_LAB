module Mux3(
	input [31:0] I0, I1, I2,
	input [1:0] Sel,
	output reg [31:0] Out
);
always@* begin
	Out = I0;
	case(Sel)
		1: Out = I1;
		2: Out = I2;
		default: Out = I0;
	endcase
end
endmodule
