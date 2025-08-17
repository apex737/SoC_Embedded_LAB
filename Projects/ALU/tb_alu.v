`timescale 1ns/1ps
module tb_alu();

//Parameter
localparam TWOS_COMP = 4'b0000;
localparam ADD = 4'b0001;
localparam SUB = 4'b0010;
localparam MUL = 4'b0011; // 16비트로 안될텐데??
localparam AND = 4'b0100;
localparam OR = 4'b0101;
localparam XOR = 4'b0110;
localparam LOGICAL_LSHIFT = 4'b0111;
localparam LOGICAL_RSHIFT = 4'b1000;
localparam ARITH_LSHIFT = 4'b1001;
localparam ARITH_RSHIFT = 4'b1010;
localparam ROTATE_LEFT = 4'b1011;
localparam ROTATE_RIGHT = 4'b1100;
localparam testMUL = 4'b1101;

reg [15:0] A, B;
reg [3:0] opcode;
wire [15:0] Result;
wire V, N;

alu uALU(A, B, opcode, Result, V, N);

initial begin
	A = 16'd0; B = 16'd0; opcode = 4'b1111; #(5);
	A = 16'hFFFF; B = 16'd0; opcode = TWOS_COMP; #(5);
	A = 16'd1; B = 16'd1; opcode = ADD; #(5);
	A = 16'h7FFF; B = 16'd30; opcode = ADD; #(5);
	A = 16'd120; B = 16'd100; opcode = SUB; #(5);
	A = 16'h8000; B = 16'd30; opcode = SUB; #(5);
	A = 16'd123; B = 16'd123; opcode = MUL; #(5);
	A = 16'd123; B = -(16'd123); opcode = MUL; #(5);
	A = 16'h7FED; B = 16'h1111; opcode = AND; #(5);
	A = 16'h7FED; B = 16'h1111; opcode = OR; #(5);
	A = 16'h7FED; B = 16'h1111; opcode = XOR; #(5);
	A = 16'h7FED;  B = 16'd0; opcode = LOGICAL_LSHIFT; #(5);
	A = 16'hAFED;  B = 16'd0; opcode = LOGICAL_RSHIFT; #(5);
	A = 16'h7FED;  B = 16'd0; opcode = ARITH_LSHIFT; #(5);
	A = 16'hAFED;  B = 16'd0; opcode = ARITH_RSHIFT; #(5);
	A = 16'h7FED;  B = 16'd0; opcode = ROTATE_LEFT; #(5);
	A = 16'h7FED;  B = 16'd0; opcode = ROTATE_RIGHT; #(5);


	#(30);
	$finish;
end


endmodule



