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
  Last Modified: 2018-12-23 20:15:20
  Modified By: Chen Haodong (easyai@outlook.com)
 */
#include "stdio.h"
#include "../intr/intr.h"
#include "../driver/kbd.h"
#include "../driver/vga.h"

char getchar(){
    intr_on();
    u8 c;
    while(1)
        if((c=kbd_getc())!=0){
            intr_off();
            return c;
        }
    //FATAL ERROR
    return 0;
}

char* gets(char* str){
    char* ptr = str;
    while (1){
        *ptr = getchar();
        if (*ptr == '\n')
            break;
        if (*ptr == '\b'){
            *ptr = 0;
            if (ptr > str){
                ptr--;
            }
            ptr--;
        }else{
            ptr++;
        }
    }
    *ptr = '\0';
    return str;
}

char* gets_drawback(char* str){
    char* ptr = str;
    while (1){
        *ptr = getchar();
        vga_putc(0x7, *ptr);
        if (*ptr == '\n')
            break;
        if (*ptr == '\b'){
            *ptr = 0;
            if (ptr > str){
                ptr--;
            }
        }else{
            ptr++;
        }
    }
    *ptr = '\0';
    return str;
}

int getn()
{
    int n = 0;
    char c;
    u8 st = 1;
    while(1)
    {
        n *= 10;
        c = getchar();
        if(c == '-' && (st & 0x1))
            st ^= 0x3;
        else if(c >= '0' && c <='9')
            n += c - '0';
        else
        {
            n /= 10;
            break;
        }
    }
    if(st & 0x2)
        n = -n;
    return n;
}

int sgetn(char *str, u32 len)
{
    int n = 0;
    char c;
    u8 st = 1;
    int count;
    for (count = 0; count < len;++count)
    {
        n *= 10;
        c = str[count];
        if (c == '-' && (st & 0x1))
            st ^= 0x3;
        else if (c >= '0' && c <= '9')
            n += c - '0';
        else
        {
            n /= 10;
            break;
        }
    }
    if (st & 0x2)
        n = -n;
    return n;
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