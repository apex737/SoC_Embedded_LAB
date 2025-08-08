module skid
#(parameter DWIDTH = 8)
(
	input clk, rst,
	// slave 
	input s_valid,
	output s_ready,
	input [DWIDTH-1:0] s_data,
 
	// master
	output m_valid,
	input m_ready,
	output [DWIDTH-1:0] m_data
);

localparam PIPE = 1'b0;
localparam SKID = 1'b1;
reg state;

reg s_valid_r, s_valid_d;
reg s_ready_r;
reg [DWIDTH-1:0] s_data_r, s_data_d; 
wire ready = ~m_valid | m_ready;

always@(posedge clk) begin
	if(rst) begin
		s_valid_r <= 0;
		s_valid_d <= 0;
		s_ready_r <= 0;
		s_data_r <= 0;
		s_data_d <= 0;
		state <= PIPE;		
	end else begin
 		case(state)
			PIPE: begin
				if(ready) begin
					state <= PIPE;
					s_data_r <= s_data;
					s_valid_r <= s_valid;
					s_ready_r <= 1'b1;
				end else begin
					state <= SKID;
					s_data_d <= s_data;
					s_valid_d <= s_valid;
					s_ready_r <= 1'b0;
				end
			end
			SKID: begin
				if(ready) begin
					state <= PIPE;
					s_data_r <= s_data_d;
					s_valid_r <= s_valid_d;
					s_ready_r <= ready;
				end
			end
		endcase
	end
end

assign m_data = s_data_r;
assign m_valid = s_valid_r;
assign s_ready = s_ready_r;


endmodule