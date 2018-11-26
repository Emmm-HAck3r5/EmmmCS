module alu_div(
	input					clk,
	input [31:0]		src_A,
	input [31:0]		src_B,
	output [31:0]		quotient,
	output [31:0]		remainder,
	input					rst,
	output reg			READY
	
);

`define OPR_LEN	32

reg [2*`OPR_LEN - 1 : 0] buf_A;
reg [2*`OPR_LEN - 1 : 0] buf_B;
reg [4:0]					count;

assign quotient = buf_A[`OPR_LEN - 1 : 0];
assign remainder = buf_A[2*`OPR_LEN - 1 : `OPR_LEN];

always @ (posedge clk) begin
	if (rst) begin
		READY = 0;
		buf_A = {32'd0, src_A};
		buf_B = {src_B, 32'd0};
		count = 5'b00000;
	end else begin
		buf_A = buf_A << 1;
		if (buf_A[2*`OPR_LEN - 1 : `OPR_LEN] >= buf_B)
			buf_A = buf_A + buf_B + 1'b1;
		else buf_A = buf_A;
		
		count = count + 1;
		if (count == 5'b00000)
			READY = 1;
	end
end

endmodule 