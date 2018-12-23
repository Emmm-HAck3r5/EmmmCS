module seg7_h(en,in,hex);
	input en;
	input [3:0] in;
	output reg [6:0] hex;

	always @(en or in)
		begin
		if(en)
			case (in)
				0: hex= 7'b1000000;
				1: hex= 7'b1111001;
				2: hex= 7'b0100100;
				3: hex= 7'b0110000;
				4: hex= 7'b0011001;
				5: hex= 7'b0010010;
				6: hex= 7'b0000010;
				7: hex= 7'b1111000;
				8: hex= 7'b0000000;
				9: hex= 7'b0010000;
				10:hex= 7'b0001000;
				11:hex= 7'b0000011;
				12:hex= 7'b1000110;
				13:hex= 7'b0100001;
				14:hex= 7'b0000110;
				15:hex= 7'b0001110;
				default: hex=7'b0110110;
			endcase
		else
			hex=7'b1111111;
		end
endmodule
