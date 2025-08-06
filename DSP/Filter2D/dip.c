#include <stdio.h>
#include <stdlib.h>
unsigned char *in_img;
unsigned char *out_img;
int height, width;

void filter2d(void) {
	int h[3][3] = {0x08, 0x10, 0x08, 0x10, 0x20, 0x10, 0x08, 0x10, 0x08};
	for(int i=0;i<height;i++) {
		for(int j=0;j<width;j++) {
			int sum = 0;
			
			if(i>0 && j>0) sum += in_img[(i-1)*width+j-1]*h[0][0];
			if(i>0) sum += in_img[(i-1)*width+j ]*h[0][1];
			if(i>0 && j<width-1) sum += in_img[(i-1)*width+j+1]*h[0][2];
			if(j>0) sum += in_img[(i )*width+j-1]*h[1][0];
			
			sum += in_img[(i )*width+j ]*h[1][1];
			
			if(j<width-1) sum += in_img[(i )*width+j+1]*h[1][2];
			if(i<height-1 && j>0) sum += in_img[(i+1)*width+j-1]*h[2][0];
			if(i<height-1) sum += in_img[(i+1)*width+j ]*h[2][1];
			if(i<height-1 && j<width-1) sum += in_img[(i+1)*width+j+1]*h[2][2];
			
			sum = (sum + (1<<6)) >> 7;
			if(sum < 0) out_img[i*width+j] = 0;
			else if(sum > 255) out_img[i*width+j] = 255;
			else out_img[i*width+j] = sum;
		}
	}
}

void init_filter2d(int h, int w) {
	int i, a;
	FILE *inf;
	inf = fopen("./img_in.txt", "r");
	height = h;
	width = w;
	in_img = malloc(height*width*sizeof(unsigned char));
	out_img = malloc(height*width*sizeof(unsigned char));
	for(i=0;i<height*width;i++) {
		fscanf(inf, "%d,", &a);
		in_img[i] = a;
	}
	filter2d();
	fclose(inf);
}

unsigned char get_input() {
	static int i;
	unsigned char res = in_img[i];
	i++;
	if(i==height*width) i = 0;
	return res;
}

unsigned char get_output() {
	static int i;
	unsigned char res = out_img[i];
	i++;
	if(i==height*width) i = 0;
	return res;
}