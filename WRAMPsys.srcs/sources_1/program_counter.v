// Daniel Oosterwijk & Tyler Marriner
// University of Waikato, 2018

module program_counter (
	// Asynchronous reset and clock
	input         rst_n,
	input         clk,

	// Increment. Takes precedence over write_enable
	input         increment,

	// Write port
	input         write_enable,
	input [31:0]  write_value,

	// Read port
	input         read_enable,
	output [31:0] read_value
	);

	
	reg [19:0]    pc_reg;

	assign read_value = read_enable ? {12'h000,pc_reg} : 32'hzzzzz;

	always @(posedge clk) begin
        if (!rst_n) begin
            // We reset to the start of ROM 
            // This is a virtual address that points to the rom hardware.
            pc_reg <= 20'h80000; //WRAMPmon will be loaded here by the ROM module
            
            // If we want to skip WRAMPmon, we can just load a program straight into ram
            //pc_reg <= 20'h00000; //FOR DEBUGGING ONLY DO NOT BUILD WITH THIS SETTING
        end   
        else if (increment) begin
            pc_reg <= pc_reg + 1;
        end
        else if (write_enable) begin 
            pc_reg <= write_value[19:0];
        end
    end

endmodule
