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

int main(void)
{
    init();
    led_on(0);
    // vga_puts(0x07, "Press ANY Key to Start.\n");
    // getchar();
    // vga_puts(0x07, "Welcome to EmmmCS!\n");
    sh();

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
