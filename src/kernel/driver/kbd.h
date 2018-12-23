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
  File: kbd.h
  Project: EmmmCS
  File Created: 2018-12-21 10:17:05
  Author: Chen Haodong (easyai@outlook.com)
          Xie Nairong (jujianai@hotmail.com)
  --------------------------
  Last Modified: 2018-12-23 17:59:25
  Modified By: Chen Haodong (easyai@outlook.com)
 */
#ifndef DRIVER_KBD_H
#define DRIVER_KBD_H
#include "../typedef.h"

void kbd_init(void);
void kbd_handler(void);
u8 kbd_getc(void);
u8 kbd_getc_async(void);
//#define KBD_BUF_SIZE 256

//void kbd_init();
//void kbd_update();
//u8   kbd_getc();

#endif