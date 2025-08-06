module fft_pipe_stg0 (
	input clk
	, input n_reset
	, input i_strb
	, input [31:0] i_data
	, output o_strb
	, output [31:0] o_data
);
reg [31:0] i_data_d;
reg [9:0] cnt_k; // counting input data
reg [2:0] cnt_o; // counting butterfly operation
reg first_garbage;
wire last_o = (cnt_o == 4);

always@(posedge clk or negedge n_reset) begin
	if(~n_reset) begin
		cnt_k <= 0;
		cnt_o <= 7;
		i_data_d <= 0;
		first_garbage <= 1'b1;
	end 
	else begin
		if(i_strb) cnt_o <= 0;
		if(cnt_o < 5) cnt_o <= cnt_o+1;
		if(last_o) begin
			cnt_k <= (cnt_k == 1023) ? 0 : cnt_k+1;
			if(cnt_k == 511) first_garbage <= 1'b0;
		end
		if(i_strb) i_data_d <= i_data;
	end
end

wire cs;
wire we;
reg [8:0] addr;
wire [31:0] r_data;
wire [31:0] w_data;

// 0: read, 4: write
assign cs = (cnt_o == 0) || (cnt_o == 4);
assign we = (cnt_o == 4);

always@(posedge clk or negedge n_reset) begin
	if(~n_reset) addr <= 0;
	else if(last_o) addr <= addr + 1;	
end

reg signed [16:0] in0_r, in0_i; // real & imaginary
wire signed [16:0] in1_r, in1_i;

always@(posedge clk or negedge n_reset) begin
	if(~n_reset) begin
		in0_r <= 0;
		in0_i <= 0;
	end 
	else begin
		if(cnt_o == 1) begin
			in0_r <= {r_data[15], r_data[15:0]};
			in0_i <= {r_data[31], r_data[31:16]};
		end
	end
end

assign in1_r = {i_data_d[15], i_data_d[15:0]};
assign in1_i = {i_data_d[31], i_data_d[31:16]};

reg signed [15:0] bf0_r, bf0_i;
reg signed [15:0] bf1_r, bf1_i;
always@(posedge clk or negedge n_reset) begin
	if(~n_reset) begin
		bf0_r <= 0;
		bf0_i <= 0;
		bf1_r <= 0;
		bf1_i <= 0;
	end 
	else begin
		if(cnt_o == 2) begin
			bf0_r <= (in0_r + in1_r) >> 1;
			bf0_i <= (in0_i + in1_i) >> 1;
			bf1_r <= (in0_r - in1_r) >> 1;
			bf1_i <= (in0_i - in1_i) >> 1;
		end
	end
end

reg [19:0] twid_lut;
wire signed [9:0] cos = (cnt_k[8:0] < 256) ? twid_lut[9:0] : twid_lut[19:10];
wire signed [9:0] sin = (cnt_k[8:0] < 256) ? twid_lut[19:10]: -twid_lut[9:0];
reg signed [9:0] twid_r, twid_i;

always@(posedge clk or negedge n_reset) begin
	if(~n_reset) begin
		twid_r <= 1'b0;
		twid_i <= 1'b0;
	end else begin
		if(cnt_o == 2) begin
			twid_r <= cos;
			twid_i <= sin;
		end
	end
end

// gen_twiddle.c
always@(*) begin
	case(cnt_k[7:0])
	0: twid_lut = {-10'd0,10'd511};
	1: twid_lut = {-10'd3,10'd511};
	2: twid_lut = {-10'd6,10'd511};
	3: twid_lut = {-10'd9,10'd511};
	...
	252: twid_lut = {-10'd511,10'd13};
	253: twid_lut = {-10'd511,10'd9};
	254: twid_lut = {-10'd511,10'd6};
	255: twid_lut = {-10'd511,10'd3};
	endcase
end

wire signed [24:0] mul_rr = bf1_r * twid_r;
wire signed [24:0] mul_ri = bf1_r * twid_i;
wire signed [24:0] mul_ir = bf1_i * twid_r;
wire signed [24:0] mul_ii = bf1_i * twid_i;
reg signed [15:0] bfmul_r;
reg signed [15:0] bfmul_i;

always@(posedge clk or negedge n_reset) begin
	if(~n_reset) begin
		bfmul_r <= 1'b0;
		bfmul_i <= 1'b0;
	end 
	else begin
		if(cnt_o == 3) begin
			bfmul_r <= (mul_rr - mul_ii) >> 9;
			bfmul_i <= (mul_ri + mul_ir) >> 9;
		end
	end
end

assign w_data = (cnt_k < 512) ? i_data_d : {bfmul_i, bfmul_r};
assign o_strb = (cnt_o == 4) && (first_garbage == 1'b0);
assign o_data = (cnt_k < 512) ? {in0_i[15:0], in0_r[15:0]} : {bf0_i, bf0_r};

mem_single #(
	.WD(32)
	, .DEPTH(512)
) i_mem (
	.clk(clk)
	, .cs(cs)
	, .we(we)
	, .addr(addr)
	, .din(w_data)
	, .dout(r_data)
);
endmodule