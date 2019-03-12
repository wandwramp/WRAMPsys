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

// This module is only used as the temp register
module register (
	// Synchronous reset and clock
	input             rst_n,
	input             clk,

	// Write port
	input             write_enable,
	input [31:0]      write_value,

	// Read port
	input             read_enable,
	output [31:0]     read_value
	);

	reg [31:0] value;

	assign read_value = read_enable ? value : 32'hzzzzzzzz;

	always @(posedge clk) begin
		if (!rst_n)
			value <= 0;
		else if (write_enable)
			value <= write_value;
	end

endmodule
