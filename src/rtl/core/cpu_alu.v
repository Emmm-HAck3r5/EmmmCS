module cpu_alu(
	input [31:0]			src_A,
	input [31:0]			src_B,
	input	[3:0]				select,
	output reg [63:0]		dest,
	output wire [3:0]		flags,
	inout reg				READY
);

`define 	OPR_LEN	32

`define	ADD_FUNC		4'b0000
`define	SUB_FUNC		4'b0001
`define	AND_FUNC		4'b0010
`define	OR_FUNC		4'b0011
`define	XOR_FUNC		4'b0100
`define	SLL_FUNC		4'b0101
`define	SRL_FUNC		4'b0110
`define	SRA_FUNC		4'b0111
`define	MUL_FUNC		4'b1000
`define	MULU_FUNC	4'b1001
`define	MULSU_FUNC	4'b1010
`define	DIV_FUNC		4'b1011
`define	DIVU_FUNC	4'b1100
`define	REM_FUNC		4'b1101
`define	REMU_FUNC	4'b1110
`define	NOP_FUNC		4'b1111

wire CF, OF, ZF, SF;
wire [`OPR_LEN : 0] src_A32;
wire [`OPR_LEN : 0] src_B32;

assign CF = dest[`OPR_LEN];
assign OF = (src_A[`OPR_LEN - 1] == src_B[`OPR_LEN - 1]) && (src_B[`OPR_LEN - 1] != dest[`OPR_LEN - 1]);
assign ZF = ~| dest;
assign SF = dest[`OPR_LEN - 1];
assign flags = { CF, OF, ZF, SF };

assign src_A32 = {1'b0, src_A};
assign src_B32 = {1'b0, src_B};

// alu_mul

reg [`OPR_LEN - 1 : 0]	mul_src_A;
reg [`OPR_LEN - 1 : 0]	mul_src_B;
wire [2 * `OPR_LEN - 1 : 0] mul_dest;

wire mul_ready;

alu_mul mul(
	.clk(clk),
	.src_A(mul_src_A),
	.src_B(mul_src_B),
	.dest(mul_dest),
	.rst(READY),
	.READY(mul_ready)
);

// alu_div

reg [`OPR_LEN - 1 : 0]	div_src_A;
reg [`OPR_LEN - 1 : 0]	div_src_B;
wire [`OPR_LEN - 1 : 0] div_quot;
wire [`OPR_LEN - 1 : 0] div_remd;

wire div_ready;

alu_div div(
	.clk(clk),
	.src_A(div_src_A),
	.src_B(div_src_B),
	.quotient(div_quot),
	.remainder(div_remd),
	.rst(READY),
	.READY(div_ready)
);

always @ (posedge clk) begin
	case(select)
		`ADD_FUNC: begin	// ADD
			dest[`OPR_LEN : 0] <= src_A32 + src_B32;
		end
		`SUB_FUNC: begin	// SUB
			dest[`OPR_LEN : 0] <= src_A32 + ~src_B32 + 1;
		end
		`AND_FUNC: begin	// AND
			dest[`OPR_LEN - 1 : 0] <= src_A & src_B;
		end
		`OR_FUNC: begin	//	OR
			dest[`OPR_LEN - 1 : 0] <= src_A | src_B;
		end
		`XOR_FUNC: begin	// XOR
			dest[`OPR_LEN - 1 : 0] <= src_A ^ src_B;
		end
		`SLL_FUNC: begin // SLL
			dest[`OPR_LEN - 1 : 0] <= (src_A << src_B[4:0]);
		end
		`SRL_FUNC: begin	// SRL
			dest[`OPR_LEN - 1 : 0] <= (src_A >> src_B[4:0]);
		end
		`SRA_FUNC: begin	// SRA
			dest[`OPR_LEN - 1 : 0] <= (src_A >> src_B[4:0]) | (32'hffffffff << (6'd32 - src_B[4:0]));
		end
		`MUL_FUNC: begin	// MUL
			if (src_A[`OPR_LEN - 1]) 
				mul_src_A <= { 1'b0, ~src_A[`OPR_LEN - 2 : 0] + 1};
			else mul_src_A <= src_A;
			if (src_B[`OPR_LEN - 1]) 
				mul_src_B <= { 1'b0, ~src_B[`OPR_LEN - 2 : 0] + 1};
			else mul_src_B <= src_B;
			if (src_A[`OPR_LEN - 1] ^ src_B[`OPR_LEN - 1])
				dest[2 * `OPR_LEN - 1 : 0] <= ~mul_dest + 1;
			else dest[2 * `OPR_LEN - 1 : 0] <= mul_dest;
		end
		`MULU_FUNC: begin	// MULU
			mul_src_A <= src_A;
			mul_src_B <= src_B;
			dest[2 * `OPR_LEN - 1 : 0] <= mul_dest;
		end
		`MULSU_FUNC: begin // MULSU
			if (src_A[`OPR_LEN - 1]) 
				mul_src_A <= { 1'b0, ~src_A[`OPR_LEN - 2 : 0] + 1};
			else mul_src_A <= src_A;
			
			mul_src_B <= src_B;
			
			if (src_A[`OPR_LEN - 1])
				dest[2 * `OPR_LEN - 1 : 0] <= ~mul_dest + 1;
			else dest[2 * `OPR_LEN - 1 : 0] <= mul_dest;
		end
		`DIV_FUNC: begin // DIV
			if (src_A[`OPR_LEN - 1]) 
				div_src_A <= { 1'b0, ~src_A[`OPR_LEN - 2 : 0] + 1};
			else div_src_A <= src_A;
			if (src_B[`OPR_LEN - 1]) 
				div_src_B <= { 1'b0, ~src_B[`OPR_LEN - 2 : 0] + 1};
			else div_src_B <= src_B;
			if (src_A[`OPR_LEN - 1] ^ src_B[`OPR_LEN - 1])
				dest[`OPR_LEN - 1 : 0] <= ~div_quot + 1;
			else dest[`OPR_LEN - 1 : 0] <= div_quot;
		end
		`DIVU_FUNC: begin // DIVU
			div_src_A <= src_A;
			div_src_B <= src_B;
			dest[`OPR_LEN - 1 : 0] <= div_quot;
		end
		`REM_FUNC: begin // REM
			if (src_A[`OPR_LEN - 1]) 
				div_src_A <= { 1'b0, ~src_A[`OPR_LEN - 2 : 0] + 1};
			else div_src_A <= src_A;
			if (src_B[`OPR_LEN - 1]) 
				div_src_B <= { 1'b0, ~src_B[`OPR_LEN - 2 : 0] + 1};
			else div_src_B <= src_B;
			if (src_A[`OPR_LEN - 1] ^ src_B[`OPR_LEN - 1])
				dest[`OPR_LEN - 1 : 0] <= ~div_remd + 1;
			else dest[`OPR_LEN - 1 : 0] <= div_remd;
		end
		`REMU_FUNC: begin // REMU
			div_src_A <= src_A;
			div_src_B <= src_B;
			dest[`OPR_LEN - 1 : 0] <= div_remd;
		end
		`NOP_FUNC: begin // NOP
			dest <= dest;
			READY <= 1;
		end
		default;
	endcase
	
	if (select < `MUL_FUNC || select == `NOP_FUNC)
		READY <= 1'b1;
	else READY <= READY;
end



endmodule
