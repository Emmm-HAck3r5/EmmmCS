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
  File: intr.c
  Project: EmmmCS
  File Created: 2018-12-21 10:17:05
  Author: Chen Haodong (easyai@outlook.com)
          Xie Nairong (jujianai@hotmail.com)
  --------------------------
  Last Modified: 2018-12-21 16:49:47
  Modified By: Chen Haodong (easyai@outlook.com)
 */
#include "intr.h"

static void *intr_handlers[INTR_COUNT];

void intr_init(void)
{
    write_csr(mtvec, intr_handlers);
}

void intr_handler_register(u8 intrno, void *handler)
{
    if(intrno < INTR_COUNT)
        intr_handlers[intrno] = handler;
}

void intr_on(void)
{
    write_csr(mie, 1);
}
void intr_off(void)
{
    write_csr(mie, 0);
}
void intr(void)
{
    intr_off();
    u32 intrno;
    read_csr(mcause, intrno);
    if(intrno < INTR_COUNT)
        (*(void (*)(void))(&intr_handlers[intrno]))();
    intr_on();
    __asm__ volatile("mret");
}
// static u8* intr_args = (u8*)INDR_ADDR;

// void intr_init(){
//     *((u32*) intr_args) = 0;
//     void* intr_ptr = intr;
//     write_csr(uscratch, intr_ptr); // fake instr
//     // asm volatile("csrw uscratch, %0": "r"(intr_ptr));
// }

// void intr_open(){
//     int code = 1;
//     write_csr(uepc, code); // fake instr
//     // asm volatile("csrw uepc, %0": "r"(code));
// }

// void intr_close(){
//     int code = 0;
//     write_csr(uepc, code); // fake instr
//     // asm volatile("csrw uepc, %0": "r"(code));
// }

// void intr(){
//     switch(intr_args[0]){
//         case 0: return;
//         case 1: kbd_update(intr_args + 1); break;
//         default: break;
//     }
//     intr_close();
//     int code = 0;
//     write_csr(ucause, code); // fake MRET instr
//     // asm volatile("csrw ucause, %0": "r"(code));
//     return;
// }