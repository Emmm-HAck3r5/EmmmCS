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
  File: vga.c
  Project: EmmmCS
  File Created: 2018-12-04 22:42:36
  Author: Chen Haodong (easyai@outlook.com)
  --------------------------
  Last Modified: 2018-12-05 23:04:21
  Modified By: Chen Haodong (easyai@outlook.com)
 */
#include "vga.h"

static u16 * const vga_mem = (u16 *)0x80004;

static u8 *const cursor_x = (u8 *)0x812C0;
static u8 *const cursor_y = (u8 *)0x812C1;