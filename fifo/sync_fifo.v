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
	output [SIZE-1:0] m_data,
	// strobe
	// input push, pop, 
	output full, empty
);

reg [SIZE-1:0] fifo [0:DEPTH-1];
reg [LOG2DEPTH-1] wptr, rptr;
reg wptr_round, rptr_round;

assign full =  (wptr_round != rptr_round) && (wptr == rptr);
assign empty = (wptr_round == rptr_round) && (wptr == rptr);

integer i;

// Write Side
wire w_hs = s_valid & s_ready;
always@(posedge clk or negedge rstn) begin
	if(~rstn) begin
		for(i=0;i<DEPTH;i=i+1) fifo[i] <= 0;
		wptr <= 0;
	end else if(w_hs && ~full) begin
		fifo[wptr] <= s_data;
		wptr = wptr + 1;
	end
end

// update round flag : 한바퀴 돌면 반전
// 1. 한바퀴 돈거를 어떻게 표현하나?
// 2. 현재상태를 유지해야하니 결국 래치를 만드나
// 3. next로 굳이 조합논리와 순차논리를 구분하여 관리하는 이유가 래치를 피하려고 그런가?
always@* begin
	if(wptr == DEPTH-1) wptr_round = ~wptr_round;
	else wptr_round = wptr_round;
end

// Read Side

endmodule
