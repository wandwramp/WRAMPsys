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

module mdu_new(
    input reset_n,
    input clk,
    // Asserted for one clock cycle to start the operation
    input start,
    input [2:0] opcode,
    // Two input data words
    input [31:0] operand_1,
    input [31:0] operand_2,
    // Asserted if an exception occurs
    output reg overflow,
    output reg div_zero,
    // Asserted when the operation is done
    output reg done,
    // The result of the operation
    output reg [31:0] result_out,
    output [15:0] debug_out
    );

	//this module uses the repeated addition techniuqe to obtain the result of multiplication
	//signed values and computed by performing the operation on the absoloute values and adjusting
	//the result based on the signs of the inputs 

	//division and remainder use the repeated subtraction techniuqe, handling signs the same way as
	//multiplication

    parameter [7:0]
        IDLE     =   0,
        MULT_1   =   1,
        MULT_2   =   2,
        DONE     =   4,
        DIV_1    =   5,
        DIV_2    =   6,
        DIV_3    =   7,
        MAKEPOS  =   8,
        ERROR    =   9,
        LATCH_IN =   10;
        
    parameter 
       FUNC_MULT    = 3'b100,
       FUNC_MULTU   = 3'b101,
       FUNC_DIV     = 3'b110,
       FUNC_DIVU    = 3'b111,
       FUNC_REM     = 3'b000,
       FUNC_REMU    = 3'b001;
    
    reg next_overflow, next_div_zero, next_done;
    
    
    reg [7:0] CURR_STATE, NEXT_STATE;
    reg [5:0] counter, next_counter;
    reg [2:0] MDU_OP, NEXT_MDU_OP;
    
    reg [63:0] result, next_result;
    reg [31:0] next_result_out;  
      
        
    reg [63:0] multiplier, next_multiplier;
    reg [63:0] multiplicand, next_multiplicand;
    
    reg [63:0] divisor,   next_divisor;
    reg [63:0] remainder, next_remainder;
    reg [31:0] quotient,  next_quotient;
    
    reg resultNeg, next_resultNeg;
    reg remNeg, next_remNeg;
    
    always @(posedge clk) begin
        if (~reset_n) begin
        
            CURR_STATE      <= IDLE;
            MDU_OP          <= 0;
            counter         <= 0;
            result          <= 0;
            multiplier      <= 1;
            multiplicand    <= 1;
            resultNeg       <= 0;   
                     
            result_out      <= 0;
            divisor         <= 1;  
            remainder       <= 1;
            quotient        <= 1;
            remNeg          <= 0;
            
            done            <= 0;
            div_zero        <= 0;
            overflow        <= 0;        
            
        end
        else begin
            CURR_STATE      <= NEXT_STATE;
            MDU_OP          <= NEXT_MDU_OP;
            counter         <= next_counter;
            result          <= next_result;
            multiplier      <= next_multiplier;
            multiplicand    <= next_multiplicand;
            resultNeg       <= next_resultNeg;
            
            result_out     	<= next_result_out;
            divisor         <= next_divisor;  
            remainder       <= next_remainder;
            quotient        <= next_quotient;
            remNeg          <= next_remNeg;
            
            done            <= next_done;
            div_zero        <= next_div_zero;
            overflow        <= next_overflow;        
        end
    end
    
        
    always @(*) begin
    
        NEXT_STATE          = ERROR;
        NEXT_MDU_OP         = MDU_OP;
        next_counter        = 0;
        next_result         = result;
        next_multiplier     = multiplier;
        next_multiplicand   = multiplicand;
        next_done           = 0;
        next_result_out     = result_out;
        next_resultNeg      = resultNeg;
        next_overflow       = 0;
        next_div_zero       = 0;
        
        
        next_divisor        = divisor;
        next_remainder      = remainder;
        next_quotient       = quotient;
        next_remNeg         = remNeg;
        
              
          
        case(CURR_STATE)
            
            IDLE: begin
                next_counter        = 0;
                next_result         = 0;
                
                if (start) begin
		            NEXT_STATE = LATCH_IN;
                end
                else begin
                    NEXT_STATE = IDLE;
                end
            end
            
            LATCH_IN: begin
            
            
                NEXT_MDU_OP         = opcode[2:0];               
                
                next_multiplier       = {32'h0, operand_1[31:0]};
                next_multiplicand     = {32'h0, operand_2[31:0]}; 
                
                next_resultNeg      = ((operand_1[31] ^ operand_2[31])) && opcode[0] == 0;  
				//negitivity of the result is the XOR of the signs (division and multiplication)

                next_remNeg         = operand_1[31] && opcode[0] == 0;                       
				//remainder signage follows dividend
            
            
                if (~opcode[0]) begin		//if a signed operation
                    NEXT_STATE = MAKEPOS;   //take the absoloute value of the operands             
                end
                else begin
                    case (opcode[2:0])
                        FUNC_MULTU: begin
                            NEXT_STATE = MULT_1;
                        end
                        
                        FUNC_DIVU, FUNC_REMU: begin
                            NEXT_STATE = DIV_1;
                        end
                        
                        default: begin
                            NEXT_STATE = ERROR;
                        end                       
                        
                    endcase   
                end          
            end
            
            
            MAKEPOS: begin
            	if (multiplier[31]) begin //if negitive, make pos
	            	next_multiplier   = (~{32'hffffffff, multiplier[31:0]} + 1);
    			end
    			if(multiplicand[31]) begin //if negitive, make pos                                                             
                	next_multiplicand = (~{32'hffffffff, multiplicand[31:0]} + 1);
       			end
       			
       			case (MDU_OP)
                    FUNC_MULT: begin
                        NEXT_STATE = MULT_1;
                    end
                    
                    FUNC_DIV, FUNC_REM: begin
                        NEXT_STATE = DIV_1;
                    end
                    
                    default: begin
                        NEXT_STATE = ERROR;
                    end                   
                endcase   
       			
       		
       		
       		end
            
            
            MULT_1: begin
                next_counter = counter + 1;
                next_result = result + (multiplicand[counter] ? multiplier : 0);
                next_multiplier = multiplier << 1;
                  
                if (counter == 31) begin
                    NEXT_STATE = MULT_2;
                end
                else begin
                    NEXT_STATE = MULT_1;      
                end
            end
            
            MULT_2: begin
                NEXT_STATE = DONE;
                next_result_out = resultNeg ? (~{32'h0, result[31:0]} + 1) : result[31:0]; 
				//negate result if supposed to be negitive 

                next_overflow = ~(
                    (MDU_OP[0] == 0 && result[63:31] == 33'h000000000) ||
                    (MDU_OP[0] == 0 && result[63:0] == 64'h0000000080000000 && resultNeg) || 
                    (MDU_OP[0] == 1 && result[63:32] == 32'h000000000)                
                );
                next_div_zero = 0;
            end
            
            DIV_1: begin	//initial values for DIV and MULT almost the same, just copy across
                next_quotient = 0;
                next_divisor = {multiplicand[31:0],{32'h0}}; 
                next_remainder = multiplier;
                NEXT_STATE = DIV_2;
            end
            
            
            DIV_2: begin
                next_counter = counter + 1; 
            
                if(divisor <= remainder) begin 
                    next_remainder = remainder - divisor;
                    next_quotient = {quotient[30:0],{1'b1}};
                end
                else begin
                   next_quotient = {quotient[30:0],{1'b0}}; 
                end
                next_divisor = {{1'b0},divisor[63:1]};
            
            
                if (counter == 32) begin
                    NEXT_STATE = DIV_3;
                end
                else begin
                    NEXT_STATE = DIV_2;      
                end
            
            
            end
            
            DIV_3: begin
                NEXT_STATE = DONE;
                if (MDU_OP[1]) begin //also perfom 2s complimetn if result is supposed to be negitive
                	next_result_out = (resultNeg  ? (~{32'h0,  quotient[31:0]} + 1) :  quotient[31:0] ) ;  //div 
               	end
               	else begin
           			next_result_out = (remNeg     ? (~{32'h0, remainder[31:0]} + 1) : remainder[31:0] ) ;  //rem
           		end
           		
                next_div_zero = (multiplicand == 0); //multiplicand is the original divisor
                next_overflow = (quotient[31:0] == 32'h80000000 && ~resultNeg);
                
            
            end
            
            DONE: begin
                NEXT_STATE = IDLE;
                next_done = 1;
                next_div_zero = div_zero;
                next_overflow = overflow;
                
            end
            
        endcase
    end
    
    
    
endmodule