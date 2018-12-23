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
  File: yamm.v
  Project: EmmmCS
  File Created: 2018-12-22 12:57:31
  Author: Chen Haodong (easyai@outlook.com)
  --------------------------
  Last Modified: 2018-12-22 15:03:09
  Modified By: Chen Haodong (easyai@outlook.com)
 */

`define YAMM_IDLE 0
`define YAMM_1BYTE 1
`define YAMM_2BYTE 2
`define YAMM_3BYTE 3
`define YAMM_4BYTE 4
`define YAMM_FINISHED 5

`define YAMM_VGA_MEM_OPR 6
`define YAMM_VGA_REG_OPR 7
`define YAMM_LED_OPR 8
`define YAMM_MEM_OPR 9

`define YAMM_VGA_MEM_OPR_FIN 10
`define YAMM_VGA_MEM_REG_FIN 11
`define YAMM_LED_OPR_FIN 12
`define YAMM_1BYTE_FIN 13
`define YAMM_2BYTE_FIN 14
`define YAMM_3BYTE_FIN 15
`define YAMM_4BYTE_FIN 16

`define YAMM_MODE_R32 0
`define YAMM_MODE_W8 1
`define YAMM_MODE_W16 2
`define YAMM_MODE_W32 3

`define YAMM_MEM 0
`define YAMM_VGA_MEM 1
`define YAMM_LED_MEM 2

//hard coded
`define YAMM_MEM_BEGIN 32'h0
`define YAMM_MEM_END 32'h80000
`define YAMM_VGA_MEM_BEGIN 32'h80004
`define YAMM_VGA_MEM_END 32'h812C4
`define YAMM_VGA_REG_BEGIN 32'h812C4
`define YAMM_VGA_REG_END 32'h812C6
`define YAMM_LED_MEM_BEGIN 32'h80000
`define YAMM_LED_MEM_END 32'h80002

//hard coded
`define YAMM_LED_ADDR1 32'h80000
`define YAMM_LED_ADDR2 32'h80001
`define YAMM_VGA_CURSOR_X 32'h812C4
`define YAMM_VGA_CURSOR_Y 32'h812C5

