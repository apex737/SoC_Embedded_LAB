module filter2d ( 
    input clk, n_reset,

    input i_strb,
    input [7:0] i_data,

    output reg o_strb,
    output reg [7:0] o_data,

    input h_write,
    input [3:0] h_idx,
    input [7:0] h_data
);

reg garbage;
/*  cnt (FSM)
    0: (1) 3×3 입력 버퍼를 왼쪽으로 시프트
       (2) 최신 입력을 버퍼의 (2,2)에 갱신
       (3) 메모리 읽기 #1 주소 설정 (rptr0 = wptr)

    1: (1) 메모리 읽기 #1 결과를 (0,2)에 갱신
       (2) 메모리 읽기 #2 주소 설정 (rptr1 = wptr ± 256)

    2: (1) 메모리 읽기 #2 결과를 (1,2)에 갱신
       (2) 현재 픽셀을 메모리에 기록 → mem_wr & wr_addr++ 
    
    3: mul
    4: sum
    5: rounding & clamping 
    6: o_data 출력
*/
reg [3:0] cnt;
reg [7:0] cnt_x, cnt_y;  /*  지금 생성할 출력 픽셀의 중심 좌표(e)
                            주소 포인터가 아닌, 경계 마스킹 용도로만 사용함
                            Ex. (cnt_x, cnt_y) = (0, 0)
                            (1,1), (1,2), (2,1), (2,2)의 부분곱만 합산
                        */
reg [7:0] i_data_d;

