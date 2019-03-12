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

module rom_wrampmon(
    input clk,
    input read_en,
    input write_en,
    inout [31:0] data_bus,
    input [19:0] address_bus
    );

	//We only need ~19000, so the rest have default X values.
	parameter ROM_WIDTH = 'h8000; 
	
	reg [31:0] data;
	reg [31:0] rom[0:ROM_WIDTH-1];
	assign data_bus = read_en ? data : 32'hzzzzzzzz;

	//this uses files created by Trim on an srec. 
	parameter READMEM_FILENAME = "monitor.mem";
	initial $readmemh(READMEM_FILENAME, rom);
	//THIS IS REQUIRED TO BUILD WRAMP, WITHOUT A PROGRAM IN ROM THE CPU WILL JUST SPIN
	//monitor.mem can be built from the WRAMPmon repo, but the .mem should be included with this repo


	always @(posedge clk) begin
		if (write_en) begin
			rom[address_bus[18:0]] <= data_bus;
		end
		else 
			data <= rom[address_bus[18:0]];
	end
    
endmodule

