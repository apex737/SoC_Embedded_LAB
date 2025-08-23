module filter (
    input clk, reset_n,
    input [15:0] d,
    output reg [15:0] q
);

reg signed [15:0] x [0:20]; // x[21] (16,13)

integer i;
always @(posedge clk or negedge reset_n) begin
    if(~reset_n) for(i=0;i<21;i=i+1) x[i] <= 0;
    else begin
        x[0] <= d;
        for(i=1;i<21;i=i+1) x[i] <= x[i-1];
    end
end

reg signed [15:0] h [0:20]; // h[21] (16,15)
always @(posedge clk or negedge reset_n) begin
    if(~reset_n) begin
        h[0] <= -16'd10; h[1] <= 16'd62; h[2] <= 16'd84; h[3] <= -16'd296; h[4] <= -16'd246;
        h[5] <= 16'd954; h[6] <= 16'd477; h[7] <= -16'd2645; h[8] <= -16'd689; h[9] <= 16'd10122;
        h[10] <= 16'd17159; h[11] <= 16'd10122; h[12] <= -16'd689; h[13] <= -16'd2645; h[14] <= 16'd477;
        h[15] <= 16'd954; h[16] <= -16'd246; h[17] <= -16'd296; h[18] <= 16'd84; h[19] <= 16'd62;
        h[20] <= -16'd10;
    end else begin end
end

reg signed [31:0] mul [0:20];  // x*h (31,28)
always @(posedge clk or negedge reset_n) begin
    if(~reset_n) for(i=0;i<21;i++) mul[i] <= 0;
    else for(i=0;i<21;i++) mul[i] <= x[i]*h[i];
end

reg signed [31:0] sum; // MAC (32,28)
always@* begin
    sum = 0;
    for(i=0;i<21;i++)
        sum = sum + mul[i];
end
// adder tree begin

// adder tree end

wire signed [31:0] q_rnd = sum + (1<<15);
always@(posedge clk or negedge reset_n) begin
    if(~reset_n) q <= 0;
    else q <= q_rnd[31:16]; // q (16,12)
end
    
endmodule