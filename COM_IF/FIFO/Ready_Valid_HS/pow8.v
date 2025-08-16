module pow8(
	input clk, reset_n,
	// Slave-Side
	input s_valid,
	output s_ready,
	input [31:0] s_data,

	// Master-Side
	output m_valid,
	input m_ready,
	output [63:0] m_data 		
);

wire m_ready_i, m_valid_o;
wire [63:0] m_data_o;
reg [2:0] r_valid;
reg [63:0] r_data [0:2];
assign s_ready = ~m_valid_o | m_ready_i;

// valid register
always@(posedge clk or negedge reset_n) begin
	if(~reset_n) r_valid <= 0;
	else if(s_ready)  r_valid <= {r_valid[1:0], s_valid}; 
end

// data register
integer i;
always@(posedge clk or negedge reset_n) begin
	if(~reset_n) for(i=0;i<3;i=i+1) r_data[i] <= 0;
	else if(s_ready) begin
		r_data[2] <= r_data[1]*r_data[1];
		r_data[1] <= r_data[0]*r_data[0];
		r_data[0] <= s_data*s_data;
	end
end

assign m_valid_o = r_valid[2];
assign m_data_o = r_data[2];
skid #(64) u_skid 
(
	.clk(clk),
	.rst(~reset_n), // rst connect
	// Slave Side 
	.s_valid(m_valid_o),
	.s_ready(m_ready_i), // skid_out -> pow8_in
	.s_data(m_data_o),
	// Master Side  
	.m_valid(m_valid),
	.m_ready(m_ready),  // skid_in -> pow8_out
	.m_data(m_data)
);	
endmodule
