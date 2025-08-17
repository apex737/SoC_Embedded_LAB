`timescale 1ns/1ps
module tb_adder16();

	reg [15:0] A, B;
	reg mode; //mode 0: ADD / mode 1: SUB

	wire V;
	wire [15:0] Sum;

	adder16 uADD16(A, B, mode, Sum, V);


	initial begin
		A = 16'd0; B = 16'd0; mode = 1'b0;
		#(10) A = 16'd2; B = 16'd3; mode = 1'b0;
		#(10) A = 16'd2; B = 16'd3; mode = 1'b1;
		#(10) A = 16'd10; B = 16'd15; mode = 1'b0;
		#(10) A = 16'd5; B = 16'd2; mode = 1'b1;
		#(10) A = 16'h7FFF; B = 16'd30; mode = 1'b0;
		#(10) A = 16'h0081; B = 16'h0004; mode = 1'b1;
		#(5) A = 16'd0; B = 16'd0; mode = 1'b0;
		#(30)
		$finish();
	end
endmodule
