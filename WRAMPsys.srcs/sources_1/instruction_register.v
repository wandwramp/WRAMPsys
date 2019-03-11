// Daniel Oosterwijk & Tyler Marriner
// University of Waikato, 2018

module instruction_register (
  input             rst_n,
  input             clk,
  
  input             write_enable,
  input      [31:0] write_data,
  input             imm_16_out,
  input             imm_20_out,
  input             sign_extend,
  
  output     [31:0] a_out, //A_BUS
  output     [31:0] current_instruction
  );
    
    
    
    
	reg [31:0] ir_register;
	reg [31:0] imm_out;
	
	assign a_out = ( imm_16_out || imm_20_out ) ? imm_out : 32'hzzzzzzzz;
	
	assign current_instruction = ir_register;

	// Controls imm_out depending on input signals.
	always @(*) begin
		if (imm_16_out) begin
			if (sign_extend) begin
				imm_out = {{16{ir_register[15]}},ir_register[15:0]};	//signextend immediate
			end
			else begin
				imm_out = {16'b0,ir_register[15:0]};					//load raw immediate
			end
		end
		else if (imm_20_out) begin
			if (sign_extend) begin
				imm_out = {{12{ir_register[19]}},ir_register[19:0]};	//sign extend immediate
			end
			else begin
				imm_out = {12'b0,ir_register[19:0]};					//load raw immediate
			end
		end
	end

	always @(posedge clk, negedge rst_n) begin
		if (!rst_n) begin
			ir_register = 32'b0;
		end
		else if (clk) begin
			if (write_enable) begin				//update ir with new ins
				ir_register = write_data;
			end
		end
	end

endmodule
