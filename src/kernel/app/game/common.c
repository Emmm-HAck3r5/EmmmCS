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
  File: common.c
  Project: EmmmCS
  File Created: 2018-12-21 19:44:05
  Author: Chen Haodong (easyai@outlook.com)
  --------------------------
  Last Modified: 2018-12-22 21:33:44
  Modified By: Chen Haodong (easyai@outlook.com)
 */

#include "common.h"
sprite_t *sprite_create(u8 w, u8 l, s8 x, s8 y, u8 p_w, u8 p_l, s8 p_x, s8 p_y, u8 *pxs)
{
    sprite_t *spr = (sprite_t *)malloc(sizeof(sprite_t));
    spr->width = w;
    spr->length = l;
    spr->x = x;
    spr->y = y;
    spr->phy_width = p_w;
    spr->phy_length = p_l;
    spr->phy_x = p_x;
    spr->phy_y = p_y;
    spr->pixels = pxs;
}
void sprite_destroy(sprite_t *spr)
{
    free(spr);
}
void sprite_draw(sprite_t *spr, u8 color)
{
    int i, j;
    for (i = 0; i < spr->length; ++i)
    {
        for (j = 0; j < spr->width; ++j)
        {
            vga_writec(color, spr->pixels[i * spr->width + j], spr->x + j, spr->y - i);
        }
    }
}
