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
  File: mm.c
  Project: EmmmCS
  File Created: 2018-12-07 19:45:10
  Author: Chen Haodong (easyai@outlook.com)
  --------------------------
  Last Modified: 2018-12-08 11:09:19
  Modified By: Chen Haodong (easyai@outlook.com)
 */
#include "mm.h"
#include "../klib/mem.h"
#define MM_LIST_ADD_TAIL(__list__, __m_next__, __m_prev__, __node__) \
    (__node__)->m_next = __list__;                                   \
    (__node__)->m_prev = (__list__)->m_prev;                         \
    (__list__)->m_prev->m_next = __node__;                           \
    (__list__)->m_prev = __node__;
/*
ATTENTION :buddy_mm_list's head node stores data.
So the dlist's delete CANT BE USED.
*/

static u8 mm_heap[HEAP_SIZE];
static buddy_mm_t buddy_mm;

static u32 align_up_pow2(u32 n)
{
    //fill the low bit
    n |= n >> 1;
    n |= n >> 2;
    n |= n >> 4;
    n |= n >> 8;
    n |= n >> 16;
    return n + 1;
}
static u32 log2(u32 n)
{
    u32 result = !!(n & 0xAAAAAAAA);
    result |= !!((n & 0xFFFF0000) << 4);
    result |= !!((n & 0xFF00FF00) << 3);
    result |= !!((n & 0xF0F0F0F0) << 2);
    result |= !!((n & 0xCCCCCCCC) << 1);
    return result;
}
static BOOL divide(u8 level)
{
    if (level == 0)
        return FALSE;
    if (buddy_mm.tree[level] == NULL)
        return FALSE;
    buddy_mm_info_t *block = buddy_mm.tree[level];
    //drop the block
    block->m_next->m_prev = block->m_prev;
    block->m_prev->m_next = block->m_next;
    if (block->m_next != block)
        buddy_mm.tree[level] = block->m_next;
    else
        buddy_mm.tree[level] = NULL;
    --level;
    //construct new block
    u32 offset = 1 << (level + 4);
    //link first
    if (buddy_mm.tree[level] == NULL)
    {
        buddy_mm.tree[level] = block;
        block->m_next = block->m_prev = block;
    }
    else
    {
        MM_LIST_ADD_TAIL(buddy_mm.tree[level], m_next, m_prev, block);
    }
    buddy_mm_info_t *block2 = (buddy_mm_info_t *)((char *)block + offset);
    MM_LIST_ADD_TAIL(buddy_mm.tree[level], m_next, m_prev, block2);
    return TRUE;
}
static u32 dealloc_merge(u8 level,u32 addr)
{
    if (buddy_mm.tree[level] == NULL || level == TREE_DEPTH - 1)
        return NULL;
    u32 idx = ((addr - (u32)mm_heap) >> (level + 4)) & 0x1;
    buddy_mm_info_t *buddy = idx == 0 ? (buddy_mm_info_t *)(addr + (1 << (level + 4)))
                                      : (buddy_mm_info_t *)(addr - (1 << (level + 4)));
    buddy_mm_info_t *node = buddy_mm.tree[level];
    do
    {
        if(node == buddy)
            break;
        else
            node = node->m_next;
    } while (node != buddy_mm.tree[level]);
    if(node == buddy)
    {
        //drop the node
        node->m_next->m_prev = node->m_prev;
        node->m_prev->m_next = node->m_next;
        if (node->m_next != node)
            buddy_mm.tree[level] = node->m_next;
        else
            buddy_mm.tree[level] = NULL;
        //DO NOT insert the node
        //just return the new addr needed merge
        if ((u32)addr > (u32)buddy)
            addr = buddy;
        return addr;
    }
    else
        return NULL;
}
void mm_init(void)
{
    memset(&buddy_mm, 0, sizeof(buddy_mm));
    ((buddy_mm_info_t *)mm_heap)->m_next = ((buddy_mm_info_t *)mm_heap)->m_prev = ((buddy_mm_info_t *)mm_heap);
    buddy_mm.tree[TREE_DEPTH - 1] = ((buddy_mm_info_t *)mm_heap);
}
void *mm_alloc(u32 sz)
{
    u32 mm_size = align_up_pow2(sz + sizeof(buddy_mm_header_t));
    u8 level = log2(mm_size) - 4;
    if (buddy_mm.tree[level] == NULL)
    {
        u32 l = level + 1;
        while(l<TREE_DEPTH && buddy_mm.tree[l]==NULL)
            ++l;
        if(l==TREE_DEPTH)
            return NULL;//MEMORY FULL
        while(l>level)
        {
            if(!divide(l))
                return NULL;//FATAL ERROR
            --l;
        }
    }
    if(buddy_mm.tree[level]==NULL)
        return NULL;//FATAL ERROR
    buddy_mm_info_t *block = buddy_mm.tree[level];
    //drop the block
    block->m_next->m_prev = block->m_prev;
    block->m_prev->m_next = block->m_next;
    if (block->m_next != block)
        buddy_mm.tree[level] = block->m_next;
    else
        buddy_mm.tree[level] = NULL;
    *(buddy_mm_header_t *)block = level;
    return ((char *)block + sizeof(buddy_mm_header_t));
}
void mm_dealloc(void *p)
{
    u32 addr = (u32)p - sizeof(buddy_mm_header_t);
    u8 level = *((buddy_mm_header_t *)addr);
    for (u32 next_addr = addr; level < TREE_DEPTH;++level)
    {
        next_addr = dealloc_merge(level, next_addr);
        if(next_addr == NULL)
        {
            //insert the node
            MM_LIST_ADD_TAIL(buddy_mm.tree[level], m_next, m_prev, (buddy_mm_info_t *)addr);
            break;
        }
        else
        {
            addr = next_addr;
        }
    }
}