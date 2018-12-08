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
  File: mm.h
  Project: EmmmCS
  File Created: 2018-12-07 19:45:05
  Author: Chen Haodong (easyai@outlook.com)
  --------------------------
  Last Modified: 2018-12-07 22:43:49
  Modified By: Chen Haodong (easyai@outlook.com)
 */
/*
Buddy Memory Allocator
allocate for
16B
32B
64B
128B
256B
512B
1KB
2KB
4KB
8KB
16KB
32KB
64KB
128KB
depth:14
ATTENTION: ALLOCATED SIZE = ALIGNED(REQUIRED SIZE + HEADER SIZE)
*/
#include "../typedef.h"
// 128KB heap
#define HEAP_SIZE 131072
#define TREE_DEPTH 14
typedef struct buddy_mm_info_s
{
    struct buddy_mm_info_s *m_next, *m_prev;
} buddy_mm_info_t;
typedef u32 buddy_mm_header_t;
typedef struct
{
    u32 used_size;
    buddy_mm_info_t* tree[TREE_DEPTH];
} buddy_mm_t;
void mm_init(void);
void *mm_alloc(u32 sz);
void mm_dealloc(void *p);