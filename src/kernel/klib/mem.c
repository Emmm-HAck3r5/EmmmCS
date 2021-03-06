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
  File: mem.c
  Project: EmmmCS
  File Created: 2018-12-04 22:44:12
  Author: Chen Haodong (easyai@outlook.com)
  --------------------------
  Last Modified: 2018-12-08 13:15:07
  Modified By: Chen Haodong (easyai@outlook.com)
 */

#include "mem.h"
#include "../mm/mm.h"

void *malloc(u32 size)
{
    return mm_alloc(size);
}
void free(void *p)
{
    mm_dealloc(p);
}
void *memcpy(void *dst, const void *src, u32 size)
{
    u8 *tmp_dst = (u8 *)dst;
    u8 *tmp_src = (u8 *)src;
    while (size--)
        *tmp_dst++ = *tmp_src++;
    return dst;
}
void *memset(void *dst, u32 val, u32 size)
{
    u8 *tmp_dst = (u8 *)dst;
    while(size--)
        *tmp_dst++ = (u8)val;
    return dst;
}
void *memmove(void *dst, const void *src, u32 size)
{
    if((u32)dst < (u32)src)
        return memcpy(dst, src, size);
    else
    {
        u8 *tmp_dst = (u8 *)dst + size;
        u8 *tmp_src = (u8 *)src + size;
        while (size--)
            *--tmp_dst = *--tmp_src;
        return dst;
    }
}