`include "cpu_define.v"

//status
`define STATUS_LEN 4
`define STATUS_INIT           `STATUS_LEN'h0
`define STATUS_FETCHING_INSTR `STATUS_LEN'h1
`define STATUS_DECODING_INSTR `STATUS_LEN'h2
`define STATUS_SET_FLAG       `STATUS_LEN'h3
`define STATUS_MEM_READ       `STATUS_LEN'h5
`define STATUS_MEM_READING    `STATUS_LEN'h6
`define STATUS_ALU            `STATUS_LEN'h7
`define STATUS_ALUING         `STATUS_LEN'h8
`define STATUS_REG_WRITE      `STATUS_LEN'h9
`define STATUS_REG_WRITE_POST `STATUS_LEN'h4
`define STATUS_MEM_WRITE      `STATUS_LEN'h10
`define STATUS_MEM_WRITING    `STATUS_LEN'h11
`define STATUS_BRANCH         `STATUS_LEN'h12

//bus
`define BUS_RUN      1'b0
`define BUS_STOP     1'b1
`define BUS_READ_32  2'b00
`define BUS_WRITE_8  2'b01
`define BUS_WRITE_16 2'b10
`define BUS_WRITE_32 2'b11

//alu
`define ALU_RUN      1'b0
`define ALU_STOP     1'b1
`define ALU_WIDTH    4
`define ALU_ADD    `ALU_WIDTH'b0000
`define ALU_SUB    `ALU_WIDTH'b0001
`define ALU_AND    `ALU_WIDTH'b0010
`define ALU_OR     `ALU_WIDTH'b0011
`define ALU_XOR    `ALU_WIDTH'b0100
`define ALU_SLL    `ALU_WIDTH'b0101
`define ALU_SRL    `ALU_WIDTH'b0110
`define ALU_SRA    `ALU_WIDTH'b0111
`define ALU_MUL    `ALU_WIDTH'b1000
`define ALU_MULU   `ALU_WIDTH'b1001
`define ALU_MULSU  `ALU_WIDTH'b1010
`define ALU_DIV    `ALU_WIDTH'b1011
`define ALU_DIVU   `ALU_WIDTH'b1100
`define ALU_REM    `ALU_WIDTH'b1101
`define ALU_REMU   `ALU_WIDTH'b1110
`define ALU_NOP    `ALU_WIDTH'b1111

//bcc
`define INSTR_BCC_EQ  3'b000
`define INSTR_BCC_NE  3'b001
`define INSTR_BCC_LT  3'b100
`define INSTR_BCC_GE  3'b101
`define INSTR_BCC_LTU 3'b110
`define INSTR_BCC_GEU 3'b111

// load / store
`define INSTR_LB  3'b000
`define INSTR_LH  3'b001
`define INSTR_LW  3'b010
`define INSTR_LBU 3'b100
`define INSTR_LHU 3'b101
`define INSTR_SB  3'b000
`define INSTR_SH  3'b001
`define INSTR_SW  3'b010

// alu_instr


module cpu_instr_exec(
    input clk,
    input clr,
    output reg cpu_clk
);

// gregs
reg  gregs_wen;
wire [`CPU_GREGIDX_WIDTH-1:0] gregs_rs1_idx;
wire [`CPU_GREGIDX_WIDTH-1:0] gregs_rs2_idx;
wire [`CPU_GREGIDX_WIDTH-1:0] gregs_rd_idx;
wire [`CPU_XLEN-1:0] gregs_rs1_dat;
wire [`CPU_XLEN-1:0] gregs_rs2_dat;
reg  [`CPU_XLEN-1:0] gregs_rd_dat;
cpu_gregs gregs(
    .clk(clk),
    .rd_wen(gregs_wen),
    .rs1_idx(gregs_rs1_idx),
    .rs2_idx(gregs_rs2_idx),
    .rd_idx(gregs_rd_idx),
    .rs1_dat(gregs_rs1_dat),
    .rs2_dat(gregs_rs2_dat),
    .rd_dat(gregs_rd_dat)
);

// alu
reg  [`CPU_XLEN-1:0] alu_src_A;
reg  [`CPU_XLEN-1:0] alu_src_B;
reg  [3:0] alu_select;
wire [63:0] alu_dest;
wire [3:0] alu_flags;
reg  alu_ready;
reg  alu_ready_yn;
wire alu_ready_wire;
assign alu_ready_wire = alu_ready_yn ? alu_ready : alu_ready_wire;
cpu_alu alu(
    .src_A(alu_src_A),
    .src_B(alu_src_B),
    .select(alu_select),
    .dest(alu_dest),
    .flags(alu_flags),
    .READY(alu_ready_wire)//Dangerous InOut Port
);

// bus
reg  [25:0] bus_address;
wire [31:0] bus_rdata;
reg  [1:0]  bus_wlen;
reg  [31:0] bus_wdata;
reg  bus_ready;
reg  bus_ready_yn;
wire bus_ready_wire;
assign bus_ready_wire = bus_ready_yn ? bus_ready : bus_ready_wire;
cpu_bus_ctrl bus_ctrl(
    .clk(clk),
    .address(bus_address),
    .wdata(bus_wdata),
    .WLEN(bus_wlen),
    .rdata(bus_rdata),
    .READY(bus_ready_wire)
);

// decoder
reg  [`CPU_INSTR_LENGTH-1 : 0] decoder_instr;
wire [`CPU_GREGIDX_WIDTH-1 : 0] decoder_rs1_idx;
wire [`CPU_GREGIDX_WIDTH-1 : 0] decoder_rs2_idx;
wire [`CPU_GREGIDX_WIDTH-1 : 0] decoder_rs3_idx;
wire [`CPU_GREGIDX_WIDTH-1 : 0] decoder_rd_idx;
wire [`CPU_XLEN-1 : 0] decoder_imm;
wire [`FUNCT_WIDTH-1 : 0] decoder_funct;
wire [`OPCODE_WIDTH-1 : 0] decoder_opcode;
wire [`CPU_INSTR_DECODE_INFO_WIDTH-1 : 0] decoder_dec_instr_info;
wire decoder_instr_valid;
wire decoder_fp_rm;
wire decoder_fp_width;
wire decoder_fp_fmt;
cpu_instr_decoder decoder(
    .instr(decoder_instr),
    .rs1_idx(decoder_rs1_idx),
    .rs2_idx(decoder_rs2_idx),
    .rs3_idx(decoder_rs3_idx),
    .rd_idx(decoder_rd_idx),
    .imm(decoder_imm),
    .funct(decoder_funct),
    .opcode(decoder_opcode),
    .dec_instr_info(decoder_dec_instr_info),
    .instr_valid(decoder_instr_valid),
    .fp_rm(decoder_fp_rm),
    .fp_width(decoder_fp_width),
    .fp_fmt(decoder_fp_fmt)
);

