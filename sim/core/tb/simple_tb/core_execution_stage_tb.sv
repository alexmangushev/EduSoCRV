import core_pkg::*;
import alu_control_pkg::*;
import shift_control_pkg::*;
module core_execution_stage_tb();	
	logic alu_op;
	logic mdu_op;
	logic shift_op;
	
	logic [3:0] alu_control;
	logic [1:0] shift_control;
	logic       mdu_control;
	
	logic [DATA_WIDTH-1:0] ex_in_a;
	logic [DATA_WIDTH-1:0] ex_in_b;
	
	logic [DATA_WIDTH-1:0] ex_out;

	core_execution_stage dut(
	.alu_op       (alu_op       ),
	.mdu_op       (mdu_op       ),
	.shift_op     (shift_op     ),
	.alu_control  (alu_control  ),
	.shift_control(shift_control),
	.mdu_control  (mdu_control  ),
	.ex_in_a      (ex_in_a      ),
	.ex_in_b      (ex_in_b      ),
	.ex_out       (ex_out       )
	);	 
	 
    initial begin
	    alu_op = 0; shift_op = 1; mdu_op = 0;
		shift_control = shift_sll;
		ex_in_a = 3; 
		ex_in_b = 5;
		#50;
		shift_control = shift_srl;
		ex_in_a = -3;  
		ex_in_b = 5;
		#50;
		shift_control = shift_sra;
		ex_in_a = -3; 
		ex_in_b = 5;
		#50;
		alu_op = 1; shift_op = 0; mdu_op = 0;
		alu_control   = alu_add;
		ex_in_a = 3;
		ex_in_b = 5;
		#50;
		alu_control   = alu_sub;
		ex_in_a = 3;
		ex_in_b = 5;
		#50;
		alu_control   = alu_and;
		ex_in_a = 'hffff0000;
		ex_in_b = 'h0000ffff;
		#50;
		alu_control   = alu_or;
		ex_in_a = 'hffff0000;
		ex_in_b = 'h0000ffff;
		#50;
		alu_control   = alu_xor;
		ex_in_a = 'hffff0000;
		ex_in_b = 'h0000ffff;
		#50;
		alu_control   = alu_slt;
		ex_in_a = -3; 
		ex_in_b = 5;
		#50;
		alu_control   = alu_sltu;
		ex_in_a = -3;
		ex_in_b = 5;
		#50;
    end
	 
	 
endmodule