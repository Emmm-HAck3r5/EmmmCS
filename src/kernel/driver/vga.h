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
  Last Modified: 2018-12-07 19:44:25
  Modified By: Chen Haodong (easyai@outlook.com)
 */
#include "../typedef.h"
void vga_init();
void vga_write(u8 color, u8 c, u32 x, u32 y);
static void scroll(void);
void vga_putc(u8 color, u8 c);
void vga_puts(u8 color, u8 *str);
void vga_putn(u8 color, u32 n, u8 mode);
void vga_clean(void)
