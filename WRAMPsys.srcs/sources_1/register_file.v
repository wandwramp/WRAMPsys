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

`timescale 1ns / 1ps

module register_file (
	// Asynchronous reset and clock
	input         rst_n,
	input         clk,

	// Read port A
	input         read_a_enable,
	input [3:0]   read_a_select,
	output [31:0] read_a_value,

	// Read port B
	input         read_b_enable,
	input [3:0]   read_b_select,
	output [31:0] read_b_value,

	// Write port
	input         write_enable,
	input [3:0]   write_select,
	input [31:0]  write_value
	);

	// The registers
	reg [31:0]      register[0:15];

	// Read the register file
	function [31:0] read_register(input [3:0] idx);
	read_register = (idx == 0) ? 0 : register[idx];
	endfunction

	// Port A - read only
	assign read_a_value = read_a_enable ? read_register(read_a_select) : 32'hzzzzzzzz;

	// Port B - read only
	assign read_b_value = read_b_enable ? read_register(read_b_select) : 32'hzzzzzzzz;

	// Port C - write only. Generate asynchronously-reset flops for the
	// registers in our register file
	genvar n;
	generate for (n = 0; n < 16; n = n + 1) begin  
		//this block of code generates 16 seperate "always blocks", one for each register 
		always @(posedge clk) begin
			if (!rst_n)
				register[n] <= 32'd0;
			else if (write_enable && write_select == n[3:0])
				register[n] <= write_value;
			end
		end
	endgenerate
endmodule
