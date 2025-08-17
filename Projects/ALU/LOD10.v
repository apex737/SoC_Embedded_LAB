module LOD10(
	input [9:0] frac,
	output [3:0] idx_o
);
wire [3:0] p2 = frac[9:6];
wire [3:0] p1 = frac[5:2];
wire [3:0] p0 = {frac[1:0],2'b00};
wire [2:0] g = {|p2, |p1, |p0};
wire valid = |g;
reg [1:0] row;
always@* begin
	casex(g)
		3'b1xx: row = 2;
		3'b01x: row = 1;
		3'b001: row = 0;
		default: row = 0; // Invalid 
	endcase
end

reg [1:0] col;
wire [3:0] pos = (row == 2) ? p2 : (row == 1) ? p1 : p0;
always@* begin
	casex(pos)
		4'b1xxx: col = 3;
		4'b01xx: col = 2;
		4'b001x: col = 1;
		4'b0001: col = 0;
		default: col = 0;
	endcase
end

assign idx_o = valid ? (4*row + col) : 0;
endmodule
