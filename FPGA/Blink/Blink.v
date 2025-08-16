module Blink (
  input clk, 
  input reset_n,
  input [1:0] sw,
  output [3:0] led
);

`ifdef XSIM
wire [31:0] w_i_cnt_th_25M 	= 32'd25;
wire [31:0] w_i_cnt_th_50M 	= 32'd50;
wire [31:0] w_i_cnt_th_100M = 32'd100;
wire [31:0] w_i_cnt_th_200M = 32'd200;
`else // Implementation
wire [31:0] w_i_cnt_th_25M 	= 32'd25000000;
wire [31:0] w_i_cnt_th_50M 	= 32'd50000000;
wire [31:0] w_i_cnt_th_100M = 32'd100000000;
wire [31:0] w_i_cnt_th_200M = 32'd200000000;
`endif


Counter u_counter_25M (
  .clk(clk), 
  .reset_n(reset_n), 
  .en(sw[0]),
  .i_freq(w_i_cnt_th_25M),
  .o_toggle(led[0])
);

Counter u_counter_50M (
  .clk(clk), 
  .reset_n(reset_n), 
  .en(sw[1]),
  .i_freq(w_i_cnt_th_50M),
  .o_toggle(led[1])
);

Counter u_counter_100M (
  .clk(clk), 
  .reset_n(reset_n), 
  .en(sw[0]),
  .i_freq(w_i_cnt_th_100M),
  .o_toggle(led[2])
);

Counter u_counter_200M (
  .clk(clk), 
  .reset_n(reset_n), 
  .en(sw[1]),
  .i_freq(w_i_cnt_th_200M),
  .o_toggle(led[3])
);


  
endmodule