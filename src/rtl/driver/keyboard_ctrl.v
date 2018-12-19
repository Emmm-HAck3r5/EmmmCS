module keyboard_ctrl(
	input								RST_N,
	input								PROC,
	output							READY,
	output							OVERFLOW,
	output wire [7:0]				kbcode,
	//////////// CLOCK //////////
	input 		          		CLOCK_50,
	//////////// PS2 //////////
	inout 		          		PS2_CLK,
	inout 		          		PS2_DAT
	);

reg [7:0] fifo [15:0];
reg [3:0] rptr;
reg [3:0] wptr;

assign READY = (rptr != wptr);
assign OVERFLOW = (fifo[wptr] != 0);
assign kbcode = fifo[rptr];

wire [7:0] 	pskb_data;
wire 			pskb_ready;

ps2_keyboard pkb(
	.clk(CLOCK_50),
	.clrn(RST_N),
	.ps2_clk(PS2_CLK),
	.ps2_data(PS2_DAT),
	.data(pskb_data),
	.nextdata_n(1'b0),
	.ready(pskb_ready)
);

`define 	KB_ST_PROC	1'b1
`define	KB_ST_IDLE	1'b0

reg state;

`define	DW_CODE_PREFIX		8'hE0

always @ (negedge CLOCK_50) begin
	if (PROC && READY) begin
		fifo[rptr] <= 0;
		rptr <= rptr + 1;
	end
	if (pskb_ready) begin
		if (pskb_data != `DW_CODE_PREFIX && pskb_data != 0) begin
			fifo[wptr] <= pskb_data;
			wptr <= wptr + 1;
		end
	end
end

endmodule