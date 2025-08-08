module pow8(
	input clk, rstn,
	// Slave-Side
	input s_valid,
	output s_ready,
	input [31:0] s_data,

	// Master-Side
	output m_valid,
	input m_ready,
	output [63:0] m_data 		
);

wire m_ready_o, m_valid_i;
wire [63:0] m_data_i;
reg [2:0] r_valid;
reg [63:0] r_data [0:2];
assign s_ready = ~m_valid_i | m_ready_o;

// valid register
always@(posedge clk or negedge rstn) begin
	if(~rstn) r_valid <= 0;
	else if(s_ready)  r_valid <= {r_valid[1:0], s_valid}; 
end

// data register
integer i;
always@(posedge clk or negedge rstn) begin
	if(~rstn) for(i=0;i<3;i=i+1) r_data[i] <= 0;
	else if(s_ready) begin
		r_data[2] <= r_data[1]*r_data[1];
		r_data[1] <= r_data[0]*r_data[0];
		r_data[0] <= s_data*s_data;
	end
end

assign m_valid_i = r_valid[2];
assign m_data_i = r_data[2];
skid #(64) u_skid 
(
	.clk(clk),
	.rst(rstn),
	// Slave I/F (LHS)
	.s_valid(m_valid_i),
	.s_ready(m_ready_o), // slave output
	.s_data(m_data_i),
	// Master I/F (RHS) 
	.m_valid(m_valid),
	.m_ready(m_ready),  // master output
	.m_data(m_data)
);	
endmodule