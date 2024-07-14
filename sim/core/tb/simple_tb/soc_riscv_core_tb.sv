import core_pkg::*;
module soc_riscv_core_tb();
	logic                     clk;          // clock
	logic                     rst;          // reset
	
	// AXI_lite READ channel
	logic  [DATA_WIDTH-1:0]   core_instr_RDATA;
	logic                     core_instr_RVALID;
	logic                     core_instr_RREADY;
	
	//AXI_lite READ ADDR channel
	logic                     core_instr_ARREADY;
	logic  [ADDR_WIDTH-1:0]   core_instr_ARADDR;
	logic                     core_instr_ARVALID;

	
	soc_riscv_core dut (
	.clk               (clk                ),
	.rst               (rst                ),
	.core_instr_RDATA  (core_instr_RDATA   ),
	.core_instr_RVALID (core_instr_RVALID  ),
	.core_instr_RREADY (core_instr_RREADY  ),
	.core_instr_ARREADY(core_instr_ARREADY ),
	.core_instr_ARADDR (core_instr_ARADDR  ),
	.core_instr_ARVALID(core_instr_ARVALID )
	);
	 
	parameter CLK_PERIOD = 50;
	always
	begin
        clk <= 0; #(CLK_PERIOD/2); clk <= 1; #(CLK_PERIOD/2);
    end
	 
	initial begin
		rst <= 0;
		#(CLK_PERIOD + CLK_PERIOD/10);
		rst <= 1;
		core_instr_RVALID  <= 1;
		core_instr_ARREADY <= 1;
		core_instr_RDATA = 32'h00100093; #(CLK_PERIOD); //addi x1, x0, 1
		core_instr_RDATA = 32'h00100113; #(CLK_PERIOD); //addi x2, x0, 1
		core_instr_RDATA = 32'h00208463; #(CLK_PERIOD); //beq x1, x2, label
		core_instr_RDATA = 32'h00a00193; #(CLK_PERIOD); //addi x3, x0, 10
		//label:
		core_instr_RDATA = 32'h00f00193; #(CLK_PERIOD); //addi x3, x0, 15
		#(10 * CLK_PERIOD);

		rst <= 0;
		#(CLK_PERIOD + CLK_PERIOD/10);
		rst <= 1;
		core_instr_RDATA = 32'h00100093; #(CLK_PERIOD); //addi x1, x0, 1
		core_instr_RDATA = 32'h00300113; #(CLK_PERIOD); //addi x2, x0, 3
		core_instr_RDATA = 32'h002081b3; #(CLK_PERIOD); //add  x3, x1, x2

		rst <= 0;
		#(CLK_PERIOD + CLK_PERIOD/10);
		rst <= 1;
		core_instr_RDATA = 32'hfff00093; #(CLK_PERIOD); //addi x1, x0, -1
		core_instr_RDATA = 32'h00209113; #(CLK_PERIOD); //slli x2, x1, 2
		core_instr_RDATA = 32'h0040a193; #(CLK_PERIOD); //slti x3, x1, 4
		core_instr_RDATA = 32'h0040b213; #(CLK_PERIOD); //sltiu x4, x1, 4
		core_instr_RDATA = 32'h0031c293; #(CLK_PERIOD); //xori x5, x3, 3
		core_instr_RDATA = 32'h0050d313; #(CLK_PERIOD); //srli x6, x1, 5
		core_instr_RDATA = 32'h4050d393; #(CLK_PERIOD); //srai x7, x1, 5
    end
endmodule