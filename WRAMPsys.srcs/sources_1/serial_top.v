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

module serial_top(
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

	//used to test the serialport1 without having to run WRAMPmon, simply echos input char on serial port

	reg [3:0] clkc = 0; 
	always @(posedge clk100MHz) begin
		clkc = clkc + 1;
	end
	wire clk;
	assign clk = clkc[3];  //clock scaler, should mimic the scaler in wramp_wrapper.v
	
	reg  [31:0] internal_data, next_internal_data;

	wire rst_n;
	assign rst_n = ~buttons[0];

	reg read_enable, next_rd_en;
	wire write_enable;
	assign write_enable = ~read_enable;

	wire [31:0] data_bus;
	assign data_bus = read_enable ? 32'hzzzzzzzz : internal_data;

	reg [19:0] address, next_address;

	wire serial_irq_n;
	wire [7:0] TxData;
	wire [7:0] RxData;

	parameter [31:0] //address of the serial ports registers 
		RxDataReg = 1,
		TxDataReg = 0,
		StatusReg = 3;
		
	parameter [3:0]
		RxPoll_STATE = 0,
		RxRead_STATE = 1,
		Stall1_STATE = 2,
		TxPoll_STATE = 3,
		TxWrit_STATE = 4,
		Stall2_STATE = 5;
	reg [3:0] next_STATE, STATE;


	always @(posedge clk) begin

		STATE <= next_STATE;
		address <= next_address;
		read_enable <= next_rd_en;
		internal_data <= next_internal_data;

		if (~rst_n) begin
			STATE <= RxPoll_STATE;
			address <= StatusReg;
			read_enable <= 1;
			internal_data <= 0;
		end
	end


	always @(*) begin

		next_address = StatusReg;
		next_rd_en = 1;
		next_internal_data = internal_data;
		next_STATE = RxPoll_STATE;

		case(STATE)

			RxPoll_STATE: begin
				if (data_bus[0]) begin //if packet recieved
					next_STATE = RxRead_STATE;
					next_address = RxDataReg;
					next_rd_en = 1;
				end
				else begin	//poll for packet
					next_STATE = RxPoll_STATE;
					next_address = StatusReg;
					next_rd_en = 1;
				end
			end

			RxRead_STATE: begin //read packet			
				next_address = RxDataReg;
				next_rd_en = 1;
				next_STATE = Stall1_STATE;
			end

			Stall1_STATE: begin //save packet
				next_internal_data = data_bus;
				next_address = StatusReg;
				next_rd_en = 1;
				next_STATE = TxPoll_STATE;
			end

			TxPoll_STATE: begin
				if (data_bus[1]) begin //if packet ready to send
					next_STATE = TxWrit_STATE;
					next_address = TxDataReg;
					next_rd_en = 0;
				end
				else begin	//poll for tx ready
					next_STATE = TxPoll_STATE;
					next_address = StatusReg;
					next_rd_en = 1;
				end
			end

			TxWrit_STATE: begin //write packet
				next_address = TxDataReg;
				next_rd_en = 0;
				next_STATE = Stall2_STATE;
			end

			Stall2_STATE: begin //delay for packet write
				next_address = StatusReg;
				next_rd_en = 1;
				next_STATE = RxPoll_STATE;
			end


		endcase
	end

	serial_port serial_port(
		rst_n,
		clk,
		read_enable,
		write_enable,
		data_bus,
		address,
		serial_irq_n,
		Tx1,
		Rx1
		); 


endmodule
