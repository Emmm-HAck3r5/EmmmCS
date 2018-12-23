#include "sh.h"

#include "../driver/vga.h"
#include "../driver/kbd.h"
#include "../driver/timer.h"

#include "../klib/stdio.h"
#include "../klib/string.h"
#include "../app/credits/credits.h"
#include "../app/app.h"

void sh(){
    while (1){
        vga_puts(0x02, "EmmmCS>");
        vga_puts(0x01, "~");
        vga_puts(VGA_F_RED|VGA_B_BLACK, "(DEBUG)");
        vga_puts(0x07, "$ ");
        char tmp[101];
        gets(tmp);
        if (strcmp(tmp, "hello") == 0){
            vga_puts(VGA_F_CYAN|VGA_B_BLACK, "Hello, world!\n");
        }else if (strcmp(tmp, "time") == 0){
            vga_putn(0x07, uptime(), VGA_N_U_DEC);
            vga_puts(0x7, "\n");
        }else if (strcmp(tmp, "credits") == 0){
            credits();
        }else if (strcmp(tmp, "fuck") == 0){
            vga_puts(0x40, "Fuck you\n");
        }else if (strcmp(tmp, "clear") == 0){
            vga_init();
        }else if (strcmp(tmp, "eval") == 0){
            char ex[100];
            gets(ex);
            vga_puts(VGA_F_RED|VGA_B_BLACK, "ex:\n");
            vga_puts(VGA_F_RED|VGA_B_BLACK, ex);
            vga_puts(VGA_F_RED|VGA_B_BLACK, "\n");
            vga_putn(VGA_F_RED|VGA_B_BLACK, eval(ex), VGA_N_S_DEC);
        }else if (strcmp(tmp, "bc") == 0){
            sh_bc();
        }else if (tmp[0] == '\0'){
            continue;
        }else{
            vga_puts(VGA_F_RED|VGA_B_WHITE, "Invalid command\n");
        }
    }
}

void sh_bc(){
    s32 a = getn();
    char c = getchar();
    s32 b = getn();
    vga_puts(0x7, "\n");
    s32 ans;
    if (c == '+'){
        ans = a+b;
    }else if (c == '-'){
        ans = a-b;
    }else if (c == '*'){
        ans = a*b;
    }else if (c == '/'){
        ans = a/b;
    }else if (c == '%'){
        ans = a%b;
    }else if (c == '|'){
        ans = a|b;
    }else if (c == '^'){
        ans = a^b;
    }else if (c == '&'){
        ans = a&b;
    }else{
        ans = 0;
    }
    vga_putn(0x7, ans, VGA_N_HEX);
    vga_puts(0x7, "\n");
}

void sh_led(){
    return;
}