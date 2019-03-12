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

module program_counter (
	// Asynchronous reset and clock
	input         rst_n,
	input         clk,

	// Increment. Takes precedence over write_enable
	input         increment,

	// Write port
	input         write_enable,
	input [31:0]  write_value,

	// Read port
	input         read_enable,
	output [31:0] read_value
	);

	
	reg [19:0]    pc_reg;

	assign read_value = read_enable ? {12'h000,pc_reg} : 32'hzzzzz;

	always @(posedge clk) begin
        if (!rst_n) begin
            // We reset to the start of ROM 
            // This is a virtual address that points to the rom hardware.
            pc_reg <= 20'h80000; //WRAMPmon will be loaded here by the ROM module
            
            // If we want to skip WRAMPmon, we can just load a program straight into ram
            //pc_reg <= 20'h00000; //FOR DEBUGGING ONLY DO NOT BUILD WITH THIS SETTING
        end   
        else if (increment) begin
            pc_reg <= pc_reg + 1;
        end
        else if (write_enable) begin 
            pc_reg <= write_value[19:0];
        end
    end

endmodule
