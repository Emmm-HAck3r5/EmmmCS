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
  File: cpu_define.v
  Project: EmmmCS
  File Created: 2018-11-20 23:07:46
  Author: Chen Haodong (easyai@outlook.com)
  --------------------------
  Last Modified: 2018-11-20 23:36:47
  Modified By: Chen Haodong (easyai@outlook.com)
 */

`define CPU_XLEN 32

//reg
//general-purpose reg
`define CPU_GREGIDX_WIDTH 5
//x0 is always zero
`define CPU_GREG_COUNT 32