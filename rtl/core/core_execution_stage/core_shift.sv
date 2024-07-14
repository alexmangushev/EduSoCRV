import core_pkg::*;
import shift_control_pkg::*; // shift control package
module core_shift
(
    input  logic [ SHIFT_WIDTH_CODE-1:0] shift_control,
	 
	input  logic signed [DATA_WIDTH-1:0] shift_in_a,
	input  logic signed [DATA_WIDTH-1:0] shift_in_b,
	
	output logic        [DATA_WIDTH-1:0] shift_out
);
	logic [DATA_WIDTH-1:0] shift_sll_res;
	logic [DATA_WIDTH-1:0] shift_srl_res;
	logic [DATA_WIDTH-1:0] shift_sra_res;
	
	assign shift_sll_res = shift_in_a <<  shift_in_b;
	assign shift_srl_res = shift_in_a >>  shift_in_b;
	assign shift_sra_res = shift_in_a >>> shift_in_b;
	
	always_comb
	begin
		shift_out = 'b0;
	    case(shift_control)
			shift_sll: shift_out = shift_sll_res;
			shift_srl: shift_out = shift_srl_res;
			shift_sra: shift_out = shift_sra_res;
			default  : shift_out = shift_none;
		endcase
	end
endmodule