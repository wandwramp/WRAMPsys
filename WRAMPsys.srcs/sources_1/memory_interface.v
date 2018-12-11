// Daniel Oosterwijk & Tyler Marriner
// University of Waikato, 2018

module memory_interface (
	// CPU side ports
	input  [31:0]     data_in,
	output [31:0]     data_out,
	input  [19:0]     cpu_address,

	input             mem_read,
	input             mem_write,
	input             rom_lock,

	// Memory side ports
	inout  [31:0]     data_bus,
	output [19:0]     address_bus,

	output reg        serial1_cs_n,
	output reg        serial2_cs_n,
	output reg        parallel_cs_n,
	output reg        timer_cs_n,
	output reg        ram_cs_n,
	output reg        rom_cs_n,
	output reg        aux1_cs_n,
	output reg        aux2_cs_n,
	output reg        sys_cs_n,

	output            write_enable_n,
	output            read_enable_n
	);
	
	// This is really redundant
    assign address_bus = cpu_address;

	assign write_enable_n = ~mem_write;
	assign read_enable_n = ~mem_read;

	// Handle inout nature of the data bus
	assign data_bus = mem_write ? data_in : 32'hzzzzzzzz;
	assign data_out = mem_read ? data_bus : 32'hzzzzzzzz;

	// Set lines to translate memory addresses into devices
	always @(address_bus or mem_read or mem_write or rom_lock) begin
		serial1_cs_n = 1;
		serial2_cs_n = 1;
		parallel_cs_n = 1;
		timer_cs_n = 1;
		ram_cs_n = 1;
		rom_cs_n = 1;
		aux1_cs_n = 1;
		aux2_cs_n = 1;
		sys_cs_n = 1;
		
		if (mem_read || mem_write) begin
			casez (address_bus[19:12])
				8'b1???????: begin
					if (mem_read || ~rom_lock)
						rom_cs_n = 0;
				end
				8'b000?????: ram_cs_n = 0; //enable the particular module the address is pointing to
				8'h70: serial1_cs_n = 0;
				8'h71: serial2_cs_n = 0;
				8'h72: timer_cs_n = 0;
				8'h73: parallel_cs_n = 0;
				8'h74: aux1_cs_n = 0; //not implimented 
				8'h75: aux2_cs_n = 0;
				8'h7f: sys_cs_n = 0;
			endcase
		end
	end

endmodule
