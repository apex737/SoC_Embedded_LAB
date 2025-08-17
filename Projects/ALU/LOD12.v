module LOD12(
	input [11:0] frac,
	output [3:0] idx_o
);
// group or
wire [3:0] p2 = frac[11:8];
wire [3:0] p1 = frac[7:4];
wire [3:0] p0 = frac[3:0];
wire [2:0] reduced = {|p2, |p1, |p0};
wire v = |reduced;
reg [1:0] row, col;
always@* begin
	casex(reduced)
		3'b1xx: row = 2;
		3'b01x: row = 1;
		3'b001: row = 0;
		default: row = 0;
	endcase
end
// prioity encoder
wire [3:0] selRow = (row == 2) ? p2 : (row == 1) ? p1 : p0; // Leading-1 block
always@* begin
	casex(selRow)
		4'b1xxx: col = 3;
		4'b01xx: col = 2;
		4'b001x: col = 1;
		4'b0001: col = 0;
		default: col = 0;
	endcase
end
assign idx_o = v ? (4*row + col) : 0;

// Note. 벡터가 크면 2차원(row*col)을 넘어서 N차원까지 확장 
endmodule
