import core_pkg::*;
module core_fetch_stage
(
    input  logic                       clk,          // clock
	input  logic                       rst,          // reset
	input  logic                       fetch_stall,  // stall 
	input  logic  [ADDR_WIDTH  - 1: 0] new_pc,       // new pc value for branch instruction
	input  logic                       is_branch,    // control signal for branch instruction	 
	output logic  [INSTR_WIDTH  - 1: 0]instr,		 // fetched instruction

	// AXI_lite READ channel
	input  logic  [DATA_WIDTH-1:0]     RDATA,
	input  logic                       RVALID,
	output logic                       RREADY,
	
	//AXI_lite READ ADDR channel
	input  logic                       ARREADY,
	output logic  [ADDR_WIDTH-1:0]     ARADDR,
	output logic                       ARVALID
);
	 
	instruction_fetch_unit IFU0(
	.clk         (clk         ),
	.rst         (rst         ),
	.is_branch   (is_branch   ),
	.ARREADY     (ARREADY     ),
	.ARVALID     (ARVALID     ),
	.new_pc      (new_pc      ),
	.instr_addr  (ARADDR      )
	);
	
	
	always_ff @(posedge clk)
	begin
		if(!fetch_stall) begin
			ARVALID = 1'b1;
			RREADY  = 1'b1;
		end else begin
			ARVALID = 1'b0;
			RREADY  = 1'b0;
		end
	end
	
	assign instr = RVALID ? RDATA : 0;
endmodule