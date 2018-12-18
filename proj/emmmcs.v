
//=======================================================
//  This code is generated by Terasic System Builder
//=======================================================

module emmmcs(

	//////////// CLOCK //////////
	input 		          		CLOCK2_50,
	input 		          		CLOCK3_50,
	input 		          		CLOCK4_50,
	input 		          		CLOCK_50,

	//////////// KEY //////////
	input 		     [3:0]		KEY,

	//////////// SW //////////
	input 		     [9:0]		SW,

	//////////// LED //////////
	output		     [9:0]		LEDR,

	//////////// Seg7 //////////
	output		     [6:0]		HEX0,
	output		     [6:0]		HEX1,
	output		     [6:0]		HEX2,
	output		     [6:0]		HEX3,
	output		     [6:0]		HEX4,
	output		     [6:0]		HEX5,

	//////////// VGA //////////
	output		          		VGA_BLANK_N,
	output		     [7:0]		VGA_B,
	output		          		VGA_CLK,
	output		     [7:0]		VGA_G,
	output		          		VGA_HS,
	output		     [7:0]		VGA_R,
	output		          		VGA_SYNC_N,
	output		          		VGA_VS,

	//////////// Audio //////////
	input 		          		AUD_ADCDAT,
	inout 		          		AUD_ADCLRCK,
	inout 		          		AUD_BCLK,
	output		          		AUD_DACDAT,
	inout 		          		AUD_DACLRCK,
	output		          		AUD_XCK,

	//////////// PS2 //////////
	inout 		          		PS2_CLK,
	inout 		          		PS2_CLK2,
	inout 		          		PS2_DAT,
	inout 		          		PS2_DAT2,

	//////////// I2C for Audio and Video-In //////////
	output		          		FPGA_I2C_SCLK,
	inout 		          		FPGA_I2C_SDAT
);



//=======================================================
//  REG/WIRE declarations
//=======================================================

wire clr_n;
wire cpu_clk;

//=======================================================
//  Structural coding
//=======================================================

reset_module reset(
	.clk(CLOCK_50),
	.rst_n(clr_n)
);

cpu cpu(
	.clk    (CLOCK_50),
	.cpu_clk(cpu_clk),
	.clr_n  (clr_n),

	.LEDR(LEDR),

	.VGA_BLANK_N(VGA_BLANK_N),
	.VGA_B	(VGA_B),
	.VGA_CLK(VGA_CLK),
	.VGA_G	(VGA_G),
	.VGA_HS	(VGA_HS),
	.VGA_R	(VGA_R),
	.VGA_SYNC_N(VGA_SYNC_N),
	.VGA_VS	(VGA_VS),

	.PS2_CLK(PS2_CLK),
	.PS2_DAT(PS2_DAT)
);



endmodule