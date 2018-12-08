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
  File: led.c
  Project: EmmmCS
  File Created: 2018-12-04 22:49:46
  Author: Chen Haodong (easyai@outlook.com)
  --------------------------
  Last Modified: 2018-12-08 14:34:19
  Modified By: Chen Haodong (easyai@outlook.com)
 */
#include "led.h"
static u8 * const led_reg = (u8 *)0x80000;

void led_init()
{
    *led_reg = 0;
    *(led_reg + 1) = 0;
}
void led_on(u8 id)
{
    if(id > 9)
        return;
    if(id > 7)
    {
        *(led_reg + 1) |= 1 << (id - 8);
    }
    else
    {
        *(led_reg) |= 1 << id;
    }
}
void led_off(u8 id)
{
    if (id > 9)
        return;
    if (id > 7)
    {
        *(led_reg + 1) &= ~(1 << (id - 8));
    }
    else
    {
        *(led_reg) &= ~(1 << id);
    }
}
void led_toggle(u8 id)
{
    if (id > 9)
        return;
    if (id > 7)
    {
        *(led_reg + 1) ^= 1 << (id - 8);
    }
    else
    {
        *(led_reg) ^= 1 << id;
    }
}