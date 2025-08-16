`timescale 1ns / 1ps
module tb_matbi_watch_top;
localparam P_COUNT_BIT = 30; // (default) 30b, under 1GHz. 2^30 = 1073741824
localparam P_SEC_BIT	 = 6; // 2^6 = 64
localparam P_MIN_BIT	 = 6; // 2^6 = 64 
localparam P_HOUR_BIT = 5; // 2^5 = 32 
//DUT Port List
reg clk, reset;
reg i_run_en;
reg [P_COUNT_BIT-1:0]	i_freq;
wire [P_SEC_BIT-1:0]	o_sec;
wire [P_MIN_BIT-1:0]	o_min;
wire [P_HOUR_BIT-1:0]	o_hour;

// clk gen
always
    #5 clk = ~clk;

/////// Main ////////
initial begin
	$dumpfile("out.vvp");
	$dumpvars(0,tb_matbi_watch_top);
//initialize value
	i_freq		<= 10;
$display("initialize value [%d]", $time);
    reset 		<= 0;
    clk     	<= 0;
	i_run_en 	<= 0;
// reset gen
$display("Reset! [%d]", $time);
# 100
    reset 		<= 1;
# 10
    reset 		<= 0;
    i_run_en 	<= 1;
# 10
@(posedge clk);
$display("Start! [%d]", $time);
# 10000000
$display("Finish! [%d]", $time);
	i_run_en	<= 0;
$finish;
end

// Call DUT
clock_arch1 u_matbi_watch_top(
	.clk(clk), 
	.rst(reset), 
	.en(i_run_en),
	.sec_cnt(o_sec),
	.min_cnt(o_min),
	.hour_cnt(o_hour)
);

endmodule
