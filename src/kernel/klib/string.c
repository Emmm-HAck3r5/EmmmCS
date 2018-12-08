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
  File: string.c
  Project: EmmmCS
  File Created: 2018-12-08 13:17:45
  Author: Chen Haodong (easyai@outlook.com)
  --------------------------
  Last Modified: 2018-12-08 13:20:31
  Modified By: Chen Haodong (easyai@outlook.com)
 */

#include "string.h"

int strcmp(const char *s1, const char *s2)
{
    for (; *s1 == *s2; s1++, s2++)
        if (*s1 == '\0')
            return 0;
    return ((*(u8 *)s1 < *(u8 *)s2) ? -1 : 1);
}

char *strcpy(char *dest, const char *src)
{
    char *tmp_dest = dest;
    while ((*tmp_dest++ = *src++) != '\0')
        ;
    return dest;
}
char *strcat(char *dest, const char *src)
{
    char *tmp_dest = dest;
    while ((*tmp_dest++) != '\0')
        ;
    strcpy(tmp_dest, src);
    return dest;
}
u32 strlen(char *s)
{
    u32 count = 0;
    while ((*s++) != '\0')
        count++;
    return count;
}