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
  File: common.h
  Project: EmmmCS
  File Created: 2018-12-21 19:44:05
  Author: Chen Haodong (easyai@outlook.com)
  --------------------------
  Last Modified: 2018-12-21 20:22:56
  Modified By: Chen Haodong (easyai@outlook.com)
 */

#ifndef KERNEL_GAME_COMMON_H
#define KERNEL_GAME_COMMON_H

#include "../../typedef.h"
#include "../../driver/vga.h"
#include "../../driver/kbd.h"
#include "../../klib/mem.h"
#include "../../klib/math.h"

#define SOLID_SQUARE 0x1
#define UP_SOLID_SQUARE 0x2
#define DP_SOLID_SQUARE 0x3
#define SOLID_CIRCLE 0x4
#define U_TRIANGLE 0x5
#define R_TRIANGLE 0x6
#define UR_TRIANGLE 0x7
#define DR_TRIANGLE 0xe
#define L_TRIANGLE 0xf
#define UL_TRIANGLE 0x10
#define DL_TRIANGLE 0x11
#define D_TRIANGLE 0x12
typedef struct sprite_t
{
    u8 width;
    u8 length;
    u8 x;
    u8 y;
    u8 phy_width;
    u8 phy_length;
    u8 phy_x;
    u8 phy_y;
    u8 *pixels;
} sprite_t;

sprite_t *sprite_create(u8 w, u8 l, u8 x, u8 y, u8 p_w, u8 p_l, u8 p_x, u8 p_y, u8 *pxs);
void sprite_destroy(sprite_t *spr);
#endif