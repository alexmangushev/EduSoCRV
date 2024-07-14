import core_pkg::*;
import comparator_control_pkg::*;
module core_comparator
(
    input  logic [COMPARATOR_WIDTH_CODE-1:0] comparator_control,
	input  logic [DATA_WIDTH-1:           0] comparator_in_a,
	input  logic [DATA_WIDTH-1:           0] comparator_in_b,
	output logic                             comparator_out
);
    logic  comparator_beq_res;
	logic  comparator_bne_res;
	logic  comparator_blt_res;
	logic  comparator_bge_res;
	logic  comparator_bltu_res;
	logic  comparator_bgeu_res; 
	
	assign comparator_beq_res  = (comparator_in_a == comparator_in_b);
	assign comparator_bne_res  = !(comparator_beq_res);
	assign comparator_blt_res  = (comparator_in_a - comparator_in_b) >>> 31;
	assign comparator_bge_res  = !(comparator_blt_res);
	assign comparator_bltu_res = (comparator_in_a < comparator_in_b);
	assign comparator_bgeu_res = !(comparator_bltu_res);
	 
	always_comb
	begin
		case(comparator_control)
			comparator_beq: comparator_out = comparator_beq_res;
			comparator_bne: comparator_out = comparator_bne_res;
			comparator_blt: comparator_out = comparator_blt_res;
			comparator_bge: comparator_out = comparator_bge_res;
			comparator_bltu:comparator_out = comparator_bltu_res;
			comparator_bgeu:comparator_out = comparator_bgeu_res;
			default:        comparator_out = comparator_none;
		endcase
	end 
endmodule