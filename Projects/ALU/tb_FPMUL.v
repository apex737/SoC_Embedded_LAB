`timescale 1ns/1ps
module tb_FPMUL;

  reg  [15:0] opA_i, opB_i;
  wire [15:0] MUL_o;

  // DUT instance
  FPMUL uut (
    .opA_i(opA_i),
    .opB_i(opB_i),
    .MUL_o(MUL_o)
  );

initial begin
	// -------- Norm × Norm Cases --------
	// N1: OVF
	opA_i = 16'b0_11000_1110000000; 
	opB_i = 16'b0_10111_1100000000; 
	#5; 
	// N2: Norm
	opA_i = 16'b0_10001_0000000000;
	opB_i = 16'b0_10000_0000000000;
	#5; 
	// N3: Norm
	opA_i = 16'b0_10000_1000000000;
	opB_i = 16'b0_10001_0100000000;
	#5; 
	// N4: Denorm
	opA_i = 16'b0_10000_1000000000;
	opB_i = 16'b0_01100_0000000000;
	#5; 
	// N5: UDF
	opA_i = 16'b0_00111_1000000001;
	opB_i = 16'b0_00000_0000000001;
	#5; 
	
	// -------- Norm × Denorm Cases --------
	// D1: Norm
	opA_i = 16'b0_10001_0000000000;
	opB_i = 16'b0_00000_0010000000;
	#5; 
	// D2: Norm
	opA_i = 16'b0_10000_1000000000;
	opB_i = 16'b0_00000_0100000000;
	#5; 
	// D3: Denorm
	opA_i = 16'b0_10000_1000000000;
	opB_i = 16'b0_00000_0000010000;
	#5; 
	// D4: Denorm
	opA_i = 16'b0_10000_0100000000;
	opB_i = 16'b0_00000_0000001000;
	#5; 
	$finish;
end
endmodule

