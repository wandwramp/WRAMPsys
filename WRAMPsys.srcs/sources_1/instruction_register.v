/*
########################################################################
# This file is part of WRAMPsys, a Verilog implimentaion of WRAMP.
#
# Copyright (C) 2019 The University of Waikato, Hamilton, New Zealand.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
########################################################################
*/

module instruction_register (
  input             rst_n,
  input             clk,
  
  input             write_enable,
  input      [31:0] write_data,
  input             imm_16_out,
  input             imm_20_out,
  input             sign_extend,
  
  output     [31:0] a_out, //A_BUS
  output     [31:0] current_instruction
  );
    
    
    
    
	reg [31:0] ir_register;
	reg [31:0] imm_out;
	
	assign a_out = ( imm_16_out || imm_20_out ) ? imm_out : 32'hzzzzzzzz;
	
	assign current_instruction = ir_register;

	// Controls imm_out depending on input signals.
	always @(*) begin
		if (imm_16_out) begin
			if (sign_extend) begin
				imm_out = {{16{ir_register[15]}},ir_register[15:0]};	//signextend immediate
			end
			else begin
				imm_out = {16'b0,ir_register[15:0]};					//load raw immediate
			end
		end
		else if (imm_20_out) begin
			if (sign_extend) begin
				imm_out = {{12{ir_register[19]}},ir_register[19:0]};	//sign extend immediate
			end
			else begin
				imm_out = {12'b0,ir_register[19:0]};					//load raw immediate
			end
		end
	end

	always @(posedge clk) begin
		if (!rst_n) begin
			ir_register = 32'b0;
		end
        if (write_enable) begin				//update ir with new ins
            ir_register = write_data;
		end
	end

endmodule