assign gregs_rs1_idx = decoder_rs1_idx;
assign gregs_rs2_idx = decoder_rs2_idx;
assign gregs_rd_idx  = decoder_rd_idx;

// main logic
reg [31:0] pc;
reg [31:0] pc_nxt;
reg flag_alu;
reg flag_reg_write;
reg flag_mem_read;
reg flag_mem_write;
reg flag_branch;

reg [`STATUS_LEN-1 : 0] status;
always @(posedge clk) begin
    if (clr) begin
        pc     <= 0;
        status <= `STATUS_INIT;
        gregs_wen <= 0;
        alu_ready <= `ALU_STOP;
        bus_ready <= `BUS_STOP;
        alu_ready_yn <= 1;
        bus_ready_yn <= 1;
        cpu_clk <= 0;
    end else begin
        case(status)
            `STATUS_INIT: begin
                status <= `STATUS_FETCHING_INSTR;
                flag_alu   <= 0;
                flag_reg_write  <= 0;
                flag_mem_read   <= 0;
                flag_mem_write  <= 0;
                flag_branch     <= 0;
                cpu_clk <= 0;
            end
            `STATUS_FETCHING_INSTR: begin
                cpu_clk <= 1;
                bus_address <= pc;
                bus_wlen    <= `BUS_READ_32;
                bus_ready   <= `BUS_RUN;
                status <= `STATUS_DECODING_INSTR;
            end
            `STATUS_DECODING_INSTR: begin
                if (bus_ready == `BUS_STOP) begin
                    decoder_instr <= bus_rdata;
                    status <= `STATUS_SET_FLAG;
                end else begin
                    status <= `STATUS_DECODING_INSTR;
                end
            end
            `STATUS_SET_FLAG: begin
                if (decoder_instr_valid) begin
                    case (decoder_dec_instr_info[`CPU_INSTR_INFO_WIDTH+`CPU_INSTR_OPR_INFO_WIDTH-1 : `CPU_INSTR_OPR_INFO_WIDTH])
                        `CPU_INSTR_GRP_LUI: begin
                            flag_reg_write <= 1;
                            gregs_rd_dat   <= decoder_imm;
                            status <= `STATUS_REG_WRITE;
                        end
                        `CPU_INSTR_GRP_AUIPC: begin
                            flag_reg_write <= 1;
                            flag_branch    <= 1;
                            gregs_rd_dat   <= decoder_imm + pc;
                            pc_nxt         <= decoder_imm + pc;
                            status <= `STATUS_REG_WRITE;
                        end
                        `CPU_INSTR_GRP_JAL:    begin
                            flag_reg_write <= 1;
                            flag_branch    <= 1;
                            gregs_rd_dat   <= pc + 4;
                            pc_nxt         <= decoder_imm + pc;
                            status <= `STATUS_REG_WRITE;
                        end
                        `CPU_INSTR_GRP_JALR:   begin
                            flag_reg_write <= 1;
                            flag_branch    <= 1;
                            gregs_rd_dat   <= pc + 4;
                            pc_nxt         <= (decoder_imm + gregs_rs1_dat) & {{31{1'b1}}, 1'b0};
                            status <= `STATUS_REG_WRITE;
                        end
                        `CPU_INSTR_GRP_BCC:    begin
                            pc_nxt <= (decoder_imm + gregs_rs1_dat) & {{31{1'b1}}, 1'b0};
                            case (decoder_funct[2:0])
                                `INSTR_BCC_EQ:  flag_branch <= (gregs_rs1_dat == gregs_rs2_dat);
                                `INSTR_BCC_NE:  flag_branch <= (gregs_rs1_dat != gregs_rs2_dat);
                                `INSTR_BCC_LT:  flag_branch <= (gregs_rs1_dat[31] >  gregs_rs2_dat[31]) ||
                                                        ((gregs_rs1_dat[31] == gregs_rs2_dat[31]) &&
                                                         (gregs_rs1_dat     <  gregs_rs2_dat));
                                `INSTR_BCC_GE:  flag_branch <= (gregs_rs1_dat[31] <= gregs_rs2_dat[31]) &&
                                                        ((gregs_rs1_dat[31] != gregs_rs2_dat[31]) ||
                                                         (gregs_rs1_dat     >= gregs_rs2_dat));
                                `INSTR_BCC_LTU: flag_branch <= (gregs_rs1_dat <  gregs_rs2_dat);
                                `INSTR_BCC_GEU: flag_branch <= (gregs_rs1_dat >= gregs_rs2_dat);
                                default:  flag_branch <= 0;
                            endcase
                            status <= `STATUS_BRANCH;
                        end
                        `CPU_INSTR_GRP_LOAD:   begin
                            flag_mem_read  <= 1;
                            flag_reg_write <= 1;
                            bus_address    <= gregs_rs1_dat + decoder_imm;
                            bus_wlen       <= `BUS_READ_32;
                            status <= `STATUS_MEM_READ;
                        end
                        `CPU_INSTR_GRP_STORE:  begin
                            flag_mem_write <= 1;
                            bus_address    <= gregs_rs1_dat + decoder_imm;
                            case (decoder_funct[2:0])
                                `INSTR_SB: bus_wlen <= `BUS_WRITE_8;
                                `INSTR_SH: bus_wlen <= `BUS_WRITE_16;
                                `INSTR_SW: bus_wlen <= `BUS_WRITE_32;
                            endcase
                            status <= `STATUS_MEM_WRITE;
                        end
                        `CPU_INSTR_GRP_ALUI:   begin
                            flag_alu   <= (decoder_funct[2:0] == 3'b010 || decoder_funct[2:0] == 3'b011) ? 0 : 1;
                            flag_reg_write <= 1;
                            alu_src_A  <= gregs_rs1_dat;
                            alu_src_B  <= (decoder_funct[2:0] == 3'b001 || decoder_funct[2:0] == 3'b101) ? {27'd0, decoder_imm[4:0]} : decoder_imm;
                            case (decoder_funct[2:0])
                                3'b000: alu_select <= `ALU_ADD;
                                3'b010: gregs_rd_dat <= (gregs_rs1_dat[31] >  decoder_imm[31]) ||
                                                       ((gregs_rs1_dat[31] == decoder_imm[31]) &&
                                                        (gregs_rs1_dat     <  decoder_imm));
                                3'b011: gregs_rd_dat <= (gregs_rs1_dat < decoder_imm);
                                3'b100: alu_select <= `ALU_XOR;
                                3'b110: alu_select <= `ALU_OR;
                                3'b111: alu_select <= `ALU_AND;
                                3'b001: alu_select <= `ALU_SLL;
                                3'b101: alu_select <= decoder_imm[10] == 0 ? `ALU_SRL : `ALU_SRA;
                            endcase
                            status <= `STATUS_ALU;
                        end
                        `CPU_INSTR_GRP_ALU:    begin
                            flag_alu <= (decoder_funct[2:0] == 3'b010 || decoder_funct[2:0] == 3'b011) ? 0 : 1;
                            flag_reg_write <= 1;
                            alu_src_A <= gregs_rs1_dat;
                            alu_src_B <= (decoder_funct[2:0] == 3'b001 || decoder_funct[2:0] == 3'b101) ? {27'd0, gregs_rs2_dat[4:0]} : gregs_rs2_dat;
                            case (decoder_funct[2:0])
                                3'b000: alu_select <= (decoder_funct[8] == 0) ? `ALU_ADD : `ALU_SUB;
                                3'b010: gregs_rd_dat <= (gregs_rs1_dat[31] >  gregs_rs2_dat[31]) ||
                                                       ((gregs_rs1_dat[31] == gregs_rs2_dat[31]) &&
                                                        (gregs_rs1_dat     <  gregs_rs2_dat));
                                3'b011: gregs_rd_dat <= (gregs_rs1_dat < gregs_rs2_dat);
                                3'b100: alu_select <= `ALU_XOR;
                                3'b110: alu_select <= `ALU_OR;
                                3'b111: alu_select <= `ALU_AND;
                                3'b001: alu_select <= `ALU_SLL;
                                3'b101: alu_select <= (decoder_funct[8] == 0) ? `ALU_SRL : `ALU_SRA;
                            endcase
                            status <= `STATUS_ALU;
                        end
                        `CPU_INSTR_GRP_FENCE:  begin
                            //TODO
                        end
                        `CPU_INSTR_GRP_E_CSR:  begin
                            //TODO
                        end
                        `CPU_INSTR_GRP_MULDIV: begin
                            //TODO()
                        end
                    endcase
                end else begin
                    status <= `STATUS_SET_FLAG;
                end
            end

            `STATUS_MEM_READ:   begin
                if (flag_mem_read) begin
                    bus_ready = `BUS_RUN;
                    status = `STATUS_MEM_READING;
                    bus_ready_yn = 0;
                end else begin
                    status <= `STATUS_ALU;
                end
            end
            `STATUS_MEM_READING:    begin
                if (flag_mem_read) begin
                    if (bus_ready_wire == `BUS_STOP) begin
                        case (decoder_funct[2:0])
                            `INSTR_LB:  gregs_rd_dat <= (bus_rdata[7] == 0) ?
                                            {{24{1'b0}}, bus_rdata[7:0]} :
                                            {{24{1'b1}}, bus_rdata[7:0]};
                            `INSTR_LH:  gregs_rd_dat <= (bus_rdata[15] == 0) ?
                                            {{16{1'b0}}, bus_rdata[15:0]} :
                                            {{16{1'b1}}, bus_rdata[15:0]};
                            `INSTR_LW:  gregs_rd_dat <= bus_rdata;
                            `INSTR_LBU: gregs_rd_dat <= {{24{1'b0}}, bus_rdata[7:0]};
                            `INSTR_LHU: gregs_rd_dat <= {{16{1'b0}}, bus_rdata[15:0]};
                        endcase
                        status <= `STATUS_REG_WRITE;
                    end else begin
                        status <= `STATUS_MEM_READING;
                    end
                end else begin
                    status <= `STATUS_ALU;
                end
            end
            `STATUS_ALU:    begin
                if (flag_alu == 1) begin
                    alu_ready = `ALU_RUN;
                    status = `STATUS_ALUING;
                    alu_ready_yn = 0;
                end else begin
                    status <= `STATUS_REG_WRITE;
                end
            end
            `STATUS_ALUING: begin
                if (flag_alu == 1) begin
                    if (alu_ready_wire == `ALU_STOP) begin
                        gregs_rd_dat <= alu_dest[31:0];
                        status <= `STATUS_REG_WRITE;
                    end else begin
                        status <= `STATUS_ALUING;
                    end
                end else begin
                    status <= `STATUS_REG_WRITE;
                end
            end
            `STATUS_REG_WRITE:  begin
                if (flag_reg_write) begin
                    gregs_wen <= 1;
                end
                status <= `STATUS_REG_WRITE_POST;
            end
            `STATUS_REG_WRITE_POST:   begin
                gregs_wen <= 0;
                status <= `STATUS_BRANCH;
            end
            `STATUS_MEM_WRITE:  begin
                if (flag_mem_write) begin
                    bus_ready = `BUS_RUN;
                    status = `STATUS_MEM_WRITING;
                    bus_ready_yn = 0;
                end else begin
                    status <= `STATUS_BRANCH;
                end
            end
            `STATUS_MEM_WRITING:    begin
                if (flag_mem_write) begin
                    if (bus_ready_wire == `BUS_STOP) begin
                        status <= `STATUS_BRANCH;
                    end else begin
                        status <= `STATUS_MEM_WRITING;
                    end
                end else begin
                    status <= `STATUS_BRANCH;
                end
            end
            `STATUS_BRANCH: begin
                if (flag_branch) begin
                    pc <= pc_nxt;
                end else begin
                    pc <= pc + 4;
                end
                status <= `STATUS_INIT;
            end
            default: begin
                status = `STATUS_INIT;
            end
        endcase
    end
end

endmodule