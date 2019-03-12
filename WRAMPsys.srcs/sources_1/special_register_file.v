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

module special_register_file (
	// Reset and clock
	input rst_n,
	input clk,

	// Register read/write signals
	input  [3:0]       reg_select,
	input              read_enable,
	output [31:0]      read_value,
	input              write_enable,
	input  [31:0]      write_value,

	// Increment the instruction count register
	input              inc_icount,
	// Save or restore state due to an exception
	input              save_state,
	input              restore_state,

	output [7:0]       interrupt_mask,
	input  [3:0]       exception_status,
	input  [7:0]       interrupt_status,
	output             interrupts_enabled,
	output             kernel_mode,

	output [19:0]      user_base,
	output [19:0]      protection_table
	);

	// Get the register name definitions
	`include "wramp.vh"

	reg [31:0] register[0:15];

	assign read_value = read_enable ? register[reg_select] : 32'hzzzzzzzz;
	// Output misc signals
	assign interrupt_mask = register[ICTRL_REGNO][11:4];
	assign interrupts_enabled = register[ICTRL_REGNO][1];
	assign kernel_mode = register[ICTRL_REGNO][3];
	assign user_base = register[USERBASE_REGNO][19:0];
	assign protection_table = register[WPTABLE_REGNO][19:0];


	//not all special registers are defined, but they all need to exist
	always @(posedge clk) begin
		if (!rst_n) begin
			register[0]              = 32'hXXXXXXXX;
			register[1]              = 32'hXXXXXXXX;
			register[2]              = 32'hXXXXXXXX;
			register[3]              = 32'hXXXXXXXX;
			register[ICTRL_REGNO]    = 32'h00000008; // Kernel mode, no interrupts
			register[ISTAT_REGNO]    = 32'b0;
			register[ICOUNT_REGNO]   = 32'b0;
			register[CCOUNT_REGNO]   = 32'b0;
			register[IVEC_REGNO]     = 32'b0;
			register[IAR_REGNO]      = 32'b0;
			register[ESP_REGNO]      = 32'b0; 	//was supposed to be an exception stack pointer
												//was never implimented/not needed (exc can use normal stack)
			register[ERS_REGNO]      = 32'b0;
			register[WPTABLE_REGNO]  = 32'b0;
			register[USERBASE_REGNO] = 32'b0;
			register[14]             = 32'hXXXXXXXX;
			register[15]             = 32'hXXXXXXXX;
		end
		
		// Enable writing to registers
		if (write_enable) begin
			if (reg_select != ISTAT_REGNO) begin
				register[reg_select] = write_value;
			end
		end

		// Increment the cycle count register
		register[CCOUNT_REGNO] = register[CCOUNT_REGNO] + 1;
		
		// Increment the instruction count register
		if (inc_icount) begin
			register[ICOUNT_REGNO] = register[ICOUNT_REGNO] + 1;
		end
		
		// If we are taking an exception
		if (save_state) begin
			// Capture the cause of the exception
			// A comment was left in the original VHDL source about fixing this
			// to support software exceptions. Pretty sure they're supported.
			register[ISTAT_REGNO] = {16'h0000,
									exception_status,
									(interrupt_status & interrupt_mask),
									4'b0000};
			// Maintain the kernel/user mode and interrupt enable bits
			// Set kernel mode and disable interrupts for exception handler
			register[ICTRL_REGNO] = {register[ICTRL_REGNO][31:4],
									1'b1,
									register[ICTRL_REGNO][3],
									1'b0,
									register[ICTRL_REGNO][1]};
		end
		
		// If we are returning from an exception
		if (restore_state) begin
			// Maintain the kernel/user mode and interrupt enable bits
			register[ICTRL_REGNO] = {register[ICTRL_REGNO][31:4],
									{2{register[ICTRL_REGNO][2]}},
									{2{register[ICTRL_REGNO][0]}}};
		end
	end

endmodule
