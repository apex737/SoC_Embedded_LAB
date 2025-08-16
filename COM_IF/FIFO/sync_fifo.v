module sync_fifo
#(
	parameter SIZE = 32,
	parameter DEPTH = 4,
	parameter LOG2DEPTH = $clog2(DEPTH)
)
(
	input clk, rstn,
	// slave side
	input s_valid,
	output s_ready,
	input [SIZE-1:0] s_data,
	// master side
	output m_valid,
	input m_ready,
	output [SIZE-1:0] m_data
);

reg [SIZE-1:0] fifo [0:DEPTH-1];
// Next 포인터는 조합논리, Current 포인터는 순차논리로 분리
reg [LOG2DEPTH-1:0] wptr, wptr_nxt, rptr, rptr_nxt;
reg [LOG2DEPTH-1:0] wptr_round, wptr_round_nxt, rptr_round, rptr_round_nxt;

integer i;
// Write Side
// Write: Sequential Logic
wire w_hs = s_valid & s_ready;
always@(posedge clk or negedge rstn) begin
	if(~rstn) begin
		for(i=0;i<DEPTH;i=i+1) fifo[i] <= 0;
		wptr <= 0;
		wptr_round <= 0;
	end else if(w_hs) begin
		fifo[wptr] <= s_data;
		{wptr, wptr_round} <= {wptr_nxt, wptr_round_nxt};
	end
end

// Write: Next State (Combinational) Logic
// to avoid Latch & Combinational Loop
always@* begin
	if(wptr == DEPTH-1) begin 
		wptr_round_nxt = ~wptr_round;
		wptr_nxt = 0;
	end else begin 
		wptr_round_nxt = wptr_round;
		wptr_nxt = wptr + 1;
	end
end

// Read Side
// Read: Sequential Logic
wire r_hs = m_valid & m_ready;
always@(posedge clk or negedge rstn) begin
	if(~rstn) begin
		rptr <= 0;
		rptr_round <= 0;
	end else if(r_hs) begin
		{rptr, rptr_round} <= {rptr_nxt, rptr_round_nxt};
	end
end

// Read: Next State (Combinational) Logic
// to avoid Latch & Combinational Loop
always@* begin
	if(rptr == DEPTH-1) begin 
		rptr_round_nxt = ~rptr_round;
		rptr_nxt = 0;
	end else begin 
		rptr_round_nxt = rptr_round;
		rptr_nxt = rptr + 1;
	end
end

assign m_data = fifo[rptr];
assign full =  (wptr_round != rptr_round) && (wptr == rptr);
assign empty = (wptr_round == rptr_round) && (wptr == rptr);
assign s_ready = ~full;
assign m_valid = ~empty;

endmodule

