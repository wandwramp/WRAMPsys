// Daniel Oosterwijk & Tyler Marriner
// University of Waikato, 2018

// This just bundles together all the components of the main CPU.
// Interesting logic happens in the control unit.
module CPU(
	//Input control signals
	input rst_n,
	input clk,

	//Bus control signals
	output write_enable_n,
	output read_enable_n,

	//Data bus
	inout [31:0] data_bus,

	//Address lines
	output [23:0] address_bus,

	//Ouput chip selects
	output rom_cs_n,
	output ram_cs_n,
	output timer_cs_n,
	output parallel_cs_n,
	output serial1_cs_n,
	output serial2_cs_n,
	output aux1_cs_n,
	output aux2_cs_n,
	output sys_cs_n,

	//Input IRQs
	input break_irq_n,
	input user_irq_n,
	input timer_irq_n,
	input parallel_irq_n,
	input serial1_irq_n,
	input serial2_irq_n,
	input aux1_irq_n,
	input aux2_irq_n,

	input rom_lock
 	);
 
 
 
	//Buses
	wire [31:0] A_bus;
	wire [31:0] B_bus;
	wire [31:0] C_bus;

	// MPU
	wire check_mem;
	wire kernel_mode;
	wire [19:0] mpu_address_out;
	wire [19:0] user_base;
	wire [19:0] protection_table;
	wire memory_violation;

	// Memory interface
	wire mem_read_en;
	wire mem_write_en;

	// Temp register
	wire temp_read_en;
	wire temp_write_en;

	// ALU
	wire [4:0] alu_func;
	wire alu_start;
	wire alu_finished;
	wire alu_out_en;
	wire zero;
	wire overflow;
	wire div_zero;

	// Register file
	wire       reg_a_read_en;
	wire [3:0] reg_a_sel;
	wire       reg_b_read_en;
	wire [3:0] reg_b_sel;
	wire       reg_write_en;
	wire [3:0] reg_write_sel;

	// IR
	wire ir_write_en;
	wire imm_16_out;
	wire imm_20_out;
	wire sign_extend_imm;
	wire [31:0] current_instruction;

	// PC
	wire pc_inc;
	wire pc_write_en;
	wire pc_read_en;


	// Special register file
	wire [3:0] special_reg_sel;
	wire       special_reg_read_en;
	wire       special_reg_write_en;
	wire       inc_icount;
	wire       save_state;
	wire       restore_state;
	wire [7:0] interrupt_mask;
	wire [3:0] exception_status;
	wire [7:0] interrupts;
	wire       interrupts_enabled;

	// Why is this wider than every other address line? It never gets used... //verilog will remove redundencies
	assign address_bus[23:20] = 4'h0;

	//Map the interrupts to the interrupt word
	assign interrupts[0] = 0; //not break_irq_n;
	assign interrupts[1] = ~user_irq_n;
	assign interrupts[2] = ~timer_irq_n;
	assign interrupts[3] = ~parallel_irq_n;
	assign interrupts[4] = ~serial1_irq_n;
	assign interrupts[5] = ~serial2_irq_n;
	assign interrupts[6] = ~aux1_irq_n;
	assign interrupts[7] = ~aux2_irq_n;
	
	// Modules
	memory_protection_unit mpu(
		.check_mem(check_mem),                      // in
		.user_mode(~kernel_mode),                   // in
		.address_in(B_bus[19:0]),                   // in
		.address_out(mpu_address_out),              //      out
		.user_base(user_base),                      // in
		.protection_table(protection_table),        // in
		.load_data(C_bus),                          // in
		.memory_violation(memory_violation)         //      out
	);

	memory_interface mem_interface(
		.data_in(A_bus),                            // in
		.data_out(C_bus),                           //      out
		.cpu_address(mpu_address_out),              // in
		.mem_read(mem_read_en),                     // in
		.mem_write(mem_write_en),                   // in
		.rom_lock(rom_lock),                        // in
		.data_bus(data_bus),                        //          inout
		.address_bus(address_bus[19:0]),            //      out
		.serial1_cs_n(serial1_cs_n),                //      out
		.serial2_cs_n(serial2_cs_n),                //      out
		.parallel_cs_n(parallel_cs_n),              //      out
		.timer_cs_n(timer_cs_n),                    //      out
		.ram_cs_n(ram_cs_n),                        //      out
		.rom_cs_n(rom_cs_n),                        //      out
		.aux1_cs_n(aux1_cs_n),                      //      out
		.aux2_cs_n(aux2_cs_n),                      //      out
		.sys_cs_n(sys_cs_n),                        //      out
		.write_enable_n(write_enable_n),            //      out
		.read_enable_n(read_enable_n)               //      out
	);

	register temp_reg(
		.rst_n(rst_n),                              // in
		.clk(clk),                                  // in
		.write_enable(temp_write_en),               // in
		.write_value(C_bus),                        // in
		.read_enable(temp_read_en),                 // in
		.read_value(B_bus)                          //      out
	);

	alu alu(
		.rst_n(rst_n),                              // in
		.clk(clk),                                  // in
		.func(alu_func),                            // in
		.operand_a(A_bus),                          // in
		.operand_b(B_bus),                          // in
		.start(alu_start),                          // in
		.finished(alu_finished),                    //      out
		.out_enable(alu_out_en),                    // in
		.out_bus(C_bus),                            //          inout
		.zero(zero),                                //      out
		.overflow_out(overflow),                    //      out
		.div_zero_out(div_zero)                     //      out
	);

	register_file reg_file(
		.rst_n(rst_n),                              // in
		.clk(clk),                                  // in
		.read_a_enable(reg_a_read_en),              // in
		.read_a_select(reg_a_sel),                  // in
		.read_a_value(A_bus),                       //      out
		.read_b_enable(reg_b_read_en),              // in
		.read_b_select(reg_b_sel),                  // in
		.read_b_value(B_bus),                       //      out
		.write_enable(reg_write_en),                // in
		.write_select(reg_write_sel),               // in
		.write_value(C_bus)                         // in
	);

	instruction_register ir(
		.rst_n(rst_n),                              // in
		.clk(clk),                                  // in
		.write_enable(ir_write_en),                 // in
		.write_data(C_bus),                         // in
		.imm_16_out(imm_16_out),                    // in
		.imm_20_out(imm_20_out),                    // in
		.sign_extend(sign_extend_imm),              // in
		.a_out(A_bus),                            // out
		.current_instruction(current_instruction)   // out
	);

	program_counter pc(
		.rst_n(rst_n),                              // in
		.clk(clk),                                  // in
		.increment(pc_inc),                         // in
		.write_enable(pc_write_en),                 // in
		.write_value(C_bus),                        // in
		.read_enable(pc_read_en),                   // in
		.read_value(B_bus)                          //      out
	);

	special_register_file special_regs(
		.rst_n(rst_n),                              // in
		.clk(clk),                                  // in
		.reg_select(special_reg_sel),               // in
		.read_enable(special_reg_read_en),          // in
		.read_value(B_bus),                         //      out
		.write_enable(special_reg_write_en),        // in
		.write_value(C_bus),                        // in
		.inc_icount(inc_icount),                    // in
		.save_state(save_state),                    // in
		.restore_state(restore_state),              // in
		.interrupt_mask(interrupt_mask),            //      out
		.exception_status(exception_status),        // in
		.interrupt_status(interrupts),              // in
		.interrupts_enabled(interrupts_enabled),    //      out
		.kernel_mode(kernel_mode),                  //      out
		.user_base(user_base),                      //      out
		.protection_table(protection_table)         //      out
	);

	control_unit cu(
		.reset_n(rst_n),                             // in
		.clk(clk),                                 // in
		.instruction_reg(current_instruction),     // in
		.mem_read(mem_read_en),                    //      out
		.mem_write(mem_write_en),                  //      out
		.check_mem(check_mem),                     //      out
		.memory_violation(memory_violation),       // in
		.ir_in(ir_write_en),                       //      out
		.imm_16_out(imm_16_out),                   //      out
		.imm_20_out(imm_20_out),                   //      out
		.sign_extend(sign_extend_imm),             //      out
		.pc_in(pc_write_en),                       //      out
		.pc_out(pc_read_en),                       //      out
		.pc_inc(pc_inc),                           //      out
		.a_out(reg_a_read_en),                     //      out
		.b_out(reg_b_read_en),                     //      out
		.c_in(reg_write_en),                       //      out
		.sel_a(reg_a_sel),                         //      out
		.sel_b(reg_b_sel),                         //      out
		.sel_c(reg_write_sel),                     //      out
		.temp_in(temp_write_en),                   //      out
		.temp_out(temp_read_en),                   //      out
		.alu_out(alu_out_en),                      //      out
		.alu_start(alu_start),                     //      out
		.alu_func(alu_func),                       //      out
		.alu_done(alu_finished),                   // in
		.zero(zero),                               // in
		.div_zero(div_zero),                       // in
		.overflow(overflow),                       // in
		.special_reg_in(special_reg_write_en),     //      out
		.special_reg_out(special_reg_read_en),     //      out
		.special_reg_save_state(save_state),       //      out
		.special_reg_restore_state(restore_state), //      out
		.inc_icount(inc_icount),                   //      out
		.special_reg_sel(special_reg_sel),         //      out
		.exception_status(exception_status),       //      out
		.interrupts_enabled(interrupts_enabled),   // in
		.kernel_mode(kernel_mode),                 // in
		.interrupts(interrupts),                   // in
		.int_mask(interrupt_mask)                  // in
	);

endmodule