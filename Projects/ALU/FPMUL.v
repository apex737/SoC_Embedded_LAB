module FPMUL(
	input [15:0] opA_i, opB_i, 
	output reg [15:0] MUL_o
);

// Decode
wire aSign = opA_i[15];
wire bSign = opB_i[15];
wire Sign = aSign ^ bSign;
wire [4:0] aE = opA_i[14:10];
wire [4:0] bE = opB_i[14:10]; 
wire [9:0] aF = opA_i[9:0];
wire [9:0] bF = opB_i[9:0];

// Instanciation : Leading-One-Detection 
wire [3:0] idxA, idxB; // 11 ~ 2 , 0 (invalid)
// Denorm : shift_amt 
wire [3:0] shA = 4'd12-idxA; // 1 ~ 10
wire [3:0] shB = 4'd12-idxB; // 1 ~ 10
LOD10 lodA (.frac(aF), .idx_o(idxA));
LOD10 lodB (.frac(bF), .idx_o(idxB));

// Denorm => Norm  
wire [10:0] F1 = (aE == 0) ? (aF << shA) : {1'b1, aF};
wire [10:0] F2 = (bE == 0) ? (bF << shB) : {1'b1, bF};
wire [21:0] FMUL = F1*F2; 
wire [21:0] FMULSel = FMUL[21] ? FMUL >> 1 : FMUL;
wire signed [5:0] aExp = (aE==0) ? -(shA + 4'd14) : aE-4'd15;
wire signed [5:0] bExp = (bE==0) ? -(shB + 4'd14) : bE-4'd15;
wire signed [6:0] Exp = FMUL[21] ? (aExp + bExp + 1) : (aExp + bExp);

reg [4:0] DNshamt;
reg [21:0] shifted;
always@* begin
	if(Exp > 7'sd15) MUL_o = {Sign, {15{1'b1}}};
	else if(Exp < -7'sd24) MUL_o = 0;
	else if(Exp <= 7'sd15 && Exp >= -7'sd14)// encode: Norm
		MUL_o = {Sign, Exp+7'sd15, FMULSel[19:10]};
	else begin // encode: Denorm (-24 <= exp < -14)
		DNshamt = -(Exp+7'sd14);
		shifted = FMULSel >> DNshamt;
		MUL_o = {Sign, 5'b0, shifted[19:10]};
	end
end
endmodule
