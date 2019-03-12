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

module parallel_interface(
    // Basic control signals
    input rst_n,
    input clk,
    
    // Wires to the board hardware
    input [15:0] sw,
    output reg [15:0] led_out_hardware,
    input [4:0] buttons,
    output [7:0] seg,
    output [3:0] an,
    
    // Control signals from cpu
    input read_enable,
    input write_enable,
    inout [31:0] data_bus,
    input [19:0] address_bus,
    
    // Interrupt
    output parallel_irq_n
    );

	// Parallel control register
	reg [1:0] control = 0;
	wire interrupt_enable = control[1];
	wire hex_decode = control[0];

	// Interrupt acknowled_out_hardwarege register
	reg int_ack = 0;

    // Used to avoid debouncing and make interrupts trigger on changes
	reg [15:0] old_sw[1:0];
	reg [4:0] old_buttons[1:0];

	// SSD value storage
	reg [7:0] ssd_values[3:0];
	
	//SSD internal data
	reg [1:0] index; //active SSD
	reg [9:0] scaler; //prescaler to slow down SSD flashing
	reg [7:0] SSDraw;
    reg [7:0] SSDhex;
    reg [3:0] anode;
    reg [7:0] SSDout;
    
    assign an = anode;
    assign seg = hex_decode ? SSDhex : ~SSDraw[7:0]; //either hex decode to the SSD or use raw values 

	reg [31:0] data;
	assign data_bus = read_enable ? data : 32'hzzzzzzzz;
	// IRQ stays high until acknowled_out_hardwareged, so this is fine
	assign parallel_irq_n = ~int_ack;

    initial begin
	    led_out_hardware = 0;
	    index = 0;
	    scaler = 0;
	    control = 1;
	    ssd_values[0] = 0;
	    ssd_values[1] = 0;
	    ssd_values[2] = 0;
	    ssd_values[3] = 0;
	end

    // Interrupt generation logic
    always @(posedge clk) begin
        old_sw[1] = old_sw[0];
        old_sw[0] = sw;
        old_buttons[1] = old_buttons[0];
        old_buttons[0] = buttons[3:1]; //ignores the first button as its rst and the last as its usr_int
    end
    
    wire sw_or_buttons_changed = 
        old_sw[1] != old_sw[0] ||
        old_buttons[1] != old_buttons[0];

	// Base address is 0x73000
	// Controls I/O
	always @(posedge clk) begin
		if (!rst_n) begin
		    data = 0;
		    control = 1;
		    int_ack = 0;
		    led_out_hardware = 0;
		    ssd_values[0] = 0;
		    ssd_values[1] = 0;
		    ssd_values[2] = 0;
		    ssd_values[3] = 0;
		end
		
		if (sw_or_buttons_changed && interrupt_enable) begin
            int_ack = 1;
		end
        
	  	scaler = scaler + 1;
		data = 32'h00000000;
		case (address_bus[11:0])
		    0: begin //SW address
		        data[15:0] = sw;
		    end

		    1: begin //buttons address
		        data[4:0] = buttons[3:1];
		    end

		    4: begin //ctrl adress
		        if (write_enable)
		            control = data_bus[1:0];
		        else data[1:0] = control;
		    end

		    5: begin //int_ack address
		        if (write_enable)
		            int_ack = data_bus[0];
		        else data[0] = int_ack;
		    end

		    6: begin //SSD[0] address
		        if (write_enable)
		            ssd_values[0] = data_bus[7:0];
		        else data[7:0] = ssd_values[0];
		    end
		    7: begin //SSD[1] address
		        if (write_enable)
		            ssd_values[1] = data_bus[7:0];
		        else data[7:0] = ssd_values[1];
		    end

			//SSD 2 can be accessed from both 0x73002 and 0x73008, allows backwards combatibility and sequential adressing
		    2, 8: begin //SSD[2] address 				
		        if (write_enable)
		            ssd_values[2] = data_bus[7:0];
		        else data[7:0] = ssd_values[2];
		    end

			//SSD 3 can be accessed from both 0x73003 and 0x73009, allows backwards combatibility and sequential adressing
		    3, 9: begin //SSD[3] address
		        if (write_enable)
		            ssd_values[3] = data_bus[7:0];
		        else data[7:0] = ssd_values[3];
		    end

		    10: begin //LEDs address
		        if (write_enable)
		            led_out_hardware = data_bus[15:0];
		        else data[15:0] = led_out_hardware;
		    end
		endcase
	end

    // Controls 7seg outputs
    // We pulse each 7seg with its value for 1/4 of the time
	always @(negedge scaler[8]) fork //index of scaler controls the multiplex speed
	
	    case (index) 							//only draw one SSD at a time
	        2'b00   : SSDraw = ssd_values[0];
	        2'b01   : SSDraw = ssd_values[1];
	        2'b10   : SSDraw = ssd_values[2];
	        2'b11   : SSDraw = ssd_values[3];
	    endcase
	            
	    case (SSDraw[3:0])						//SSD hex decode table
	        4'h0: SSDhex = 8'b11000000; //0
	        4'h1: SSDhex = 8'b11111001; //1
	        4'h2: SSDhex = 8'b10100100; //2
	        4'h3: SSDhex = 8'b10110000; //3
	        4'h4: SSDhex = 8'b10011001; //4
	        4'h5: SSDhex = 8'b10010010; //5
	        4'h6: SSDhex = 8'b10000010; //6
	        4'h7: SSDhex = 8'b11111000; //7
	        4'h8: SSDhex = 8'b10000000; //8
	        4'h9: SSDhex = 8'b10010000; //9
	        4'hA: SSDhex = 8'b10001000; //A
	        4'hB: SSDhex = 8'b10000011; //B
	        4'hC: SSDhex = 8'b11000110; //C
	        4'hD: SSDhex = 8'b10100001; //D
	        4'hE: SSDhex = 8'b10000110; //E
	        4'hF: SSDhex = 8'b10001110; //F  
	    endcase
	    
	    case(index)								//SSD is active low
	        2'b00 : anode = 4'b0111;
	        2'b01 : anode = 4'b1011;
	        2'b10 : anode = 4'b1101;
	        2'b11 : anode = 4'b1110;
	    endcase
	    
	    index = index + 1;    
	join
    
endmodule

