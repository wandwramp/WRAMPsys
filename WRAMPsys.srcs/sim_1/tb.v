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

module tb();

    reg clk = 0;
    always #5 clk = ~clk; //100MHz
    reg [15:0] sw = 16'h8000;
    wire [15:0] led;
    reg [4:0] buttons = 0;
    wire [7:0] seg;
    wire [3:0] an;
    reg Rx = 1;
    wire Tx;
    reg Rx2 = 1;
    wire Tx2;
    
    wramp_wrapper wramp(
        clk,
        sw,
        led,
        buttons,
        seg,
        an,
        Tx,
        Rx,
        Tx2,
        Rx2
    );

endmodule
