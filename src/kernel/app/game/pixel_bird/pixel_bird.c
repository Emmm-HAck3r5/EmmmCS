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
  File: pixel_bird.c
  Project: EmmmCS
  File Created: 2018-12-22 20:25:43
  Author: Chen Haodong (easyai@outlook.com)
  --------------------------
  Last Modified: 2018-12-23 20:50:36
  Modified By: Chen Haodong (easyai@outlook.com)
 */

#include "physics.h"
#include "objects.h"
#include "../../../klib/math.h"
#include "../../../driver/timer.h"
#include "../../../intr/intr.h"

#define KBD_SPACE 0x20
extern pb_rigid_body_t rigid_bodys[9];
static BOOL is_gameover;
static int cur_time;
void pb_physics_update(pb_rigid_body_t *bodys)
{
    for (u8 i = 0; i < 9; i++)
    {
        bodys[i].spr.x += bodys[i].x_speed;
        bodys[i].spr.phy_x += bodys[i].x_speed;
    }
    bodys[0].spr.y += bodys[0].y_speed;
    bodys[0].spr.phy_y += bodys[0].y_speed;
    bodys[0].y_speed -= PB_PHY_G;
}
//the tube1,and tube2 is the most close tube to the bird
//          | <- tube2
//bird -> .
//          | <- tube1
static BOOL is_bird_die()
{
    sprite_t *bird = &(rigid_bodys[0].spr);
    if (bird->x >= 80 || bird->x < 0 || bird->y >=30 || bird->y < 0)
        return TRUE;
    sprite_t *tube1 = &(rigid_bodys[1].spr), *tube2 = &(rigid_bodys[2].spr);
    if (bird->phy_x >= tube1->phy_x && bird->phy_x < tube1->phy_x + tube1->width)
    {
        if(bird->phy_y >= tube2->phy_y || bird->phy_y <= tube1->phy_y)
            return TRUE;
    }
    return FALSE;
}
void update_tubes()
{
    if (rigid_bodys[1].spr.x + rigid_bodys[1].spr.width <= 0)
    {
        //tube_pixels_destroy(rigid_bodys[1]->spr->pixels);
        //sprite_destroy(rigid_bodys[1]->spr);
        //pb_rigid_body_destroy(rigid_bodys[1]);
        //tube_pixels_destroy(rigid_bodys[2]->spr->pixels);
        //sprite_destroy(rigid_bodys[2]->spr);
        //pb_rigid_body_destroy(rigid_bodys[2]);
        memmove(rigid_bodys + 1, rigid_bodys + 3, 6 * sizeof(pb_rigid_body_t));
        int l1 = rand() % 14;
        int l2 = rand() % 14;
        pb_rigid_body_create(7,-1, 0, 8, l1, 60, 0, 8, l1, 60, 0);
        tube_pixels_generate(rigid_bodys[7].spr.pixels,l1, 8);
        pb_rigid_body_create(8,-1, 0, 8, l2, 60, 29-l2, 8, l2, 60, 16);
        tube_pixels_generate(rigid_bodys[8].spr.pixels, l2, 8);
    }
}
static void tick(void)
{
    cur_time = (cur_time + 1) & 0x3F;
}
int pixel_bird(void)
{
    //init the scene
    srand(time());
    vga_clean();
    cur_time == 0;
    pb_rigid_body_create(0,0,0,3, 1, BIRD_X, 15, 1, 1, BIRD_PHY_X, 15);
    memcpy(rigid_bodys[0].spr.pixels, bird[0], 3);
    for (u8 i = 1; i <= 4;i++)
    {
        int l1 = rand() % 14;
        int l2 = rand() % 14;
        int x = 15 * i;
        pb_rigid_body_create(i*2-1,-1, 0, 8, l1, x, 0, 8, l1, x, 0);
        tube_pixels_generate(rigid_bodys[i * 2 - 1].spr.pixels, l1, 8);
        pb_rigid_body_create(i*2,-1, 0, 8, l2, x, 29-l2, 8, l2, x, 16);
        tube_pixels_generate(rigid_bodys[i * 2].spr.pixels, l2, 8);
    }
    for(u8 i =0;i<9;i++)
    {
        sprite_draw(&rigid_bodys[i].spr,0x7);
    }
    //scene init finished
    is_gameover = FALSE;
    //register game main logic as the timer handler
    intr_on();
    tick_handler_register(tick);
    while (!is_gameover)
    {
        if(cur_time == 0)
        {
                //main logic
                        for(u8 i =0;i<9;i++)
            {
                sprite_clear(&rigid_bodys[i].spr);
            }
            pb_physics_update(rigid_bodys);
            for(u8 i =0;i<9;i++)
            {
                sprite_draw(&rigid_bodys[i].spr,0x7);
            }
            if(rand() & 0x1)
            {
                rigid_bodys[0].y_speed += 2;
            }
            if (kbd_getc_async() == KBD_SPACE)
            {
                rigid_bodys[0].y_speed += 2;
                kbd_clear_buf();
            }
            if(is_bird_die())
                is_gameover = TRUE;
            update_tubes();
        }
    }
    tick_handler_unregister();
    //sprite_destroy(rigid_bodys[0]->spr);
    //pb_rigid_body_destroy(rigid_bodys[0]);
    //for (int i = 1; i < 9;i++)
    //{
    //    if(rigid_bodys[i])
    //    {
    //        tube_pixels_destroy(rigid_bodys[i]->spr->pixels);
    //        sprite_destroy(rigid_bodys[i]->spr);
    //        pb_rigid_body_destroy(rigid_bodys[i]);
    //    }
    //}
    vga_clean();
    return 0;
}