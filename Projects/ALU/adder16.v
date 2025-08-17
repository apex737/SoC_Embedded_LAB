module fulladder(
	input a,b,c,
	output cout, s
);
assign {cout, s} = a + b + c;
endmodule

module adder4(
	input [3:0] a,b,
	input mode,
	output [3:0] s,
	output v
);

wire [4:1] cout;
wire [3:0] exMode;
assign exMode = {4{mode}};
wire [3:0] modeB;
assign modeB = b^exMode;
fulladder fa1 (a[0],modeB[0],mode,cout[1], s[0]);
fulladder fa2 (a[1],modeB[1],cout[1],cout[2], s[1]);
fulladder fa3 (a[2],modeB[2],cout[2],cout[3], s[2]);
fulladder fa4 (a[3],modeB[3],cout[3],cout[4], s[3]);

assign v = (a[3]&modeB[3]&(~s[3])) | ((~a[3])&(~modeB[3])&s[3]);
endmodule

`timescale 1ns/1ps
module tb_adder4;
reg [3:0] a,b;
reg mode;
wire [3:0] s;
wire v;
adder4 ad4(a,b,mode,s,v);
initial begin
	mode = 0; a = 4'b0100; b = 4'b0001; #5; 
	a = 4'b1000; b = 4'b1000; #5; 
	mode = 1; a = 4'b1000; b = 4'b1010; #5; 
	a = 4'b1000; b = 4'b0100; #5; 
	a = 4'b0000; b = 4'b0000; #5; 
	$stop;
end
endmodule
