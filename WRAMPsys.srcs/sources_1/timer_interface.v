// Daniel Oosterwijk & Tyler Marriner
// University of Waikato, 2018

`timescale 1ns / 1ps

module timer_interface(
    input rst_n,
    input clk,
    input read_enable,
    input write_enable,
    inout [31:0] data_bus,
    input [19:0] address_bus,
    output timer_irq_n
    );

	reg [1:0] control = 0;
	reg [15:0] load = 0;
	reg [15:0] count = 0;
	reg [1:0] ack = 0;
	reg run_again = 0;

	wire timer_enabled = control[0];
	wire auto_restart = control[1];

	reg [15:0] data;
	assign data_bus = read_enable ? {16'h0000,data} : 32'hzzzzzzzz;
	assign timer_irq_n = ack == 0;

	wire clk_scaled;
	reg has_set_ack = 0;
	reg has_decremented = 0;

	// small module to clk at 2400Hz (2400.153609831Hz due to rounding)
	clock_scaler clock_scaler(clk, clk_scaled); 

	always @(posedge clk) begin
		if (!rst_n) begin
			control = 0;
			load = 0;
			ack = 0;
			data = 0;
			has_decremented = 0;
			count = 0;
			run_again = 1;
		end
		
		// This section handles the timer and restart logic
		if (timer_enabled) begin
			// We should only decrement once per clk_scaled cycle
			has_decremented = clk_scaled & has_decremented;
			
			// Decrement
			if (clk_scaled && !has_decremented && count != 0) begin
				count = count - 1;
				has_decremented = 1;
				// If we're now at zero, set the ack bits
				if (count == 0) begin
					ack = {auto_restart && ack[0] == 1, 1'b1};
					control = {2{control[1]}};
				end
			end
			// If we should restart, do so
			if (count == 0 && (run_again || auto_restart)) begin
				count = load;
				run_again = auto_restart;
			end
		end
		// If the timer was disabled, prime for another single-shot
		else begin
			run_again = 1;
		end


		// This section interacts with the I/O ports
		data <= 16'h0000;
		case (address_bus[12:0])
			0: begin
				if (write_enable)
					control = data_bus[1:0];
				else data[1:0] = control;
			end
			1: begin
				if (write_enable)
					load <= data_bus[15:0];
				else data[15:0] <= load;
			end
			2: begin
				data[15:0] = count;
			end
			3: begin
				if (write_enable)
					ack = data_bus[1:0];
				else data[1:0] = ack;
			end
		endcase
	end

endmodule
