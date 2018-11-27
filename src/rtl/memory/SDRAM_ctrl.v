module SDRAM_ctrl(
	input 				clk,
	input	  [25:0]		address,
	input	  [31:0]		wdata,
	input	  [1:0]		WLEN,
	input					EN_N,
	output reg			READY,
	output reg [31:0]	rdata,
	
	// debug
	// output reg [3:0] state,
	// output reg [4:0] command,
	
	output reg [12:0] 	ADDR,
	output reg [1:0] 		BA,
	inout  reg [15:0]		DQ,
	output 					CKE, CLK,
	output 					CS_N, RAS_N, CAS_N, WE_N,
	output reg [1:0]		DMASK
);

// COMMANDS

`define CMD_NOP		5'b0111x
`define CMD_ACT 		5'b0011x
`define CMD_READ_AP 	5'b01011
`define CMD_WRITE_AP 5'b01001
`define CMD_MRS 		5'b00000
`define CMD_BST 		5'b0110x

// Initial mode registers
// M9: 		Programmed burst length (Write Burst Mode)
// M8~M7: 	Standard operation (Operating Mode)
// M6~M4:	CAS Latency = 2 
// M3:		Sequential (Burst Type)
// M2~M0:	Burst length = 4
`define INIT_REGISTER 15'b000000000100010

reg [4:0] 	command;

wire [12:0]	row_addr;
wire [1:0]	blank;
wire [9:0]	col_addr;
wire 			btye_addr;

assign CLK = clk;
assign CKE = 1'b1;
assign CS_N = command[4];
assign RAS_N = command[3];
assign CAS_N = command[2];
assign WE_N = command[1];

assign row_addr = address[25:13];
assign blank = address[12:11];
assign col_addr = address[10:1];
assign btye_addr = address[0];

// FINITE STATE MACHINE

`define ST_INIT 			4'd0
`define ST_IDLE 			4'd1
`define ST_R32_CMD 		4'd2
`define ST_R32_WAIT 		4'd3
`define ST_R32_DATA1 	4'd4
`define ST_R32_DATA2 	4'd5
`define ST_R32_DATA3 	4'd6
`define ST_W8_CMD 		4'd7
`define ST_W16_CMD 		4'd8
`define ST_W16_DATA2		4'd9
`define ST_W32_CMD 		4'd10
`define ST_W32_DATA2 	4'd11
`define ST_W32_DATA3 	4'd12
`define ST_TRUNC 			4'd15

reg [3:0] state;

initial begin
	state <= `ST_INIT;
	command <= `CMD_NOP;
end

always @ (negedge clk) begin
	case (state)
		4'd0: begin	// `ST_INIT
			command <= `CMD_MRS;
			ADDR[9:0] <= `INIT_REGISTER;
			state <= `ST_IDLE;
		end
		4'd1: begin // `ST_IDLE
			if (EN_N) begin 
				command <= `CMD_NOP;
				state <= `ST_IDLE;
			end else begin
				command <= `CMD_ACT;
				ADDR <= row_addr;
				BA <= blank;
				READY <= 0;
				case (WLEN)
					2'b00: state <= `ST_R32_CMD;	// read 32 bits
					2'b01: state <= `ST_W8_CMD;		// write 8 bits
					2'b10: state <= `ST_W16_CMD;	// write 16 bits
					2'b11: state <= `ST_W32_CMD;	// write 32 bits
					default: state <= `ST_IDLE;
				endcase
			end
		end
		4'd2: begin	// `ST_R32_CMD
			command <= `CMD_READ_AP;
			ADDR[10] <= command[0];
			ADDR[9:0] <= col_addr;
			BA <= blank;
			DMASK <= 2'b00;
			state <= `ST_R32_WAIT;
		end
		4'd3: begin // `ST_R32_WAIT
			command <= `CMD_NOP;
			state <= `ST_R32_DATA1;
		end
		4'd4: begin // `ST_R32_DATA1
			if (btye_addr) begin
				command <= `CMD_NOP;
				rdata[7:0] <= DQ[15:8];
			end else begin
				command <= `CMD_BST;
				rdata[15:0] <= DQ[15:0];
			end
			state <= `ST_R32_DATA2;
		end
		4'd5: begin	// `ST_R32_DATA2
			if (btye_addr) begin
				command <= `CMD_BST;
				rdata[23:8] <= DQ[15:0];
				state <= `ST_R32_DATA3;
			end else begin
				command <= `CMD_NOP;
				rdata[31:16] <= DQ[15:0];
				READY <= 1'b1;
				state <= `ST_IDLE;
			end
		end
		4'd6: begin	// `ST_R32_DATA3
			command <= `CMD_NOP;
			rdata[31:24] <= DQ[7:0];
			READY <= 1'b1;
			state <= `ST_IDLE;
		end
		4'd7: begin	// `ST_W8_CMD
			command <= `CMD_WRITE_AP;
			ADDR[10] <= command[0];
			ADDR[9:0] <= col_addr;
			BA <= blank;
			DQ <= wdata[15:0];
			
			if (btye_addr)
				DMASK <= 2'b01;
			else DMASK <= 2'b10;
			
			state <= `ST_TRUNC;
		end
		4'd8: begin	// `ST_W16_CMD
			command <= `CMD_WRITE_AP;
			ADDR[10] <= command[0];
			ADDR[9:0] <= col_addr;
			BA <= blank;
			
			if (btye_addr) begin
				DQ <= { wdata[7:0], 8'd0 };
				DMASK <= 2'b01;
				state <= `ST_W16_DATA2;
			end else begin
				DQ <= wdata[15:0];
				DMASK <= 2'b00;
				state <= `ST_TRUNC;
			end
		end
		4'd9: begin // `ST_W16_DATA2
			command <= `CMD_NOP;
			DQ <= { 8'd0, wdata[15:8]};
			DMASK <= 2'b10;
			state <= `ST_TRUNC;
		end
		4'd10: begin	// `ST_W32_CMD
			command <= `CMD_WRITE_AP;
			ADDR[10] <= command[0];
			ADDR[9:0] <= col_addr;
			BA <= blank;
			DQ <= wdata[15:0];
			
			if (btye_addr) begin
				DQ <= { wdata[7:0], 8'd0 };
				DMASK <= 2'b01;
			end else begin
				DQ <= wdata[15:0];
				DMASK <= 2'b00;
			end
			state <= `ST_W32_DATA2;
		end
		4'd11: begin // `ST_W32_DATA2
			command <= `CMD_NOP;
			if (btye_addr) begin
				DQ <= wdata[23:8];
				state <= `ST_W32_DATA3;
			end else begin
				DQ <= wdata[31:16];
				state <= `ST_TRUNC;
			end
		end
		4'd12: begin // `ST_W32_DATA3
			command <= `CMD_NOP;
			DQ <= wdata[31:24];
			state <= `ST_TRUNC;
		end
		4'd15: begin // `ST_TRUNC
			command <= `CMD_BST;
			state <= `ST_IDLE;
			DMASK <= 2'b00;
			READY <= 1'b1;
		end
		default: state <= `ST_INIT;
	endcase
end

endmodule
