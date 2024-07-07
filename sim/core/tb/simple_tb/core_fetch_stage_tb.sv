import core_pkg::*;
module core_fetch_stage_tb();
	logic                     clk;          // clock
	logic                     rst;          // reset
	logic                     fetch_stall;  // stall 
	logic  [REG_WIDTH  - 1: 0]new_pc;       // new pc value for branch instruction
	logic                     is_branch;    // control signal for branch instruction	 
	logic  [REG_WIDTH  - 1: 0]instr;
	
	// AXI_lite READ channel
	logic  [DATA_WIDTH-1:0]   RDATA;
	logic                     RVALID;
	logic                     RREADY;
	
	//AXI_lite READ ADDR channel
	logic                     ARREADY;
	logic  [ADDR_WIDTH-1:0]   ARADDR;
	logic                     ARVALID;
	
	 
	core_fetch_stage dut (
	.clk        (clk        ),
	.rst        (rst        ),
	.fetch_stall(fetch_stall),
	.new_pc     (new_pc     ),
	.is_branch  (is_branch  ),
	.instr      (instr      ),
	.RDATA      (RDATA      ),
	.RVALID     (RVALID     ),
	.ARREADY    (ARREADY    ),
	.ARADDR     (ARADDR     ),
	.ARVALID    (ARVALID    )
	);
	 
	parameter CLK_PERIOD = 50;
	always
	begin
		clk <= 0; #(CLK_PERIOD/2); clk <= 1; #(CLK_PERIOD/2);
	end
	 
	initial begin
		rst <= 0;
		#(CLK_PERIOD/10);
		rst <= 1;
		ARREADY <= 1'b1;
		RVALID  <= 1'b1;
		RDATA   <= 1'b1;
    end
endmodule