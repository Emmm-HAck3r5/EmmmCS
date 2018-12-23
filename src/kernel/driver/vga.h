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
  File: vga.h
  Project: EmmmCS
  File Created: 2018-12-04 22:42:41
  Author: Chen Haodong (easyai@outlook.com)
  --------------------------
  Last Modified: 2018-12-23 15:51:03
  Modified By: Chen Haodong (easyai@outlook.com)
 */
#ifndef DRIVER_VGA_H
#define DRIVER_VGA_H
#include "../typedef.h"
//80x30
#define VGA_CHAR_X_SIZE 80
#define VGA_CHAR_Y_SIZE 30
#define VGA_CHAR_BUF_SIZE 2400
#define VGA_B_BLACK 0x00
#define VGA_B_BLUE 0x10
#define VGA_B_GREEN 0x20
#define VGA_B_CYAN 0x30
#define VGA_B_RED 0x40
#define VGA_B_MAGENTA 0x50
#define VGA_B_BROWN 0x60
#define VGA_B_WHITE 0x70
#define VGA_F_BLACK 0x00
#define VGA_F_BLUE 0x01
#define VGA_F_GREEN 0x02
#define VGA_F_CYAN 0x03
#define VGA_F_RED 0x04
#define VGA_F_MAGENTA 0x05
#define VGA_F_BROWN 0x06
#define VGA_F_WHITE 0x07
#define VGA_F_YELLOW 0x0e
#define VGA_N_S_DEC 0x0
#define VGA_N_U_DEC 0x1
#define VGA_N_HEX 0x2
void vga_init();
void vga_writec(u8 color, char c, u8 x, u8 y);
void vga_putc(u8 color, char c);
void vga_puts(u8 color, const char *str);
void vga_putn(u8 color, u32 n, u8 mode);
void vga_clean(void);
void vga_force_scroll(int begin, int end);
#endif