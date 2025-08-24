#include <stdio.h>
#include <math.h>
void filter2d(unsigned char in_img[], unsigned char out_img[], int height, int width) 
{
    int h[3][3] = {0x08, 0x10, 0x08, 0x10, 0x20, 0x10, 0x08, 0x10, 0x08};
    for(int i=0;i<height;i++) {
        for(int j=0;j<width;j++) {
            int sum = 0;
            if(i>0 && j>0)               sum += in_img[(i-1)*width+j-1]*h[0][0];
            if(i>0)                      sum += in_img[(i-1)*width+j ]*h[0][1];
            if(i>0 && j<width-1)         sum += in_img[(i-1)*width+j+1]*h[0][2];
            if(j>0)                      sum += in_img[(i )*width+j-1]*h[1][0];
                                         sum += in_img[(i )*width+j ]*h[1][1];
            if(j<width-1)                sum += in_img[(i )*width+j+1]*h[1][2];
            if(i<height-1 && j>0)        sum += in_img[(i+1)*width+j-1]*h[2][0];
            if(i<height-1)               sum += in_img[(i+1)*width+j ]*h[2][1];
            if(i<height-1 && j<width-1)  sum += in_img[(i+1)*width+j+1]*h[2][2];

            sum = (sum + (1<<6)) >> 7;
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
    memf = fopen("img_in.dat", "w");
    for(i=0;i<256*256;i++) {
        fscanf(inf, "%d,", &a);
        in_img[i] = a;
        fprintf(memf, "%02X\n", in_img[i]);
    }
    filter2d(in_img, out_img, 256, 256);
    for(i=0;i<256*256;i++) {
        fprintf(outf, "%3d ", out_img[i]);
        if(i%256 == 255) fprintf(outf, "\n");
    }

    fclose(inf); fclose(outf); fclose(memf);
}