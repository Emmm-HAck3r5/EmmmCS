#include <iostream>
using namespace std;

#define WORD_LEN 16
#define MIF_DEPTH 0x8000

void write_mifhead(FILE* fp)
{
	fprintf(fp, "WIDTH=%d;\n", WORD_LEN);
	fprintf(fp, "DEPTH=%d;\n", MIF_DEPTH);
	fprintf(fp, "ADDRESS_RADIX=HEX;\n");
	fprintf(fp, "DATA_RADIX=HEX;\n");
	fprintf(fp, "CONTENT\n");
	fprintf(fp, "BEGIN\n");
}

void write_mifbody(FILE* fp, int BUFFER[], int char_wlen)
{
	static int start = 0;
	int wlen = char_wlen / 4 + 1;
	for (int i = 0; i < wlen; i++) {
		fprintf(fp, "%.4x: %.8x;\n", start, BUFFER[i]);
		start += 4;
	}
}

void write_mifend(FILE* fp)
{
	fprintf(fp, "END;");
}

void convert_binary2mif(const char* file_name, const char* dest_name)
{
	char BUFFER[1024] = { 0 };
	FILE* fp = fopen(file_name, "rb");
	FILE* dp = fopen(dest_name, "w");
	if (!fp) {
		printf("Open file failed.\n");
		exit(0);
	}
	write_mifhead(dp);
	while (!feof(fp)) {
		int len = fread(BUFFER, sizeof(char), sizeof(BUFFER), fp);
		write_mifbody(dp, (int*)BUFFER, len);
		memset(BUFFER, 0, sizeof(BUFFER) * sizeof(char));
	}
	write_mifend(dp);
}

int main()
{
	convert_binary2mif("testcase.txt", "dest.txt");
	return 0;
}