always@(posedge clk or negedge n_reset) begin
    /* 	새로운 img의 첫째 픽셀이 읽히는 경우
    이전 img의 마지막 프레임의 연산이 끝난 상태가 자연스럽다
    마지막 프레임의 center 값은 (254,254) 이므로 
    (cnt_x, cnt_y)의 IDLE 값은 (254,254) */
    if(n_reset == 1'b0) begin
        garbage <= 1'b1;
        cnt <= 7;
        cnt_x <= 254;
        cnt_y <= 254;
        i_data_d <= 'b0;
    end else begin
        if(i_strb == 1'b1) begin
            cnt_x <= (cnt_x == 255) ? 0 : cnt_x+1;
            if(cnt_x == 255) begin
                cnt_y <= (cnt_y == 255) ? 0 : cnt_y+1;
                if(cnt_y == 255) garbage <= 1'b0; 
                /*  왜 첫번째 프레임은 garbage 처리할까?
                                                            
                
                */ 
            end
        end
        if(i_strb == 1'b1) cnt <= 0;
        else if(cnt < 7) cnt <= cnt+1;
        if(i_strb == 1'b1) i_data_d <= i_data;
    end
end
reg [7:0] ibuf[2:0][2:0];
wire [7:0] dout;
always@(posedge clk or negedge n_reset) begin
    if(n_reset == 1'b0) begin
        for(int i=0;i<3;i++) begin
            for(int j=0;j<3;j++) begin
                ibuf[i][j] <= 'b0;
            end
        end
    end else begin
        if(cnt == 0) begin
            for(int i=0;i<3;i++) begin
                for(int j=0;j<2;j++) begin
                    ibuf[i][j] <= ibuf[i][j+1];
                end
            end
            ibuf[2][2] <= i_data_d;
        end
        if(cnt == 1) ibuf[0][2] <= dout;
        if(cnt == 2) ibuf[1][2] <= dout;
    end
end

wire mem_rd = (cnt == 0) || (cnt == 1);
wire mem_wr = (cnt == 2);
reg [8:0] wptr; // Line Buffer wptr 
// wire [8:0] rptr0 = (wptr < 2*WIDTH) ? (wptr-2*WIDTH+BUF_LEN) : wptr-2*WIDTH;
// wptr은 항상 2*WIDTH보다 작고, BUF_LEN은 2*WIDTH로 고정
wire [8:0] rptr0 = wptr; // rptr0 자리를 wptr로 읽은 값으로 override
// wire [8:0] rptr0 = (wptr < WIDTH) ? (wptr-*WIDTH+BUF_LEN) : wptr-WIDTH;
wire [8:0] rptr1 = (wptr<256) ? wptr+256 : wptr-256;
wire [8:0] rptr = (cnt == 0) ? rptr0 : rptr1;

// wptr은 0 ~ 2*WIDTH-1를 순환하며 단순 증가
always@(posedge clk or negedge n_reset) begin
    if(n_reset == 1'b0) wptr <= 0;
    else if(mem_wr == 1'b1) begin
        wptr <= (wptr == 2*256-1) ? 0 : wptr + 1;
    end
end

// line buffer에서 읽어야하면 rptr0, rptr1 자리에서 dout을 가져오고 
// line buffer에 써야하면 wptr(이전 rptr0) 자리에 din을 전달함
wire cs = mem_rd | mem_wr;
wire we = mem_wr;
wire [8:0] addr = (mem_wr == 1'b1) ? wptr : rptr;
wire [7:0] din = i_data_d;

mem_single #(
    .WD(8),
    .DEPTH(2*256)
) i_buf0 (
    .clk(clk),
    .cs(cs),
    .we(we),
    .addr(addr),
    .din(din),
    .dout(dout)
);

reg signed [7:0] h[0:8];
always@(posedge clk or negedge n_reset) begin
    if(n_reset == 1'b0) begin
        h[0] <= 8'h08;
        h[1] <= 8'h10;
        h[2] <= 8'h08;
        h[3] <= 8'h10;
        h[4] <= 8'h20;
        h[5] <= 8'h10;
        h[6] <= 8'h08;
        h[7] <= 8'h10;
        h[8] <= 8'h08;
    end else if(h_write == 1'b1) h[h_idx] <= h_data;
end

reg signed [15:0] mul[2:0][2:0];
always@(posedge clk or negedge n_reset) begin
    if(n_reset == 1'b0) begin
        for(int i=0;i<3;i++) begin
            for(int j=0;j<3;j++) begin
                mul[i][j] <= 'b0;
            end
        end
    end else begin
        if((cnt == 3) && (garbage == 1'b0)) begin
            // 상단
            mul[0][0] <= ((cnt_y > 0) && (cnt_x > 0)) ? ibuf[0][0] * h[0] : 'b0;
            mul[0][1] <= ((cnt_y > 0)) ? ibuf[0][1] * h[1] : 'b0;
            mul[0][2] <= ((cnt_y > 0) && (cnt_x < 255)) ? ibuf[0][2] * h[2] : 'b0;
            // 중단
            mul[1][0] <= (cnt_x > 0) ? ibuf[1][0] * h[3] : 'b0;
            mul[1][1] <= ibuf[1][1] * h[4]; // (cnt_x, cnt_y) 위치
            mul[1][2] <= (cnt_x < 255) ? ibuf[1][2] * h[5] : 'b0;
            // 하단
            mul[2][0] <= ((cnt_y < 255) && (cnt_x > 0)) ? ibuf[2][0] * h[6] : 'b0;
            mul[2][1] <= ((cnt_y < 255)) ? ibuf[2][1] * h[7] : 'b0;
            mul[2][2] <= ((cnt_y < 255) && (cnt_x < 255)) ? ibuf[2][2] * h[8] : 'b0;
        end
    end
end
reg signed [19:0] sum_in;
reg signed [19:0] sum;
always@(*) begin
    sum_in = 0;
    for(int i=0;i<3;i++) begin
        for(int j=0;j<3;j++) begin
            sum_in = sum_in + mul[i][j];
        end
    end
end

always@(posedge clk or negedge n_reset) begin
    if(n_reset == 1'b0) begin
        sum <= 'b0;
    end else begin
        if((cnt == 4) && (garbage == 1'b0)) begin
            sum <= sum_in;
        end
    end
end

wire signed [19:0] pd_rnd_1 = sum + (1<<6);
wire signed [12:0] pd_rnd = pd_rnd_1[19:7];
wire [7:0] pd_out = (pd_rnd < 0) ? 0 : (pd_rnd > 255) ? 255 : pd_rnd[7:0];

always@(posedge clk or negedge n_reset) begin
    if(n_reset == 1'b0) begin
        o_strb <= 1'b0;
        o_data <= 'b0;
    end else begin
        o_strb <= ((cnt == 5) && (garbage == 1'b0));
        if((cnt == 5) && (garbage == 1'b0)) begin
            o_data <= pd_out;
        end
    end
end
endmodule