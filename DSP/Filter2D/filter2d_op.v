module filter2d_op #(parameter WIDTH = WIDTH)
(
	input clk,
	input n_reset,
	input start,
	output mem_rd,
	output reg [15:0] rd_addr,
	input [7:0] rd_data,
	output reg o_strb,
	output reg [7:0] o_data,
	input h_write,
	input [3:0] h_idx,
	input [7:0] h_data
);

reg on_proc;
reg [3:0] cnt;
reg [7:0] cnt_x;
reg [7:0] cnt_y;
always@(posedge clk or negedge n_reset) begin
	if(n_reset == 1'b0) begin
		on_proc <= 1'b0;
		cnt <= 0;
		cnt_x <= 0;
		cnt_y <= 0;
	end
	else begin
		if(start == 1'b1) on_proc <= 1'b1;
		else if((cnt == 11) && (cnt_x == WIDTH - 1) && (cnt_y == WIDTH - 1)) on_proc <= 1'b0;
		
		if(on_proc == 1'b1) begin
			cnt <= (cnt == 11) ? 0 : cnt+1;
			if(cnt == 11) begin
				cnt_x <= (cnt_x == WIDTH - 1) ? 0 : cnt_x+1;
				if(cnt_x == WIDTH - 1) begin
					cnt_y <= (cnt_y == WIDTH - 1) ? 0 : cnt_y+1;
				end
			end
		end
	end
end

assign mem_rd= (cnt >= 0) && (cnt <= 8) && (on_proc == 1'b1);
always@(*) begin
	case(cnt)
		4'd0: rd_addr = (cnt_y-1)*WIDTH + cnt_x-1;
		4'd1: rd_addr = (cnt_y-1)*WIDTH + cnt_x;
		4'd2: rd_addr = (cnt_y-1)*WIDTH + cnt_x+1;
		4'd3: rd_addr = (cnt_y )*WIDTH + cnt_x-1;
		4'd4: rd_addr = (cnt_y )*WIDTH + cnt_x;
		4'd5: rd_addr = (cnt_y )*WIDTH + cnt_x+1;
		4'd6: rd_addr = (cnt_y+1)*WIDTH + cnt_x-1;
		4'd7: rd_addr = (cnt_y+1)*WIDTH + cnt_x;
		4'd8: rd_addr = (cnt_y+1)*WIDTH + cnt_x+1;
		default: rd_addr = 'bx;
	endcase
end

reg [7:0] pd;
wire pd_en = (cnt >= 1) && (cnt <= 9);

always@(posedge clk or negedge n_reset) begin
	if(n_reset == 1'b0) begin
		pd<= 0;
	end
	else
		if(pd_en == 1'b1) pd<= rd_data;
end
reg signed[7:0] h[0:8];
always@(posedge clk or negedge n_reset) begin
	if(n_reset == 1'b0) begin
		h[0] <= 8'h08;
		h[1] <= 8'h10;
		h[2] <= 8'h08;
		h[3] <= 8'h10;
		h[4] <= 8'h20;
		h[5] <= 8'h10;
		h[6] <= 8'h08;
		h[7] <= 8'h10;
		h[8] <= 8'h08;
	end
	else begin
		if(h_write == 1'b1) begin
			h[h_idx] <= h_data;
		end
	end
end

wire signed[7:0] coeff = h[cnt-2];
wire signed[15:0] mul = pd* coeff;
reg signed[19:0] acc;
wire signed[19:0] acc_in = (cnt == 1) ? 0 : mul + acc;
reg acc_en;
always@(*) begin
	acc_en = 1'b0;
	case(cnt)
		4'd1: acc_en = 1'b1;
		4'd2: if((cnt_y > 0) && (cnt_x > 0)) acc_en = 1'b1;
		4'd3: if((cnt_y > 0) ) acc_en = 1'b1;
		4'd4: if((cnt_y > 0) && (cnt_x < WIDTH - 1)) acc_en = 1'b1;
		4'd5: if(cnt_x > 0) acc_en = 1'b1;
		4'd6: acc_en = 1'b1;
		4'd7: if(cnt_x < WIDTH - 1) acc_en = 1'b1;
		4'd8: if((cnt_y < WIDTH - 1) && (cnt_x > 0)) acc_en = 1'b1;
		4'd9: if((cnt_y < WIDTH - 1) ) acc_en = 1'b1;
		4'd10: if((cnt_y < WIDTH - 1) && (cnt_x < WIDTH - 1)) acc_en = 1'b1;
		default: acc_en = 1'b0;
	endcase
end

always@(posedge clk or negedge n_reset) begin
	if(~n_reset) acc <= 0;
	else if(acc_en) acc <= acc_in;
end
wire [19:0] pd_rnd_1 = acc + (1<<6);
wire [12:0] pd_rnd= pd_rnd_1[19:7];
wire [7:0] pd_out = (pd_rnd< 0) ? 0 : (pd_rnd> WIDTH - 1) ? WIDTH - 1 : pd_rnd[7:0];

always@(posedge clk or negedge n_reset) begin
	if(~n_reset) begin
		o_strb <= 1'b0;
		o_data <= 'b0;
	end else begin
		o_strb <= (cnt == 11);
		if(cnt == 11)
			o_data <= pd_out;
	end
end
endmodule