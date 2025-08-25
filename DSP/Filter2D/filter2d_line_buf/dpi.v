module top_filter_2d;
reg clk, n_reset;
reg start;
initial clk = 1'b0;
always #5 clk = ~clk;
import "DPI" function void init_filter2d(input int h, input int w);
import "DPI" function byte get_input();
import "DPI" function byte get_output();
reg i_strb;
reg [7:0] i_data;

initial begin
  n_reset = 1'b1;
  init_filter2d(256, 256);
  i_strb = 1'b0;
  i_data = 'bx;
  #3;
  n_reset = 1'b0;
  #20;
  n_reset = 1'b1;
  @(posedge clk);
  @(posedge clk);
  @(posedge clk);
  repeat(3) begin
  repeat(256*256) begin
    i_strb = 1'b1;
    i_data = get_input();
    @(posedge clk);
    repeat(16) begin
      i_strb = 1'b0;
      i_data = 'bx;
      @(posedge clk);
    end
  end
  end
  @(posedge clk);
  @(posedge clk);
  @(posedge clk);
  $finish;
end

wire o_strb;
wire [7:0] o_data;

filter2d i_filter (
  .clk(clk),
  .n_reset(n_reset),
  .i_strb(i_strb),
  .i_data(i_data),
  .o_strb(o_strb),
  .o_data(o_data),
  .h_write(1'b0),
  .h_idx(4'b0),
  .h_data(8'b0)
);
reg [7:0] out_ref;

always@(posedge clk) begin
  if(o_strb) begin
    out_ref = get_output();
    if(o_data != out_ref) begin
      $display("Error!! o_data = %3d, out_ref = %3d", o_data, out_ref);
      #10;
      $finish;
    end
  end
end
endmodule