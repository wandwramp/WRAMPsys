// Daniel Oosterwijk & Tyler Marriner
// University of Waikato, 2018

module memory_protection_unit (
	input             check_mem,
	input             user_mode,

	input  [19:0]     address_in,
	output [19:0]     address_out,

	input  [19:0]     user_base,
	input  [19:0]     protection_table,

	input  [31:0]     load_data,

	output            memory_violation
	);


	wire [19:0] table_entry;
	wire [19:0] absolute_address;

	// This computes the address of the table word that holds the protection
	// bit for the requested memory location
	assign table_entry = protection_table + {15'b0,absolute_address[19:15]};

	// This selects between absolute and base-relative addressing
	assign absolute_address = user_mode ? (address_in + user_base) : address_in;

	// This selects between using the address or the table entry
	assign address_out = check_mem ? table_entry : absolute_address;

	// This selects the appropriate bit from the memory protection word
	assign memory_violation = check_mem ? ~(load_data[31 - absolute_address[14:10]]) : 0;

endmodule
