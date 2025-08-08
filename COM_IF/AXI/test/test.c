#include <stdio.h>

int main(){

	FILE* fp = fopen("test.txt", "w");
	for(int i = 0; i < 100; i++){
		long result = 1;
		for(int j = 0; j < 8; j++){
			result *= i; // 0^8 , 1^8, 2^8 , ... , 100^8
		}
		fprintf(fp, "result = %lu\n", result);
	}	

	fclose(fp);	

	return 1;
}
