module alu_mul(
	input					clk,
	input [31:0]		src_A,
	input [31:0]		src_B,
	output reg [63:0]	dest,
	input					rst,
	output reg			READY
);

`define	OPR_LEN	32

reg [63:0]	array32 [31 : 0];
reg [63:0]	array16 [15 : 0];
reg [63:0]	array8  [7 : 0];
reg [63:0]	array4  [3 : 0];
reg [63:0]	array2  [1 : 0];

integer i;

reg [3:0] count;

always @ (posedge clk) begin
	if (rst) begin
		READY <= 0;
		count <= 0;
		for(i = 0; i < 32 ; i = i + 1)
			array32[i] <= 0;
		for(i = 0; i < 16 ; i = i + 1)
			array16[i] <= 0;
		for(i = 0; i < 8 ; i = i + 1)
			array8[i] <= 0;
		for(i = 0; i < 4 ; i = i + 1)
			array4[i] <= 0;
		for(i = 0; i < 2 ; i = i + 1)
			array2[i] <= 0;
	end else begin
		for(i = 0; i < 32 ; i = i + 1)
			array32[i] <= src_B[i] ? (src_A << i) : 0;
		for(i = 0; i < 16 ; i = i + 1)
			array16[i] <= array32[2*i] + array32[2*i + 1];
		for(i = 0; i < 8 ; i = i + 1)
			array8[i] <= array16[2*i] + array16[2*i + 1];
		for(i = 0; i < 4 ; i = i + 1)
			array4[i] <= array8[2*i] + array8[2*i + 1];
		for(i = 0; i < 2 ; i = i + 1)
			array2[i] <= array4[2*i] + array4[2*i + 1];
		dest <= array2[0] + array2[1];
		
		if (count >= 4'd5) begin
			READY <= 1;
		end else count <= count + 1;
	end
end

endmodule 