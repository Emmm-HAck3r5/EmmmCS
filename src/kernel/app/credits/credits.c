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
  File: credits.c
  Project: EmmmCS
  File Created: 2018-12-23 12:51:46
  Author: Chen Haodong (easyai@outlook.com)
  --------------------------
  Last Modified: 2018-12-23 18:23:04
  Modified By: Chen Haodong (easyai@outlook.com)
 */
#include "credits_include.h"
extern const char *const credits_position[];
extern const char *const credits_data[];
extern u16 eh_logo[];
extern u16 emmmcs_logo[];
extern u16 anime_frame[18][990];

static int cur_frame;
static int cur_time;
static int cur_anime_time;
static int cur_pos_print;
static int cur_data_print;
static BOOL is_refresh;
static void credits_tick()
{
    cur_anime_time = (cur_anime_time + 1) & 0x3FF;
    cur_time = (cur_time + 1) & 0x3FFF;
}
static void update_anime()
{
    for (int i = 0; i < 30;i++)
    {
        int idx = i * 33;
        for (int j = 47; j < 80; j++)
        {
            vga_writec(0x07, (char)anime_frame[cur_frame][idx + j - 47], j, i);
        }
    }
    cur_frame = (cur_frame + 1) % 18;
}
static void print_pos()
{
    int len = 0;
    if(cur_data_print == 0)
    {
        len = strlen(credits_position[cur_pos_print]);
        for (int i = 0; i < len;i++)
        {
            vga_writec(VGA_B_BLACK | VGA_F_WHITE, credits_position[cur_pos_print][i], i, 29);
        }
        ++cur_data_print;
    }
    else if(cur_data_print == 1)
    {
        for (int i = 0; i < 47; i++)
        {
            vga_writec(VGA_B_BLACK | VGA_F_WHITE, ' ', i, 29);
        }
        ++cur_data_print;
    }
    else
    {
        if(cur_pos_print < 5)
        {
            if(cur_data_print == 2)
            {
                char *str;
                if(cur_pos_print  < 3)
                    str = credits_data[0];
                else if(cur_pos_print == 3)
                    str = credits_data[1];
                else if(cur_pos_print == 4)
                    str = credits_data[2];
                len = strlen(str);
                for (int i = 0; i < len; i++)
                {
                    vga_writec(VGA_B_BLACK | VGA_F_WHITE, str[i], i + 2, 29);
                }
                ++cur_data_print;
            }
            else
            {
                for (int i = 0; i < 47; i++)
                {
                    vga_writec(VGA_B_BLACK | VGA_F_WHITE, ' ', i, 29);
                }
                cur_data_print = 0;
                ++cur_pos_print;
            }
        }
        else if (cur_pos_print < 11)
        {
            if (cur_data_print < 5)
            {
                len = strlen(credits_data[cur_data_print - 2]);
                for (int i = 0; i < len; i++)
                {
                    vga_writec(VGA_B_BLACK | VGA_F_WHITE, credits_data[cur_data_print - 2][i], i + 2, 29);
                }
                ++cur_data_print;
            }
            else
            {
                for (int i = 0; i < 47; i++)
                {
                    vga_writec(VGA_B_BLACK | VGA_F_WHITE, ' ', i, 29);
                }
                cur_data_print = 0;
                ++cur_pos_print;
            }
        }
        else if(cur_pos_print == 11)
        {
            if (cur_data_print < 5)
            {
                len = strlen(credits_data[cur_data_print + 2]);
                for (int i = 0; i < len; i++)
                {
                    vga_writec(VGA_B_BLACK | VGA_F_WHITE, credits_data[cur_data_print + 2][i], i + 2, 29);
                }
                ++cur_data_print;
            }
            else
            {
                for (int i = 0; i < 47; i++)
                {
                    vga_writec(VGA_B_BLACK | VGA_F_WHITE, ' ', i, 29);
                }
                cur_data_print = 0;
                ++cur_pos_print;
            }
        }
        else if (cur_pos_print == 12)
        {
            if (cur_data_print < 5)
            {
                int idx = (cur_data_print - 2) * 41;
                for (int i = 0; i < 41; i++)
                {
                    vga_writec(eh_logo[idx + i] >> 8, eh_logo[idx + i], i + 2, 29);
                }
                ++cur_data_print;
            }
            else if(cur_data_print == 5)
            {
                for (int i = 0; i < 47; i++)
                {
                    vga_writec(VGA_B_BLACK | VGA_F_WHITE, ' ', i, 29);
                }
                ++cur_data_print;
            }
            else if(cur_data_print == 6)
            {
                len = strlen(credits_data[3]);
                for (int i = 0; i < len; i++)
                {
                    vga_writec(VGA_B_BLACK | VGA_F_WHITE, credits_data[3][i], i, 29);
                }
                ++cur_data_print;
            }
            else
            {
                for (int i = 0; i < 47; i++)
                {
                    vga_writec(VGA_B_BLACK | VGA_F_WHITE, ' ', i, 29);
                }
                ++cur_pos_print;
            }
        }
    }
}
int credits(void)
{
    vga_clean();
    cur_frame = 0;
    cur_time = 0;
    cur_anime_time = 0;
    cur_pos_print = 0;
    cur_data_print = 0;
    is_refresh = 1;
    tick_handler_register(credits_tick);
    while (1)
    {
        //print credits info
        if(cur_time == 0)
        {
            if (is_refresh)
                if (cur_pos_print < 13)
                {
                    print_pos();
                    vga_force_scroll(0, 47);
                }
                else if (cur_pos_print == 13 && cur_data_print < 38)
                {
                    vga_force_scroll(0, 47);
                    ++cur_data_print;
                }
                else
                {
                    for (int i = 0; i < 4; i++)
                    {
                        for (int j = 0; j < 34; j++)
                        {
                            vga_writec(emmmcs_logo[i * 34 + j] >> 8, emmmcs_logo[i * 34 + j], 6 + j, 12 + i);
                        }
                    }
                    int len = strlen(credits_data[3]);
                    for (int i = 0; i < len; i++)
                    {
                        vga_writec(VGA_B_BLACK | VGA_F_WHITE, credits_data[3][i], i, 17);
                    }
                    is_refresh = FALSE;
                }
            else
                ;
        }
        if(cur_anime_time == 0)
            update_anime();
        if(kbd_getc_async()=='q')
            break;
    }
    credits_exit();
}

void credits_exit()
{
    tick_handler_unregister();
}