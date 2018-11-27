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
  File: cpu_instr_decoder.v
  Project: EmmmCS
  File Created: 2018-11-24 20:06:41
  Author: Chen Haodong (easyai@outlook.com)
  --------------------------
  Last Modified: 2018-11-25 11:22:35
  Modified By: Chen Haodong (easyai@outlook.com)
 */

`include "cpu_define.v"
//support the RV32I,[M],[F]
`define FUNCT_WIDTH 10
`define OPCODE_WIDTH 7
`define INSTR_TYPE_WIDTH 4
`define INSTR_TYPE_INVALID `INSTR_TYPE_WIDTH'd0
`define INSTR_TYPE_R `INSTR_TYPE_WIDTH'd1
`define INSTR_TYPE_I `INSTR_TYPE_WIDTH'd2
`define INSTR_TYPE_S `INSTR_TYPE_WIDTH'd3
`define INSTR_TYPE_B `INSTR_TYPE_WIDTH'd4
`define INSTR_TYPE_U `INSTR_TYPE_WIDTH'd5
`define INSTR_TYPE_J `INSTR_TYPE_WIDTH'd6
`define INSTR_TYPE_R4 `INSTR_TYPE_WIDTH'd7
module cpu_instr_decoder(
    input [`CPU_INSTR_LENGTH-1:0] instr,

    output [`CPU_GREGIDX_WIDTH-1:0] rs1_idx,
    output [`CPU_GREGIDX_WIDTH-1:0] rs2_idx,
    output [`CPU_GREGIDX_WIDTH-1:0] rs3_idx,
    output [`CPU_GREGIDX_WIDTH-1:0] rd_idx,
    output reg [`CPU_XLEN-1:0] imm,
    output reg [`FUNCT_WIDTH-1:0] funct,
    output [`OPCODE_WIDTH-1:0] opcode,
    output [`CPU_INSTR_DECODE_INFO_WIDTH-1:0] dec_instr_info,
    output instr_valid,
    //for Floating-Point Instruction
    output [2:0] fp_rm,
    output [2:0] fp_width,
    output [1:0] fp_fmt
    );

    reg [`INSTR_TYPE_WIDTH-1:0] instr_type;
    reg [`CPU_INSTR_OPR_INFO_WIDTH-1:0] opr_info;
    reg [`CPU_INSTR_INFO_WIDTH-1:0] instr_info;

    assign opcode = instr[6:0];
    assign rd_idx = instr[11:7];
    assign rs1_idx = instr[19:15];
    assign rs2_idx = instr[24:20];
    assign fp_width = instr[14:12];
    assign fp_rm = instr[14:12];
    assign fp_fmt = instr[26:25];
    assign instr_valid = instr_info != `CPU_INSTR_GRP_INVALID;
    assign dec_instr_info = {instr_info,opr_info};

    always @(instr)
    begin
        case (opcode)
            `OPCODE_WIDTH'b0110111:begin instr_type = `INSTR_TYPE_U; instr_info = `CPU_INSTR_GRP_LUI; end//LUI
            `OPCODE_WIDTH'b0010111:begin instr_type = `INSTR_TYPE_U; instr_info = `CPU_INSTR_GRP_AUIPC; end//AUIPC
            `OPCODE_WIDTH'b1101111:begin instr_type = `INSTR_TYPE_J; instr_info = `CPU_INSTR_GRP_JAL; end//JAL
            `OPCODE_WIDTH'b1100111:begin instr_type = `INSTR_TYPE_I; instr_info = `CPU_INSTR_GRP_JALR; end//JALR
            `OPCODE_WIDTH'b1100011:begin instr_type = `INSTR_TYPE_B; instr_info = `CPU_INSTR_GRP_BCC; end//BCC
            `OPCODE_WIDTH'b0000011:begin instr_type = `INSTR_TYPE_I; instr_info = `CPU_INSTR_GRP_LOAD; end//LOAD
            `OPCODE_WIDTH'b0100011:begin instr_type = `INSTR_TYPE_S; instr_info = `CPU_INSTR_GRP_STORE; end//STORE
            `OPCODE_WIDTH'b0010011:begin instr_type = `INSTR_TYPE_I; instr_info = `CPU_INSTR_GRP_ALUI; end//ALUI
            `OPCODE_WIDTH'b0110011:begin instr_type = `INSTR_TYPE_R; instr_info = `CPU_INSTR_GRP_ALU; end//ALU
            `OPCODE_WIDTH'b0001111:begin instr_type = `INSTR_TYPE_I; instr_info = `CPU_INSTR_GRP_FENCE; end//FENCE
            `OPCODE_WIDTH'b1110011:begin instr_type = `INSTR_TYPE_I; instr_info = `CPU_INSTR_GRP_E_CSR; end//ECALL,EBREAK,CSR
            `OPCODE_WIDTH'b0110011:begin instr_type = `INSTR_TYPE_R; instr_info = `CPU_INSTR_GRP_MULDIV; end//[M]
            //[F]
            `OPCODE_WIDTH'b0000111:begin instr_type = `INSTR_TYPE_I; instr_info = `CPU_INSTR_GRP_F_FLW; end//FLW
            `OPCODE_WIDTH'b0100111:begin instr_type = `INSTR_TYPE_S; instr_info = `CPU_INSTR_GRP_F_FSW; end//FSW
            `OPCODE_WIDTH'b1000011:begin instr_type = `INSTR_TYPE_R4; instr_info = `CPU_INSTR_GRP_F_FMADD; end//FM
            `OPCODE_WIDTH'b1000111:begin instr_type = `INSTR_TYPE_R4; instr_info = `CPU_INSTR_GRP_F_FMSUB; end//FM
            `OPCODE_WIDTH'b1001011:begin instr_type = `INSTR_TYPE_R4; instr_info = `CPU_INSTR_GRP_F_FNMSUB; end//F[N]M
            `OPCODE_WIDTH'b1001111:begin instr_type = `INSTR_TYPE_R4; instr_info = `CPU_INSTR_GRP_F_FNMADD; end//F[N]M
            `OPCODE_WIDTH'b1010011:begin instr_type = `INSTR_TYPE_R; instr_info = `CPU_INSTR_GRP_F_FOPR; end//FOPR
            default:begin instr_type = `INSTR_TYPE_INVALID; instr_info = `CPU_INSTR_GRP_INVALID; end
        endcase

        case (instr_type)
            `INSTR_TYPE_R:
            begin
                funct = {instr[31:25], instr[14:12]};
                imm = `CPU_XLEN'd0;
                opr_info = `CPU_INSTR_OPR_RS1 | `CPU_INSTR_OPR_RS2 | `CPU_INSTR_OPR_RD;
            end
            `INSTR_TYPE_I:
            begin
                 funct = {{7{1'b0}}, instr[14:12]};
                 imm = {{20{instr[31]}},instr[31:20]};
                 opr_info = `CPU_INSTR_OPR_RS1 | `CPU_INSTR_OPR_RD | `CPU_INSTR_OPR_IMM;
            end
            `INSTR_TYPE_S:
            begin
                funct = {{7{1'b0}}, instr[14:12]};
                imm = {{20{instr[31]}},instr[31:25],instr[11:7]};
                opr_info = `CPU_INSTR_OPR_RS1 | `CPU_INSTR_OPR_RS2 | `CPU_INSTR_OPR_IMM;
            end
            `INSTR_TYPE_B:
            begin
                funct = {{7{1'b0}}, instr[14:12]};
                imm = {{20{instr[31]}},instr[7],instr[30:25],instr[11:8],{1'b0}};
                opr_info  = `CPU_INSTR_OPR_RS1 | `CPU_INSTR_OPR_RS2 | `CPU_INSTR_OPR_IMM;
            end
            `INSTR_TYPE_U:
            begin
                funct = `FUNCT_WIDTH'd0;
                imm = {instr[31:12],{12{1'b0}}};
                opr_info = `CPU_INSTR_OPR_RD | `CPU_INSTR_OPR_IMM;
            end
            `INSTR_TYPE_J:
            begin
                funct = `FUNCT_WIDTH'd0;
                imm = {{12{instr[31]}},instr[19:12],instr[20],instr[30:21],{1'b0}};
                opr_info = `CPU_INSTR_OPR_RD | `CPU_INSTR_OPR_IMM;
            end
            `INSTR_TYPE_R4:
            begin
                funct = {{5{1'b0}},instr[26:25],instr[14:12]};
                imm = `CPU_XLEN'd0;
                opr_info = `CPU_INSTR_OPR_RS1 | `CPU_INSTR_OPR_RS2 | `CPU_INSTR_OPR_RS3 | `CPU_INSTR_OPR_RD;
            end
            default:
            begin
                funct = `FUNCT_WIDTH'd0;
                imm = `CPU_XLEN'd0;
                opr_info = `CPU_INSTR_OPR_INVALID;
            end
        endcase
    end
endmodule