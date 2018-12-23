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
  File: objects.h
  Project: EmmmCS
  File Created: 2018-12-22 20:24:39
  Author: Chen Haodong (easyai@outlook.com)
  --------------------------
  Last Modified: 2018-12-23 20:48:17
  Modified By: Chen Haodong (easyai@outlook.com)
 */

#ifndef GAME_PB_OBJECTS_H
#define GAME_PB_OBJECTS_H
#include "../common.h"

#define BIRD_X 5
#define BIRD_PHY_X 6
#define BIRD_ACT_UP 0
#define BIRD_ACT_DOWN 1
void tube_pixels_generate(u8 *buf, int l, int w);
void tube_pixels_destroy(u8 *tube);

extern u8 bird[2][3];
#endif
