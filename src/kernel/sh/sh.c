#include "sh.h"

#include "../driver/vga.h"
#include "../driver/kbd.h"
#include "../driver/timer.h"

#include "../klib/stdio.h"
#include "../klib/string.h"
#include "../app/credits/credits.h"

void sh(){
    while (1){
        vga_puts(0x02, "forewing@EmmmCS:");
        vga_puts(0x01, "~$ ");
        char tmp[101];
        gets(tmp);
        if (strcmp(tmp, "hello") == 0){
            vga_puts(0x3, "Hello, world!\n");
        }else if (strcmp(tmp, "time") == 0){
            vga_putn(0x07, uptime(), VGA_N_HEX);
            vga_puts(0x7, "\n");
        }else if (strcmp(tmp, "credits") == 0){
            credits();
        }else if (strcmp(tmp, "fuck") == 0){
            vga_puts(0x50, "Fuck you\n");
        }else if (strcmp(tmp, "clear") == 0){
            vga_init();
        }else if (strcmp(tmp, "bc") == 0){
            sh_bc();
        }else{
            vga_puts(0x50, "Invalid command\n");
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