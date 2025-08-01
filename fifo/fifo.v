module fifo
#(
	parameter WIDTH = 8,
	parameter DEPTH = 32,
	parameter CNT = $clog2(DEPTH)
)
(
	input clk, rstn,
	input push, pop, // read, write strob
	output full, a_full,
	output empty, a_empty,
	input [WIDTH-1:0] din,
	output reg  [WIDTH-1:0] dout
);

reg [WIDTH-1:0]  mem [0:DEPTH-1];
reg [CNT:0]  pTail;
assign full = (pTail == DEPTH);
assign a_full = (pTail >= DEPTH-1);
assign empty = (pTail == 0);
assign a_empty = (pTail <= 1);
integer i;
always@(posedge clk or negedge rstn) begin
	if(~rstn) begin 
		for(i = 0; i < DEPTH; i=i+1) begin
			mem[i] = 0; 		// rst all
		end
		pTail <= 0;
	end else begin 
		if (push && ~full)  begin 	// push tail
			mem[pTail] <= din;
			pTail <= pTail+1;
			
		end else if (pop && ~empty) begin
			for(i = 1; i < DEPTH; i=i+1) begin
				mem[i-1] <= mem[i];
			end
			dout <= mem[0]; // pop head
			pTail <= pTail-1;		
		end
	end
end

endmodule
