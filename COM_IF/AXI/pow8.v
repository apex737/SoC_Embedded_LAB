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

assign s_ready = ~m_valid | m_ready;

reg [2:0] r_valid;
reg [63:0] r_data [0:2];

// valid register
always@(posedge clk or negedge rstn) begin
	if(~rstn) r_valid <= 0;
	else if(s_ready)  r_valid <= {r_valid[1:0], s_valid}; 
end
assign m_valid = r_valid[2];

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
assign m_data = r_data[2];

endmodule
