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

module control_unit (
	input reset_n,
	input clk,

    // Wired directly to the current instruction
	input [31:0] instruction_reg,

	//Here are the control outputs
	//Memory unit control signals
	output reg mem_read,
	output reg mem_write,
	output reg check_mem,
	input memory_violation,

	//Instruction register controls
	output reg ir_in,
	output reg imm_16_out,
	output reg imm_20_out,
	output reg sign_extend,

	//Program counter
	output reg pc_in,
	output reg pc_out,
	output reg pc_inc,

	//Register file
	output reg a_out,
	output reg b_out,
	output reg c_in,
	output reg [3:0] sel_a,
	output reg [3:0] sel_b,
	output reg [3:0] sel_c,

	//Temp register
	output reg temp_in,
	output reg temp_out,

	//ALU
	output reg alu_out,
	output reg alu_start,
	output reg [4:0] alu_func,
	input alu_done,
	input zero,
	input div_zero,
	input overflow,

	//Special register file control signals
	output reg special_reg_in,
	output reg special_reg_out,
	output reg special_reg_save_state,
	output reg special_reg_restore_state,
	output reg inc_icount,
	output reg [3:0] special_reg_sel,
	output reg [3:0] exception_status,
	//Special register inputs
	input interrupts_enabled,
	input kernel_mode,
	input [7:0] interrupts,
	input [7:0] int_mask
	);
    
    // Instruction definitions
    `include "wramp.vh"
	
	//state names
	parameter check_exceptions 		=  0;
	parameter fetch_memcheck 		=  1;
	parameter insn_fetch 			=  2;
    parameter insn_fetch_2          =  3;
	parameter insn_decode 			=  4;
	parameter uncond_jump 			=  5;
	parameter jump_and_link 		=  6;
	parameter single_cycle_alu 		=  7;
	parameter setup_multi_cycle_alu =  8;
	parameter wait_multi_cycle_alu 	=  9;
	parameter special_move 			= 10;
	parameter eff_add_comp 			= 11;
	parameter do_memory_op 			= 12;
    parameter do_memory_op_load     = 13;
	parameter cond_branch 			= 14;
	parameter branch_taken 			= 15;
	parameter load_immed 			= 16;
	parameter error_state 			= 17;
	parameter memop_memcheck 		= 18;
	parameter arithmetic_exception 	= 19;
	parameter syscall_exception 	= 20;
	parameter break_exception 		= 21;
	parameter gpf_exception 		= 22;
	parameter exception_save_reg13 	= 23;
	parameter exception_load_reg13 	= 24;
	parameter interrupt_save_PC 	= 25;
	parameter interrupt_take_vector = 26;
	parameter return_from_exception = 27;
	parameter halt 					= 31;
	parameter fetch_memcheck_post   = 32;
	parameter memop_memcheck_post   = 33;

	//instruction parts
	wire [ 3:0] opcode 	   = instruction_reg[31:28];
	wire [ 3:0] reg_d 	   = instruction_reg[27:24];
	wire [ 3:0] reg_s 	   = instruction_reg[23:20];
	wire [ 3:0] reg_t      = instruction_reg[ 3: 0];
	wire [ 3:0] func       = instruction_reg[19:16];
	wire [15:0] immediate  = instruction_reg[15: 0];
	wire [19:0] address    = instruction_reg[19: 0];

	reg [5:0] current_state, next_state;
	//declaration end

	//This is the output logic for the state machine
	always @(current_state, opcode, alu_done) begin
		
		//Temp register
		temp_in <= 0;
		temp_out <= 0;

		//Special register file
		special_reg_in <= 0;
		special_reg_out <= 0;
		special_reg_sel <= 0;
		inc_icount <= 0;
		special_reg_save_state <= 0;
		special_reg_restore_state <= 0;
		exception_status <= 0;
		
		//Register file
		a_out <= 0;
		b_out <= 0;
		c_in <= 0;
		sel_a <= 0000;
		sel_b <= 0000;
		sel_c <= 0000;
		
		//Program counter
		pc_in <= 0;
		pc_out <= 0;
		pc_inc <= 0;
		
		//Instruction Register
		ir_in <= 0;
		imm_16_out <= 0;
		imm_20_out <= 0;
		sign_extend <= 0;
		
		//ALU
		alu_out <= 0;
		alu_func <= 0;
		alu_start <= 0;
		
		//Memory interface
		mem_read <= 0;
		mem_write <= 0;
		check_mem <= 0;

		case (current_state)
			check_exceptions : begin
				//If we have an external interrupt then we will save state.
		    	if (((interrupts & int_mask) != 8'h00) && interrupts_enabled == 1'b1) begin
		      		special_reg_save_state <= 1;
		    	end
			end		    

		  	fetch_memcheck : begin
				//Do a memory read
				mem_read <= 1;
				//Use the PC
				pc_out <= 1;
				//Check the validity of this memory access
				//check_mem <= 1;				
			end
			
			fetch_memcheck_post : begin
                //Do a memory read
                mem_read <= 1;
                //Use the PC
                pc_out <= 1;
                //Check the validity of this memory access
                check_mem <= 1;
            end
			
	
			insn_fetch : begin			    
				//We want to do a memory read
				//We set the address to the PC, and wait for the ram to fetch it
				mem_read <= 1;
				pc_out <= 1;
				//We also want to increment the icount register
				inc_icount <= 1;
			end		  
			
			insn_fetch_2 : begin
                //We want to read from ram now it's fetched the insn
                mem_read <= 1;
                //The address is given by the PC and needs to still be valid to 
                // let the memory interface enable the ram
                pc_out <= 1;
                //Latch in the instruction
                ir_in <= 1;
			end  

			insn_decode : begin
				//Increment the program counter
				pc_inc <= 1;
			end

			uncond_jump : begin
				//jump or jump register
				//Get either the immediate address...
				if (opcode == OPCODE_J || opcode == OPCODE_JAL) begin
					imm_20_out <= 1;
				end else begin
					//Or the specified register
					a_out <= 1;
					sel_a <= reg_s;
				end

				//Now get register $zero
				b_out <= 1;
				sel_b <= 0;
				//Add the two
				alu_out <= 1;
				alu_func <= FUNC_ADD;
				//Store new location into PC
				pc_in <= 1;
			end


			jump_and_link : begin
				//Get the PC
				pc_out <= 1;
				//Get register $zero
				a_out <= 1;
				sel_a <= 0;
				//Add the two
				alu_out <= 1;
				alu_func <= FUNC_ADD;
				//Store the result into register $ra = $15
				c_in <= 1;
				sel_c <= 15;
			end

			load_immed : begin
				//Get the immediate part from the instruction register
				imm_20_out <= 1;
				//Get register $zero
				b_out <= 1;
				sel_b <= 0;
				//Add them
				alu_out <= 1;
				if (opcode == OPCODE_LA) begin
					alu_func <= FUNC_ADD;
				end else begin
					alu_func <= ALU_LHI;
				end
				//Store in the specified destination register
				c_in <= 1;
				sel_c <= reg_d;
			end


			cond_branch : begin
				//Get the register
				a_out <= 1;
				sel_a <= reg_s;
				//And register $zero
				b_out <= 1;
				sel_b <= 0;
				//Add the two & don't output anything
				alu_func <= FUNC_ADD;
			end

			branch_taken : begin
				//Get the sign extended immediate address offset
				imm_20_out <= 1;
				sign_extend <= 1;
				//Get the program counter
				pc_out <= 1;
				//Add the two
				alu_out <= 1;
				alu_func <= FUNC_ADD;
				//Store the result back into the PC
				pc_in <= 1;
			end

			eff_add_comp : begin
				//Here we compute the effective address
				//Get the sign extended immediate address offset
				imm_20_out <= 1;
				sign_extend <= 1;
				//Get the second register
				b_out <= 1;
				sel_b <= reg_s;
				//Add the two
				alu_out <= 1;
				alu_func <= FUNC_ADD;
				//Store the result into the temp register
				temp_in <= 1;
			end
			
			memop_memcheck_post : begin
                //Use the effective address
                temp_out <= 1;
                //Check the memory protection table
                mem_read <= 1;
                //Tell the memory protection unit to check
                check_mem <= 1;
            end

			memop_memcheck : begin
				//Use the effective address
				temp_out <= 1;
				//Check the memory protection table
				mem_read <= 1;
				//Tell the memory protection unit to check
                check_mem <= 1;
			end
			
			

			do_memory_op : begin
				//Output the address
				temp_out <= 1;
				//Set up the memory operation
				if (opcode == OPCODE_LW) begin
					//On a load word we want to read, and we've told it to start reading
					// Now we wait
				end 
				if (opcode == OPCODE_SW) begin
					//On a store word we want to write
					mem_write <= 1;
					//Data will come from the register file
					a_out <= 1;
					//from RegD
					sel_a <= reg_d;
				end
			end
			
			do_memory_op_load : begin
			    // Keep outputting the address
			    temp_out <= 1;
			    // We want to read from memory
			    mem_read <= 1;
			    // Data will go into the register file
			    c_in <= 1;
			    // In the specified register
			    sel_c <= reg_d;
			end

			single_cycle_alu : begin
				//Get the first operand
				b_out <= 1;
				sel_b <= reg_s;
				//Get the second operand
				case (opcode) 
					OPCODE_ARITHI, OPCODE_TESTI : begin
						imm_16_out <= 1;
						//Sign extend if necessary
						if (func[0] == 0) begin
							sign_extend <= 1;
						end
					end
					OPCODE_ARITH,OPCODE_TEST : begin
						a_out <= 1;
						sel_a <= reg_t;
					end
				endcase
				//Set up the ALU
				alu_out <= 1;
				if (opcode == OPCODE_ARITHI || opcode == OPCODE_ARITH) begin
					alu_func <= {1'b0, func};
				end else begin
					alu_func <= {1'b1, func};
				end
				//Store the result back to the destination register
				c_in <= 1;
				sel_c <= reg_d;
			end

			setup_multi_cycle_alu : begin
				//Get the first operand
				b_out <= 1;
				sel_b <= reg_s;
				//Get the second operand
				case (opcode)
					OPCODE_ARITHI : begin
						imm_16_out <= 1;
						//Sign extend if necessary
						if (func[0] == 0) begin
							sign_extend <= 1;
						end
					end
					OPCODE_ARITH : begin
						a_out <= 1;
						sel_a <= reg_t;
					end
				endcase
				alu_func <= {1'b0, func};
				alu_start <= 1;
			end

			wait_multi_cycle_alu : begin
				//Get the first operand
				//alu_start <= 1;
				b_out <= 1;
				sel_b <= reg_s;
				//Get the second operand
				case (opcode)
					OPCODE_ARITHI : begin
						imm_16_out <= 1;
						//Sign extend if necessary
						if (func[0] == 0) begin
							sign_extend <= 1;
						end
					end
					OPCODE_ARITH : begin
						a_out <= 1;
						sel_a <= reg_t;
					end
				endcase
				alu_func <= {1'b0, func};
				sel_c <= reg_d;
				if (alu_done == 1) begin
					alu_out <= 1;
					c_in <= 1;
				end
			end

			special_move : begin
			    // Add nothing to the source register
				a_out <= 1;
				sel_a <= 0;

				alu_out <= 1;
				alu_func <= FUNC_ADD;

                // Save it to the destination register
				if (func == FUNC_MOVGS) begin
					b_out <= 1;
					sel_b <= reg_s;
					special_reg_in <= 1;
					special_reg_sel <= reg_d;
				end else begin
					c_in <= 1;
					sel_c <= reg_d;
					special_reg_out <= 1;
					special_reg_sel <= reg_s;
				end
			end

			exception_save_reg13 : begin
			    // Store $13 in $ers when an exception happens
				a_out <= 1;
				sel_a <= 13;

				b_out <= 1;
				sel_b <= 0;

				alu_out <= 1;
				alu_func <= FUNC_ADD;

				special_reg_in <= 1;
				special_reg_sel <= ERS_REGNO;
			end

			exception_load_reg13 : begin
			    // Restore $13 from $ers when an exception ends
				special_reg_out <= 1;
				special_reg_sel <= ERS_REGNO;

				a_out <= 1;
				sel_a <= 0;

				alu_out <= 1;
				alu_func <= FUNC_ADD;

				c_in <= 1;
				sel_c <= 13;
			end

			interrupt_save_PC : begin
				//Get the PC
				pc_out <= 1;

				a_out <= 1;
				sel_a <= 0;

				alu_out <= 1;
				alu_func <= FUNC_ADD;

				//Save it to the IAR
				special_reg_in <= 1;
				special_reg_sel <= IAR_REGNO;
			end

			interrupt_take_vector : begin
				//Get the IVEC
				special_reg_out <= 1;
				special_reg_sel <= IVEC_REGNO;

				a_out <= 1;
				sel_a <= 0;

				alu_out <= 1;
				alu_func <= FUNC_ADD;

				//Store it to the PC
				pc_in <= 1;
			end

			return_from_exception : begin
				special_reg_out <= 1;
				special_reg_sel <= IAR_REGNO;

				a_out <= 1;
				sel_a <= 0;

				alu_out <= 1;
				alu_func <= FUNC_ADD;

				//Store it to the PC
				pc_in <= 1;

				//Restore the special register state
				special_reg_restore_state <= 1;
			end

			break_exception : begin
				//Get the PC
				pc_out <= 1;

				a_out <= 1;
				sel_a <= 0;

				alu_out <= 1;
				alu_func <= FUNC_ADD;

				//Save it to the IAR
				special_reg_in <= 1;
				special_reg_sel <= IAR_REGNO;

				exception_status <= 4;

				special_reg_save_state <= 1;
			end

			syscall_exception : begin
				//Get the PC
				pc_out <= 1;

				a_out <= 1;
				sel_a <= 0;

				alu_out <= 1;
				alu_func <= FUNC_ADD;

				//Save it to the IAR
				special_reg_in <= 1;
				special_reg_sel <= IAR_REGNO;

				exception_status <= 2;

				special_reg_save_state <= 1;
			end

			arithmetic_exception : begin
				//Get the PC
				pc_out <= 1;

				a_out <= 1;
				sel_a <= 0;

				alu_out <= 1;
				alu_func <= FUNC_ADD;

				//Save it to the IAR
				special_reg_in <= 1;
				special_reg_sel <= IAR_REGNO;

				exception_status <= 8;

				special_reg_save_state <= 1;
			end

			gpf_exception : begin
				//Get the PC
				pc_out <= 1;

				a_out <= 1;
				sel_a <= 0;

				alu_out <= 1;
				alu_func <= FUNC_ADD;

				//Save it to the IAR
				special_reg_in <= 1;
				special_reg_sel <= IAR_REGNO;

				exception_status <= 1;

				special_reg_save_state <= 1;
			end
		endcase
	end		

////////////////////////////////////////////////////////////////////

	//This is the next-state logic for the state machine
	always @(current_state, 
	         instruction_reg, 
	         zero, 
	         interrupts, 
	         int_mask, 
	         interrupts_enabled, 
	         alu_done, 
	         kernel_mode, 
	         overflow, 
	         div_zero, 
	         memory_violation) begin

		//Default to error state, if nothing explodes then this gets overwritten
		next_state <= error_state;

		case (current_state)

			check_exceptions : begin
				//Check for unmasked interrupts
				if (((interrupts & int_mask) != 0) && interrupts_enabled) begin
					next_state <= interrupt_save_PC;
				end else if (kernel_mode == 0) begin
					next_state <= fetch_memcheck;
				end else begin
					next_state <= insn_fetch;
				end
			end

			fetch_memcheck : begin
				if (memory_violation == 1 && kernel_mode == 0) begin
					next_state <= gpf_exception;
				end else begin
					next_state <= fetch_memcheck_post;
				end
			end
			
			fetch_memcheck_post : begin
			    next_state <= insn_fetch;
			end

			insn_fetch : begin
				next_state <= insn_fetch_2;
			end
			
			insn_fetch_2 : begin
			    next_state <= insn_decode;
			end

			insn_decode : begin
				//Decode the instruction
				case (opcode)
					//Handle the direct jumps
					OPCODE_J, OPCODE_JR : begin
						next_state <= uncond_jump;				
					end

					//And the direct jumps with linking
					OPCODE_JAL, OPCODE_JALR : begin
						next_state <= jump_and_link;
					end

					//Memory operations
					OPCODE_LW, OPCODE_SW : begin
						next_state <= eff_add_comp;
					end
		
					//Conditional branches
					OPCODE_BEQZ, OPCODE_BNEZ : begin
						next_state <= cond_branch;
					end

					//Load address
					OPCODE_LA : begin
						next_state <= load_immed;
					end
		
					//Basic ALU operations
					OPCODE_ARITH, OPCODE_ARITHI : begin
						if (func == FUNC_MULT || func == FUNC_MULTU	|| func == FUNC_DIV || func == FUNC_DIVU || func == FUNC_REM || func == FUNC_REMU) begin
							next_state <= setup_multi_cycle_alu;
						end else begin
							next_state <= single_cycle_alu;
						end
					end

					//Tests
					OPCODE_TESTI, OPCODE_TEST : begin
						if (func == FUNC_SLT || func == FUNC_SLTU
								|| func == FUNC_SGT || func == FUNC_SGTU
								|| func == FUNC_SLE || func == FUNC_SLEU
								|| func == FUNC_SGE || func == FUNC_SGEU
								|| func == FUNC_SEQ || func == FUNC_SEQU
								|| func == FUNC_SNE || func == FUNC_SNEU) begin
				
							next_state <= single_cycle_alu;
						end else if (opcode == OPCODE_TESTI && func == FUNC_LHI) begin
							next_state <= load_immed;
						end else if (opcode == OPCODE_TESTI && (func == FUNC_MOVSG || func == FUNC_MOVGS)) begin
							//If we are in user mode then it is illegal to execute a movgs
							//or movsg instruction.
							if (kernel_mode == 0) begin
								next_state <= gpf_exception;
							end else begin
								next_state <= special_move;
							end
						end else if (opcode == OPCODE_TEST && func == FUNC_RFE) begin
							//If we are in user mode then is illegal to execute a rfe instruction
							if (kernel_mode == 0) begin
								next_state <= gpf_exception;
							end else begin
								next_state <= return_from_exception;
							end
						end else if (opcode == OPCODE_TEST && func == FUNC_BREAK) begin
							next_state <= break_exception;
						end else if (opcode == OPCODE_TEST && func == FUNC_SYSCALL) begin
							next_state <= syscall_exception;
						end else begin
							//Illegal or unimplemented instruction
							next_state <= gpf_exception;
						end
					end

					default :
						//Illegal or unimplemented instruction
						next_state <= gpf_exception;
				endcase
			end

			//movsg or movgs
			special_move : begin
				next_state <= check_exceptions;
			end

			//Alu arithmetic insn (add, sub, and, or, xor (all flavours))
			//Alu test instructions (slt, sgt, sle, sge, seq, sne (both flavours))
			single_cycle_alu : begin
				next_state <= check_exceptions;
				//Here we should check for overflow on 'add' and 'sub'
				if (func == FUNC_ADD || func == FUNC_ADDU || func == FUNC_SUB || func == FUNC_SUBU) begin
					if (overflow == 1) begin
						next_state <= arithmetic_exception;
					end
				end
			end

			setup_multi_cycle_alu : begin
				next_state <= wait_multi_cycle_alu;
			end

			wait_multi_cycle_alu : begin
				if (div_zero == 1 || overflow == 1) begin
					next_state <= arithmetic_exception;  //ALU might not clear err flags before next cycle
				end else if (alu_done == 1) begin
					next_state <= check_exceptions;
				end else begin
					next_state <= wait_multi_cycle_alu;
				end
			end

			//Load high immediate & load address
			load_immed : begin
				next_state <= check_exceptions;
			end

			//Unconditional jump stuff (j, jr, jal, jalr)
			uncond_jump : begin
				next_state <= check_exceptions;
			end

			jump_and_link : begin
				next_state <= uncond_jump;
			end

			//Memory operations (lw, sw)
			eff_add_comp : begin
				if (kernel_mode == 0) begin
					next_state <= memop_memcheck_post;
				end else begin
					next_state <= do_memory_op;
				end
			end
			
			memop_memcheck_post : begin
			    next_state <= memop_memcheck;
			end

			memop_memcheck : begin
				if (memory_violation == 1 && kernel_mode == 0) begin
					next_state <= gpf_exception;
				end else begin
					next_state <= do_memory_op;
				end
			end

			do_memory_op : begin
			    // Loading takes an additional cycle
				if (opcode == OPCODE_LW) begin
                    next_state <= do_memory_op_load;
				end
				else next_state <= check_exceptions;
			end
			
			do_memory_op_load : begin
			    next_state <= check_exceptions;
			end

			//Conditional branch stuff (beqz, bnez)
			cond_branch : begin
				if ((opcode == OPCODE_BEQZ && zero == 1) || (opcode == OPCODE_BNEZ && zero == 0)) begin
					next_state <= branch_taken;
				end else begin
					next_state <= check_exceptions;
				end
			end

			branch_taken : begin
				next_state <= check_exceptions;
			end

			interrupt_save_PC : begin
				next_state <= exception_save_reg13;
			end

			exception_save_reg13 : begin
				next_state <= interrupt_take_vector;
			end

			interrupt_take_vector : begin
				next_state <= insn_fetch;
			end

			return_from_exception : begin
				next_state <= exception_load_reg13;
			end

			exception_load_reg13 : begin
				next_state <= check_exceptions;
			end

			break_exception, syscall_exception, arithmetic_exception, gpf_exception : begin
				next_state <= interrupt_save_PC;
			end

			halt : begin
				next_state <= halt;
			end

		endcase
	end


	//This process drives the state machine
	always @(posedge clk) begin
		if (reset_n == 0) begin
			current_state <= insn_fetch;
		end else begin
			current_state <= next_state;
		end
	end
endmodule






