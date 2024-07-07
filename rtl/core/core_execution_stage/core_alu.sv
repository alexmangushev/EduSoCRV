import core_pkg::*; 
import alu_control_pkg::*; // alu control package
module core_alu 
(
    input  logic [ALU_WIDTH_CODE-1: 0] alu_control,
	 
	 // values
	input  logic      [DATA_WIDTH-1:0] alu_in_a,
	input  logic      [DATA_WIDTH-1:0] alu_in_b,
	
	output logic      [DATA_WIDTH-1:0] alu_out
);
    logic [DATA_WIDTH-1:0] alu_add_res;
	logic [DATA_WIDTH-1:0] alu_sub_res;
	logic [DATA_WIDTH-1:0] alu_and_res;
	logic [DATA_WIDTH-1:0] alu_xor_res;
	logic [DATA_WIDTH-1:0] alu_or_res;
	logic [DATA_WIDTH-1:0] alu_slt_res;
	logic [DATA_WIDTH-1:0] alu_sltu_res;
	
	
	assign alu_add_res     = alu_in_a + alu_in_b;
	assign alu_sub_res     = alu_in_a - alu_in_b;
	assign alu_and_res     = alu_in_a & alu_in_b;
	assign alu_or_res      = alu_in_a | alu_in_b;
	assign alu_xor_res     = alu_in_a ^ alu_in_b;
	assign alu_sltu_res    = alu_in_a < alu_in_b;
	assign alu_slt_res     = alu_sub_res[DATA_WIDTH-1];
	
	always_comb
	begin
		alu_out = 'b0;
		case(alu_control)
			alu_add : alu_out = alu_add_res;
			alu_sub : alu_out = alu_sub_res;
			alu_and : alu_out = alu_and_res;
			alu_xor : alu_out = alu_xor_res;
			alu_or  : alu_out = alu_or_res;
			alu_slt : alu_out = alu_slt_res;
			alu_sltu: alu_out = alu_sltu_res;
			default : alu_out = alu_none;
		endcase
	end
	 
endmodule