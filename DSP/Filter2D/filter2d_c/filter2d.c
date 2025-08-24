#include <stdio.h>
#include <math.h>
void filter2d(unsigned char in_img[], unsigned char out_img[], int height, int width) 
/*
    1. Kernel의 중심을 (i,j)로 잡고 2D img(width x height)와 Convolution
    2. 2D를 1D 배열처럼 다루기 위해서 Unpacking
        - 즉, (i, j) 대신 (i*width + j)로 다룸
    3. 경계에 해당하는 값은 0으로 간주 (zero-padding)
        - 조건문을 통해 덧셈 연산에서 제외하는 방식으로 구현
    4. 커널 계수는 (8,7), 데이터는 (8,0)
        - PP(partial-product)는 (16,7)
        - Kernel 크기가 9이므로, clog2(9) = 4; 즉 MAC은 (20,7)
*/  
{
    int h[3][3] = {0x08, 0x10, 0x08, 0x10, 0x20, 0x10, 0x08, 0x10, 0x08}; // (8,7)
    for(int i=0;i<height;i++) {
        for(int j=0;j<width;j++) {
            int sum = 0;
            // 상단 경계
            if(i>0 && j>0)               sum += in_img[(i-1)*width+j-1]*h[0][0];
            if(i>0)                      sum += in_img[(i-1)*width+j ]*h[0][1];
            if(i>0 && j<width-1)         sum += in_img[(i-1)*width+j+1]*h[0][2];
            // 중단 경계
            if(j>0)                      sum += in_img[(i )*width+j-1]*h[1][0];
                                         sum += in_img[(i )*width+j ]*h[1][1];
            if(j<width-1)                sum += in_img[(i )*width+j+1]*h[1][2];
            // 하단 경계
            if(i<height-1 && j>0)        sum += in_img[(i+1)*width+j-1]*h[2][0];
            if(i<height-1)               sum += in_img[(i+1)*width+j ]*h[2][1];
            if(i<height-1 && j<width-1)  sum += in_img[(i+1)*width+j+1]*h[2][2];
            // Rounding
            sum = (sum + (1<<6)) >> 7;
            // Clamping
            if(sum < 0) out_img[i*width+j] = 0;
            else if(sum > 255) out_img[i*width+j] = 255;
            else out_img[i*width+j] = sum;
        }
    }
}

int main(void) {
    int i, a;
    FILE *inf, *outf, *memf;
    unsigned char in_img[256*256];
    unsigned char out_img[256*256];
    inf = fopen("img_in.txt", "r");
    outf = fopen("img_out.txt", "w");
    memf = fopen("img_in.dat", "w"); // for verilog tb
    for(i=0;i<256*256;i++) {
        fscanf(inf, "%d,", &a);
        in_img[i] = a;
        fprintf(memf, "%02X\n", in_img[i]);
    }
    filter2d(in_img, out_img, 256, 256);
    for(i=0;i<256*256;i++) {
        fprintf(outf, "%3d ", out_img[i]);
        if(i%256 == 255) fprintf(outf, "\n"); // 행 끝에서 개행
    }

    fclose(inf); fclose(outf); fclose(memf);
}