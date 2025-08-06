module top_fft;
reg clk, n_reset;
reg start;
wire ready;

initial clk = 1'b0;
always #5 clk = ~clk;
import "DPI" function void init_fft();
import "DPI" function int unsigned get_input();
import "DPI" function int unsigned get_output();
int i;
reg [31:0] mem_data[0:1023];
reg [31:0] c_data;

initial begin
	n_reset = 1'b1;
	start = 1'b0;
	init_fft();
	for(i=0;i<1024;i++) begin
		mem_data[i] = get_input();
	end
	#3;
	n_reset = 1'b0;
	#20;
	n_reset = 1'b1;
	@(posedge clk);
	@(posedge clk);
	start = 1'b1;
	@(posedge clk);
	start = 1'b0;
	@(posedge ready);
	@(posedge clk);
	for(i=0;i<1024;i++) begin
		c_data = get_output();
		if(mem_data[i] !== c_data) begin
			$display("Error: mem_data[%d] = %8X, c_data = %8X"
			, i, mem_data[i], c_data);
		end
	end
	@(posedge clk);
	@(posedge clk);
	$finish;

end
wire cs, we;
wire [9:0] addr;
wire [31:0] w_data;
reg [31:0] r_data;

fft i_fft (
	.clk(clk)
	, .n_reset(n_reset)
	, .start(start)
	, .ready(ready)
	, .cs(cs)
	, .we(we)
	, .addr(addr)
	, .w_data(w_data)
	, .r_data(r_data)
);

always@(posedge clk) begin
	if(cs) begin
		if(we) mem_data[addr] <= w_data;
		else r_data <= mem_data[addr];
	end
end
endmodule