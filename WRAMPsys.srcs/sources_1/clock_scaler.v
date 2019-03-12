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

module clock_scaler(
    input in,
    output reg out
    );
    
    reg [14:0] current;
    
	//(SHOULD run at 2400Hz but rounding means 2400.153609831Hz)
    parameter load_value = 1302; //6.25MHz / 2400 Hz, rounded and divided by 2 as 2 pulses is one clock cycle
    initial begin
        current = load_value;
        out = in;
    end
    
    always @(posedge in) begin
        current = current - 1;
        if (current == 0) begin
            out = ~out;
            current = load_value;
        end
    end
    
endmodule
