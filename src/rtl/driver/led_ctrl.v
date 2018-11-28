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
  File Created: 2018-11-27 22:08:22
  Author: Chen Haodong (easyai@outlook.com)
  --------------------------
  Last Modified: 2018-11-28 19:52:33
  Modified By: Chen Haodong (easyai@outlook.com)
 */

module led_ctrl(
    input [`LED_REG_WIDTH-1:0] led_reg,
    output led_0,led_1,led_2,led_3,led_4,led_5,led_6,led_7,led_8,led_9
    );

    assign led_0 = led_reg[0];
    assign led_1 = led_reg[1];
    assign led_2 = led_reg[2];
    assign led_3 = led_reg[3];
    assign led_4 = led_reg[4];
    assign led_5 = led_reg[5];
    assign led_6 = led_reg[6];
    assign led_7 = led_reg[7];
    assign led_8 = led_reg[8];
    assign led_9 = led_reg[9];

endmodule