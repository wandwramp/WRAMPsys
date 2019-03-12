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

module serial_tb();

	reg clk = 0;
	reg [15:0] sw = 16'h0000;
	wire [15:0] led;
	reg [4:0] buttons = 1;
	wire [7:0] seg;
	wire [3:0] an;
	reg RxD = 1;
	wire TxD;


	//length of bit in nanoseconds at 38400baud = (100,000,000Hz/38400Bps) * 10ns/C = 26041.6ns/B
	parameter delay = 26042;  

	always #5 clk = ~clk; //100MHz
	always begin	
		//UART serial char sequence
		//8bits
		//no parity
		//1 stop bit
		//0x75 / 'u' 

		//#(delay) RxD = 1; //Idle 
		//#(delay) RxD = 1; //Idle
		//#(delay) RxD = 1; //Idle
		//#(delay) RxD = 1; //Idle

		#(delay) RxD = 0; //start bit    
		#(delay) RxD = 1; //bit0
		#(delay) RxD = 0; //bit1
		#(delay) RxD = 1; //bit2
		#(delay) RxD = 0; //bit3    
		#(delay) RxD = 1; //bit4
		#(delay) RxD = 1; //bit5
		#(delay) RxD = 1; //bit6
		#(delay) RxD = 0; //bit7    
		#(delay) RxD = 1; //stop bit  

	end

	initial begin
		#500  buttons[0] = 1; //reset is tied to button[0]
		#2000 buttons[0] = 0;
	end

	serial_top sptop(
		clk,
		sw,
		led,
		buttons,
		seg,
		an,
		TxD,
		RxD,
		Tx2,
		Rx2
	); 
		
		
		
	endmodule
