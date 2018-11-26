module bus_ctrl(
	input 			CLK,
	input  [26:0]	address,
	input	 [32:0]	wdata,
	input	 [1:0]	WLEN,
	inout				READY,
	output [32:0]	rdata
);
endmodule