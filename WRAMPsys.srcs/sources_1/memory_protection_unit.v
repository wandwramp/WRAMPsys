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

module memory_protection_unit (
	input             check_mem,
	input             user_mode,

	input  [19:0]     address_in,
	output [19:0]     address_out,

	input  [19:0]     user_base,
	input  [19:0]     protection_table,

	input  [31:0]     load_data,

	output            memory_violation
	);


	wire [19:0] table_entry;
	wire [19:0] absolute_address;

	// This computes the address of the table word that holds the protection
	// bit for the requested memory location
	assign table_entry = protection_table + {15'b0,absolute_address[19:15]};

	// This selects between absolute and base-relative addressing
	assign absolute_address = user_mode ? (address_in + user_base) : address_in;

	// This selects between using the address or the table entry
	assign address_out = check_mem ? table_entry : absolute_address;

	// This selects the appropriate bit from the memory protection word
	assign memory_violation = check_mem ? ~(load_data[31 - absolute_address[14:10]]) : 0;

endmodule
