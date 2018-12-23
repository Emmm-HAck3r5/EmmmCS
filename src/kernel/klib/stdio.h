#ifndef KLIB_STDIO_H
#define KLIB_STDIO_H

#include "../typedef.h"

char  getchar();
char* gets(char* str);
int getn();
int sgetn(char *str, u32 len);
char *gets_drawback(char *str);

int putchar(char cha);
int   puts(const char* str);
void  putn(u32 n, u8 mode);
int   putchar_color(u8 color, char cha);
int   puts_color(u8 color, const char * str);
void  putn_color(u8 color, u32 n, u8 mode);

#endif