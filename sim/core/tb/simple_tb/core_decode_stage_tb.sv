module core_decode_stage_tb();	
	logic clk, rst;
	
	logic [31:0] instr;
	          
   	logic         mem_op;         
	logic         alu_op;         
	logic         mdu_op;         
	logic         shift_op;       
	logic   [3:0] alu_control;    
	logic   [1:0] shift_control;  
	logic         mdu_control;    
	logic         rs1_use;        
	logic         rs2_use;	     
	logic         rd_use;         
	logic         imm_use;        
	logic         is_branch;      

	logic  [31:0] imm;
	logic   [4:0] rs1_value;      
	logic   [4:0] rs2_value;
	 
	logic  [4:0]  rd_addr;
	
	core_decode_stage dut(
	.clk          (clk          ),
	.instr        (instr        ), 
	.mem_op       (mem_op       ),
	.alu_op       (alu_op       ),
	.mdu_op       (mdu_op       ),
	.shift_op     (shift_op     ),
	.alu_control  (alu_control  ),
	.shift_control(shift_control),
	.mdu_control  (mdu_control  ),
	.rs1_use      (rs1_use      ),
	.rs2_use      (rs2_use      ),
	.rd_use       (rd_use       ),
	.imm_use      (imm_use      ),
	.is_branch    (is_branch    ),
	.imm          (imm          ),
	.rs1_value    (rs1_value    ),
	.rs2_value    (rs2_value    ),
	.rd_addr      (rd_addr      )
	);
	 
    parameter CLK_PERIOD = 10;

    always
	begin
        clk <= 0; #(CLK_PERIOD/2); clk <= 1; #(CLK_PERIOD/2);
    end

    initial begin
		rst <= 0;
		#(CLK_PERIOD);
		rst <= 1;
		instr = 32'b00000000000100101000111110110011; #(CLK_PERIOD); 
		instr = 32'b01000000000100101000111110110011; #(CLK_PERIOD);
		instr = 32'b00000000000100101001111110110011; #(CLK_PERIOD);
		instr = 32'b00000000000100101010111110110011; #(CLK_PERIOD);
		instr = 32'b00000000000100101011111110110011; #(CLK_PERIOD);
		instr = 32'b00000000000100101100111110110011; #(CLK_PERIOD);
		instr = 32'b00000000000100101101111110110011; #(CLK_PERIOD);
		instr = 32'b01000000000100101101111110110011; #(CLK_PERIOD);
		instr = 32'b00000000000100101110111110110011; #(CLK_PERIOD);
		instr = 32'b00000000000100101111111110110011; #(CLK_PERIOD);
    end
	 
endmodule