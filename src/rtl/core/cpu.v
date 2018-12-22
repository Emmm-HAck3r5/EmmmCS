`include "cpu_define.v"
`include "../memory/cpu_bus_define.v"
`include "alu_define.v"

// cpu status
`define STATUS_LEN 5
`define STATUS_INIT           `STATUS_LEN'd0
`define STATUS_FETCHING_INSTR `STATUS_LEN'd1
`define STATUS_DECODING_INSTR `STATUS_LEN'd2
`define STATUS_SET_FLAG       `STATUS_LEN'd3
`define STATUS_REG_WRITE_POST `STATUS_LEN'd4
`define STATUS_MEM_READ       `STATUS_LEN'd5
`define STATUS_MEM_READING    `STATUS_LEN'd6
`define STATUS_ALU            `STATUS_LEN'd7
`define STATUS_ALUING         `STATUS_LEN'd8
`define STATUS_REG_WRITE      `STATUS_LEN'd9
`define STATUS_MEM_WRITE      `STATUS_LEN'd10
`define STATUS_MEM_WRITING    `STATUS_LEN'd11
`define STATUS_BRANCH         `STATUS_LEN'd12
`define STATUS_ALU_2          `STATUS_LEN'd13
`define STATUS_INTR_OFF    `STATUS_LEN'd14
`define STATUS_INTR_HANDEL    `STATUS_LEN'd15
`define STATUS_INTR_KBD       `STATUS_LEN'd16



module cpu(
    input 		     [3:0]		KEY,
	input 		     [9:0]		SW,

	input clk,
    input clr_n,
    output reg cpu_clk,

    /////////////// LED ///////////////
	output 			[9:0]		LEDR,
	//////////// VGA //////////
	output		          		VGA_BLANK_N,
	output		    [7:0]		VGA_B,
	output		          		VGA_CLK,
	output		    [7:0]		VGA_G,
	output		          		VGA_HS,
	output		    [7:0]		VGA_R,
	output		          		VGA_SYNC_N,
	output		          		VGA_VS,
    //////////// PS2 //////////
	inout 		          		PS2_CLK,
	inout 		          		PS2_DAT,
    //////////// Seg7 //////////
	output		     [6:0]		HEX0,
	output		     [6:0]		HEX1,
	output		     [6:0]		HEX2,
	output		     [6:0]		HEX3,
	output		     [6:0]		HEX4,
	output		     [6:0]		HEX5
);

//=======================================================
//  REG/WIRE declarations
//=======================================================

//ps2
wire ps2_proc;
wire ps2_ready;
wire ps2_ovf;
wire [7:0] ps2_kbcode;
wire [7:0] scan2ascii_ascii;

// gregs
reg  gregs_wen;
wire [`CPU_GREGIDX_WIDTH-1:0] gregs_rs1_idx;
wire [`CPU_GREGIDX_WIDTH-1:0] gregs_rs2_idx;
wire [`CPU_GREGIDX_WIDTH-1:0] gregs_rd_idx;
wire [`CPU_XLEN-1:0] gregs_rs1_dat;
wire [`CPU_XLEN-1:0] gregs_rs2_dat;
reg  [`CPU_XLEN-1:0] gregs_rd_dat;
reg gregs_backup;
reg gregs_restore;

// alu
reg  [`CPU_XLEN-1:0] alu_src_A;
reg  [`CPU_XLEN-1:0] alu_src_B;
reg  [3:0] alu_select;
wire [63:0] alu_dest;
wire [3:0] alu_flags;
reg  alu_rst;
wire alu_ready;

// bus
reg  [25:0] bus_address;
wire [31:0] bus_rdata;
reg  [1:0]  bus_wlen;
reg  [31:0] bus_wdata;
reg  bus_en_n;
wire bus_ready;

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
// gRegs idx always be the decoding result
// assign gregs_rs1_idx = greg_back_flag ? greg_back_no[`CPU_GREGIDX_WIDTH-1:0] : decoder_rs1_idx;
// assign gregs_rs2_idx = decoder_rs2_idx;
// assign gregs_rd_idx  = greg_restore_flag ? greg_back_no : decoder_rd_idx;

assign gregs_rs1_idx = decoder_rs1_idx;
assign gregs_rs2_idx = decoder_rs2_idx;
assign gregs_rd_idx  = decoder_rd_idx;

// PC
reg [31:0] pc;
reg [31:0] pc_nxt;
reg [31:0] pc_back;
// flags
reg flag_alu;
reg flag_reg_write;
reg flag_mem_read;
reg flag_mem_write;
reg flag_branch;
// status
reg [`STATUS_LEN-1 : 0] status;

reg [`CPU_GREGIDX_WIDTH : 0] greg_back_no;
reg is_intring;
reg IF;

