/*
  Copyright 2018 EmmmHackers

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
  --------------------------
  File: yakbd.v
  Project: EmmmCS
  File Created: 2018-12-23 13:27:26
  Author: Chen Haodong (easyai@outlook.com)
  --------------------------
  Last Modified: 2018-12-23 13:28:33
  Modified By: Chen Haodong (easyai@outlook.com)
 */

module keyboard(clk,clrn,ps2_clk,ps2_data,o_ascii,hexascii);
	input clk;
	input clrn;
	input ps2_clk;
	input ps2_data;
	reg caps;
	reg alt;
	reg shift;
	reg ctrl;
	//for dbg
	output wire [13:0]hexascii;
	//
	reg nextdata_n;
	reg [7:0] count;
	wire ready,overflow;
	reg outputen;
	reg last_f0;
	wire inner_shift;
	reg is_press;
	wire [7:0]out_d;
	wire [7:0]ps2code;
	wire [7:0]ascii;
	output wire [7:0] o_ascii;

	ps2_keyboard ps2(.clk(clk),.clrn(clrn),.ps2_clk(ps2_clk),.ps2_data(ps2_data),.data(ps2code),
 .ready(ready),.nextdata_n(nextdata_n),.overflow(overflow));
	ps2_ascii p2a(.pscode(out_d),.shift(inner_shift),.ctrl(ctrl),.ascii(ascii));

	d_trigger d(.en(~outputen),.in_data(ps2code),.clk(clk),.out(out_d));

	// seg7display_h s2(.en(1'b1),.in(ascii[3:0]),.hex(hexascii[6:0]));
	// seg7display_h s3(.en(1'b1),.in(ascii[7:4]),.hex(hexascii[13:7]));

	assign o_ascii = outputen?ascii:0;
	always @(posedge clk)
	begin
		if(ready)
		begin
			if(last_f0)
				last_f0<=0;
			else
			begin
				outputen=1'b1;
				if(ps2code!=8'hf0 && ps2code!=8'he0 && !is_press)
				begin
					count<=count+1;
					if(!is_press)
					is_press<=1'b1;
				end
			end
			case(ps2code)
			8'h58:
			begin
				if(!last_f0)
					caps=~caps;
			end
			8'h12:
			begin
				if(!last_f0)
					shift=1'b1;
				else
					shift=1'b0;
			end
			8'h59:
			begin
				if(!last_f0)
					shift=1'b1;
				else
					shift=1'b0;
			end
			8'h14:
			begin
				if(!last_f0)
					ctrl=1'b1;
				else
					ctrl=1'b0;
			end
			8'h11:
			begin
				if(!last_f0)
					alt=1'b1;
				else
					alt=1'b0;
			end
			8'hf0:
			begin
			is_press<=1'b0;
			last_f0<=1'b1;
			outputen=1'b0;
			end
			8'he0:outputen=1'b0;
			endcase
		end
		nextdata_n<=1'b0;
	end
	assign inner_shift = shift|caps;
endmodule
