module BranchTaken(
	input [31:0] DOUT1_D,
	input [2:0] cond,
	output reg Taken_D
);
always@* begin
	Taken_D = 0;
	case(cond)
		1: Taken_D = 1;
		2: if(DOUT1_D==0) Taken_D = 1;
		3: if(DOUT1_D!=0) Taken_D = 1;
		4: if(~DOUT1_D[31]) Taken_D = 1;
		5: if(DOUT1_D[31]) Taken_D = 1;
	endcase
end
endmodule
