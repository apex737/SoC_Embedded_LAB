#include <stdio.h>
#include <math.h>
#define N 1024
int main(void) {
const float pi = acos(-1.0);
int k, c, s;
for(k=0;k<N/4;k++) { // 1/4 주기만 만들어서 사용
		c = floor(cos(-2*pi*k/N)*511 + 0.5);
		s = floor(sin(-2*pi*k/N)*511 + 0.5);
		printf("\t\t%d: twid_lut = {-10'd%d,10'd%d};\n", k, -s, c);
	}
}