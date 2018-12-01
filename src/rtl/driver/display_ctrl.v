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
  File: led_ctrl.v
  Project: EmmmCS
  File Created: 2018-12-01 15:06:22
  Author: Chen Haodong (easyai@outlook.com)
  --------------------------
  Last Modified: 2018-12-01 15:06:22
  Modified By: Chen Haodong (easyai@outlook.com)
 */

module display_ctrl(
    input clk,
    input reset_n,

    input [7:0] in_ascii,
    input [`DP_REG_WIDTH-1:0] ctrl_reg,
    //to upper
    output [`DP_X_ADDR_WIDTH-1:0] x_addr,
    output [`DP_Y_ADDR_WIDTH-1:0] y_addr,
    //vga
    input vga_rst,
    output vga_vs,
    output vga_hs,
    output vga_syncn,
    output vga_blankn,
    output vga_clk,
    output [7:0] vga_r,
    output [7:0] vga_g,
    output [7:0] vga_b,
    );
    wire cur_clock;
    wire [`DP_X_ADDR_WIDTH-1:0] cur_x_addr;
    wire [`DP_Y_ADDR_WIDTH-1:0] cur_y_addr;
    wire [`DP_COLOR_WIDTH-1:0] bg_color;
    wire [`DP_COLOR_WIDTH-1:0] fg_color;
    //font
    wire [7:0] font_line_bitmap;
    wire [2:0] font_x_addr; //0 - 7 
    wire [10:0] font_line_addr; // for font rom
    //vga
    wire [9:0] h_addr;//x
    wire [9:0] v_addr;//y
    wire [23:0] vga_data;

    //DP_X_ADDR_WIDTH = 8
    //DP_Y_ADDR_WIDTH = 5
    //DP_COLOR_WIDTH = 4
    assign cur_x_addr = ctrl_reg[7:0];
    assign cur_y_addr = ctrl_reg[12:8];
    assign bg_color = ctrl_reg[19:16];
    assign fg_color = ctrl_reg[23:20];

    assign vga_syncn = 1'b0;

    //clock
    clkgen_module #(25000000) vgaclk(.clkin(clk),.rst(~reset_n),.clken(1'b1),.clkout(vga_clk));
    clkgen_module #(2) cursorclk(.clkin(clk),.rst(~reset_n),.clken(1'b1),clkout(cur_clk));
    //vga
    vga_ctrl vga(.pclk(vga_clk),
                .reset(vga_rst),
                .vga_data(vga_data),
                .h_addr(h_addr),
                .v_addr(v_addr),
                .hsync(vga_hs),
                .vsync(vga_vs),
                .valid(vga_blankn),
                .vga_r(vga_r),
                .vga_g(vga_g),
                .vga_b(vga_b));
    //font
    vga_font_rom from(.address(font_line_addr),.clock(~clk),.q(font_line_bitmap));

    /*
    h_addr,v_addr start from 1
    640 x 480 -> 80 x 30
    h_addr -> x_addr:
    (h_addr - 1) / 8
    v_addr -> y_addr:
    (v_addr - 1) / 16
    h_addr -> font_x_addr:
    (h_addr - 1) % 8
    */
    assign x_addr = (h_addr - 1) >> 3;
    assign y_addr = (v_addr - 1) >> 4;
    assign font_x_addr = (h_addr - 1) & 10'h7;

    assign font_line_addr = ({3'b0,in_ascii}<<4) + ((v_addr - 1)&10'hf);

    //todo the color and cursor
    assign vga_data = {24{font_line_bitmap[font_x_addr]}};
endmodule
