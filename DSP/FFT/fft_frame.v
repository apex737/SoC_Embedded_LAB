module fft (
	input clk, 
	input n_reset,
	input start,
	output ready, 
	output cs, 
	output we, 
	output [9:0] addr, 
	output [31:0] w_data, 
	input [31:0] r_data
);

reg on_proc;
reg [9:0] cnt_p; // counting stage, one hot, 512 to 1
				 // in C, 1024 to 2
wire [9:0] cnt_pi; // reverse of cnt_p
reg [9:0] cnt_j; // counting block
reg [9:0] cnt_k; // counting butterfly
reg [9:0] cnt_t; // k*pi
reg [2:0] cnt_o; // FSM State
				 // 0-1 : Read(In0-1), 3: add/sub, 4: mul
				 // 5-6	: Write
wire last_o = (cnt_o == 6);
wire last_k = (cnt_k == cnt_p-1);
wire last_j = (cnt_j == cnt_pi-1);
wire last_p = (cnt_p == 10'h001);
assign ready = ~on_proc;

always@(posedge clk or negedge n_reset) begin
	if(n_reset == 1'b0) begin
		on_proc <= 1'b0;
		cnt_p <= 10'h200;
		cnt_j <= 1'b0;
		cnt_k <= 1'b0;
		cnt_t <= 1'b0;
		cnt_o <= 1'b0;
	end 
	else begin
		if((on_proc == 1'b0) && (start == 1'b1)) begin
			on_proc <= 1'b1;
			cnt_p <= 10'h200; // 512 ~ 1
			cnt_j <= 1'b0;
			cnt_k <= 1'b0;
			cnt_t <= 1'b0;
			cnt_o <= 1'b0;
		end
		/*
		for(i=0,p=1024;i<10;i++,p/=2) {
			for(j=0;j<1024/p;j++) {
				for(k=0;k<p/2;k++) {
					t_complex bf0, bf1;
					complex_add(&bf0, out[j*p+k], out[j*p+k+p/2]);
					complex_sub(&bf1, out[j*p+k], out[j*p+k+p/2]);
					twiddle_mul(&bf1, k, p);
					out[j*p+k] = bf0;
					out[j*p+k+p/2] = bf1;
				}
			}
		}
		*/
		if(on_proc == 1'b1) begin
			cnt_o <= (last_o == 1'b1) ? 1'b0 : cnt_o+1;
			if(last_o == 1'b1) begin
				cnt_k <= (last_k == 1'b1) ? 1'b0 : cnt_k+1;
				cnt_t <= (last_k == 1'b1) ? 1'b0 : cnt_t+cnt_pi;
				if(last_k == 1'b1) begin
					cnt_j <= (last_j == 1'b1) ? 1'b0 : cnt_j+1;
					if(last_j == 1'b1) begin
						cnt_p <= cnt_p >> 1; // p /= 2
						if(last_p == 1'b1) begin
							on_proc <= 1'b0;
						end
					end
				end
			end
		end
	end
end

genvar i;
for(i=0;i<10;i++) begin
	assign cnt_pi[i] = cnt_p[9-i];
end

// 1,2 : Read
// 5,6 : Write
assign cs = (cnt_o == 0) || (cnt_o == 1) || (cnt_o == 5) || (cnt_o == 6);
assign we = (cnt_o == 5) || (cnt_o == 6);

reg [9:0] addr0;
always@(posedge clk or negedge n_reset) begin
	if(n_reset == 1'b0) begin
		addr0 <= 1'b0;
	end 
	else begin
		if(on_proc == 1'b1) begin
			if(last_o == 1'b1) begin
				if((last_j == 1'b1) && (last_k == 1'b1)) addr0 <= 1'b0;
				// cnt_p만큼 jump ( cnt_p-1 => cnt_p*2 )
				else if(last_k == 1'b1) addr0 <= addr0 + cnt_p+1;  
				else addr0 <= addr0 + 1;
			end
		end
	end
end


wire [9:0] addr1 = addr0 + cnt_p;
assign addr = (cnt_o == 0) || (cnt_o == 5) ? addr0 : addr1;
reg signed [16:0] in0_r, in0_i;
reg signed [16:0] in1_r, in1_i;

always@(posedge clk or negedge n_reset) begin
	if(n_reset == 1'b0) begin
		in0_r <= 1'b0;
		in0_i <= 1'b0;
		in1_r <= 1'b0;
		in1_i <= 1'b0;
	end else begin
		if(cnt_o == 1) begin
			in0_r <= {r_data[15], r_data[15:0]};
			in0_i <= {r_data[31], r_data[31:16]};
		end
		if(cnt_o == 2) begin
			in1_r <= {r_data[15], r_data[15:0]};
			in1_i <= {r_data[31], r_data[31:16]};
		end
	end
end

reg signed [15:0] bf0_r, bf0_i;
reg signed [15:0] bf1_r, bf1_i;
always@(posedge clk or negedge n_reset) begin
	if(n_reset == 1'b0) begin
		bf0_r <= 1'b0;
		bf0_i <= 1'b0;
		bf1_r <= 1'b0;
		bf1_i <= 1'b0;
	end else begin
		if(cnt_o == 3) begin
			bf0_r <= (in0_r + in1_r) >> 1;
			bf0_i <= (in0_i + in1_i) >> 1;
			bf1_r <= (in0_r - in1_r) >> 1;
			bf1_i <= (in0_i - in1_i) >> 1;
		end
	end
end

reg [19:0] twid_lut;
wire signed [9:0] cos = (cnt_t < 256) ? twid_lut[9:0] : twid_lut[19:10];
wire signed [9:0] sin = (cnt_t < 256) ? twid_lut[19:10] : -twid_lut[9:0];
reg signed [9:0] twid_r, twid_i;

always@(posedge clk or negedge n_reset) begin
	if(n_reset == 1'b0) begin
		twid_r <= 1'b0;
		twid_i <= 1'b0;
	end else begin
		if(cnt_o == 3) begin
			twid_r <= cos;
			twid_i <= sin;
		end
	end
end

// 최대 길이로 lut 생성 후
// stage가 진행되면서 1/2, 1/4... 선택해서 사용 
always@(*) begin
	case(cnt_t[7:0])
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
	if(n_reset == 1'b0) begin
		bfmul_r <= 1'b0;
		bfmul_i <= 1'b0;
	end else begin
		if(cnt_o == 4) begin
			bfmul_r <= (mul_rr - mul_ii) >> 9;
			bfmul_i <= (mul_ri + mul_ir) >> 9;
		end
	end
end

assign w_data = (cnt_o == 5) ? {bf0_i, bf0_r} : {bfmul_i, bfmul_r};
endmodule