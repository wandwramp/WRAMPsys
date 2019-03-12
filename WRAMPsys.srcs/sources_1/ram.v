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

module ram(
    input clk,
    input read_en,
    input write_en,
    inout [31:0] data_bus,
    input [19:0] address_bus
    );

	parameter RAM_WIDTH = 'h4000; //16k words 

	reg [31:0] data;
	reg [31:0] ram[0:RAM_WIDTH-1];

	assign data_bus = read_en ? data : 32'hzzzzzzzz;

	// This initialisation also gets done by WRAMPmon, but we can do it again here for free.
	genvar i;
	generate 
		for (i = 0; i < RAM_WIDTH; i = i + 1) begin
			initial ram[i] = 32'hffffffff;
		end
	endgenerate

	// Load some data as an initial program in RAM.
	// This uses files created by Trim on an srec.
	//parameter filename = "test.mem";	//add test.mem as a source in vivado
	//initial $readmemh(filename, ram); 
	//FOR DEBUGGING ONLY DO NOT BUILD WITH THIS SETTING

	// This gets inferred into block RAM by the Vivado synthesis tool.
	// It behaves the same as distributed (regular) ram, but takes a cycle to do anything.
	always @(posedge clk) begin
		if (write_en) begin
			ram[address_bus] <= data_bus;
		end
		else data <= ram[address_bus];
	end
    
endmodule

