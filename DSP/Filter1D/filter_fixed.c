
#include <stdio.h>
#include <math.h>
int filter(int in) {
static int x[21]; // x: (16,13)
int h[21] = { -10, 62, 84, -296, -246,
              954, 477, -2645, -689, 10122,
              17159, 10122, -689, -2645, 477,
              954, -246, -296, 84, 62, -10}; // h: (16,15)

for(int i=20;i>=1;i--)
  x[i] = x[i-1];
x[0] = in;

int out = 0;
for(int i=0;i<21;i++)
  out += x[i] * h[i];   // x * h: (31, 28), MAC  : (32, 28)

out = (out+(1<<15)) >> 16;    // MAC_rnd : (16, 12)  
if(out > 32767) out = 32767;  // 2^15 = 32768
else if(out < -32767) out = -32767;
return out;
} 

int main(void) {
  FILE *inf, *outf;
  inf = fopen("input.txt", "r");
  outf = fopen("output.txt", "w");

  float in_f;
  while(fscanf(inf, "%f", &in_f) > 0)  // floating input
  { // fixed input 
    int in_i = (int)floor(in_f*8192+0.5);   // x: (16,13); 2^13 = 8192
    if(in_i > 32767) in_i = 32767;          // Clamping into 2's complement range
    else if(in_i < -32767) in_i = -32767; 

    int out_i;
    float out_f;
    out_i = filter(in_i);                  // fixed output
    out_f = out_i / 4096.;                 // floating output
    fprintf(outf, "%f\n", out_f);
  } 
  
  fclose(inf); fclose(outf);
  
}