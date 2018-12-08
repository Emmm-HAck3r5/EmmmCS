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
  File: dlist.h
  Project: EmmmCS
  File Created: 2018-12-07 22:31:49
  Author: Chen Haodong (easyai@outlook.com)
  --------------------------
  Last Modified: 2018-12-07 23:35:09
  Modified By: Chen Haodong (easyai@outlook.com)
 */

/* ATTENTION! the head of dlist doesn't store data!*/
#define DLIST_INIT(__list__, __m_next__, __m_prev__) \
    {                                                \
        (__list__)->__m_next__ = __list__;             \
        (__list__)->__m_prev__ = __list__;             \
    }
#define DLIST_EMPTY(__list__, __m_next__, __m_prev__) (((__list__)->__m_prev__ == (__list__) && (__list__)->__m_next__ == (__list__)) ? TRUE : FALSE)
#define DLIST_INSERT(__pos__, __m_next__, __m_prev__, __node__) \
    {                                                           \
        (__pos__)->__m_next__->__m_prev__ = __node__;             \
        (__node__)->__m_next__ = (__pos__)->__m_next__;             \
        (__node__)->__m_prev__ = __pos__;                         \
        (__pos__)->__m_next__ = __node__;                         \
    }
#define DLIST_DELETE(__list__, __pos__, __m_next__, __m_prev__)    \
    {                                                              \
        if (!DLIST_EMPTY(__list__, __m_next__, __m_prev__))        \
        {                                                          \
            (__pos__)->__m_next__->__m_prev__ = (__pos__)->__m_prev__; \
            (__pos__)->__m_prev__->__m_next__ = (__pos__)->__m_next__; \
            (__pos__)->__m_next__ = NULL;                            \
            (__pos__)->__m_prev__ = NULL;                            \
        }                                                          \
    }
#define DLIST_ADD_TAIL(__list__, __m_next__, __m_prev__, __node__) DLIST_INSERT(__list__, __m_prev__, __m_next__, __node__)
#define DLIST_ADD_HEAD(__list__, __m_next__, __m_prev__, __node__) DLIST_INSERT(__list__, __m_next__, __m_prev__, __node__)
#define DLIST_FOREACH(__list__, __m_next__, __ptr__) for (__ptr__ = (__list__)->__m_next__; __ptr__ != __list__; __ptr__ = (__ptr__)->__m_next__)
#define DLIST_FIND_NODE(__list__, __m_next__, __p_node__, __key__, __cmpfunc__) \
    {                                                                           \
        DLIST_FOREACH(__list__, __m_next__, __p_node__)                         \
        if (!__cmpfunc__(__key__, __p_node__))                                  \
        {                                                                       \
            break;                                                              \
            if (__p_node__ == __list__)                                         \
                __p_node__ = NULL;                                              \
        }
