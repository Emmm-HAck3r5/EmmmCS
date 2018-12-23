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
  File: yakbd_ps2ascii.v
  Project: EmmmCS
  File Created: 2018-12-23 13:24:07
  Author: Chen Haodong (easyai@outlook.com)
  --------------------------
  Last Modified: 2018-12-23 13:31:58
  Modified By: Chen Haodong (easyai@outlook.com)
 */

module ps2_ascii(pscode,shift,ctrl,ascii);
	input [7:0]pscode;
	input shift;
    input ctrl;
	output reg[7:0]ascii;
	
	always @(pscode or shift)
	begin
        if(ctrl && pscode == 8'h21) ascii=8'h14;
        else
        begin
		    if(shift)
		    begin
		    	case(pscode)
		    		8'h0e:ascii=8'h7e;
		    		8'h16:ascii=8'h21;
		    		8'h1e:ascii=8'h40;
		    		8'h26:ascii=8'h23;
		    		8'h25:ascii=8'h24;
		    		8'h2e:ascii=8'h25;
		    		8'h36:ascii=8'h5e;
		    		8'h3d:ascii=8'h26;
		    		8'h3e:ascii=8'h2a;
		    		8'h46:ascii=8'h28;
		    		8'h45:ascii=8'h29;
		    		8'h4e:ascii=8'h5f;
		    		8'h55:ascii=8'h2b;
		    		8'h5d:ascii=8'h7c;
		    		8'h15:ascii=8'h51;
		    		8'h1d:ascii=8'h57;
		    		8'h24:ascii=8'h45;
		    		8'h2d:ascii=8'h52;
		    		8'h2c:ascii=8'h54;
		    		8'h35:ascii=8'h59;
		    		8'h3c:ascii=8'h55;
		    		8'h43:ascii=8'h49;
		    		8'h44:ascii=8'h4f;
		    		8'h4d:ascii=8'h50;
		    		8'h54:ascii=8'h7b;
		    		8'h5b:ascii=8'h7d;
		    		8'h1c:ascii=8'h41;
		    		8'h1b:ascii=8'h53;
		    		8'h23:ascii=8'h44;
		    		8'h2b:ascii=8'h46;
		    		8'h34:ascii=8'h47;
		    		8'h33:ascii=8'h48;
		    		8'h3b:ascii=8'h4a;
		    		8'h42:ascii=8'h4b;
		    		8'h4b:ascii=8'h4c;
		    		8'h4c:ascii=8'h3a;
		    		8'h52:ascii=8'h22;
		    		8'h1a:ascii=8'h5a;
		    		8'h22:ascii=8'h58;
		    		8'h21:ascii=8'h43;
		    		8'h2a:ascii=8'h56;
		    		8'h32:ascii=8'h42;
		    		8'h31:ascii=8'h4e;
		    		8'h3a:ascii=8'h4d;
		    		8'h41:ascii=8'h3c;
		    		8'h49:ascii=8'h3e;
		    		8'h4a:ascii=8'h3f;
		    		//common
		    		//no support for number keyboard
		    		//so we don't need to process the conflict between the direction keys and number keys
		    		8'h29:ascii=8'h20;
		    		8'h66:ascii=8'h8;
		    		8'h5a:ascii=8'ha;
		    		8'h75:ascii=8'h1;
		    		8'h72:ascii=8'h2;
		    		8'h6b:ascii=8'h3;
		    		8'h74:ascii=8'h4;
		    		8'hf0:ascii=8'h5;
		    		default:ascii=8'h00;
		    	endcase
		    end
		    else
		    begin
		      case(pscode)
		    		8'h0e:ascii=8'h60;
		    		8'h16:ascii=8'h31;
		    		8'h1e:ascii=8'h32;
		    		8'h26:ascii=8'h33;
		    		8'h25:ascii=8'h34;
		    		8'h2e:ascii=8'h35;
		    		8'h36:ascii=8'h36;
		    		8'h3d:ascii=8'h37;
		    		8'h3e:ascii=8'h38;
		    		8'h46:ascii=8'h39;
		    		8'h45:ascii=8'h30;
		    		8'h4e:ascii=8'h2d;
		    		8'h55:ascii=8'h3d;
		    		8'h5d:ascii=8'h5c;
		    		8'h15:ascii=8'h71;
		    		8'h1d:ascii=8'h77;
		    		8'h24:ascii=8'h65;
		    		8'h2d:ascii=8'h72;
		    		8'h2c:ascii=8'h74;
		    		8'h35:ascii=8'h79;
		    		8'h3c:ascii=8'h75;
		    		8'h43:ascii=8'h6c;
		    		8'h44:ascii=8'h6f;
		    		8'h4d:ascii=8'h70;
		    		8'h54:ascii=8'h5b;
		    		8'h5b:ascii=8'h5d;
		    		8'h1c:ascii=8'h61;
		    		8'h1b:ascii=8'h73;
		    		8'h23:ascii=8'h64;
		    		8'h2b:ascii=8'h66;
		    		8'h34:ascii=8'h67;
		    		8'h33:ascii=8'h68;
		    		8'h3b:ascii=8'h6a;
		    		8'h42:ascii=8'h6b;
		    		8'h4b:ascii=8'h6c;
		    		8'h4c:ascii=8'h3b;
		    		8'h52:ascii=8'h27;
		    		8'h1a:ascii=8'h7a;
		    		8'h22:ascii=8'h78;
		    		8'h21:ascii=8'h63;
		    		8'h2a:ascii=8'h76;
		    		8'h32:ascii=8'h62;
		    		8'h31:ascii=8'h6e;
		    		8'h3a:ascii=8'h6d;
		    		8'h41:ascii=8'h2c;
		    		8'h49:ascii=8'h2e;
		    		8'h4a:ascii=8'h2f;
		    		//common
		    		8'h29:ascii=8'h20;
		    		8'h66:ascii=8'h8;
		    		8'h5a:ascii=8'ha;
		    		8'h75:ascii=8'h1;
		    		8'h72:ascii=8'h2;
		    		8'h6b:ascii=8'h3;
		    		8'h74:ascii=8'h4;
		    		8'hf0:ascii=8'h5;
		    		default:ascii=8'h00;
		    	endcase
		    end
        end
	end
endmodule
