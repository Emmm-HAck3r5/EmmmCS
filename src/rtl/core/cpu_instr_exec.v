`include "cpu_define.v"

module cpu_instr_exec(
    input clk,
    input clr
);

// regs
reg [31:0] pc;

// gregs
reg gregs_wen;
reg [`CPU_GREGIDX_WIDTH-1:0] gregs_rs1_idx;
reg [`CPU_GREGIDX_WIDTH-1:0] gregs_rs2_idx;
reg [`CPU_GREGIDX_WIDTH-1:0] gregs_rd_idx;
reg [`CPU_XLEN-1:0] gregs_rs1_dat;
reg [`CPU_XLEN-1:0] gregs_rs2_dat;
reg [`CPU_XLEN-1:0] gregs_rd_dat;

cpu_gregs gregs(
    .clk(clk),
    .rd_wen(gregs_wen),
    .rs1_idx(gregs_rs1_idx),
    .rs2_idx(gregs_rs2_idx),
    .rd_idx(gregs_rd_idx),
    rs1_dat(gregs_rs1_dat),
    rs2_dat(gregs_rs2_dat),
    rd_dat(gregs_rd_dat)
);

// alu
reg [`CPU_XLEN-1:0] alu_src_A;
reg [`CPU_XLEN-1:0] alu_src_B;
reg [3:0] alu_select;
reg [63:0] alu_dest;
reg [3:0] alu_flags;
reg alu_ready;

cpu_alu alu(
    .src_A(alu_src_A),
    .src_B(alu_src_B),
    .select(alu_select),
    .dest(alu_dest),
    .flags(alu_flags),
    .READY(alu_ready)
);

// bus
reg [25:0] bus_address;
reg [31:0] bus_rdata;
reg [1:0] bus_wlen;
reg [31:0] bus_wdata;
reg bus_ready;

cpu_bus_ctrl bus_ctrl(
    .address(bus_address),
    .rdata(bus_rdata),
    .WLEN(bus_wlen),
    .wdata(bus_wdata),
    .READY(bus_ready)
);

// decoder
reg [`CPU_INSTR_LENGTH-1 : 0] decoder_instr;
reg [`CPU_GREGIDX_WIDTH-1 : 0] decoder_rs1_idx;
reg [`CPU_GREGIDX_WIDTH-1 : 0] decoder_rs2_idx;
reg [`CPU_GREGIDX_WIDTH-1 : 0] decoder_rs3_idx;
reg [`CPU_GREGIDX_WIDTH-1 : 0] decoder_rd_idx;
reg [`CPU_XLEN-1 : 0] decoder_imm;
reg [`FUNCT_WIDTH-1 : 0] decoder_funct;
reg [`OPCODE_WIDTH-1 : 0] decoder_opcode;
reg [`CPU_INSTR_DECODE_INFO_WIDTH-1 : 0] decoder_instr_info;
reg decoder_instr_valid;
reg decoder_fp_rm;
reg decoder_fp_width;
reg decoder_fp_fmt;

cpu_instr_decoder decoder(
    .instr(decoder_instr)
    .rs1_idx(decoder_rs1_idx)
    .rs2_idx(decoder_rs2_idx)
    .rs3_idx(decoder_rs3_idx)
    .rd_idx(decoder_rd_idx)
    .imm(decoder_imm)
    .funct(decoder_funct)
    .opcode(decoder_opcode)
    .dec_instr_info(decoder_instr_info)
    .instr_valid(decoder_instr_valid)
    .fp_rm(decoder_fp_rm)
    .fp_width(decoder_fp_width)
    .fp_fmt(decoder_fp_fmt)
);

endmodule