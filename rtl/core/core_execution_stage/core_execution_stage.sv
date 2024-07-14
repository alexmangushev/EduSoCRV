import core_pkg::*;
import alu_control_pkg::*;
import shift_control_pkg::*;
module core_execution_stage 
(
    //control signals for mux
    input  logic                  alu_op,
	input  logic                  shift_op,
	input  logic                  mdu_op,
	
	//control signal for executions modules
	input  logic [ALU_WIDTH_CODE  -1:0]      alu_control,
	input  logic [SHIFT_WIDTH_CODE-1:0]      shift_control,
	input  logic                             mdu_control,

	//input values
	input  logic [DATA_WIDTH-1:0] ex_in_a,
	input  logic [DATA_WIDTH-1:0] ex_in_b,
	
	output logic [DATA_WIDTH-1:0] ex_out
);
    logic [31:0] alu_out;
	logic [31:0] shift_out;
    logic [31:0] mdu_out;
	 
	core_alu alu0 (
	.alu_control(alu_control),
	.alu_in_a   (ex_in_a    ),
	.alu_in_b   (ex_in_b    ),
	.alu_out    (alu_out    )
	);
	
	core_shift shift0 (
	.shift_control(shift_control),
	.shift_in_a   (ex_in_a      ),
	.shift_in_b   (ex_in_b      ),
	.shift_out    (shift_out    )
	);
	 	 
	always_comb
	begin
		ex_out = 'b0;
		if     (alu_op  ) ex_out = alu_out;
		else if(shift_op) ex_out = shift_out;
		else if(mdu_op  ) ex_out = mdu_out;
	end
	
endmodule
	 