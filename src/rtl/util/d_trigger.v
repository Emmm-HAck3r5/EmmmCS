module d_trigger(en,in_data,clk,out);
	input [7:0]in_data;
	input en;
	input clk;
	output reg [7:0]out;

	always @ (posedge clk)
	if(en)
		begin
			out <= in_data;
		end
	else
		begin
			out <= out;
		end
endmodule
