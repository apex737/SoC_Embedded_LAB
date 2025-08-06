module fft (
input clk
, input n_reset
, input i_strb
, input [31:0] i_data
, output o_strb
, output [31:0] o_data
);
wire o_strb0;
wire [31:0] o_data0;
wire o_strb1;
wire [31:0] o_data1;
wire o_strb2;
wire [31:0] o_data2;
wire o_strb3;
wire [31:0] o_data3;
wire o_strb4;
wire [31:0] o_data4;
wire o_strb5;
wire [31:0] o_data5;
wire o_strb6;
wire [31:0] o_data6;
wire o_strb7;
wire [31:0] o_data7;
wire o_strb8;
wire [31:0] o_data8;
wire o_strb9;
wire [31:0] o_data9;
fft_pipe_stg0 i_stg0 (
.clk(clk)
, .n_reset(n_reset)
, .i_strb(i_strb)
, .i_data(i_data)
, .o_strb(o_strb0)
, .o_data(o_data0)
);
fft_pipe_stg1 i_stg1 (
.clk(clk)
, .n_reset(n_reset)
, .i_strb(o_strb0)
, .i_data(o_data0)
, .o_strb(o_strb1)
, .o_data(o_data1)
);
fft_pipe_stg2 i_stg2 (
.clk(clk)
, .n_reset(n_reset)
, .i_strb(o_strb1)
, .i_data(o_data1)
, .o_strb(o_strb2)
, .o_data(o_data2)
);
fft_pipe_stg3 i_stg3 (
.clk(clk)
, .n_reset(n_reset)
, .i_strb(o_strb2)
, .i_data(o_data2)
, .o_strb(o_strb3)
, .o_data(o_data3)
);
fft_pipe_stg4 i_stg4 (
.clk(clk)
, .n_reset(n_reset)
, .i_strb(o_strb3)
, .i_data(o_data3)
, .o_strb(o_strb4)
, .o_data(o_data4)
);
fft_pipe_stg5 i_stg5 (
.clk(clk)
, .n_reset(n_reset)
, .i_strb(o_strb4)
, .i_data(o_data4)
, .o_strb(o_strb5)
, .o_data(o_data5)
);
fft_pipe_stg6 i_stg6 (
.clk(clk)
, .n_reset(n_reset)
, .i_strb(o_strb5)
, .i_data(o_data5)
, .o_strb(o_strb6)
, .o_data(o_data6)
);
fft_pipe_stg7 i_stg7 (
.clk(clk)
, .n_reset(n_reset)
, .i_strb(o_strb6)
, .i_data(o_data6)
, .o_strb(o_strb7)
, .o_data(o_data7)
);
fft_pipe_stg8 i_stg8 (
.clk(clk)
, .n_reset(n_reset)
, .i_strb(o_strb7)
, .i_data(o_data7)
, .o_strb(o_strb8)
, .o_data(o_data8)
);
fft_pipe_stg9 i_stg9 (
.clk(clk)
, .n_reset(n_reset)
, .i_strb(o_strb8)
, .i_data(o_data8)
, .o_strb(o_strb9)
, .o_data(o_data9)
);
assign o_strb = o_strb9;
assign o_data = o_data9;
endmodule
