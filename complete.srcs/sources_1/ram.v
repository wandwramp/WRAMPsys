`timescale 1ns / 1ps

module ram(
    input clk,
    input read_en,
    input write_en,
    inout [31:0] data_bus,
    input [19:0] address_bus
    );

	parameter RAM_WIDTH = 'h4000; //16k words 

	reg [31:0] data;
	reg [31:0] ram[0:RAM_WIDTH-1];

	assign data_bus = read_en ? data : 32'hzzzzzzzz;

	// This initialisation also gets done by WRAMPmon, but we can do it again here for free.
	genvar i;
	generate 
		for (i = 0; i < RAM_WIDTH; i = i + 1) begin
			initial ram[i] = 32'hffffffff;
		end
	endgenerate

	// Load some data as an initial program in RAM.
	// This uses files created by Trim on an srec.
	//parameter filename = "file.mem";	//add file.mem as a source in vivado
	//initial $readmemh(filename, ram); 
	//FOR DEBUGGING ONLY DO NOT BUILD WITH THIS SETTING

	// This gets inferred into block RAM by the Vivado synthesis tool.
	// It behaves the same as distributed (regular) ram, but takes a cycle to do anything.
	always @(posedge clk) begin
		if (write_en) begin
			ram[address_bus] <= data_bus;
		end
		else data <= ram[address_bus];
	end
    
endmodule

