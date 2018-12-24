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
  File: kbd.c
  Project: EmmmCS
  File Created: 2018-12-21 10:17:05
  Author: Chen Haodong (easyai@outlook.com)
          Xie Nairong (jujianai@hotmail.com)
  --------------------------
  Last Modified: 2018-12-23 17:59:38
  Modified By: Chen Haodong (easyai@outlook.com)
 */
#include "kbd.h"
#include "vga.h"  //tmp
#include "../intr/intr.h"

// static u8* kbd_buf;
// static u32 kbd_ptr = 0, kbd_ptr_r = 0;;

static u32 kbd_buf;
// static const u8 scan_to_ascii[] = {
//     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x60, 0x00,
//     0x00, 0x00, 0x00, 0x00, 0x00, 0x71, 0x31, 0x00, 0x00, 0x00, 0x7A, 0x73, 0x61, 0x77, 0x32, 0x00,
//     0x00, 0x63, 0x78, 0x64, 0x65, 0x34, 0x33, 0x00, 0x00, 0x20, 0x76, 0x66, 0x74, 0x72, 0x35, 0x00,
//     0x00, 0x6E, 0x62, 0x68, 0x67, 0x79, 0x36, 0x00, 0x00, 0x00, 0x6D, 0x6A, 0x75, 0x37, 0x38, 0x00,
//     0x00, 0x2C, 0x6B, 0x69, 0x6F, 0x30, 0x39, 0x00, 0x00, 0x2E, 0x2F, 0x6C, 0x3A, 0x71, 0x2D, 0x00,
//     0x00, 0x00, 0x27, 0x00, 0x5B, 0x3D, 0x00, 0x00, 0x00, 0x00, 0x0D, 0x5D, 0x00, 0x5C, 0x00, 0x00,
//     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x00, 0x00, 0x31, 0x00, 0x34, 0x37, 0x00, 0x00, 0x00,
//     0x30, 0x2E, 0x32, 0x35, 0x36, 0x38, 0x00, 0x00, 0x00, 0x2B, 0x33, 0x2C, 0x2A, 0x39, 0x00, 0x00
// };

void kbd_init(void)
{
    kbd_buf = 0;
    intr_handler_register(KBD_INTR, kbd_handler);
}

void kbd_clear_buf(void){
    kbd_buf = 0;
}

void kbd_handler(void)
{
    // kbd_buf = read_csr(mtval);
    read_csr(mscratch, kbd_buf);
    // vga_puts(0x07, "Hit kbd_handel: ");
    // vga_putn(0x07, kbd_buf, VGA_N_HEX);
    // vga_puts(0x07, "\n");
    // vga_putn(0x07, &kbd_buf, VGA_N_HEX);
    // vga_putn(0x70, kbd_buf, VGA_N_HEX);
}

u8 kbd_getc(void)
{
    u8 key;
    if (kbd_buf <= 0xFF){
        // key = scan_to_ascii[kbd_buf];
        key = kbd_buf;
    }else{
        key = 0;
    }
    // vga_puts(0x70, "kbd_getc\n");
    // vga_putn(0x70, kbd_buf, VGA_N_HEX);
    kbd_buf = 0;
    return key;
}
u8 kbd_getc_async(void)
{
    return kbd_buf;
}
    // void kbd_init(){
    //     kbd_buf = (u8*)mm_alloc(KBD_BUF_SIZE);
    // }

    // void kbd_update(u8* args){
    //     if (args[0] == 1){
    //         kbd_buf[kbd_ptr % KBD_BUF_SIZE] = scan_to_ascii[args[1] % 128];
    //         args[0] = 0;
    //         kbd_ptr++;
    //     }
    //     return;
    // }

    // u8 kbd_getc(){
    //     u8 ret = 0;
    //     intr_open();
    //     while(1){
    //         if (kbd_ptr != kbd_ptr_r){
    //             ret = kbd_buf[kbd_ptr_r % KBD_BUF_SIZE];
    //             kbd_ptr_r++;
    //             break;
    //         }
    //     }
    //     return ret;
    // }