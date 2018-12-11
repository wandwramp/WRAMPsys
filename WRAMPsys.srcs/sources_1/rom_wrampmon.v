// Daniel Oosterwijk & Tyler Marriner
// University of Waikato, 2018

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

