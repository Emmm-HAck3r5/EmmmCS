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
  Last Modified: 2018-11-25 10:47:47
  Modified By: Chen Haodong (easyai@outlook.com)
 */

`define CPU_XLEN 32

//reg
//general-purpose reg
`define CPU_GREGIDX_WIDTH 5
//x0 is always zero
`define CPU_GREG_COUNT 32
//instruction length
`define CPU_INSTR_LENGTH 32
//decoder info
`define CPU_INSTR_INFO_WIDTH 5
`define CPU_INSTR_OPR_INFO_WIDTH 8
`define CPU_INSTR_DECODE_INFO_WIDTH 13
`define CPU_INSTR_OPR_INVALID `CPU_INSTR_OPR_INFO_WIDTH'b0
`define CPU_INSTR_OPR_IMM `CPU_INSTR_OPR_INFO_WIDTH'b1
`define CPU_INSTR_OPR_RS1 `CPU_INSTR_OPR_INFO_WIDTH'b10
`define CPU_INSTR_OPR_RS2 `CPU_INSTR_OPR_INFO_WIDTH'b100
`define CPU_INSTR_OPR_RD `CPU_INSTR_OPR_INFO_WIDTH'b1000
`define CPU_INSTR_OPR_RS3 `CPU_INSTR_OPR_INFO_WIDTH'b10000
`define CPU_INSTR_GRP_INVALID `CPU_INSTR_INFO_WIDTH'd0
`define CPU_INSTR_GRP_LUI `CPU_INSTR_INFO_WIDTH'd1
`define CPU_INSTR_GRP_AUIPC `CPU_INSTR_INFO_WIDTH'd2
`define CPU_INSTR_GRP_JAL `CPU_INSTR_INFO_WIDTH'd3
`define CPU_INSTR_GRP_JALR `CPU_INSTR_INFO_WIDTH'd4
`define CPU_INSTR_GRP_BCC `CPU_INSTR_INFO_WIDTH'd5
`define CPU_INSTR_GRP_LOAD `CPU_INSTR_INFO_WIDTH'd6
`define CPU_INSTR_GRP_STORE `CPU_INSTR_INFO_WIDTH'd7
`define CPU_INSTR_GRP_ALUI `CPU_INSTR_INFO_WIDTH'd8
`define CPU_INSTR_GRP_ALU `CPU_INSTR_INFO_WIDTH'd9
`define CPU_INSTR_GRP_FENCE `CPU_INSTR_INFO_WIDTH'd10
`define CPU_INSTR_GRP_E_CSR `CPU_INSTR_INFO_WIDTH'd11
`define CPU_INSTR_GRP_MULDIV `CPU_INSTR_INFO_WIDTH'd12
`define CPU_INSTR_GRP_F_FLW `CPU_INSTR_INFO_WIDTH'd13
`define CPU_INSTR_GRP_F_FSW `CPU_INSTR_INFO_WIDTH'd14
`define CPU_INSTR_GRP_F_FMADD `CPU_INSTR_INFO_WIDTH'd15
`define CPU_INSTR_GRP_F_FMSUB `CPU_INSTR_INFO_WIDTH'd16
`define CPU_INSTR_GRP_F_FNMSUB `CPU_INSTR_INFO_WIDTH'd17
`define CPU_INSTR_GRP_F_FNMADD `CPU_INSTR_INFO_WIDTH'd18
`define CPU_INSTR_GRP_F_FOPR `CPU_INSTR_INFO_WIDTH'd19