//=======================================================
//  Structural coding
//=======================================================
// scan to ascii
kbd_scan2ascii s2a(
	.address(ps2_kbcode),
	.clock(CLOCK_50),
	.q(scan2ascii_ascii)
);

// ps2 kbd
keyboard_ctrl kbd(
    .RST_N    (clr_n),
    .PROC     (ps2_proc),
    .READY    (ps2_ready),
    .OVERFLOW (ps2_ovf),
    .kbcode   (ps2_kbcode),
    .CLOCK_50 (clk),
    .PS2_CLK  (PS2_CLK),
    .PS2_DAT  (PS2_DAT)
);
assign ps2_proc = IF;

// gregs
cpu_gregs gregs(
    .clk     (clk),
    .rd_wen  (gregs_wen),
    .reset_n (clr_n),
    .rs1_idx (gregs_rs1_idx),
    .rs2_idx (gregs_rs2_idx),
    .rd_idx  (gregs_rd_idx),
    .rs1_dat (gregs_rs1_dat),
    .rs2_dat (gregs_rs2_dat),
    .rd_dat  (gregs_rd_dat),

    .backup(gregs_backup),
    .restore(gregs_restore),

    .HEX0(),
	.HEX1(),
	.HEX2(),
	.HEX3(),
	.HEX4(),
	.HEX5()
);

// alu
cpu_alu alu(
    .clk(clk),
    .src_A(alu_src_A),
    .src_B(alu_src_B),
    .select(alu_select),
    .dest(alu_dest),
    .flags(alu_flags),
    .RST(alu_rst),
    .READY(alu_ready)
);

// bus
cpu_bus bus(
    .clk(clk),
    .reset_n(clr_n),
    .address(bus_address),
    .wdata(bus_wdata),
    .WLEN(bus_wlen),
    .EN_N(bus_en_n),
    .READY(bus_ready),
    .rdata(bus_rdata),

    .LEDR(LEDR),
    .VGA_BLANK_N(VGA_BLANK_N),
    .VGA_B(VGA_B),
    .VGA_CLK(VGA_CLK),
    .VGA_G(VGA_G),
    .VGA_HS(VGA_HS),
    .VGA_R(VGA_R),
    .VGA_SYNC_N(VGA_SYNC_N),
    .VGA_VS(VGA_VS)
);

// decoder
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

//========================================
//  CSRs
//========================================

`define CSR_READ  3'b001
`define CSR_WRITE 3'b010

`define CSR_MTVEC 3'h305
`define CSR_MIE 3'h304
`define CSR_MCAUSE 3'h342
`define CSR_MSCRATCH 3'h340

reg [`CPU_XLEN-1 : 0] csr_mtvec;
reg [`CPU_XLEN-1 : 0] csr_mie;
reg [`CPU_XLEN-1 : 0] csr_mcause;
reg [`CPU_XLEN-1 : 0] csr_mscratch;

//========================================
//
//========================================

/////////////////////////////////////////

