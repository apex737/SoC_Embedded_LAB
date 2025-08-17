`timescale 1ns/1ps

module tb_FPADD;

reg  [15:0] opA_i, opB_i;
wire [15:0] ADD_o;

FPADD dut (
    .opA_i(opA_i),
    .opB_i(opB_i),
    .ADD_o(ADD_o)
);

initial begin
    // 1. Norm + Norm (1.5 + 1.0 = 2.5)
    opA_i = 16'b0_01111_1000000000; // 1.5
    opB_i = 16'b0_01111_0000000000; // 1.0 
		#10;
    // 2. Norm - Norm (2.5 - 1.5 = 1.0)
    opA_i = 16'b0_10000_0100000000; // 2.5
    opB_i = 16'b1_01111_1000000000; // -1.5
		#10;
    // 3. Denorm + Denorm (2^-15 + 2^-15)
    opA_i = 16'b0_00000_0000000001; // ~2^-15
    opB_i = 16'b0_00000_0000000001;
		#10;
    // 4. Denorm - Denorm (cancel out)
    opA_i = 16'b0_00000_0000000010;
    opB_i = 16'b1_00000_0000000010;
		#10;
    // 5. Denorm + Norm (2^-15 + 1.0)
    opA_i = 16'b0_00000_0000000001;
    opB_i = 16'b0_01111_0000000000;
		#10;
    // 6. Norm - Denorm (1.0 - 2^-15)
    opA_i = 16'b0_01111_0000000000;
    opB_i = 16'b1_00000_0000000001;
		#10;
    // 7. Overflow (max norm + max norm)
    opA_i = 16'b0_11110_1111111111; // Max norm: ~65504
    opB_i = 16'b0_11110_1111111111;
		#10;
    // 8. Underflow (min norm - denorm)
    opA_i = 16'b0_00001_0000000000; // Min norm: 2^-14
    opB_i = 16'b1_00000_0000000001; // -2^-15
		#10;
    $finish;
end

endmodule


