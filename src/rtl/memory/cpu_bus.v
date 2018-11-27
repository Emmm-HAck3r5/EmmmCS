module cpu_bus(
	input 					clk,
	input	[31:0]			address,
	input	[31:0]			wdata,
	input	[1:0]				WLEN,
	input						EN_N,
	output reg				READY,
	output reg [31:0]		rdata,
	
	output [12:0] 			ADDR,
	output [1:0] 			BA,
	inout  [15:0]			DQ,
	output 					CKE, CLK,
	output 					CS_N, RAS_N, CAS_N, WE_N,
	output [1:0]			DMASK
);

reg [15:0] LED_memory;

wire [31:0] sdram_rdata;
wire	sdram_ready;

SDRAM_ctrl sdram(
	.clk(clk),
	.address(address[25:0]),
	.wdata(wdata),
	.WLEN(WLEN),
	.EN_N(EN_N),
	.READY(sdram_ready),
	.rdata(sdram_rdata),
	
	.ADDR(ADDR),
	.BA(BA),
	.DQ(DQ),
	.CKE(CKE),
	.CLK(CLK),
	.CS_N(CS_N),
	.RAS_N(RAS_N),
	.CAS_N(CAS_N),
	.WE_N(WE_N),
	.DMASK(DMASK)
);

`define 	SDRAM_MAXSIZE 	32'h4000000
`define	LED_MAXSIZE		32'h4
`define	VGA_MAXSIZE		32'h9610

`define	SDRAM_START		32'h0
`define	LED_START		(`SDRAM_START + `SDRAM_MAXSIZE)
`define	VGA_START		(`LED_START + `LED_MAXSIZE)
`define	KB_START			(`VGA_START + `VGA_MAXSIZE)

wire [15:0] vga_addr;
wire [15:0] vga_wdata;
wire [15:0] vga_rdata;

reg vga_wren;

assign vga_addr = address - `VGA_START;
assign vga_wdata = wdata[15:0];

vga_memory vm(
	.address(vga_addr),
	.clock(clk),
	.data(vga_wdata),
	.wren(vga_wren),
	.q(vga_rdata)
);

// VGA write enable port
always @ (posedge clk) begin
	if (address >= `VGA_START && address < `KB_START)
		if ( WLEN == 2'b00)
			vga_wren <= 1'b0;
		else vga_wren <= 1'b1;
	else vga_wren <= 1'b0;
end
	
// read & write data
always @ (posedge clk) begin
	if (address < `LED_START) begin
		rdata <= sdram_rdata;
		READY <= sdram_ready;
	end else if ( address >= `LED_START && address < `VGA_START) begin
		if (WLEN == 2'b00)
			rdata <= { 16'd0, LED_memory};
		else LED_memory <= wdata[15:0];
		READY <= 1;
	end else if ( address >= `VGA_START && address < `KB_START) begin
		if (WLEN == 2'b00)
			rdata <= { 16'd0, vga_rdata};
		READY <= 1;
	end else ; // TODO
end

endmodule 