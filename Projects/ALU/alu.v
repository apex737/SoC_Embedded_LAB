module fulladder(
input X, Y, Cin,
output Cout, Sum
);
assign {Cout, Sum} = X + Y + Cin;
endmodule

module adder16(
	input [15:0] X, Y,
	input mode,
	output [15:0] Sum,
	output V
);

wire [16:0] c;
wire [15:0] modeY;
assign c[0] = mode;
assign modeY = Y ^ {16{mode}};

genvar i;
generate 
	for(i = 0; i < 16; i=i+1) begin
		fulladder fa (X[i], modeY[i], c[i], c[i+1], Sum[i]);
	end
endgenerate
assign V = c[15]^c[16];
endmodule


module alu(
	input signed [15:0] A,B,
	input [3:0] opcode,
	output reg signed [15:0] Result,
	output V, 
	output N 
);

localparam TWOS_COMP = 4'b0000;
localparam ADD = 4'b0001;
localparam SUB = 4'b0010;
localparam MUL = 4'b0011; 
localparam AND = 4'b0100;
localparam OR = 4'b0101;
localparam XOR = 4'b0110;
localparam LOGICAL_LSHIFT = 4'b0111;
localparam LOGICAL_RSHIFT = 4'b1000;
localparam ARITH_LSHIFT = 4'b1001;
localparam ARITH_RSHIFT = 4'b1010;
localparam ROTATE_LEFT = 4'b1011;
localparam ROTATE_RIGHT = 4'b1100;

wire signed [31:0] exA = A;
wire signed [31:0] exB = B;

reg mode;  
wire [15:0] addsub_result;
wire ovf;
adder16 a16(A, B , mode, addsub_result, ovf);
always@* begin
	mode = 0;
	case(opcode)
		TWOS_COMP: Result = ~A + 1;
		ADD: Result = addsub_result;
		SUB: begin
			mode = 1;
			Result = addsub_result;
		end
		MUL: Result = exA*exB;
		AND: Result = A&B;
		OR: Result = A|B;
		XOR: Result = A^B;
		LOGICAL_LSHIFT: Result = A << 1;
		LOGICAL_RSHIFT: Result = A >> 1;
		ARITH_LSHIFT: Result = A <<< 1;
		ARITH_RSHIFT: Result = A >>> 1; 
		ROTATE_LEFT: Result = {A[14:0], A[15]};
		ROTATE_RIGHT: Result = {A[0], A[15:1]};
		default: Result = 16'b0;
	endcase
end

assign N = (Result[15] == 1);
assign V = (opcode == ADD) || (opcode == SUB) ? ovf : 0;
endmodule
