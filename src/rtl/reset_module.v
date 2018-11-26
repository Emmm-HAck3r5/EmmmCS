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
  File: reset_module.v
  Project: EmmmCS
  File Created: 2018-11-26 21:49:13
  Author: Chen Haodong (easyai@outlook.com)
  --------------------------
  Last Modified: 2018-11-26 22:11:03
  Modified By: Chen Haodong (easyai@outlook.com)
 */

module reset_module(clk,rst_n);
input clk;
output rst_n;
reg [15:0]cnt;
reg rst_n;
 
always@(posedge clk)
begin
	begin
		if(cnt<16'hffff)
		begin
			cnt<=cnt+1;
			rst_n<=0;
		end
		else
			rst_n<=1;
	end
end
endmodule
