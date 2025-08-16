module Counter (
  input clk, reset_n, en,
  input [31:0] i_freq;
  output reg o_toggle
);

reg [31:0] cnt;
always @(posedge clk or negedge reset_n) begin
  if(!reset_n) begin cnt <= 0; o_toggle <= 0; end
  else if(!en) begin cnt <= 0; o_toggle <= 0; end // sw off -> timer reset
  else if(cnt >= i_freq-1) begin // defensive coding
      cnt <= 0;
      o_toggle <= ~o_toggle;
  end else begin
    cnt <= cnt + 1;
  end
end
  
endmodule