seg7_h s0(
    .en(1'b1),
    .in(pc[3:0]),
    .hex(HEX0)
);

seg7_h s1(
    .en(1'b1),
    .in(pc[7:4]),
    .hex(HEX1)
);

seg7_h s2(
    .en(1'b1),
    .in(pc[11:8]),
    .hex(HEX2)
);

seg7_h s3(
    .en(1'b1),
    .in(alu_src_A[3:0]),
    .hex(HEX3)
);

seg7_h s4(
    .en(1'b1),
    .in(alu_src_B[3:0]),
    .hex(HEX4)
);

seg7_h s5(
   .en(1'b1),
   .in(alu_dest[3:0]),
   .hex(HEX5)
);

// assign LEDR[0] = bus_wlen[0];
// assign LEDR[1] = bus_wlen[1];
// assign LEDR[2] = bus_en_n;
// assign LEDR[3] = bus_ready;
// assign LEDR[6:4] = decoder_funct[2:0];
////////////////////////////////////////

wire clk_1s;
clkgen_module #(2500000) cursorclk(.clkin(clk), .rst(~clr_n), .clken(1'b1), .clkout(clk_1s));

wire clk_real;
assign clk_real = clk_1s;
// main logic
always @(posedge clk_real) begin
    if (!KEY[0]) begin
        pc     <= 0;
        status <= `STATUS_INIT;
        gregs_wen <= 0;
        alu_rst <= 0;
        cpu_clk <= 0;
        is_intring <= 0;
        IF = 0;
    end else begin
        case(status)
            `STATUS_INIT: begin
            if (SW[0]) begin
                status <= `STATUS_INIT;
            end else begin
                gregs_restore <= 0;
                flag_alu   <= 0;
                flag_reg_write  <= 0;
                flag_mem_read   <= 0;
                flag_mem_write  <= 0;
                flag_branch     <= 0;
                cpu_clk <= 0;
                if (is_intring == 0 && IF == 1) begin
                    gregs_backup <= 1;
                    pc_back = pc;
                    status = `STATUS_INTR_HANDEL;
                    is_intring = 1;
                    flag_branch <= 1;
                    pc_nxt = csr_mtvec;
                    // TODO: Add data to CSR
                end else begin
                    gregs_backup <= 0;
                    status <= `STATUS_FETCHING_INSTR;
                end
            end
            end
            `STATUS_FETCHING_INSTR: begin
                cpu_clk <= 1;
                bus_address <= pc;
                bus_wlen    <= `BUS_READ_32;
                bus_en_n      <= `BUS_RUN;
                status <= `STATUS_DECODING_INSTR;
            end
            `STATUS_DECODING_INSTR: begin
                bus_en_n <= 1;
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
                            pc_nxt <= (decoder_imm + pc) & {{31{1'b1}}, 1'b0};
                            case (decoder_funct[2:0])
                                3'b000:  flag_branch <= (gregs_rs1_dat == gregs_rs2_dat);
                                3'b001:  flag_branch <= (gregs_rs1_dat != gregs_rs2_dat);
                                3'b100:  flag_branch <= (gregs_rs1_dat[31] >  gregs_rs2_dat[31]) ||
                                                        ((gregs_rs1_dat[31] == gregs_rs2_dat[31]) &&
                                                         (gregs_rs1_dat     <  gregs_rs2_dat));
                                // 3'b101:  flag_branch <= (gregs_rs1_dat[31] <= gregs_rs2_dat[31]) &&
                                //                         ((gregs_rs1_dat[31] != gregs_rs2_dat[31]) ||
                                //                          (gregs_rs1_dat     >= gregs_rs2_dat));
                                3'b101: flag_branch <=  !((gregs_rs1_dat[31] >  gregs_rs2_dat[31]) ||
                                                        ((gregs_rs1_dat[31] == gregs_rs2_dat[31]) &&
                                                         (gregs_rs1_dat     <  gregs_rs2_dat)));
                                3'b110: flag_branch <= (gregs_rs1_dat <  gregs_rs2_dat);
                                3'b111: flag_branch <= (gregs_rs1_dat >= gregs_rs2_dat);
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
                            bus_wdata <= gregs_rs2_dat;
                            case (decoder_funct[2:0])
                                3'b000: bus_wlen <= `BUS_WRITE_8;
                                3'b001: bus_wlen <= `BUS_WRITE_16;
                                3'b010: bus_wlen <= `BUS_WRITE_32;
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
                            status <= `STATUS_INIT;
                            //NOT SUPPORT
                        end
                        `CPU_INSTR_GRP_E_CSR:  begin
                            case(decoder_funct[2:0])
                                3'b000: begin
                                    is_intring <= 0;
                                    gregs_restore <= 1;
                                    pc <= pc_back;
                                    pc_nxt <= pc_back;
                                    flag_branch <= 1;
                                    status <= `STATUS_INTR_OFF;
                                end
                                `CSR_READ: begin
                                    flag_reg_write <= 1;
                                    status <= `STATUS_REG_WRITE;
                                    case(decoder_imm[11:0])
                                        `CSR_MCAUSE:
                                            gregs_rd_dat <= csr_mcause;
                                        `CSR_MIE:
                                            gregs_rd_dat <= {31'b0, IF};
                                        `CSR_MTVEC:
                                            gregs_rd_dat <= csr_mtvec;
                                        `CSR_MSCRATCH:
                                            gregs_rd_dat <= 32'h35;
                                            // gregs_rd_dat <= csr_mscratch;
                                        default:
                                            gregs_rd_dat <= 32'b0;
                                    endcase
                                end
                                `CSR_WRITE: begin
                                    status <= `STATUS_BRANCH;
                                    case(decoder_imm[11:0])
                                        `CSR_MCAUSE:
                                            csr_mcause <= gregs_rs1_dat;
                                        `CSR_MIE:
                                            IF <= gregs_rs1_dat[0];
                                        `CSR_MTVEC:
                                            csr_mtvec <= gregs_rs1_dat;
                                        `CSR_MSCRATCH:
                                            csr_mscratch <= gregs_rs1_dat;
                                    endcase
                                end

                                default:
                                    status = `STATUS_BRANCH;
                            endcase
                        end
                        `CPU_INSTR_GRP_MULDIV: begin
                            flag_alu <= 1;
                            flag_reg_write <= 1;
                            alu_src_A <= gregs_rs1_dat;
                            alu_src_B <= gregs_rs2_dat;
                            case (decoder_funct[2:0])
                                3'b000: // MUL
                                    alu_select <= `ALU_MUL;
                                3'b001: // MULH
                                    alu_select <= `ALU_MULU;
                                3'b010: // MULHSU
                                    alu_select <= `ALU_MULSU;
                                3'b011: // MULHU
                                    alu_select <= `ALU_MULU;
                                3'b100: // DIV
                                    alu_select <= `ALU_DIV;
                                3'b101: // DIVU
                                    alu_select <= `ALU_DIVU;
                                3'b110: // REM
                                    alu_select <= `ALU_REM;
                                3'b111: // REMU
                                    alu_select <= `ALU_REMU;
                            endcase
                            status <= `STATUS_ALU;
                        end
                    endcase
                end else begin
                    status <= `STATUS_BRANCH;
                end
            end

            `STATUS_MEM_READ:   begin
                if (flag_mem_read) begin
                    bus_en_n = 0;
                    status = `STATUS_MEM_READING;
                end else begin
                    status <= `STATUS_ALU;
                end
            end
            `STATUS_MEM_READING:    begin
                bus_en_n = 1;
                if (flag_mem_read) begin
                    if (bus_ready == `BUS_STOP) begin
                        case (decoder_funct[2:0])
                            3'b000:
                                if (bus_address[0] == 0)
                                    gregs_rd_dat <= (bus_rdata[7] == 0) ?
                                            {{24{1'b0}}, bus_rdata[7:0]} :
                                            {{24{1'b1}}, bus_rdata[7:0]};
                                else
                                    gregs_rd_dat <= (bus_rdata[15] == 0) ?
                                            {{24{1'b0}}, bus_rdata[15:8]} :
                                            {{24{1'b1}}, bus_rdata[15:8]};

                            3'b001: gregs_rd_dat <= (bus_rdata[15] == 0) ?
                                            {{16{1'b0}}, bus_rdata[15:0]} :
                                            {{16{1'b1}}, bus_rdata[15:0]};

                            3'b010: gregs_rd_dat <= bus_rdata;

                            3'b100:
                                if (bus_address[0] == 0)
                                    gregs_rd_dat <= {{24{1'b0}}, bus_rdata[7:0]};
                                else
                                    gregs_rd_dat <= {{24{1'b0}}, bus_rdata[15:8]};

                            3'b101: gregs_rd_dat <= {{16{1'b0}}, bus_rdata[15:0]};
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
                    alu_rst = 1;
                    status = `STATUS_ALU_2;
                end else begin
                    status <= `STATUS_REG_WRITE;
                end
            end
            `STATUS_ALU_2:  begin
                if (flag_alu == 1) begin
                    alu_rst = 0;
                    status = `STATUS_ALUING;
                end else begin
                    status <= `STATUS_REG_WRITE;
                end
            end
            `STATUS_ALUING: begin
                if (flag_alu == 1) begin
                    if (alu_ready == 1) begin
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
                    gregs_wen = 1;
                end
                status <= `STATUS_REG_WRITE_POST;
            end
            `STATUS_REG_WRITE_POST:   begin
                gregs_wen = 0;
                status <= `STATUS_BRANCH;
            end
            `STATUS_MEM_WRITE:  begin
                if (flag_mem_write) begin
                    bus_en_n = 0;
                    status = `STATUS_MEM_WRITING;
                end else begin
                    status <= `STATUS_BRANCH;
                end
            end
            `STATUS_MEM_WRITING:    begin
                bus_en_n = 1;
                if (flag_mem_write) begin
                    if (bus_ready == 1) begin
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
            `STATUS_INTR_OFF: begin
                gregs_restore <= 0;
                status <= `STATUS_BRANCH;
            end
            `STATUS_INTR_HANDEL: begin
                gregs_backup <= 0;
                csr_mcause <= 1;
                csr_mscratch <= 32'h33;
                status <= `STATUS_BRANCH;
            end
            `STATUS_INTR_KBD: begin
                status <= `STATUS_BRANCH;
            end
            default: begin
                status = `STATUS_INIT;
            end
        endcase
    end
end


endmodule
