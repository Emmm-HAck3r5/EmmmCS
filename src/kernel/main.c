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
#include "driver/timer.h"
#include "mm/mm.h"
#include "sh/sh.h"

#include "klib/stdio.h"

#include "intr/intr.h"
#include "riscv_asm.h"

void init(void);

extern u16 emmmcs_logo[];
extern const char * const credits_data[];
int main(void)
{
    init();
    for (int i = 0; i < 4; i++){
        for (int j = 0; j < 34; j++){
            vga_putc(emmmcs_logo[i*34+j]>>8, emmmcs_logo[i*34+j] & 0xff);
        }
        vga_putc(0x07, '\n');
    }
    vga_puts(0x7, "======================================\n");
    vga_puts(0x7, credits_data[0]);
    vga_puts(0x7, "\n");
    vga_puts(0x7, credits_data[1]);
    vga_puts(0x7, "\n");
    vga_puts(0x7, credits_data[2]);
    vga_puts(0x7, "\n");
    vga_puts(0x7, "======================================\n\n");
    led_on(0);
    // vga_puts(0x07, "Press ANY Key to Start.\n");
    // getchar();
    // vga_puts(0x07, "Welcome to EmmmCS!\n");
    while (1){
        sh();
        vga_puts(0x7, "Press Any Key to Start Shell.\n");
        getchar();
    }

    return 0;
}

void init(void)
{
    led_init();
    vga_init();
    kbd_init();
    timer_init();
    mm_init();
    intr_init();
}
