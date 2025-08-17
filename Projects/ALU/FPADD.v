module FPADD(
	input [15:0] opA_i, opB_i, 
	output reg [15:0] ADD_o
);

// Decode
wire aSign = opA_i[15];
wire bSign = opB_i[15];
wire [4:0] aE = opA_i[14:10];
wire [4:0] bE = opB_i[14:10];
wire [9:0] aF = opA_i[9:0];
wire [9:0] bF = opB_i[9:0];
reg Sign, isSub;
wire isEqual = (aE == bE) & (aF == bF);
// Sign
always@* begin
	if(aSign == bSign) begin 
		Sign = aSign; 
		isSub = 1'b0; 
	end
	else begin 
		isSub = 1'b1;	 
		if(aE == bE) Sign = (aF > bF) ? aSign : bSign; 
		else Sign = (aE > bE) ? aSign : bSign; 
	end
end

// Big/Small Exp, Frac 
reg signed [5:0] rs_bigExp, rs_smallExp;
reg [11:0] r_bigF, r_smallF; // 01.ffffffffff (12bit)
always@* begin
	if(aE == 0 && bE == 0) begin  // DN+DN
		rs_bigExp = -6'sd14; rs_smallExp = rs_bigExp;
		{r_bigF, r_smallF} = aF >= bF 
			? {{2'b00, aF}, {2'b00, bF}}
			: {{2'b00, bF}, {2'b00, aF}};
	end 
	else if (aE != 0 && bE == 0) begin // N+DN
		rs_bigExp = $signed({1'b0, aE}) - 6'sd15; 
		rs_smallExp = -6'sd14; 
		r_bigF = {2'b01, aF}; r_smallF = {2'b00, bF};
	end
	else if (aE == 0 && bE != 0) begin // DN+N
		rs_bigExp = $signed({1'b0, bE}) - 6'sd15; 
		rs_smallExp = -6'sd14; 
		r_bigF = {2'b01, bF}; r_smallF = {2'b00, aF};
	end
	else begin // N+N
		{rs_bigExp, rs_smallExp} = (aE > bE) 
			? { $signed({1'b0, aE}) - 6'sd15 , $signed({1'b0, bE}) - 6'sd15 }
			: { $signed({1'b0, bE}) - 6'sd15 , $signed({1'b0, aE}) - 6'sd15 };
		if(aE == bE) begin  
			{r_bigF, r_smallF} = (aF > bF) 
				? {{2'b01, aF}, {2'b01, bF}}
				: {{2'b01, bF}, {2'b01, aF}};
		end
		else begin
			{r_bigF, r_smallF} = (aE > bE) 
				? {{2'b01, aF}, {2'b01, bF}}
				: {{2'b01, bF}, {2'b01, aF}};
		end
	end
end
// Instanciation : Leading-One-Detection 
wire [5:0] shamt = rs_bigExp - rs_smallExp;
wire [11:0] F_add = r_bigF + (r_smallF >> shamt);
wire [11:0] F_sub = r_bigF - (r_smallF >> shamt);
wire [3:0] idxAdd, idxSub; // 11 ~ 2 , 0 (invalid)
wire [3:0] sh_Add = 4'd12-idxAdd; // 1 ~ 10
wire [3:0] sh_Sub = 4'd12-idxSub; // 1 ~ 10
LOD10 lodA (.frac(F_add[9:0]), .idx_o(idxAdd));
LOD10 lodB (.frac(F_sub[9:0]), .idx_o(idxSub));

reg signed [6:0] rs_Exp;
reg [11:0] r_F;
always@* begin
	if(~isSub) begin 
		if(F_add[11]) begin // M >= 2
			r_F = F_add >> 1; // RShift
			rs_Exp = rs_bigExp + 1;
		end
		else if(F_add[11:10] == 2'b00) begin // M < 1
			rs_Exp = rs_bigExp - $signed({1'b0, sh_Add}); // Leading One Detection
			r_F = F_add << sh_Add;
		end
		else begin 
			rs_Exp = rs_bigExp;
			r_F = F_add;
		end
	end
	else begin 
		if(F_sub[11]) begin // M >= 2
			r_F = F_sub >> 1; // RShift
			rs_Exp = rs_bigExp + 1;
		end
		else if(F_sub[11:10] == 2'b00) begin // M < 1
			rs_Exp = rs_bigExp - $signed({1'b0, sh_Sub}); // Leading One Detection
			r_F = F_sub << sh_Sub; // LShift
		end
		else begin 
			rs_Exp = rs_bigExp;
			r_F = F_sub;
		end
	end
end

// Output Encoding
reg [4:0] DNshamt;
reg [11:0] shifted;
wire [4:0] E_Norm = rs_Exp + 7'sd15;
always@* begin
	DNshamt = 0; shifted = 0; 
	if(isEqual & isSub) ADD_o = 0; // A - A 
	else begin
		if(rs_Exp > 7'sd15) ADD_o = {16{1'b1}}; // ovf
		else if(rs_Exp < -7'sd24) ADD_o = 0; // udf 
		else if(rs_Exp <= 7'sd15 && rs_Exp >= -7'sd14) ADD_o = {Sign, E_Norm, r_F[9:0]};
		else begin // encode: Denorm (-24 <= rs_Exp < -14)
			DNshamt = -(rs_Exp+7'sd14);
			shifted = r_F >> DNshamt;
			ADD_o = {Sign, 5'b0, shifted[9:0]};
		end
	end
end
endmodule