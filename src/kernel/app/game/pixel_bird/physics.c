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
  Last Modified: 2018-12-22 21:28:49
  Modified By: Chen Haodong (easyai@outlook.com)
 */

#include "physics.h"

pb_rigid_body_t *pb_rigid_body_create(u8 x_s, u8 y_s, sprite_t *spr)
{
    pb_rigid_body_t *body = (pb_rigid_body_t *)malloc(sizeof(pb_rigid_body_t));
    body->x_speed = x_s;
    body->y_speed = y_s;
    body->spr = spr;
}
void pb_rigid_body_destroy(pb_rigid_body_t *body)
{
    free(body);
}