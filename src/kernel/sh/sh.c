#include "sh.h"

#include "../driver/vga.h"
#include "../driver/kbd.h"
#include "../driver/timer.h"
#include "../driver/led.h"

#include "../klib/stdio.h"
#include "../klib/string.h"
#include "../app/credits/credits.h"
#include "../app/app.h"
#include "../app/game/pixel_bird/pixel_bird.h"

void sh(){
    while (1){
        vga_puts(0x02, "EmmmCS>");
        vga_puts(VGA_F_RED|VGA_B_BLACK, "(DEBUG)");
        vga_puts(0x01, "~");
        vga_puts(0x07, "$ ");
        char tmp[101];
        gets_drawback(tmp);
        char* cmd = strtok(tmp, ' ');
        // if (strcmp(cmd, "hello") == 0){
        //     vga_puts(VGA_F_CYAN|VGA_B_BLACK, "Hello, world!\n");
        // }else
        if (strcmp(cmd, "time") == 0){
            vga_putn(0x07, uptime(), VGA_N_U_DEC);
            vga_puts(0x7, "\n");
        }else if (strcmp(cmd, "credits") == 0){
            credits();
            vga_init();
            vga_putc(0x7, '\b');
        }else if (strcmp(cmd, "hello") == 0){
            char* subcmd;
            if ((subcmd = strtok(NULL, ' ')) != NULL){
                vga_puts(VGA_B_BLACK|VGA_F_CYAN, "Hello ");
                vga_puts(VGA_B_BLACK|VGA_F_CYAN, subcmd);
                vga_puts(VGA_B_BLACK|VGA_F_CYAN, "!\n");
            }else{
                vga_puts(VGA_B_BLACK|VGA_F_CYAN, "Hello World!\n");
            }
        }else if (strcmp(cmd, "uname") == 0){
            vga_puts(0x07, "EmmmCS 1.0.0-Build275-Emmm_Hackers RISC-V\n");
        }else if (strcmp(cmd, "clear") == 0){
            vga_init();
        }else if (strcmp(cmd, "eval") == 0){
            char ex[100];
            while(1){
                vga_puts(0x07, "exp: ");
                gets_drawback(ex);
                if (strcmp(ex, "quit") == 0){
                    break;
                }
                int ret, errno;
                ret = eval(ex, &errno);
                if (errno != 1){
                    vga_puts(0x07, "result: ");
                    vga_putn(VGA_F_RED|VGA_B_BLACK, ret, VGA_N_S_DEC);
                    vga_puts(0x7, "\n");
                }
            }
        }else if (strcmp(cmd, "bird") == 0){
            pixel_bird();
            vga_init();
        }else if (strcmp(cmd, "exit") == 0){
            return;
        }else if (strcmp(cmd, "led") == 0){
            char* subcmd;
            if ((subcmd = strtok(NULL, ' ')) != NULL){
                led_toggle(subcmd[0] - '0');
            }else{
                vga_puts(0x7, "Please provide LED id.\n");
            }
        }else if (strcmp(cmd, "help") == 0){
            vga_puts(0x7, "help page\n");
        }else if (strcmp(cmd, "bc") == 0){
            sh_bc();
        }else if (cmd[0] == '\0'){
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