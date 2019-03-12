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

module wramp_wrapper(
    input clk100MHz,
    // Parallel I/O
    input [15:0] sw,
    output [15:0] led_out_hardware,
    input [4:0] buttons,
    output [7:0] seg,
    output [3:0] an,
    // Serial data lines for two serial ports
    output Tx1,
    input Rx1,
    output Tx2,
    input Rx2
    );
    
	reg keep_longer = 1;
	reg force_rst = 0;
	wire rst_n;
	assign rst_n = ~buttons[0] && force_rst; //reset is tied to the top button 

	wire write_enable_n;
	wire read_enable_n;

	wire [31:0] data_bus;
	wire [23:0] address_bus;

	wire rom_cs_n;
	wire ram_cs_n;
	wire timer_cs_n;
	wire parallel_cs_n;
	wire serial1_cs_n;
	wire serial2_cs_n;
	wire aux1_cs_n;
	wire aux2_cs_n;
	wire sys_cs_n;

	wire break_irq_n;
	wire user_irq_n;
	wire timer_irq_n;
	wire parallel_irq_n;
	wire serial1_irq_n;
	wire serial2_irq_n;
	wire aux1_irq_n;
	wire aux2_irq_n;

	wire rom_lock;

	wire led_out_hardware_from_parallel;


	wire [15:0] pc_out_value;
	wire [15:0] debug_out_value;


	// We scale the 100MHz clock down 16x to pass timing constraints,
	// since some of our datapaths are too deep to pass at the full speed.
	reg [3:0] clk_counter = 0;
	wire clk = clk_counter[3]; //6.25MHz
	always @(posedge clk100MHz) begin
		clk_counter = clk_counter + 1;
	end

	// Hold the reset signal for two clock cycles
	always @(posedge clk) begin
		if (!keep_longer)
			force_rst = 1;
		if (keep_longer)
			keep_longer = 0;
	end
		
	// Serial interface 1
	serial_port serial1(
		.rst_n(rst_n),
		.clk(clk),
		.read_enable(~read_enable_n && ~serial1_cs_n),
		.write_enable(~write_enable_n && ~serial1_cs_n),
		.data_bus(data_bus),
		.address_bus(address_bus),
		.serial_irq_n(serial1_irq_n),
		.Tx(Tx1),
		.Rx(Rx1)
	);
	// Serial interface 2
	serial_port serial2(
		.rst_n(rst_n),
		.clk(clk),
		.read_enable(~read_enable_n && ~serial2_cs_n),
		.write_enable(~write_enable_n && ~serial2_cs_n),
		.data_bus(data_bus),
		.address_bus(address_bus),
		.serial_irq_n(serial2_irq_n),
		.Tx(Tx2),
		.Rx(Rx2)
	);
	// Parallel interface
	parallel_interface parallel(
		.rst_n(rst_n),
		.clk(clk),
		.sw(sw),
		.led_out_hardware(led_out_hardware),
		.buttons(buttons),
		.seg(seg),
		.an(an),
		.read_enable(~read_enable_n && ~parallel_cs_n),
		.write_enable(~write_enable_n && ~parallel_cs_n),
		.data_bus(data_bus),
		.address_bus(address_bus),
		.parallel_irq_n(parallel_irq_n)
	);

	// Timer interface
	timer_interface timer(
		.rst_n(rst_n),
		.clk(clk),
		.read_enable(~read_enable_n && ~timer_cs_n),
		.write_enable(~write_enable_n && ~timer_cs_n),
		.data_bus(data_bus),
		.address_bus(address_bus),
		.timer_irq_n(timer_irq_n)
	);

	// Ram unit
	ram ram(
		.clk(clk),
		.read_en(~read_enable_n && ~ram_cs_n),
		.write_en(~write_enable_n && ~ram_cs_n),
		.data_bus(data_bus),
		.address_bus(address_bus)
	);

	// Rom unit
	rom_wrampmon rom(
		.clk(clk),
		.read_en(~read_enable_n && ~rom_cs_n),
		.write_en(~write_enable_n && ~rom_cs_n),
		.data_bus(data_bus),
		.address_bus(address_bus)
	);

	// Aux1
	assign aux1_irq_n = 1;
	// Aux2
	assign aux2_irq_n = 1;
	// Sys 
	// Generates interrupts from the user interrupt button,
	// which does not exist on the Basys3 implementation of WRAMP. //TODO?
	// Would write 0 to memory address 0x7f000 to acknowled_out_hardwarege.
	assign user_irq_n = ~buttons[4];

	CPU cpu(
		.rst_n(rst_n),
		.clk(clk),
		.write_enable_n(write_enable_n),
		.read_enable_n(read_enable_n),
		.data_bus(data_bus),
		.address_bus(address_bus),
		.rom_cs_n(rom_cs_n),
		.ram_cs_n(ram_cs_n),
		.timer_cs_n(timer_cs_n),
		.parallel_cs_n(parallel_cs_n),
		.serial1_cs_n(serial1_cs_n),
		.serial2_cs_n(serial2_cs_n),
		.aux1_cs_n(aux1_cs_n),
		.aux2_cs_n(aux2_cs_n),
		.sys_cs_n(sys_cs_n),
		.break_irq_n(break_irq_n),
		.user_irq_n(user_irq_n),
		.timer_irq_n(timer_irq_n),
		.parallel_irq_n(parallel_irq_n),
		.serial1_irq_n(serial1_irq_n),
		.serial2_irq_n(serial2_irq_n),
		.aux1_irq_n(aux1_irq_n),
		.aux2_irq_n(aux2_irq_n),
		.rom_lock(rom_lock)
	);
endmodule
