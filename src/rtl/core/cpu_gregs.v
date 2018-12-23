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
  File: cpu_gregs.v
  Project: EmmmCS
  File Created: 2018-11-20 23:19:54
  Author: Chen Haodong (easyai@outlook.com)
  --------------------------
  Last Modified: 2018-11-26 22:56:03
  Modified By: Chen Haodong (easyai@outlook.com)
 */

`include "cpu_define.v"

module cpu_gregs(
    input clk,
    input rd_wen,
    input reset_n,

    input [`CPU_GREGIDX_WIDTH-1:0] rs1_idx,
    input [`CPU_GREGIDX_WIDTH-1:0] rs2_idx,
    input [`CPU_GREGIDX_WIDTH-1:0] rd_idx,

    output reg [`CPU_XLEN-1:0] rs1_dat,
    output reg [`CPU_XLEN-1:0] rs2_dat,
    input [`CPU_XLEN-1:0] rd_dat,

    input backup,
    input restore,

    //DEBUG
    output [6:0] HEX0,
    output [6:0] HEX1,
    output [6:0] HEX2,
    output [6:0] HEX3,
    output [6:0] HEX4,
    output [6:0] HEX5
    );

    seg7_h s0(
       .en(1'b1),
       .in(rx[12][3:0]),
       .hex(HEX0)
    );

    seg7_h s1(
       .en(1'b1),
       .in(rx[12][7:4]),
       .hex(HEX1)
    );

    seg7_h s2(
       .en(1'b1),
       .in(rx[12][11:8]),
       .hex(HEX2)
    );

    seg7_h s3(
       .en(1'b1),
       .in(rx[12][15:12]),
       .hex(HEX3)
    );

seg7_h s4(
   .en(1'b1),
   .in(rx[12][19:16]),
   .hex(HEX4)
);

seg7_h s5(
   .en(1'b1),
   .in(rx[12][23:20]),
   .hex(HEX5)
);


   reg [`CPU_XLEN-1:0] rx [`CPU_GREG_COUNT-1:0];
   reg [`CPU_XLEN-1:0] rx_back [`CPU_GREG_COUNT-1:0];
//
//        seg7_h s2(
//    .en(1'b1),
//    .in(rx[1][3:0]),
//    .hex(HEX2)
//);
//
//seg7_h s3(
//    .en(1'b1),
//    .in(rx[1][7:4]),
//    .hex(HEX3)
//);
integer i;

   always @(posedge clk)
    begin
        if(!reset_n) begin
            rx[0] = `CPU_XLEN'b0;
        end else if (backup) begin
            for (i = 0; i < `CPU_GREG_COUNT; i = i + 1)
                rx_back[i] = rx[i];
        end else if (restore) begin
            for (i = 0; i < `CPU_GREG_COUNT; i = i + 1)
                rx[i] = rx_back[i];
        end else begin
            rs1_dat = rx[rs1_idx];
            rs2_dat = rx[rs2_idx];
            if(rd_wen && rd_idx!=`CPU_GREGIDX_WIDTH'b0)
            begin
                rx[rd_idx] = rd_dat;
            end
        end
    end
endmodule