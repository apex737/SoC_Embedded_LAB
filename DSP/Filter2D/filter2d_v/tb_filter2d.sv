module top_filter_2d;
reg clk, reset_n;
reg start;
wire finish;
wire cs, we;
wire [16:0] addr;
wire [7:0] din;
wire [7:0] dout;

integer i,j,fd;
initial clk = 1'b0;
always #5 clk = ~clk;

initial begin
    reset_n = 1'b1;
    $readmemh("img_in.dat", i_buf.data); // 1번째 Memory에 매핑
    #3; reset_n = 1'b0;
    #20; reset_n = 1'b1;
    @(posedge clk); @(posedge clk); @(posedge clk);
    start = 1'b1; @(posedge clk); start = 1'b0;    
end

filter2d i_filter (
    .clk(clk), .reset_n(reset_n), .start(start), .finish(finish),
    .cs(cs), .we(we), .addr(addr), .din(din), .dout(dout),
    .h_write(1'b0), .h_idx(4'b0), .h_data(8'b0)
);

mem_single #(
    .WD(8),
    .DEPTH(256*256*2) // 256*256 Memory 2개 
) i_buf (
    .clk(clk),
    .cs(cs),
    .we(we),
    .addr(addr),
    .din(din),
    .dout(dout)
);

always@(posedge clk) begin
    if(finish) begin
        fd = $fopen("img_out.dat", "w");
        for(i=0;i<256;i++) begin
            for(j=0;j<256;j++)
                $fwrite(fd, "%3d ", i_buf.data[i*256+j+256*256]); // 2번째 Memory에 매핑
            $fdisplay(fd, "");  // 자동 개행용
        end
        $fclose(fd);
        $finish;
    end
end
endmodule