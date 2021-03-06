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
  File: mem.h
  Project: EmmmCS
  File Created: 2018-12-04 22:44:16
  Author: Chen Haodong (easyai@outlook.com)
  --------------------------
  Last Modified: 2018-12-08 12:03:07
  Modified By: Chen Haodong (easyai@outlook.com)
 */
#ifndef KLIB_MEM_H
#define KLIB_MEM_H
#include "../typedef.h"

void* malloc(u32 size);
void free(void *p);
void* memcpy(void *dst, const void *src, u32 size);
void* memset(void *dst, u32 val, u32 size);
void* memmove(void *dst, const void *src, u32 size);
#endif