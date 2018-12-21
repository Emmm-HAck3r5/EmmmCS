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
  File: vga.c
  Project: EmmmCS
  File Created: 2018-12-04 22:42:36
  Author: Chen Haodong (easyai@outlook.com)
  --------------------------
  Last Modified: 2018-12-21 21:10:25
  Modified By: Chen Haodong (easyai@outlook.com)
 */
#include "vga.h"
#include "../klib/mem.h"
static u16 * const vga_mem = (u16 *)0x80004;

static u8 *const cursor_x = (u8 *)0x812C5;
static u8 *const cursor_y = (u8 *)0x812C4;

void vga_init()
{
    vga_clean();
    *cursor_x = 0;
    *cursor_y = 0;
}
static void scroll(void)
{
    if (*cursor_y >= VGA_CHAR_Y_SIZE)
    {
        u16 i = 0;
        for (; i < VGA_CHAR_BUF_SIZE - VGA_CHAR_X_SIZE;++i)
            *(vga_mem + i) = *(vga_mem + i + VGA_CHAR_X_SIZE);
        for (; i < VGA_CHAR_X_SIZE;++i)
            *(vga_mem + i) = 0x0020;
        *cursor_y = VGA_CHAR_Y_SIZE - 1;
    }
}
void vga_writec(u8 color, char c, u8 x, u8 y)
{
    if(x >=VGA_CHAR_X_SIZE || y >= VGA_CHAR_Y_SIZE)
        return;
    *(vga_mem + y * VGA_CHAR_X_SIZE + x) = ((u16)color << 8) | c;
}
void vga_putc(u8 color, char c)
{
    switch(c)
    {
    case 0x08:// \b
        if(*cursor_x)
            --(*cursor_x);
        else
        {
            if(*cursor_y)
            {
                *cursor_x = VGA_CHAR_X_SIZE;
                --(*cursor_y);
            }
        }
        break;
    case 0x09:// tab
        if(*cursor_x < VGA_CHAR_X_SIZE - 4)
        {
            *cursor_x = (*cursor_x + 4) & ~(3);
        }
        break;
    case 0x0D:// \r
        *cursor_x = 0;
        break;
    case 0x0A:// \n
        *cursor_x = 0;
        ++(*cursor_y);
        break;
    default:
        if(c >= 0x20)
        {//printable
            *(vga_mem + (*cursor_y) * VGA_CHAR_X_SIZE + *cursor_x) = ((u16)color << 8) | c;
            if(*cursor_x < VGA_CHAR_X_SIZE)
                ++(*cursor_x);
            else
            {
                *cursor_x = 0;
                ++(*cursor_y);
            }
        }
        break;
    }
    if(*cursor_x>=VGA_CHAR_X_SIZE)
    {
        *cursor_x = 0;
        ++(*cursor_y);
    }
    scroll();
}
void vga_puts(u8 color, const char *str)
{
    while(*str != '\0')
        vga_putc(color, *str++);
}
void vga_putn(u8 color, u32 n, u8 mode)
{
    if(mode == VGA_N_S_DEC || mode == VGA_N_U_DEC)
    {
        if(n==0)
        {
            vga_putc(color, '0');
            return;
        }
        char num[10] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
        u8 neg = FALSE;
        if(mode == VGA_N_S_DEC)
        {
            if(n == 0x80000000)
            {
                vga_puts(color, "-2147483648");
                return;
            }
            else if(n > 0x80000000)
            {
                n = ~n + 1;
                neg = TRUE;
            }
        }
        u8 i;
        for (i = 0; n;++i)
        {
            num[i] = n % 10 + '0';
            n /= 10;
        }
        if(neg)
            vga_putc(color, '-');
        while(i>0)
            vga_putc(color, num[--i]);

    }
    else if(mode == VGA_N_HEX)
    {
        vga_puts(color, "0x");
        if(n==0)
        {
            vga_putc(color, '0');
            return;
        }
        u8 skip_zero = TRUE;
        for (s8 i = 28; i >= 0;i-=4)
        {
            u8 tmp = (n >> i) & 0xF;
            if(tmp == 0 && skip_zero)
                continue;
            skip_zero = FALSE;
            if(tmp >=0xA)
                vga_putc(color, tmp - 0xA + 'A');
            else
                vga_putc(color, tmp + '0');
        }
    }
}
void vga_clean(void)
{
    for (u16 i = 0; i < VGA_CHAR_BUF_SIZE;++i)
    {
        //black space
        *(vga_mem + i) = 0x0020;
    }
}