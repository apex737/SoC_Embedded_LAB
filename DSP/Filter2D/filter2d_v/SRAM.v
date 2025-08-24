module mem_single 
#(
   parameter WD = 8, 
   parameter DEPTH = 256*256*2, 
   parameter WA = $clog2(DEPTH)
)(
  input clk, 
  input cs, 
  input we, 
  input  [WA-1:0] addr, 
  input  [WD-1:0] din, 
  output [WD-1:0] dout
);

reg     [WD-1:0]        data[DEPTH-1:0]; // ibuf.data
reg     [WA-1:0]        addr_d;

always@(posedge clk) begin
        if(cs) begin
                if(we) data[addr] <= din;
                addr_d <= addr;
        end
end
assign dout = data[addr_d];

endmodule

