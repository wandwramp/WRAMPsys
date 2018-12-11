// Daniel Oosterwijk & Tyler Marriner
// University of Waikato, 2018

// This module is only used as the temp register
module register (
	// Synchronous reset and clock
	input             rst_n,
	input             clk,

	// Write port
	input             write_enable,
	input [31:0]      write_value,

	// Read port
	input             read_enable,
	output [31:0]     read_value
	);

	reg [31:0] value;

	assign read_value = read_enable ? value : 32'hzzzzzzzz;

	always @(posedge clk) begin
		if (!rst_n)
			value <= 0;
		else if (write_enable)
			value <= write_value;
	end

endmodule
