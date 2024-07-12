module core_control_unit(
	input  logic is_branch,
	input  logic new_pc_valid,

	input  logic mem_op,
	input  logic mem_op_valid,

	output logic fetch_stall
);
   always_comb
	begin
	   fetch_stall = 'b0;
	   if(is_branch) begin
	        if(new_pc_valid) 	fetch_stall = 0;
		    else             	fetch_stall = 1;
		end
		else if(mem_op) begin
			if(mem_op_valid) 	fetch_stall = 0;
		    else               	fetch_stall = 1;
		end else               	fetch_stall = 0; 
	end
endmodule