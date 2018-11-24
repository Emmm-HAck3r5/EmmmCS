module SDRAM_ctrl(
	input 				clk,
	input	  [25:0]		address,
	input	  [31:0]		wdata,
	input	  [1:0]		WLEN,
	inout reg			READY,
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

parameter CMD_NOP = 5'b0111x;
parameter CMD_ACT = 5'b0011x;
parameter CMD_READ_AP = 5'b01011;
parameter CMD_WRITE_AP = 5'b01001;
parameter CMD_MRS = 5'b00000;
parameter CMD_BST = 5'b0110x;

// Initial mode registers
// M9: 		Programmed burst length (Write Burst Mode)
// M8~M7: 	Standard operation (Operating Mode)
// M6~M4:	CAS Latency = 2 
// M3:		Sequential (Burst Type)
// M2~M0:	Burst length = 2
parameter INIT_REGISTER = 15'b00000000100001;

reg [4:0] 	command;

wire [12:0]	row_addr;
wire [1:0]	blank;
wire [9:0]	col_addr;

assign CLK = clk;
assign CKE = 1'b1;
assign CS_N = command[4];
assign RAS_N = command[3];
assign CAS_N = command[2];
assign WE_N = command[1];

assign row_addr = address[25:12];
assign blank = address[11:10];
assign col_addr = address[9:0];

// FINITE STATE MACHINE

parameter ST_INIT = 4'd0;
parameter ST_IDLE = 4'd1;
parameter ST_R32_CMD = 4'd2;
parameter ST_R32_WAIT = 4'd3;
parameter ST_R32_DATA1 = 4'd4;
parameter ST_R32_DATA2 = 4'd5;
parameter ST_W8_CMD = 4'd6;
parameter ST_W16_CMD = 4'd7;
parameter ST_W32_CMD = 4'd8;
parameter ST_W32_DATAH = 4'd9;
parameter ST_TRUNC = 4'd10;

reg [3:0] state;

initial begin
	state <= ST_INIT;
	command <= CMD_NOP;
end

always @ (negedge clk) begin
	case (state)
		4'd0: begin	// ST_INIT
			command <= CMD_MRS;
			ADDR[9:0] <= INIT_REGISTER;
			state <= ST_IDLE;
		end
		4'd1: begin // ST_IDLE
			if (READY) command <= CMD_NOP;
			else begin
				command <= CMD_ACT;
				ADDR <= row_addr;
				BA <= blank;
				case (WLEN)
					2'b00: state <= ST_R32_CMD;	// read 32 bits
					2'b01: state <= ST_W8_CMD;			// write 8 bits
					2'b10: state <= ST_W16_CMD;			// write 16 bits
					2'b11: state <= ST_W32_CMD;			// write 32 bits
					default: state <= ST_IDLE;
				endcase
			end
		end
		4'd2: begin	// ST_R32_CMD
			command <= CMD_READ_AP;
			ADDR[10] <= command[0];
			ADDR[9:0] <= col_addr;
			BA <= blank;
			DMASK <= 2'b00;
			state <= ST_R32_WAIT;
		end
		4'd3: begin // ST_R32_WAIT
			command <= CMD_NOP;
			state <= ST_R32_DATA1;
		end
		4'd4: begin // ST_R32_DATA1
			command <= CMD_NOP;
			rdata[15:0] <= DQ;
			state <= ST_R32_DATA2;
		end
		4'd5: begin	// ST_R32_DATA2
			command <= CMD_NOP;
			rdata[15:0] <= rdata[15:0];
			rdata[31:16] <= DQ;
			READY <= 1'b1;
			state <= ST_IDLE;
		end
		4'd6: begin	// ST_W8_CMD
			command <= CMD_WRITE_AP;
			ADDR[10] <= command[0];
			ADDR[9:0] <= col_addr;
			BA <= blank;
			DQ <= wdata[15:0];
			DMASK <= 2'b10;
			READY <= 1'b1;
			state <= ST_TRUNC;
		end
		4'd7: begin	// ST_W16_CMD
			command <= CMD_WRITE_AP;
			ADDR[10] <= command[0];
			ADDR[9:0] <= col_addr;
			BA <= blank;
			DQ <= wdata[15:0];
			DMASK <= 2'b00;
			READY <= 1'b1;
			state <= ST_TRUNC;
		end
		4'd8: begin	// ST_W32_CMD
			command <= CMD_WRITE_AP;
			ADDR[10] <= command[0];
			ADDR[9:0] <= col_addr;
			BA <= blank;
			DQ <= wdata[15:0];
			DMASK <= 2'b00;
			state <= ST_W32_DATAH;
		end
		4'd9: begin // ST_W32_DATAH
			command <= CMD_NOP;
			DQ <= wdata[31:16];
			READY <= 1'b1;
			state <= ST_IDLE;
		end
		4'd10: begin // ST_TRUNC
			command <= CMD_BST;
			state <= ST_IDLE;
		end
		default: state <= ST_INIT;
	endcase
end

endmodule
