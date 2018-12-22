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
  File: main.c
  Project: EmmmCS
  File Created: 2018-12-07 19:46:30
  Author: Chen Haodong (easyai@outlook.com)
  --------------------------
  Last Modified: 2018-12-07 19:48:45
  Modified By: Chen Haodong (easyai@outlook.com)
 */

#include "driver/led.h"
#include "driver/vga.h"
#include "driver/kbd.h"
#include "mm/mm.h"
#include "intr/intr.h".

#include "klib/stdio.h"

void init(void);

int main(void)
{
    // init();
    // led_on(1);
    // u32* ptr = 0x80000;
    // *ptr = 0x3;
    // u16* ptr2 = 0x80010;
    // *ptr2 = 0x7031;
    // while (1){
    //     vga_putc(0x70, 'f');
    // // }
    // led_on(1);
    // int i = 0;
    // u16* ptr_char = 0x80004;
    // for (i = 0; i < 0x81000; i++){
    //     *(ptr_char + i) = 0x7031;
    // }
    // u16* ptr_cur = 0x812C4;
    // *ptr_cur = 0x21;
    init();
    // vga_putn(0x70, i, VGA_N_HEX);
    // vga_putn(0x70, i-3>=0, VGA_N_HEX);
    // vga_putn(0x70, i-3, VGA_N_HEX);
        // vga_putn(0x07, i >= 0, VGA_N_HEX);
        // vga_puts(0x07, "\t");
        // vga_putn(0x07, i, VGA_N_HEX);
        // vga_puts(0x07, "\n");
        // if (a > 8){
        //     break;
        // }
    vga_putn(0x07, 0x123ff, VGA_N_HEX);
    while(1){
        getchar();
    }
    return 0;
}

void init(void)
{
    led_init();
    vga_init();
    kbd_init();
    mm_init();
    intr_init();
}
