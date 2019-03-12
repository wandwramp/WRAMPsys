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

// WRAMP Instruction Set Architecture definitions
`ifndef _WRAMP_VH_
//`define _WRAMP_VH_
// In Vivado, defines are global, but parameters are per-module, so the definitions only happen in one module.

// Opcodes
parameter
   OPCODE_ARITH        = 4'b0000,
   OPCODE_ARITHI       = 4'b0001,
   OPCODE_TEST         = 4'b0010,
   OPCODE_TESTI        = 4'b0011,
   OPCODE_J            = 4'b0100,
   OPCODE_JR           = 4'b0101,
   OPCODE_JAL          = 4'b0110,
   OPCODE_JALR         = 4'b0111,
   OPCODE_LW           = 4'b1000,
   OPCODE_SW           = 4'b1001,
   OPCODE_BEQZ         = 4'b1010,
   OPCODE_BNEZ         = 4'b1011,
   OPCODE_LA           = 4'b1100;

parameter
// Function codes for OPCODE_ARITH and OPCODE_ARITHI
   FUNC_ADD            = 4'b0000,
   FUNC_ADDU           = 4'b0001,
   FUNC_SUB            = 4'b0010,
   FUNC_SUBU           = 4'b0011,
   FUNC_MULT           = 4'b0100,
   FUNC_MULTU          = 4'b0101,
   FUNC_DIV            = 4'b0110,
   FUNC_DIVU           = 4'b0111,
   FUNC_REM            = 4'b1000,
   FUNC_REMU           = 4'b1001,
   FUNC_SLL            = 4'b1010,
   FUNC_AND            = 4'b1011,
   FUNC_SRL            = 4'b1100,
   FUNC_OR             = 4'b1101,
   FUNC_SRA            = 4'b1110,
   FUNC_XOR            = 4'b1111,

// Function codes for OPCODE_TEST and OPCODE_TESTI
   FUNC_SLT            = 4'b0000,
   FUNC_SLTU           = 4'b0001,
   FUNC_SGT            = 4'b0010,
   FUNC_SGTU           = 4'b0011,
   FUNC_SLE            = 4'b0100,
   FUNC_SLEU           = 4'b0101,
   FUNC_SGE            = 4'b0110,
   FUNC_SGEU           = 4'b0111,
   FUNC_SEQ            = 4'b1000,
   FUNC_SEQU           = 4'b1001,
   FUNC_SNE            = 4'b1010,
   FUNC_SNEU           = 4'b1011,
// OPCODE_TESTI
   FUNC_MOVGS          = 4'b1100,
   FUNC_MOVSG          = 4'b1101,
   FUNC_LHI            = 4'b1110,
// OPCODE_TEST
   FUNC_BREAK          = 4'b1100,
   FUNC_SYSCALL        = 4'b1101,
   FUNC_RFE            = 4'b1110;
   
parameter
// ALU function codes
   ALU_ADD             = {1'b0,FUNC_ADD},
   ALU_ADDU            = {1'b0,FUNC_ADDU},
   ALU_SUB             = {1'b0,FUNC_SUB},
   ALU_SUBU            = {1'b0,FUNC_SUBU},

   ALU_MULT            = {1'b0,FUNC_MULT},
   ALU_MULTU           = {1'b0,FUNC_MULTU},
   ALU_DIV             = {1'b0,FUNC_DIV},
   ALU_DIVU            = {1'b0,FUNC_DIVU},
   ALU_REM             = {1'b0,FUNC_REM},
   ALU_REMU            = {1'b0,FUNC_REMU},

   ALU_SLL             = {1'b0,FUNC_SLL},
   ALU_SRL             = {1'b0,FUNC_SRL},
   ALU_SRA             = {1'b0,FUNC_SRA},

   ALU_AND             = {1'b0,FUNC_AND},
   ALU_OR              = {1'b0,FUNC_OR},
   ALU_XOR             = {1'b0,FUNC_XOR},

   ALU_SLT             = {1'b1,FUNC_SLT},
   ALU_SLTU            = {1'b1,FUNC_SLTU},
   ALU_SGT             = {1'b1,FUNC_SGT},
   ALU_SGTU            = {1'b1,FUNC_SGTU},
   ALU_SLE             = {1'b1,FUNC_SLE},
   ALU_SLEU            = {1'b1,FUNC_SLEU},
   ALU_SGE             = {1'b1,FUNC_SGE},
   ALU_SGEU            = {1'b1,FUNC_SGEU},
   ALU_SEQ             = {1'b1,FUNC_SEQ},
   ALU_SEQU            = {1'b1,FUNC_SEQU},
   ALU_SNE             = {1'b1,FUNC_SNE},
   ALU_SNEU            = {1'b1,FUNC_SNEU},

   ALU_LHI             = {1'b1,FUNC_LHI},
   ALU_INC             = {5'b1};

parameter
// Named general register locations
   ZERO_REGNO          = 4'd0,
   SP_REGNO            = 4'd14,
   RA_REGNO            = 4'd15;

parameter
// Special register locations
   ICTRL_REGNO         = 4'b0100,
   ISTAT_REGNO         = 4'b0101,
   ICOUNT_REGNO        = 4'b0110,
   CCOUNT_REGNO        = 4'b0111,
   IVEC_REGNO          = 4'b1000,
   IAR_REGNO           = 4'b1001,
   ESP_REGNO           = 4'b1010,
   ERS_REGNO           = 4'b1011,
   
   WPTABLE_REGNO       = 4'b1100,
   USERBASE_REGNO      = 4'b1101;

`endif
