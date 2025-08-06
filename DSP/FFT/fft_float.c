#include <stdio.h>
#include <math.h>
typedef struct {
	float r, i;
} t_complex;

void complex_add(t_complex *dst, t_complex src0, t_complex src1) {
	dst->r = src0.r + src1.r;
	dst->i = src0.i + src1.i;
}
void complex_sub(t_complex *dst, t_complex src0, t_complex src1) {
	dst->r = src0.r - src1.r;
	dst->i = src0.i - src1.i;
}
void complex_mul(t_complex *dst, t_complex src0, t_complex src1) {
	dst->r = src0.r * src1.r - src0.i * src1.i;
	dst->i = src0.r * src1.i + src0.i * src1.r;
}
float complex_mag(t_complex in) {
	return sqrt(in.r*in.r + in.i*in.i);
}
void twiddle_mul(t_complex *dst, int k, int N) {
	t_complex twiddle_factor;
	const float pi = acos(-1.0);
	twiddle_factor.r = cos(-2*pi*k/N);
	twiddle_factor.i = sin(-2*pi*k/N);
	complex_mul(dst, *dst, twiddle_factor);
}

void fft(float in[1024], t_complex out[1024]) {
	int i, j, k, p;
	for(i=0;i<1024;i++) {
		out[i].r = in[i];
		out[i].i = 0;
	}
	
	for(i=0,p=1024;i<10;i++,p/=2) { // clog2(N)개의 stage
		for(j=0;j<1024/p;j++) {		// 블럭 개수 
			for(k=0;k<p/2;k++) {	// 블럭내부에서 연산 (짝/홀로 나눔)
				t_complex bf0, bf1;
				complex_add(&bf0, out[j*p+k], out[j*p+k+p/2]);
				// p/2 : 블럭내부에서 페어링
				complex_sub(&bf1, out[j*p+k], out[j*p+k+p/2]);
				twiddle_mul(&bf1, k, p);
				out[j*p+k] = bf0;
				out[j*p+k+p/2] = bf1;
			}
		}
	}
}

int bit_reverse(int in) {
	int i, out = 0;
	for(i=0;i<10;i++) {
		out <<= 1;
		out |= in & 0x01;
		in >>= 1;
	}
	return out;
}

int main(void) {
	float fft_in[1024];
	t_complex fft_out[1024];
	int i;
	const float pi = acos(-1.0);
	for(i=0;i<1024;i++) {
		fft_in[i] = sin(2*pi*i*100/1024); // N = 1024
	}
	fft(fft_in, fft_out);
	/*
	for(i=0;i<1024;i++) {
	printf("%f %f\n", fft_out[bit_reverse(i)].r, fft_out[bit_reverse(i)].i);
	}
	*/
	// 그냥 출력하면 bit 역순으로 출력됨 
	for(i=0;i<1024;i++) {
		printf("%f\n", complex_mag(fft_out[bit_reverse(i)]));
	}
}