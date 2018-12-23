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
  File: physics.c
  Project: EmmmCS
  File Created: 2018-12-22 20:30:41
  Author: Chen Haodong (easyai@outlook.com)
  --------------------------
  Last Modified: 2018-12-23 20:45:05
  Modified By: Chen Haodong (easyai@outlook.com)
 */

#include "physics.h"
pb_rigid_body_t rigid_bodys[9];
void pb_rigid_body_create(u8 idx, u8 x_s, u8 y_s, u8 w, u8 l, s8 x, s8 y, u8 p_w, u8 p_l, s8 p_x, s8 p_y)
{
    pb_rigid_body_t *body = &rigid_bodys[idx];
    body->x_speed = x_s;
    body->y_speed = y_s;
    body->spr.width = w;
    body->spr.length = l;
    body->spr.x = x;
    body->spr.y = y;
    body->spr.phy_width = p_w;
    body->spr.phy_length = p_l;
    body->spr.phy_x = p_x;
    body->spr.phy_y = p_y;
}
void pb_rigid_body_destroy(pb_rigid_body_t *body)
{
    free(body);
}