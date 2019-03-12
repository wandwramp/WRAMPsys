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

module alu(
  	// Synchronous reset and clock
    input             rst_n,
    input             clk,
    
    // Input
    input [4:0]       func,
    input [31:0]      operand_a,
    input [31:0]      operand_b,
    input             start,
    
    // Output
    output            finished,
    input             out_enable,
    inout  [31:0]     out_bus,
    output            zero,
    output            overflow_out,
    output            div_zero_out
    );
    
  `include "wramp.vh"



wire mdu_active = (func == ALU_MULT  ||
                   func == ALU_MULTU ||
                   func == ALU_DIV   ||
                   func == ALU_DIVU  ||
                   func == ALU_REM   ||
                   func == ALU_REMU);
wire mdu_overflow;
wire mdu_div_zero;
wire mdu_done;
wire [31:0] mdu_result;

reg [32:0] result = 0;
reg overflow = 0;
reg div_zero = 0;

wire [31:0] result_out = mdu_active ? mdu_result : result[31:0];
assign finished = mdu_active ? mdu_done : 1'b0;
assign out_bus = out_enable ? result_out[31:0] : 32'hzzzzzzzz;
assign zero = result_out == 0;
assign overflow_out = mdu_active ? mdu_overflow : overflow;
assign div_zero_out = mdu_active ? mdu_div_zero : 1'b0;


mdu_new mdu(    
    .reset_n(rst_n),
    .clk(clk),
    .start(start),
    .opcode(func[3:0]),
    .operand_1(operand_b),
    .operand_2(operand_a),
    .overflow(mdu_overflow),
    .div_zero(mdu_div_zero),
    .done(mdu_done),
    .result_out(mdu_result)
);


always @* begin
    overflow = 0;
    case (func)
        // Multi-cycle operations are all handled by the mdu
        ALU_MULT, ALU_MULTU,
        ALU_DIV,  ALU_DIVU,
        ALU_REM,  ALU_REMU: begin
            
        end
    
        // Single cycle operations
        // Arithmetic
        ALU_ADD: begin
            result = operand_b + operand_a;
            // If the input signs are the same, and the output sign is different, it's overflow.
            if (operand_a[31] == operand_b[31] && operand_a[31] != result[31]) begin
                overflow = 1;
            end
        end
        ALU_ADDU: begin
            result = operand_a + operand_b;
            if (result[32] == 1) begin
                overflow = 1;
            end
        end
        ALU_SUB: begin
            result = operand_b - operand_a;
            // If the input signs are different, and the output sign is not the same as A, it's overflow.
            // ie Large positive - Large negative should equal Larger positive
            if (operand_a[31] != operand_b[31] && operand_b[31] != result[31]) begin
                overflow = 1;
            end
        end
        ALU_SUBU: begin
            if (operand_a > operand_b) begin
                overflow = 1;
            end
            result = operand_b - operand_a;
        end
        ALU_AND: begin
            result = operand_a & operand_b;
        end
        ALU_OR: begin
            result = operand_a | operand_b;
        end
        ALU_XOR: begin
            result = operand_a ^ operand_b;
        end
        ALU_SLL: begin
            result = operand_b << operand_a[4:0];
        end
        ALU_SRL: begin
            result = operand_b >> operand_a[4:0];
        end
        ALU_SRA: begin
            result = $signed(operand_b) >>> operand_a[4:0];
        end
        
        // Test
        ALU_SLT: begin
            if (operand_a[31] == operand_b[31]) begin
                result = operand_b[30:0] < operand_a[30:0];
            end
            else result = operand_b[31];
        end
        ALU_SLTU: begin
            result = operand_b < operand_a;
        end
        ALU_SGT: begin 
            if (operand_a[31] == operand_b[31]) begin
                result = operand_b[30:0] > operand_a[30:0];
            end
            else result = operand_a[31];
        end
        ALU_SGTU: begin 
            result = operand_b > operand_a;
        end
        ALU_SLE: begin
            if (operand_a[31] == operand_b[31]) begin
                result = operand_b[30:0] <= operand_a[30:0];
            end
            else result = operand_b[31];
        end
        ALU_SLEU: begin 
            result = operand_b <= operand_a;
        end
        ALU_SGE: begin 
            if (operand_a[31] == operand_b[31]) begin
                result = operand_b[30:0] >= operand_a[30:0];
            end
            else result = operand_a[31];
        end
        ALU_SGEU: begin 
            result = operand_b >= operand_a;
        end
        ALU_SEQ, ALU_SEQU: begin 
            result = operand_a == operand_b;
        end
        ALU_SNE, ALU_SNEU: begin 
            result = operand_a != operand_b;
        end
        
        // Misc
        ALU_LHI: begin 
            result = {operand_a[15:0],16'h0000};
        end
        ALU_INC: begin
            result = operand_a + 1;
        end
    endcase
end
  
endmodule
