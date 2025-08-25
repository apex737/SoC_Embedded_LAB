module tb;
reg clk, reset_n;
reg start;
initial clk = 1'b0;
always #5 clk = ~clk;
reg [7:0] img_data[0:65535];
reg i_strb;
reg [7:0] i_data;
integer idx, cnt, fd;

initial begin
    cnt = 0;
    reset_n = 1'b1;
    $readmemh("../filter_2d_c/img_in.dat", img_data);
    fd = $fopen("img_out.dat", "w");
    i_strb = 1'b0; i_data = 'bx; #3;
    reset_n = 1'b0; #20; reset_n = 1'b1;
    @(posedge clk); @(posedge clk); @(posedge clk);
    repeat(3) begin
        for(idx=0;idx<65536;idx=idx+1) begin
            i_strb = 1'b1;
            i_data = img_data[idx];
            @(posedge clk);
            repeat(16) begin
                i_strb = 1'b0;
                i_data = 'bx;
                @(posedge clk);
            end
        end
    end
    @(posedge clk); @(posedge clk); @(posedge clk);
    $fclose(fd);
    $finish;
end

wire o_strb;
wire [7:0] o_data;

top i_filter (
    .clk(clk),
    .reset_n(reset_n),
    .i_strb(i_strb),
    .i_data(i_data),
    .o_strb(o_strb),
    .o_data(o_data),
    .h_write(1'b0),
    .h_idx(4'b0),
    .h_data(8'b0)
);

always@(posedge clk) begin
    if(o_strb) begin
        $fwrite(fd, "%3d ", o_data);
        cnt = cnt + 1;
        if(cnt[7:0] == 0) 
            $fwrite(fd, "\n");
    end
end
endmodule