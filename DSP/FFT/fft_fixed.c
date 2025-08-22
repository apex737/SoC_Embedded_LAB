#include <stdio.h>
#include <math.h>
typedef struct {
	int r, i;
} t_complex;

// 덧셈과 뺄셈에서 bit Rshift
void complex_add(t_complex *dst, t_complex src0, t_complex src1) {
	dst->r = (src0.r + src1.r) >> 1;
	dst->i = (src0.i + src1.i) >> 1;
}

void complex_sub(t_complex *dst, t_complex src0, t_complex src1) {
	dst->r = (src0.r - src1.r) >> 1;
	dst->i = (src0.i - src1.i) >> 1;
}

// 
void complex_mul(t_complex *dst, t_complex src0, t_complex src1) {
	dst->r = (src0.r * src1.r - src0.i * src1.i) >> 9;
	dst->i = (src0.r * src1.i + src0.i * src1.r) >> 9;
}

float complex_mag(t_complex in) {
	return sqrt(in.r*in.r/32./32. + in.i*in.i/32./32.);
}

void twiddle_mul(t_complex *dst, int k, int N) {
	t_complex twiddle_factor;
	const float pi = acos(-1.0);
	twiddle_factor.r = floor(cos(-2*pi*k/N)*511 + 0.5);
	twiddle_factor.i = floor(sin(-2*pi*k/N)*511 + 0.5);
	complex_mul(dst, *dst, twiddle_factor);
}

void fft(int in[1024], t_complex out[1024]) {
	int i, j, k, p;
	for(i=0;i<1024;i++) {
		out[i].r = in[i];
		out[i].i = 0;
	}
	for(i=0,p=1024;i<10;i++,p/=2) {
		for(j=0;j<1024/p;j++) {
			for(k=0;k<p/2;k++) {
				t_complex bf0, bf1;
				complex_add(&bf0, out[j*p+k], out[j*p+k+p/2]);
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
	int fft_in[1024];
	t_complex fft_out[1024];
	int i;
	const float pi = acos(-1.0);
	for(i=0;i<1024;i++) {
		//fft_in[i] = floor(sin(2*pi*i*100/1024) * 32767 + 0.5);
		fft_in[i] = (i<5) ? 32767 : (i>=1019) ? 32767 : 0;
	}
	fft(fft_in, fft_out);
	/*
	for(i=0;i<1024;i++) {
	printf("%d %d\n", fft_out[bit_reverse(i)].r, fft_out[bit_reverse(i)].i);
	}
	*/
	for(i=0;i<1024;i++) {
		printf("%f\n", complex_mag(fft_out[bit_reverse(i)]));
	}
}