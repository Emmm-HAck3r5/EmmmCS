`include "cpu_define.v"
`define STATUS_LEN 3
`define STATUS_FETCH_INSTR `STATUS_LEN'd0
`define STATUS_DECODE_INSTR `STATUS_LEN'd1
`define STATUS_DECODE_DONE `STATUS_LEN'd2
`define STATUS_GREG_WRITE_END `STATUS_LEN'd3
`define STATUS_ALU `STATUS_LEN'd4
`define STATUS_MEMIO `STATUS_LEN'd5
`define STATUS_GREG_WRITE `STATUS_LEN'd6
`define STATUS_BRANCH `STATUS_LEN'd7

module cpu_instr_exec(
    input clk,
    input clr
);

// regs
reg [31:0] pc;

// gregs
reg gregs_wen;
wire [`CPU_GREGIDX_WIDTH-1:0] gregs_rs1_idx;
wire [`CPU_GREGIDX_WIDTH-1:0] gregs_rs2_idx;
wire [`CPU_GREGIDX_WIDTH-1:0] gregs_rd_idx;
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
    .clk(clk),
    .address(bus_address),
    .wdata(bus_wdata),
    .WLEN(bus_wlen),
    .rdata(bus_rdata),
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
reg [`CPU_INSTR_DECODE_INFO_WIDTH-1 : 0] decoder_dec_instr_info;
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
    .dec_instr_info(decoder_dec_instr_info)
    .instr_valid(decoder_instr_valid)
    .fp_rm(decoder_fp_rm)
    .fp_width(decoder_fp_width)
    .fp_fmt(decoder_fp_fmt)
);

assign gregs_rs1_idx = decoder_rs1_idx;
assign gregs_rs2_idx = decoder_rs2_idx;
assign gregs_rd_idx  = decoder_rd_idx;

// main logic
reg [`STATUS_LEN-1 : 0] status;
reg [31:0] pc_nxt;
always @(posedge clk) begin
    if (clr) begin
        pc = 0;
        status = 0;
        gregs_wen = 0;
        alu_ready = 1;
        bus_ready = 1;
    end else begin
        case(status)
            `STATUS_FETCH_INSTR: begin
                bus_address <= pc;
                bus_wlen <= 2'b11;
                bus_ready <= 1'b0;
                status <= `STATUS_DECODE_INSTR;
            end
            `STATUS_DECODE_INSTR: begin
                if (bus_ready) begin
                    pc <= pc + 4;
                    decoder_instr <= bus_rdata;
                    status <= `STATUS_DECODE_DONE;
                end else begin
                    pc <= pc;
                    status <= `STATUS_DECODE_INSTR;
                end
            end
            `STATUS_DECODE_DONE: begin
                if (decoder_instr_valid) begin
                    case (decoder_dec_instr_info[`CPU_INSTR_INFO_WIDTH+`CPU_INSTR_OPR_INFO_WIDTH-1 : `CPU_INSTR_OPR_INFO_WIDTH])
                        `CPU_INSTR_GRP_LUI: begin
                            gregs_rd_dat <= decoder_imm;
                            gregs_wren = 1;
                            status <= STATUS_GREG_WRITE_END;
                        end
                        `CPU_INSTR_GRP_AUIPC: begin
                            gregs_rd_dat <= decoder_imm;
                            gregs_wren = 1;
                            status <= STATUS_GREG_WRITE_END;
                            //TODO
                        end
                        `CPU_INSTR_GRP_JAL    begin
                            //TODO
                        end
                        `CPU_INSTR_GRP_JALR   begin
                            //TODO
                        end
                        `CPU_INSTR_GRP_BCC    begin
                            //TODO
                        end
                        `CPU_INSTR_GRP_LOAD   begin
                            //TODO
                        end
                        `CPU_INSTR_GRP_STORE  begin
                            //TODO
                        end
                        `CPU_INSTR_GRP_ALUI   begin
                            //TODO
                        end
                        `CPU_INSTR_GRP_ALU    begin
                            //TODO
                        end
                        `CPU_INSTR_GRP_FENCE  begin
                            //TODO
                        end
                        `CPU_INSTR_GRP_E_CSR  begin
                            //TODO
                        end
                        `CPU_INSTR_GRP_MULDIV begin
                            //TODO()
                        end
                    endcase
                end else begin
                    status <= `STATUS_DECODE_DONE;
                end
            end
            `STATUS_GREG_WRITE: begin
                //TODO()
            end
            `STATUS_ALU: begin
                //TODO()
            end
            `STATUS_MEMIO: begin
                //TODO()
            end
            `STATUS_GREG_WRITE_END: begin
                gregs_wren <= 0;
                status <= STATUS_FETCH_INSTR;
            end
            `STATUS_BRANCH: begin
                //TODO()
            end
            default: begin
                status = `STATUS_INIT;
            end
        endcase
    end
end

endmodule