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
  File: objects.c
  Project: EmmmCS
  File Created: 2018-12-21 19:44:05
  Author: Chen Haodong (easyai@outlook.com)
  --------------------------
  Last Modified: 2018-12-23 20:48:40
  Modified By: Chen Haodong (easyai@outlook.com)
 */

#include "objects.h"

u8 bird[2][3] = {{0x5F, SOLID_SQUARE, DL_TRIANGLE}, {0x60, SOLID_SQUARE, DR_TRIANGLE}};

void tube_pixels_generate(u8 *buf, int l, int w)
{
      //u8 *pixel = (u8 *)malloc(sizeof(u8) * l * w);
      memset(buf, SOLID_SQUARE, l * w);
      //return pixel;
}
void tube_pixels_destroy(u8 *tube)
{
      free(tube);
}