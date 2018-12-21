module cpu_bus(
	input 						clk,
	input						reset_n,
	input	[31:0]				address,
	input	[31:0]				wdata,
	input	[1:0]				WLEN,
	input						EN_N,
	output reg					READY,
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

`define ADDR_SIZE		32
`define WORD_SIZE		16
`define BYTE_SIZE		8

`define	CACHE_MAXSIZE	32'h80000
`define	LED_MAXSIZE		32'h4
`define	VGA_MAXSIZE		32'h12d0
`define VGA_MEMORY_SIZE	32'h12c0
`define VGA_CREGS_SIZE  32'h10

`define	CACHE_START		32'h0
`define	LED_START		(`CACHE_START + `CACHE_MAXSIZE)
`define	VGA_START		(`LED_START + `LED_MAXSIZE)
`define VGA_CTRL_START	(`VGA_START + `VGA_MEMORY_SIZE)
`define	KB_START		(`VGA_START + `VGA_MAXSIZE)

// ENABLE
// wire cache_en;
wire led_en;
wire vga_en;
assign cache_en = (address >= `CACHE_START) && (address < `LED_START);
assign led_en = (address >= `LED_START) && (address < `VGA_START);
assign vga_en =  (address >= `VGA_START) && (address < `KB_START);

// base ADDRESS
wire [`ADDR_SIZE - 1:0] cache_addr;
wire [`ADDR_SIZE - 1:0] led_addr;
wire [`ADDR_SIZE - 1:0] vga_addr;
wire [`ADDR_SIZE - 1:0] vga_dp_raddr;
// reg  [`ADDR_SIZE - 1:0] addr_offset;

assign cache_addr = address - `CACHE_START + addr_offset;
assign led_addr = address - `LED_START + addr_offset;
assign vga_addr = address - `VGA_START + addr_offset;

// select output radata
// wire [`WORD_SIZE - 1:0] cache_rdata;
wire [`WORD_SIZE - 1:0] led_rdata;
wire [`WORD_SIZE - 1:0] vga_rdata;
wire [`WORD_SIZE - 1:0] vga_dp_rdata;
// reg [`WORD_SIZE - 1:0] selected_rdata;

always @ (negedge clk)
	if (cache_en) selected_rdata <= cache_rdata;
	else if (led_en) selected_rdata <= led_rdata;
	else if (vga_en) selected_rdata <= vga_rdata;
	else selected_rdata <= selected_rdata;

// write-in data
// wire global_wen;
// wire cache_wen;
wire led_wen;
wire vga_wen;
// reg [`WORD_SIZE - 1:0] wdata16;
reg writing = 0;

assign global_wen = writing;
assign cache_wen = cache_en && global_wen;
assign led_wen = led_en && global_wen;
assign vga_wen = vga_en && global_wen;

// ADDRESS MAPPING FSM
`define BUS_ST_IDLE			0
`define	BUS_ST_RD32_R1		1
`define	BUS_ST_RD32_R2		2
`define	BUS_ST_WR8_R		3
`define	BUS_ST_WR8_W		4
`define	BUS_ST_WR16_W		5
`define	BUS_ST_WR32_W1		6
`define	BUS_ST_WR32_W2		7

`define WLEN_RD32	2'b00
`define WLEN_WR8	2'b01
`define WLEN_WR16	2'b10
`define WLEN_WR32	2'b11

// reg [2:0] bus_state = `BUS_ST_IDLE;

initial begin
	bus_state = `BUS_ST_IDLE;
end

// address offset
always @ (posedge clk) begin
	case (bus_state)
	  `BUS_ST_IDLE:
	  	if (!EN_N && WLEN == `WLEN_RD32)
		  addr_offset <= 32'd2;
		else addr_offset <= 32'd0;
	  `BUS_ST_WR32_W1: addr_offset <= 32'd2;
	  default: addr_offset <= 32'd0;
	endcase
end

// select read data
always @ (posedge clk) begin
	case (bus_state)
	  `BUS_ST_RD32_R1: rdata[`WORD_SIZE-1:0] <= selected_rdata;
	  `BUS_ST_RD32_R2: rdata[2*`WORD_SIZE-1:`WORD_SIZE] <= selected_rdata;
	  default: rdata <= rdata;
	endcase
end

// writing
always @ (posedge clk)
	case (bus_state)
		`BUS_ST_WR8_W, `BUS_ST_WR16_W, `BUS_ST_WR32_W2: writing <= 0;
		`BUS_ST_WR8_R: writing <= 1;
		`BUS_ST_IDLE:
			if (!EN_N)
				case (WLEN)
					`WLEN_RD32, `WLEN_WR8: writing <= 0;
					`WLEN_WR16, `WLEN_WR32: writing <= 1;
				endcase
			else writing <= 0;
		default: writing <= writing;
	endcase

