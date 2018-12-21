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
  File: math.c
  Project: EmmmCS
  File Created: 2018-12-21 19:44:05
  Author: Chen Haodong (easyai@outlook.com)
  --------------------------
  Last Modified: 2018-12-21 21:17:45
  Modified By: Chen Haodong (easyai@outlook.com)
 */

#include "math.h"

static rand_seed;

void srand(u32 seed)
{
    rand_seed = seed;
}
u32 rand(void)
{
    rand_seed = (rand_seed * 31 + 13) % (((u32)1 << 31) - 1);
    return rand_seed;
}