import core_pkg::*;
import alu_control_pkg::*;
import shift_control_pkg::*;
import comparator_control_pkg::*;
import mem_control_pkg::*;
module soc_riscv_core
(
	input  logic                     clk,          // clock
	input  logic                     rst,          // reset
	 
	// Instruction AXI_lite Read Data Channel
	input  logic  [DATA_WIDTH-1:0]   core_instr_RDATA, 
	input  logic                     core_instr_RVALID,
	output logic                     core_instr_RREADY,
	
	// Instruction AXI_lite Read Addr Channel
	input  logic					 core_instr_ARREADY,
	output logic  [ADDR_WIDTH-1:0]   core_instr_ARADDR,
	output logic                     core_instr_ARVALID,

	//Data AXI_lite Read Address Channel
	output  logic [ADDR_WIDTH-1:0]	 core_data_ARADDR,
	output  logic					 core_data_ARVALID,
	input 	logic 					 core_data_ARREADY,

	//Data AXI_lite Read Data Channel
	output logic  					 core_data_RREADY,
	input  logic [DATA_WIDTH-1:0]	 core_data_RDATA,
	input  logic 					 core_data_RVALID,

	//Data AXI_lite Write Address Channel
	output logic [ADDR_WIDTH-1:0] 	 core_data_AWADDR,
	output logic 					 core_data_AWVALID,
	input  logic					 core_data_AWREADY,

	//Data AXI_lite Write Data Channel
	output logic [DATA_WIDTH-1:0]	 core_data_WDATA,
	input  logic 					 core_data_WREADY,
	output logic 					 core_data_WVALID
);
	// Fetch
    logic				   fetch_stall;	
	logic                  is_branch;            // Instruction is a branch instruction
	logic [DATA_WIDTH-1:0] fetched_instr;
	logic [DATA_WIDTH-1:0] new_pc;				 // New PC if instruction is a branch
	logic [REG_WIDTH-1:0]  cur_pc;				 // Current PC
	logic                  new_pc_valid;
	
	// Decoder
	logic                       rf_we;           // write enable for register file
	logic [DATA_WIDTH-1:0]      rf_data;         // data for write in register file
	logic [4:0]                 rf_addr;         // address for write in register file
	logic                       mem_op;          // Memory operation
	logic                       alu_op;          // Instruction uses ALU
	logic                       mdu_op;          // Instruction uses MDU
	logic                       shift_op;        // Instruction uses shift
	logic [ALU_WIDTH_CODE  -1:0]alu_control;     // Code for ALU
	logic [SHIFT_WIDTH_CODE-1:0]shift_control;   // Code for shift
	logic                       mdu_control;     // Code for MDU
	logic [MEM_WIDTH_CODE-1:0]	mem_control;	 // Code for mem
	logic                       rs1_use;         // Instrucion contain rs1
	logic                       rs2_use;	     // Instruction contain rs2
	logic                       rd_use;          // Instruction contain rd
	logic                       imm_use;         // Instruction contain use
	logic  [DATA_WIDTH-1:0]     imm;             // imm field
	logic  [DATA_WIDTH-1:0]     rs1_value;       // rs1 data
	logic  [DATA_WIDTH-1:0]     rs2_value;       // rs2 data
	logic  [4:0]                rd_addr;         // rd address  
	  
	// execution ports
	logic  [DATA_WIDTH-1:0]     ex_in_a;
	logic  [DATA_WIDTH-1:0]     ex_in_b;
	logic  [DATA_WIDTH-1:0]     ex_out;
	  
	// comparator ports
	logic                                  comparator_out;
	logic  [COMPARATOR_WIDTH_CODE-1:0]     comparator_control;
	logic                                  comparator_op;

	// Load Store Unit
	logic 						mem_op_valid;
	logic [DATA_WIDTH-1:0] 		mem_read_data;
	logic 						mem_op_read;

	core_fetch_stage IF
	(
		.clk        (clk               ),
		.rst        (rst               ),
		.fetch_stall(fetch_stall       ),
		.new_pc     (new_pc            ),
		.is_branch  (is_branch         ),
		.instr      (fetched_instr     ),
		.RDATA      (core_instr_RDATA  ),
		.RVALID     (core_instr_RVALID ),
		.RREADY     (core_instr_RREADY ),
		.ARREADY    (core_instr_ARREADY),
		.ARADDR     (core_instr_ARADDR ),
		.ARVALID    (core_instr_ARVALID)
	);
	 
	assign cur_pc = core_instr_ARADDR << 2; // Current PC
	
	core_decode_stage ID
	(
		.clk               (clk               ),
		.instr             (fetched_instr     ),
		.rf_we             (rf_we             ),
		.rf_data           (rf_data           ),
		.rf_addr           (rf_addr           ),
		.mem_op            (mem_op            ),
		.alu_op            (alu_op            ),
		.mdu_op            (mdu_op            ),
		.shift_op          (shift_op          ),
		.comparator_op     (comparator_op     ),
		.comparator_control(comparator_control),
		.alu_control       (alu_control       ),
		.shift_control     (shift_control     ),
		.mdu_control       (mdu_control       ),
		.mem_control	   (mem_control		  ),
		.rs1_use           (rs1_use           ),
		.rs2_use           (rs2_use           ),
		.rd_use            (rd_use            ),
		.imm_use           (imm_use           ),
		.is_branch         (is_branch         ),
		.imm               (imm               ),
		.rs1_value         (rs1_value         ),
		.rs2_value         (rs2_value         ),
		.rd_addr           (rd_addr           )
	);
	
	assign mem_op_read = 	(mem_control == mem_lb  | 
							mem_control == mem_lbu |
							mem_control == mem_lh  |
							mem_control == mem_lhu |
							mem_control == mem_lw);

	always_comb // muxes between ID and IE stages
	begin
		ex_in_a = '0;
		ex_in_b = '0;
		if(rs1_use & rs2_use & !is_branch) begin 		// opcode 51 (add, sub, sll, sra...)
			ex_in_a 	= rs1_value;
			ex_in_b 	= rs2_value;
		end
		else if(rs1_use & imm_use & !is_branch) begin 	// opcode 19, opcode 3 (lb, lw, lh... and addi, srai, slti...)
			ex_in_a 	= rs1_value;
			ex_in_b 	= imm;
		end
		else if(!rs2_use & imm_use & is_branch) begin	// opcode 103, opcode 111 (jal and jalr)
			ex_in_a 	= rs1_use ? rs1_value : 0;
			ex_in_b		= imm;
		end
		else if(!rs1_use & !rs2_use & !is_branch) begin // opcode 55, opcode 23 (lui, auipc)
			ex_in_a 	= (fetched_instr[6:0] == 7'b0010111) ? cur_pc : 0; 	// if opcode 23 -> cur_pc (auipc), else 0 (lui)
			ex_in_b 	= imm;
		end
		else if(rs1_use & rs2_use & is_branch) begin 	// opcode 99 (beq, bne...)
			ex_in_a 	= cur_pc;
			ex_in_b 	= imm;
		end
	end
	

	core_execution_stage IE
	(
		.alu_op			(alu_op       ),
		.mdu_op			(mdu_op       ),
		.shift_op		(shift_op     ),
		.alu_control	(alu_control  ),
		.mdu_control	(mdu_control  ),
		.shift_control	(shift_control),
		.ex_in_a		(ex_in_a      ),
		.ex_in_b		(ex_in_b      ),
		.ex_out			(ex_out       )
	);
	 
	always_comb // write back
	begin
		rf_we		= 'b0;
		rf_data		= 'b0;
		rf_addr		= 'b0;
		if(rd_use & !is_branch) begin
			if(mem_op) begin
				if(mem_op_read) begin
					rf_we	= mem_op_valid;
					rf_data	= mem_read_data;
					rf_addr	= rd_addr;
				end
				else begin
					rf_we	= 'b0;
					rf_data	= 'b0;
					rf_addr	= 'b0;
				end
			end
			else begin // usually case
				rf_we	= 1;
				rf_data	= ex_out;
				rf_addr	= rd_addr;
			end
		end
		else if(rd_use & is_branch) begin // opcode 103, opcode 111 (jal and jalr)
			rf_we 	= 1;
			rf_data = cur_pc + 4;
			rf_addr = rd_addr;
		end
	end

	always_comb
	begin
		new_pc_valid = 'b0;
		if(rs1_use & rs2_use & is_branch) begin // opcode 99
			if(comparator_op) begin
				new_pc			= comparator_out ? ex_out : cur_pc + 4;
				new_pc_valid	= 1'b1;
			end else begin
				new_pc			= ex_out;
				new_pc_valid	= 1'b1;
			end
		end
		else begin
			new_pc				= 0;
			new_pc_valid		= 0;
		end 
	end
	
	load_store_unit LSU(
		.clk			(clk				),
		.rst			(rst				),
		.mem_op			(mem_op				),
		.mem_control	(mem_control		),
		.mem_addr		(ex_out				),
		.mem_op_valid	(mem_op_valid		),
		.ARADDR			(core_data_ARADDR	),
		.ARVALID		(core_data_ARVALID	),
		.ARREADY		(core_data_ARREADY	),
		.RREADY			(core_data_RREADY	),
		.RDATA			(core_data_RDATA	),
		.RVALID			(core_data_RVALID	),
		.AWADDR			(core_data_AWADDR	),
		.AWVALID		(core_data_AWVALID	),
		.AWREADY		(core_data_AWREADY	),
		.WDATA			(core_data_WDATA	),
		.WREADY			(core_data_WREADY	),
		.WVALID			(core_data_WVALID	),
		.mem_read_data	(mem_read_data  	),
		.mem_write_data	(rs2_value			)

	);
	core_comparator comparator(
		.comparator_control	(comparator_control),
		.comparator_in_a	(rs1_value         ),
		.comparator_in_b	(rs2_value         ),
		.comparator_out		(comparator_out    )
	);
	
	core_control_unit CU(
		.is_branch   	(is_branch   	),
		.new_pc_valid	(new_pc_valid	),
		.mem_op			(mem_op			),
		.mem_op_valid	(mem_op_valid	),
		.fetch_stall	(fetch_stall 	)	
	);
	 
endmodule
