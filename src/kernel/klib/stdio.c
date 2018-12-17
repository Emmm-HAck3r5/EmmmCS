#include "stdio.h"
#include "../driver/kbd.h"
#include "../driver/vga.h"

char  getchar(){
    return kbd_getc();
}

char* gets(char* str){
    char* ptr = str;
    while (1){
        *ptr = kbd_getc();
        if (*ptr == '\n'){
            break;
        }
        ptr++;
    }
    *ptr = '\0';
    return str;
}

int putchar(char cha){
    vga_putc(0, cha);
    return 0;
}

int puts   (const char* str){
    vga_puts(0, str);
    return 0;
}

void putn  (u32 n, u8 mode){
    vga_putn(0, n, mode);
    return 0;
}

int putchar_color(u8 color, char cha){
    vga_putc(color, cha);
    return 0;
}

int puts_color   (u8 color, const char* str){
    vga_puts(color, str);
    return 0;
}

void putn_color(u8 color, u32 n, u8 mode){
    vga_putn(color, n, mode);
    return 0;
}