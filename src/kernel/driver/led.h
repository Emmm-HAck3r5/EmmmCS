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
  File: led.h
  Project: EmmmCS
  File Created: 2018-12-04 22:49:50
  Author: Chen Haodong (easyai@outlook.com)
  --------------------------
  Last Modified: 2018-12-08 16:23:48
  Modified By: Chen Haodong (easyai@outlook.com)
 */
#ifndef DRIVER_LED_H
#define DRIVER_LED_H
#include "../typedef.h"

void led_init(void);
void led_on(u8 id);
void led_off(u8 id);
void led_toggle(u8 id);
#endif