/*
  Copyright 2018 EmmmHackers

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
  --------------------------
  File: stdio.c
  Project: EmmmCS
  File Created: 2018-12-21 10:17:05
  Author: Chen Haodong (easyai@outlook.com)
          Xie Nairong (jujianai@hotmail.com)
  --------------------------
  Last Modified: 2018-12-21 16:49:33
  Modified By: Chen Haodong (easyai@outlook.com)
 */
#include "stdio.h"
#include "../driver/kbd.h"
#include "../driver/vga.h"

char getchar(){
    u8 c;
    while(1)
        if((c=kbd_getc())!=0)
            return c;
    //FATAL ERROR
    return 0;
}

char* gets(char* str){
    char* ptr = str;
    while (1){
        *ptr = kbd_getc();
        if (*ptr == '\n')
            break;
        else if(*ptr == 0)
            continue;
        ptr++;
    }
    *ptr = '\0';
    return str;
}

int putchar(char cha){
    vga_putc(VGA_B_BLACK | VGA_F_WHITE, cha);
    return 0;
}

int puts(const char* str){
    vga_puts(VGA_B_BLACK | VGA_F_WHITE, str);
    return 0;
}

void putn(u32 n, u8 mode){
    vga_putn(VGA_B_BLACK | VGA_F_WHITE, n, mode);
    return;
}

int putchar_color(u8 color, char cha){
    vga_putc(color, cha);
    return 0;
}

int puts_color(u8 color, const char* str){
    vga_puts(color, str);
    return 0;
}

void putn_color(u8 color, u32 n, u8 mode){
    vga_putn(color, n, mode);
    return;
}