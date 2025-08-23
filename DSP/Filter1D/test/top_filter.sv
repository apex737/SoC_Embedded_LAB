module top_filter;
    reg  clk, n_reset;
    initial clk = 1'b0;
    always #5 clk = ~clk;

    // DUT I/O
    reg  signed [15:0] x_in;
    wire signed [15:0] y_out;

    // 파일 핸들 & 임시 변수
    integer fd_in, fd_out;
    integer tmp;         // 32비트 signed(입력 파싱 후 담아두기)
    integer i;

    // 플러시 사이클(필터 레이턴시보다 크게)
    localparam FLUSH_CYCLES = 32;

    initial begin
        // 입력 파일 열기(읽기), 출력 파일 열기(쓰기)
        fd_in  = $fopen("fixed_input_c.txt", "r");
        fd_out = $fopen("output_v.txt", "w");

        // 리셋 시퀀스
        x_in = 0;
        n_reset = 1'b1; #3;
        n_reset = 1'b0; #20;
        n_reset = 1'b1;
        @(posedge clk); @(posedge clk); @(posedge clk);

        // ====== 입력 읽어서 한 샘플씩 투입 & 그때그때 출력 기록 ======
        // 파일 끝까지 반복: "%d"로 십진수(부호 포함) 파싱
        // (HEX 파일이라면 "%h"로 바꾸면 됩니다)
        while ($fscanf(fd_in, "%d\n", tmp) > 0) begin
            x_in = tmp;                 // 16비트로 자동 축소(2의보수 유지)
            @(posedge clk);
            $fdisplay(fd_out, "%0d", $signed(y_out)); // 한 줄 기록(개행 자동)
        end

        // 파일 닫고 종료
        $fclose(fd_in);
        $fclose(fd_out);
        $finish;
    end

    // DUT 인스턴스 (출력 16비트라 가정)
    filter i_filter (
        .clk     (clk),
        .reset_n (n_reset),
        .d       (x_in),
        .q       (y_out)
    );
endmodule
