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
  File: vga_color_decoder.v
  Project: EmmmCS
  File Created: 2018-12-18 16:00:20
  Author: Chen Haodong (easyai@outlook.com)
  --------------------------
  Last Modified: 2018-12-18 16:20:16
  Modified By: Chen Haodong (easyai@outlook.com)
 */

`define VGA_BLACK 4'h0
`define VGA_BLUE 4'h1
`define VGA_GREEN 4'h2
`define VGA_CYAN 4'h3
`define VGA_RED 4'h4
`define VGA_MAGENTA 4'h5
`define VGA_BROWN 4'h6
`define VGA_WHITE 4'h7
`define VGA_YELLOW 4'he

`define VGA_RGB_BLACK 24'h000000
`define VGA_RGB_BLUE 24'h0000ff
`define VGA_RGB_GREEN 24'h008000
`define VGA_RGB_CYAN 24'h00ffff
`define VGA_RGB_RED 24'hff0000
`define VGA_RGB_MAGENTA 24'hff00ff
`define VGA_RGB_BROWN 24'ha52a2a
`define VGA_RGB_WHITE 24'hffffff
`define VGA_RGB_YELLOW 24'hffff00
module vga_color_decoder(
    input fb,
    input [3:0] fg_color,
    input [3:0] bg_color,
    output [23:0] rgb
);
    wire [3:0] color_data;
    assign color_data = fb? fg_color:bg_color;
    always @ (fb or fg_color or bg_color)
    begin
        case (color_data)
            `VGA_BLACK: begin rgb = `VGA_RGB_BLACK; end
            `VGA_BLUE: begin rgb = `VGA_RGB_BLUE; end
            `VGA_GREEN: begin rgb = `VGA_RGB_GREEN; end
            `VGA_CYAN: begin rgb = `VGA_RGB_CYAN; end
            `VGA_RED: begin rgb = `VGA_RGB_RED; end
            `VGA_MAGENTA: begin rgb = `VGA_RGB_MAGENTA; end
            `VGA_BROWN: begin rgb = `VGA_RGB_BROWN; end
            `VGA_WHITE: begin rgb = `VGA_RGB_WHITE; end
            `VGA_YELLOW: begin rgb = `VGA_RGB_YELLOW; end
        endcase
    end
endmodule