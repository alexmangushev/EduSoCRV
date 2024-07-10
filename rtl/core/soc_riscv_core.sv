import core_pkg::*;
import alu_control_pkg::*;
import shift_control_pkg::*;
import comparator_control_pkg::*;
module soc_riscv_core
(
    input  logic                     clk,          // clock
	input  logic                     rst,          // reset
	 
    // Instruction AXI_lite READ channel
	input  logic  [DATA_WIDTH-1:0]   core_instr_RDATA, 
	input  logic                     core_instr_RVALID,
	output logic                     core_instr_RREADY,
	
	// Instruction AXI_lite READ ADDR channel
	input  logic                    core_instr_ARREADY,
	output logic  [ADDR_WIDTH-1:0]   core_instr_ARADDR,
	output logic                     core_instr_ARVALID
	 
);
	// Fetch
    logic                  fetch_stall;	
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
	.ARADDR     (cur_pc            ),
	.ARVALID    (core_instr_ARVALID)
	);
	 
	assign core_instr_ARADDR = cur_pc;
	
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
	 
	always_comb // muxes between ID and IE stages
	begin
		ex_in_a = '0;
		ex_in_b = '0;
		if(rs1_use & rs2_use & !is_branch) begin 		// opcode 51
			ex_in_a 	= rs1_value;
			ex_in_b 	= rs2_value;
		end
		else if(rs1_use & imm_use & !is_branch) begin 	// opcode 19
			ex_in_a 	= rs1_value;
			ex_in_b 	= imm;
		end
		else if(!rs1_use & !rs2_use) begin 				// opcode 55
			ex_in_a 	= 0;
			ex_in_b 	= imm;
		end
		else if(rs1_use & rs2_use & is_branch) begin 	// opcode 99
			ex_in_a 	= cur_pc;
			ex_in_b 	= imm;
		end
	end
	 
	
	core_execution_stage IE
	(
	.alu_op       (alu_op       ),
	.mdu_op       (mdu_op       ),
	.shift_op     (shift_op     ),
	.alu_control  (alu_control  ),
	.mdu_control  (mdu_control  ),
	.shift_control(shift_control),
	.ex_in_a      (ex_in_a      ),
	.ex_in_b      (ex_in_b      ),
	.ex_out       (ex_out       )
	);
	 
	 
	always_comb // write back
	begin
		rf_we   	<= 'b0;
		rf_data 	<= 'b0;
		rf_addr 	<= 'b0;
		if(rd_use) begin
			rf_we   <= 1'b1;
			rf_data <= ex_out;
			rf_addr <= rd_addr;
		end
	end
	 
	always_comb
	begin
		new_pc_valid = 'b0;
		if(rs1_use & rs2_use & is_branch) begin // opcode 99
			if(comparator_op) begin
				new_pc        	= comparator_out ? ex_out : cur_pc + 4;
				new_pc_valid  	= 1'b1;
			end else begin
				new_pc        	= ex_out;
				new_pc_valid  	= 1'b1;
			end
		end
		else begin
			new_pc        		= 0;
			new_pc_valid  		= 0;
		end 
	end
	 
	core_comparator comparator(
	.comparator_control(comparator_control),
	.comparator_in_a   (rs1_value         ),
	.comparator_in_b   (rs2_value         ),
	.comparator_out    (comparator_out    )
	);
	
	core_control_unit CU(
	.is_branch   (is_branch   ),
	.new_pc_valid(new_pc_valid),
	.fetch_stall (fetch_stall )
	);
	 
endmodule
