module gen_sec
#(
  parameter FREQ = 100,
  parameter LOG2FREQ = $clog2(FREQ)
)(
  input clk, reset, en,
  output reg o_sec_tick
);
// clog2(60) = 6
reg [LOG2FREQ-1:0] cnt;
always @(posedge clk) begin
  if(reset) begin cnt <= 0; o_sec_tick <= 0; end
  else if (en) begin
    if(cnt == FREQ-1) begin
      cnt <= 0;
      o_sec_tick <= 1;
    end else begin
      cnt <= cnt + 1;
      o_sec_tick <= 0;
    end
  end 
  else
      o_sec_tick <= 0;
end
  
endmodule