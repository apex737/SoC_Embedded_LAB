module sync_fifo_skid
#(
  // skid buffer on/off
  parameter REG_IN = 1,
  parameter REG_OUT = 1,
  // param for reuse
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
// ptr for descript fifo state
reg [LOG2DEPTH-1:0] wptr, wptr_nxt, wptr_round, wptr_round_nxt;
reg [LOG2DEPTH-1:0] rptr, rptr_nxt, rptr_round, rptr_round_nxt;

// I/O Ports for Instanciate Skid Buffer
wire w_s_valid, w_s_ready, w_m_valid, w_m_ready;
wire [SIZE-1:0] w_m_data, w_s_data;

// Define Strobes
wire full = wptr_round != rptr_round && wptr == rptr;
wire empty = wptr_round == rptr_round && wptr == rptr;
assign w_s_ready = ~full;
assign w_m_valid = ~empty;

// Handshake
wire i_hs = w_s_valid && w_s_ready;
wire o_hs = w_m_valid && w_m_ready;

// Write_When (always_ff)
integer i;
always@(posedge clk or negedge rstn) begin
  if(~rstn) begin
    for(i=0;i<DEPTH;i=i+1) fifo[i] <= 0;
    wptr <= 0;
    wptr_round <= 0;
  end else if (i_hs) begin
    fifo[wptr] <= s_data;
    wptr <= wptr_nxt;
    wptr_round <= wptr_round_nxt;
  end
end
// Write_What (always_comb)
always@* begin
  if(wptr == DEPTH-1) begin 
      wptr_round_nxt = ~wptr_round;
      wptr_nxt = 0;
  end else begin
    wptr_nxt = wptr + 1;
    wptr_round_nxt = wptr_round;
  end
end

// Read_When (always_ff)
always@(posedge clk or negedge rstn) begin
  if(~rstn) begin
    rptr <= 0;
    rptr_round <= 0;
  end else if (o_hs) begin
    rptr <= rptr_nxt;
    rptr_round <= rptr_round_nxt;
  end
end
// Read_What (always_comb)
always@* begin
  if(rptr == DEPTH-1) begin 
      rptr_round_nxt = ~rptr_round;
      rptr_nxt = 0;
  end else begin
    rptr_nxt = rptr + 1;
    rptr_round_nxt = rptr_round;
  end
end
assign w_m_data = fifo[rptr];
// Instanciate Skid Buffer
generate
  if(REG_IN) begin
    skid #(
      .DWIDTH(SIZE)
    ) u_skid_in (
      .clk(clk),
      .rst(~rstn),
      // skid input port : Delegation Connection
      .s_valid(s_valid),
      .s_ready(s_ready),
      .s_data(s_data),
      // skid output port : Functional Connection
      .m_valid(w_s_valid),
      .m_ready(w_s_ready),
      .m_data(w_s_data)
    );
  end else begin
    assign w_s_valid = s_valid;
    assign s_ready = w_s_ready;
    assign w_s_data = s_data;
  end
endgenerate

generate
  if(REG_OUT) begin
    skid #(
      .DWIDTH(SIZE)
    ) u_skid_out (
      .clk(clk),
      .rst(~rstn),
      // skid input port : Functional Connection
      .s_valid(w_m_valid),
      .s_ready(w_m_ready),
      .s_data(w_m_data),
      // skid output port : Delegation Connection
      .m_valid(m_valid),
      .m_ready(m_ready),
      .m_data(m_data)
    );
  end else begin
    assign m_valid = w_m_valid;
    assign w_m_ready = m_ready;
    assign m_data = w_m_data;
  end
endgenerate
endmodule
