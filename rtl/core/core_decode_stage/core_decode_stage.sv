import core_pkg::*;                //package with INSTR_WIDTH, DATA_WIDTH, REG_WIDTH and ADDR_WIDTH
import alu_control_pkg::*;         //package with ALU control code
import shift_control_pkg::*;       //package with shift control code
import comparator_control_pkg::*;  //package with comparator control code
import mem_control_pkg::*;		   //package with memory control code
module core_decode_stage
(
	input  logic                       		clk,
	input  logic [INSTR_WIDTH-1:0]    		instr,           	// instruction
		
	// register file signals
	input  logic                       		rf_we,           	// write enable for register file
	input  logic [DATA_WIDTH-1:0]      		rf_data,         	// data for write in register file
	input  logic [4:0]      				rf_addr,         	// address for write in register file
	 
	 // Control signals
	output logic                       		mem_op,         	// Memory operation
	output logic                       		alu_op,         	// Instruction uses ALU 
	output logic                       		mdu_op,         	// Instruction uses MDU
	output logic                       		shift_op,	    	// Instruction uses shift
	output logic                       		comparator_op,  	// Instruction uses comparator
	output logic [ALU_WIDTH_CODE  -1:0]		alu_control,    	// Code for ALU
	output logic [SHIFT_WIDTH_CODE-1:0]		shift_control,  	// Code for shift
	output logic                       	 	mdu_control,   		// Code for MDU
	output logic [MEM_WIDTH_CODE-1:0]		mem_control,		// Code for LSU
	output logic [COMPARATOR_WIDTH_CODE-1:0]comparator_control, // Code for comparator
	output logic                      	 	rs1_use,        	// Instruction contain rs1
	output logic                       		rs2_use,	      	// Instruction contain rs2
	output logic                       		rd_use,         	// Instruction contain rd
	output logic                       		imm_use,        	// Instruction contain imm field
	output logic                       		is_branch,      	// Instruction is a branch instruction

	// Data
	output logic  [DATA_WIDTH-1:0]  imm,           				// imm field
	output logic  [DATA_WIDTH-1:0]  rs1_value,      			// rs1 data
	output logic  [DATA_WIDTH-1:0]  rs2_value,      			// rs2 data
	
	// Address
	output logic  [4:0]             rd_addr         			// rd address  
);
    //rs1 and rs2 address
	logic [4:0] rs1_addr;
	logic [4:0] rs2_addr;
	 
	instruction_decode_unit IDU0(
		.instr        		(instr        		), 
		.mem_op       		(mem_op       		),
		.mdu_op       		(mdu_op       		),
		.alu_op       		(alu_op       		),
		.shift_op     		(shift_op     		),
		.comparator_op		(comparator_op		),
		.alu_control  		(alu_control  		),
		.shift_control		(shift_control		),
		.mdu_control  		(mdu_control  		),
		.comparator_control	(comparator_control ),
		.mem_control		(mem_control		),
		.rs1_use      		(rs1_use     	 	),
		.rs2_use     		(rs2_use      		),
		.rd_use       		(rd_use       		),
		.imm_use      		(imm_use      		),
		.is_branch    		(is_branch    		),
		.imm         	 	(imm          		),
		.rs1_addr     		(rs1_addr     		),
		.rs2_addr     		(rs2_addr     		),
		.rd_addr      		(rd_addr      		)
	);
	 
	core_register_file GPR(
		.clk       (clk      ), 
		.read_addr1(rs1_addr ),
		.read_addr2(rs2_addr ),
		.read_data1(rs1_value),
		.read_data2(rs2_value),
		.write_data(rf_data  ),
		.write_addr(rf_addr  ),
		.we        (rf_we    )
	);
		 	 
endmodule