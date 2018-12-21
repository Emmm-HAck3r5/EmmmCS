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
  File: timer.c
  Project: EmmmCS
  File Created: 2018-12-21 17:08:40
  Author: Chen Haodong (easyai@outlook.com)
  --------------------------
  Last Modified: 2018-12-21 17:18:36
  Modified By: Chen Haodong (easyai@outlook.com)
 */

#include "timer.h"
#include "../intr/intr.h"
static void (*tick_handler)(void);

void timer_init(void)
{
    intr_handler_register(TIMER_INTR, timer_handler);
}

void timer_handler(void)
{
    if(tick_handler)
        tick_handler();
}

void tick_handler_register(void *handler)
{
    tick_handler = (void (*)(void))handler;
}

void tick_handler_unregister(void)
{
    tick_handler = (void (*)(void))NULL;
}