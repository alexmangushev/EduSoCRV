import core_pkg::*;          //package with INSTR_WIDTH, DATA_WIDTH, REG_WIDTH and ADDR_WIDTH
import alu_control_pkg::*;   //package with ALU control code
import shift_control_pkg::*; //package with shift control code
import imm_types_pkg::*;     //package with imm types code
import comparator_control_pkg::*;
module instruction_decode_unit
(
    input logic  [   INSTR_WIDTH-1:0]  		 instr,         	 // instruction                 

	 // Control signals
    output logic                       		 mem_op,        	 // Memory operation
	 output logic                       	 alu_op,        	 // Instruction uses ALU
	 output logic                      		 mdu_op,        	 // Instruction uses MDU
	 output logic                      		 shift_op,      	 // Instruction uses shift
	 output logic                      		 comparator_op, 	 // Instruction uses comparator
	 output logic [ALU_WIDTH_CODE  -1:0]	 alu_control,   	 // Code for ALU
	 output logic [SHIFT_WIDTH_CODE-1:0]	 shift_control, 	 // Code for shift
	 output logic                       	 mdu_control,  		 // Code for MDU
	 output logic [COMPARATOR_WIDTH_CODE-1:0]comparator_control, // Code for comparator
	 output logic                       	 rs1_use,      		 // Instruction contain rs1
	 output logic                      		 rs2_use,       	 // Instruction contain rs2
	 output logic                      		 rd_use,       		 // Instruction contain rd
	 output logic                      		 imm_use,       	 // Instruction contain use
	 output logic                      		 is_branch,     	 // Instruction is a branch instruction
	  
	 
	 // Data and address
	 output logic  [   DATA_WIDTH-1:0]  imm,           			 // imm field
	 output logic  [   4:0]             rs1_addr,      			 // rs1 address
	 output logic  [   4:0]             rs2_addr,      			 // rs2 address
	 output logic  [   4:0]             rd_addr        			 // rd address 
);
	logic [6:0] funct7;
	logic [6:0] opcode;
    logic [2:0] funct3;
	 
	//imm types
	logic [IMM_WIDTH_CODE-1:0]       imm_use_code;
	logic [11:0]                     imm_i_type;
	logic [11:0]                     imm_s_type;
	logic [12:0]                     imm_b_type;
	logic [31:0]                     imm_u_type;
	logic [20:0]                     imm_j_type; 
	logic                            imm_sign_ext;
	 
	//imm_fields
	assign imm_i_type = instr[31:20];
	assign imm_s_type = {instr[31:25], instr[11:7]};
	assign imm_b_type = {instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
	assign imm_u_type = {instr[31:12], 12'b0};
	assign imm_j_type = {instr[31], instr[30:23], instr[22], instr[21:12], 1'b0};
	
	//rs1, rs2 addr and rd_addr
	assign rs1_addr = instr[19:15];
	assign rs2_addr = instr[24:20];
	assign rd_addr  = instr[11: 7];
	
	//opcode, funct3 and funct7 fields
	assign opcode = instr[6:0  ];
	assign funct3 = instr[14:12];
	assign funct7 = instr[31:25];	 
	
	always_comb // imm type select and sign extend
	begin
		imm = 32'b0;
		case(imm_use_code)
			imm_i_use: imm = (imm_sign_ext & imm_i_type[11]) ? (32'hfffff000 | imm_i_type) : (32'h00000fff & imm_i_type); 
			imm_s_use: imm = (imm_sign_ext & imm_s_type[11]) ? (32'hfffff000 | imm_s_type) : {20'b0, imm_s_type}; 
			imm_b_use: imm = (imm_sign_ext & imm_b_type[12]) ? (32'hffffe000 | imm_b_type) : {19'b0, imm_b_type}; 
			imm_u_use: imm = imm_u_type; 
			imm_j_use: imm = (imm_sign_ext & imm_j_type[20]) ? (32'hffe00000 | imm_j_type) : {11'b0, imm_j_type}; 
		endcase
	end
	
	always_comb // decode
	begin
		mem_op      		= 0;    
		alu_op      		= 0;
		shift_op    		= 0;		  
		mdu_op      		= 0;
		comparator_op 		= 0;		  
		imm_use     		= 0; 
		imm_use_code		= imm_none;
		imm_sign_ext		= 0;
		rs1_use    			= 0;
		rs2_use     		= 0;
		rd_use      		= 0;
		is_branch   		= 0;
		alu_control			= alu_none;
		mdu_control 		= 1'bx;
		shift_control 		= shift_none;
		comparator_control 	= comparator_none;
		case(opcode)
				7'b0110011:   //opcode 51
				begin				    
					imm_use     = 0; 
					rs1_use     = 1;
					rs2_use     = 1;
					rd_use      = 1;
					is_branch   = 0;
					case(funct3)
						3'b000:
							begin
								case(funct7)
									7'b0000000: 			// add
										begin
											alu_control 	= alu_add; 
											alu_op 			= 1; 
											shift_op 		= 0; 
											shift_control 	= shift_none;
										end
									7'b0100000: 			// sub 
										begin
											alu_control 	= alu_sub; 
											alu_op			= 1; 
											shift_op	 	= 0; 
											shift_control 	= shift_none;
										end		 
								endcase
							end
						3'b001:
							begin
								case(funct7)
									7'b0000000: 			// sll
									begin
										shift_control 		= shift_sll; 
										alu_op 				= 0; 
										shift_op 			= 1; 
										alu_control 		= alu_none;
									end
								endcase
							end
						3'b010:
							begin
								case(funct7)
									7'b0000000: 			// slt
									begin
										alu_control 		= alu_slt; 
										alu_op 				= 1; 
										shift_op 			= 0; 
										shift_control 		= shift_none;
									end
								endcase
							end
						3'b011:
							begin
								case(funct7)
									7'b0000000: 			// sltu
									begin
										alu_control 		= alu_sltu; 
										alu_op 				= 1; 
										shift_op 			= 0; 
										shift_control 		= shift_none;
									end
								endcase
							end
						3'b100:
							begin
								case(funct7)
									7'b0000000: 			// xor
									begin
										alu_control 		= alu_xor; 
										alu_op 				= 1; 
										shift_op 			= 0; 
										shift_control 		= shift_none;
									end
								endcase
							end
						3'b101:
							begin
								case(funct7)
									7'b0000000: 			// srl
									begin
										shift_control 		= shift_srl; 
										alu_op 				= 0; 
										shift_op 			= 1; 
										alu_control 		= alu_none;
									end
									7'b0100000: 			// sra
									begin
										shift_control 		= shift_sra;
										alu_op 				= 0;
										shift_op 			= 1;
										alu_control 		= alu_none;
									end
								endcase
							end
						3'b110:
							begin
								case(funct7)
									7'b0000000: 			// or
									begin
										alu_control 		= alu_or;
										alu_op 				= 1;
										shift_op 			= 0;
										shift_control 		= shift_none;
									end
								endcase
							end
						3'b111:
							begin
								case(funct7)
									7'b0000000: 			// and
									begin 
										alu_control 		= alu_and;
										alu_op 				= 1;
										shift_op 			= 0;
										shift_control 		= shift_none;
									end
								endcase
							end
					endcase
				end
			7'b0010011:    //opcode 19
			begin				     
				imm_use     	= 1; 
				imm_use_code	= imm_i_use;
				rs1_use     	= 1;
				rs2_use     	= 0;
				rd_use      	= 1;
				is_branch   	= 0;
				case(funct3)
					3'b000:                            		// addi
						begin 
										alu_control 		= alu_add; 
										alu_op 				= 1;
										imm_sign_ext 		= 1;
										shift_op 			= 0; 
										shift_control 		= shift_none;
						end
					3'b001:
						begin
								case(funct7)
									7'b0000000:            // slli
									begin
										shift_control 		= shift_sll; 
										alu_op 				= 0; 
										imm_sign_ext 		= 0;
										shift_op 			= 1; 
										alu_control 		= alu_none;
									end
								endcase
						end
					3'b010:                            // slti
						begin
										alu_control 	= alu_slt; 
										alu_op 			= 1; 
										imm_sign_ext	= 1;
										shift_op	 	= 0; 
										shift_control 	= shift_none;
						end
					3'b011:                            // sltiu
						begin
										alu_control		= alu_sltu; 
										alu_op 			= 1; 
										imm_sign_ext 	= 1;
										shift_op 		= 0; 
										shift_control 	= shift_none;
						end
					3'b100:                            // xori
						begin
										alu_control 	= alu_xor; 
										alu_op 			= 1;
										imm_sign_ext 	= 1; 
										shift_op 		= 0; 
										shift_control 	= shift_none;
						end
					3'b101:
						begin
								case(funct7)
									7'b0000000:       	// srli
									begin
										shift_control 	= shift_srl; 
										alu_op 			= 0; 
										imm_sign_ext 	= 0;
										shift_op 		= 1; 
										alu_control 	= alu_none;
									end
									7'b0100000:         // srai
									begin
										shift_control 	= shift_sra;
										alu_op 			= 0;
										imm_sign_ext 	= 0;
										shift_op 		= 1;
										alu_control 	= alu_none;
									end
								endcase
						end
					3'b110:                           // ori
						begin
										alu_control 	= alu_or;
										alu_op 			= 1;
										imm_sign_ext 	= 1;
										shift_op 		= 0;
										shift_control 	= shift_none;
						end
					3'b111:                          // andi
						begin
										alu_control 	= alu_and;
										alu_op 			= 1;
										imm_sign_ext 	= 1;
										shift_op 		= 0;
										shift_control 	= shift_none;
						end
				endcase
			end
			7'b0110111:              // opcode 55
				begin                    			// lui   
					alu_op      	= 1;			  
					imm_use     	= 1; 
					imm_use_code	= imm_u_use;
					imm_sign_ext	= 1;
					rs1_use     	= 0;
					rs2_use     	= 0;
					rd_use     	 	= 1;
					is_branch  	 	= 0;
					alu_control 	= alu_add;
				end
				7'b1100011:             //opcode 99
				begin
					mem_op        = 0;
					alu_op        = 1;
					alu_control   = alu_add;
					shift_op      = 0;
					comparator_op = 1;
					rs1_use       = 1;
					rs2_use       = 1;
					rd_use        = 0;
					imm_use       = 1;
					imm_use_code  = imm_b_use;
					is_branch     = 1;
					case(funct3)
						3'b000: comparator_control = comparator_beq;  // beg
						3'b001: comparator_control = comparator_bne;  // bne
						3'b100: comparator_control = comparator_blt;  // blt
						3'b101: comparator_control = comparator_bge;  // bge
						3'b110: comparator_control = comparator_bltu; // bltu
						3'b111: comparator_control = comparator_bgeu; // bgeu
					endcase
				end
		endcase
	end
endmodule