// write-in data
always @ (posedge clk) begin
	case(bus_state)
		`BUS_ST_WR8_R:
			if (address[0]) wdata16 <= {wdata[7:0], selected_rdata[7:0]};
			else wdata16 <= {selected_rdata[`WORD_SIZE-1:8], wdata[7:0]};
		`BUS_ST_WR32_W1:  wdata16 <= wdata[2*`WORD_SIZE-1:`WORD_SIZE];
		default: wdata16 <= wdata[`WORD_SIZE-1:0];
	endcase
end

// state transformation
always @ (posedge clk) begin
	case (bus_state)
		`BUS_ST_IDLE : begin
			READY <= 1;
			if (EN_N) bus_state <= `BUS_ST_IDLE;
			else begin
				READY <= 0;
				case (WLEN)
					`WLEN_RD32: bus_state <= `BUS_ST_RD32_R1;
					`WLEN_WR8: bus_state <= `BUS_ST_WR8_R;
					`WLEN_WR16: bus_state <= `BUS_ST_WR16_W;
					`WLEN_WR32: bus_state <= `BUS_ST_WR32_W1;
				  	default: bus_state <= `BUS_ST_IDLE;
				endcase
			end
		end
		`BUS_ST_RD32_R1:bus_state <= `BUS_ST_RD32_R2;
		`BUS_ST_RD32_R2:bus_state <= `BUS_ST_IDLE;
		`BUS_ST_WR8_R:bus_state <= `BUS_ST_WR8_W;
		`BUS_ST_WR8_W:bus_state <= `BUS_ST_IDLE;
		`BUS_ST_WR16_W:bus_state <= `BUS_ST_IDLE;
		`BUS_ST_WR32_W1:bus_state <= `BUS_ST_WR32_W2;
		`BUS_ST_WR32_W2:bus_state <= `BUS_ST_IDLE;
	  default: bus_state <= `BUS_ST_IDLE;
	endcase
end

// MEMORYS
reg [`WORD_SIZE - 1 : 0] led_memory [`LED_MAXSIZE - 1 : 0];
reg [`VGA_CREGS_SIZE * `BYTE_SIZE - 1 : 0 ] vga_ctrl = 0;

cache c(
	.address(cache_addr[18:1]),
	.clock(clk),
	.data(wdata16),
	.wren(cache_wen),
	.q(cache_rdata)
	);

vga_memory2port vm2p(
	.clock(clk),
	// display ctrl only read
	.address_a(vga_dp_raddr[11:0]),
	// data_a is not used
	.wren_a(0),
	.q_a(vga_dp_rdata),
	// vga memory write/read
	.address_b(vga_addr[12:1]),
	.data_b(wdata16),
	.wren_b(vga_wen),
	.q_b(vga_rdata)
);

assign led_rdata = led_memory[0];

always @ (posedge clk) begin
	if (led_wen) begin
		if (WLEN == `WLEN_WR8)
			led_memory[0][7:0] <= wdata[7:0];
		else begin
			led_memory[0] <= wdata[`WORD_SIZE - 1 : 0];
			led_memory[1] <= wdata[2*`WORD_SIZE-1 : `WORD_SIZE];
		end
	end
end
// DEVICE OUTPUT
assign LEDR = led_memory[0][9:0];

wire [7:0] x_addr;
wire [4:0] y_addr;

assign vga_dp_raddr = ({7'b0,y_addr} << 6) + ({7'b0,y_addr} << 4) + x_addr;

display_ctrl dp(
    .clk(clk),
    .reset_n(reset_n),
    .in_data(vga_dp_rdata),
    .ctrl_reg(vga_ctrl),
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
