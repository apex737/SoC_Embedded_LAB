module top_fft;
reg clk, n_reset;
reg i_strb;
reg [31:0] i_data;
wire o_strb;
wire [31:0] o_data;
initial begin
$vcdplusfile(”top_fft.vpd”);
$vcdpluson(0, top_fft);
end
initial clk = 1’b0;
always #5 clk = ~clk;
import ”DPI” function void init_fft();
import ”DPI” function int unsigned get_input();
import ”DPI” function int unsigned get_output();
int i;
initial begin
n_reset = 1’b1;
i_strb = 1’b0;
i_data = ’bx;
init_fft();
#3;
n_reset = 1’b0;
#20;
n_reset = 1’b1;
@(posedge clk);
@(posedge clk);
repeat(2) begin
for(i=0;i<1024;i++) begin
#1;
i_strb = 1’b1;
i_data = get_input();
@(posedge clk);
#1;
i_strb = 1’b0;
i_data = ’bx;
repeat(5) @(posedge clk);
end
end
@(posedge clk);
@(posedge clk);
@(posedge clk);
$finish;
end
fft i_fft (
.clk(clk)
, .n_reset(n_reset)
, .i_strb(i_strb)
, .i_data(i_data)
, .o_strb(o_strb)
, .o_data(o_data)
);
int j;
reg [31:0] c_data;
initial begin
for(j=0;j<1024;j++) begin
@(posedge o_strb);
@(posedge clk);
c_data = get_output();
if(o_data !== c_data) begin
$display(”Error: o_data[%d] = %8X, c_data = %8X”
, j, o_data, c_data);
end
end
end
endmodule