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
  File: intr.h
  Project: EmmmCS
  File Created: 2018-12-21 10:17:05
  Author: Chen Haodong (easyai@outlook.com)
          Xie Nairong (jujianai@hotmail.com)
  --------------------------
  Last Modified: 2018-12-21 16:49:53
  Modified By: Chen Haodong (easyai@outlook.com)
 */
#ifndef KERNEL_INTR_H
#define KERNEL_INTR_H

#include "../typedef.h"
#include "../riscv_asm.h"

#define INTR_COUNT 3
#define FATAL_ERROR 0x0
#define KBD_INTR 0x1
#define TIMER_INTR 0x2

void intr_init(void);
void intr_handler_register(u8 intrno, void *handler);
void intr_on(void);
void intr_off(void);
void intr(void);
//#define INDR_ADDR 0x7fffc

//void intr_init();
//void intr_open();
//void intr_close();
//void intr();

#endif