module yamm(
	input 						clk,
	input						reset_n,
	input	[31:0]				address,
	input	[31:0]				wdata,
	input	[1:0]				mode,
	input						sig_work,
	output reg					sig_ready,
    output reg                  sig_succ,
	output reg [31:0]			rdata,
	// debugging
	output 			global_wen,
	output			cache_en,
	output			cache_wen,
	output reg [15:0] selected_rdata,
	output reg  [31:0] addr_offset,
	output reg [2:0]	bus_state,
	output wire [15:0] cache_rdata,
	output reg [15:0] wdata16,
	output wire [31:0] vgac_addr,
	/////////////// LED ///////////////
	output 			[9:0]		LEDR,
	/////////////// VGA ///////////////
	output		          		VGA_BLANK_N,
	output		    [7:0]		VGA_B,
	output		          		VGA_CLK,
	output		    [7:0]		VGA_G,
	output		          		VGA_HS,
	output		    [7:0]		VGA_R,
	output		          		VGA_SYNC_N,
	output		          		VGA_VS
);
//CMEM regs
reg [7:0] data_cache1;
reg [7:0] data_cache2;
reg [7:0] data_cache3;
reg [7:0] data_cache4;
//MEM regs
reg [7:0] led_reg1;
reg [7:0] led_reg2;
reg [7:0] vga_regx;
reg [7:0] vga_regy;
//control
reg [4:0] yamm_state;
wire [11:0] vga_dp_raddr;
wire [15:0] vga_dp_rdata;
reg [31:0] cur_address;
reg [31:0] vga_address;
reg [15:0] vga_wdata;
wire [15:0] vga_rdata;
reg [7:0] mem_wdata;
wire [7:0] mem_rdata;
wire mem_en;
wire mem_wren;
wire vgam_en;
wire vgar_en;
wire vga_wren;
assign mem_en = address >= `YAMM_MEM_BEGIN && address < `YAMM_MEM_END;
assign vgam_en =  address >= `YAMM_VGA_MEM_BEGIN && address < `YAMM_VGA_MEM_END;
assign vgar_en =  address >= `YAMM_VGA_REG_BEGIN && address < `YAMM_VGA_REG_END;
assign vga_wren = vgam_en && mode == `YAMM_MODE_W16;
assign mem_wren = mem_en && mode != `YAMM_MODE_R32;
always @ (posedge clk)
begin
    case (yamm_state)
    `YAMM_IDLE:
    begin
        if(sig_work == 0)
        begin
            if(sig_ready == 1)
                sig_ready <= 0;
            yamm_state <= `YAMM_IDLE;
        end
        else if(sig_ready == 0)
        begin
            //preparing the working information
            data_cache1 <= 0;
            data_cache2 <= 0;
            data_cache3 <= 0;
            data_cache4 <= 0;
            //check the special working mode
            if(vgam_en) yamm_state <= `YAMM_VGA_MEM_OPR;
            else if(vgar_en) yamm_state <= `YAMM_VGA_REG_OPR;
            else if(address >= `YAMM_LED_MEM_BEGIN && address < `YAMM_LED_MEM_END) yamm_state <= `YAMM_LED_OPR;
            else if(mem_en) yamm_state <= `YAMM_MEM_OPR;
            else
            begin
                //fatal error
                sig_succ = 1'b0;
                yamm_state <= `YAMM_FINISHED;
            end
        end
        else yamm_state <= `YAMM_IDLE;
    end
    //VGA MEMORY OPERATION
    `YAMM_VGA_MEM_OPR:
    begin
        //this must be 2 bytes writing or reading
        if(mode == `YAMM_MODE_W8  || mode == `YAMM_MODE_W32)
        begin
            sig_succ = 1'b0;
            yamm_state <= `YAMM_FINISHED;
        end
        else
        begin
            //parsing the address and value
            vga_address = address - `YAMM_VGA_MEM_BEGIN;
            vga_wdata = wdata[15:0];
            yamm_state <= `YAMM_VGA_MEM_OPR_FIN;
        end
    end
    `YAMM_VGA_MEM_OPR_FIN:
    begin
        rdata = {16'b0,vga_rdata};
        yamm_state <= `YAMM_FINISHED;
    end
    //VGA CONTROL REG OPERATION MUST BE 8BITS
    `YAMM_VGA_REG_OPR:
    begin
        if(mode == `YAMM_MODE_W8)
        begin
            if(address == `YAMM_VGA_CURSOR_X) vga_regx <= wdata[7:0];
            else vga_regy <= wdata[7:0];
        end
        else
        begin
            if(address == `YAMM_VGA_CURSOR_X) rdata <= {24'b0,vga_regx};
            else rdata <= {24'b0,vga_regy};
        end
        yamm_state <= `YAMM_VGA_REG_OPR_FIN;
    end
    `YAMM_VGA_REG_OPR_FIN: yamm_state <= `YAMM_FINISHED;
    //LED OPERATION MUST BE 8BITS
    `YAMM_LED_OPR:
    begin
        if(mode == `YAMM_MODE_W8)
        begin
            if(address == `YAMM_LED_ADDR1) led_reg1 <= wdata[7:0];
            else led_reg2 <= wdata[7:0];
        end
        else
        begin
            if(address == `YAMM_LED_ADDR1) rdata <= {24'b0,led_reg1};
            else rdata <= {24'b0,led_reg2};
        end
        yamm_state <= `YAMM_LED_OPR_FIN;
    end
    `YAMM_LED_OPR_FIN: yamm_state <= `YAMM_FINISHED;
    //GENERAL MEMORY OPERATION
    `YAMM_MEM_OPR:
    begin
        //parsing information
        //do nothing
        yamm_state <= `YAMM_1BYTE;
    end
    `YAMM_1BYTE:
    begin
        mem_wdata = wdata[7:0];
        yamm_state <= `YAMM_1BYTE_FIN;
    end
    `YAMM_1BYTE_FIN:
    begin
        data_cache1 = mem_rdata;
        if(mode == `YAMM_MODE_W8) yamm_state <= `YAMM_FINISHED;
        else
        begin
            cur_address <= cur_address + 1;
            yamm_state <= `YAMM_2BYTE;
        end
    end
    `YAMM_2BYTE:
    begin
        mem_wdata = wdata[15:8];
        yamm_state <= `YAMM_2BYTE_FIN;
    end
    `YAMM_2BYTE_FIN:
    begin
        data_cache2 = mem_rdata;
        if(mode == `YAMM_MODE_W16) yamm_state <= `YAMM_FINISHED;
        else
        begin
            cur_address <= cur_address + 1;
            yamm_state <= `YAMM_3BYTE;
        end
    end
    `YAMM_3BYTE:
    begin
        mem_wdata = wdata[23:16];
        yamm_state <= `YAMM_3BYTE_FIN;
    end
    `YAMM_3BYTE_FIN:
    begin
        //CANT GET ONLY 3 BYTES
        data_cache3 = mem_rdata;
        cur_address <= cur_address + 1;
        yamm_state <= `YAMM_4BYTE;
    end
    `YAMM_4BYTE:
    begin
        mem_wdata = wdata[31:24];
        yamm_state <= `YAMM_4BYTE_FIN;
    end
    `YAMM_4BYTE_FIN:
    begin
        //CANT GET ONLY 3 BYTES
        data_cache4 = mem_rdata;
        cur_address <= cur_address + 1;
        yamm_state <= `YAMM_FINISHED;
    end
    `YAMM_FINISHED:
    begin
        //we only need to process the memory
        //vga,led has finished all works
        if(mem_en)
        begin
            rdata = {data_cache4,data_cache3,data_cache2,data_cache1};
        end
        sig_ready <= 1'b1;
        sig_succ <= 1'b1;
        yamm_state <= `YAMM_IDLE;
    end
    endcase
end
// MEMORYS
yamm_mem mem(
	.clock(clk),
	.data(mem_wdata),
	.rdaddress(cur_address),
	.wraddress(cur_address),
	.wren(mem_wren),
	.q(mem_rdata));

//using a port as display control
yamm_vga_mem vga_mem(
	.address_a(vga_dp_raddr),
	.address_b(vga_address[11:0]),
	.clock(clk),
	.data_a(16'b0),
	.data_b(vga_wdata),
	.wren_a(1'b0),
	.wren_b(vga_wren),
	.q_a(vga_dp_rdata),
	.q_b(vga_rdata));

// DEVICE OUTPUT
assign LEDR = led_memory[0][9:0];

wire [7:0] x_addr;
wire [4:0] y_addr;

assign vga_dp_raddr = ({7'b0,y_addr} << 6) + ({7'b0,y_addr} << 4) + x_addr;

display_ctrl dp(
    .clk(clk),
    .reset_n(reset_n),
    .in_data(vga_dp_rdata),
    .ctrl_reg({vga_regy,vga_regx}),
    .x_addr(x_addr),
    .y_addr(y_addr),
    .vga_rst(~reset_n),
    .vga_vs(VGA_VS),
    .vga_hs(VGA_HS),
    .vga_syncn(VGA_SYNC_N),
    .vga_blankn(VGA_BLANK_N),
    .vga_clk(VGA_CLK),
    .vga_r(VGA_R),
    .vga_g(VGA_G),
    .vga_b(VGA_B)
    );

endmodule
