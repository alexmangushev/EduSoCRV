import core_pkg::*; // package with INSTR_WIDTH, DATA_WIDTH, REG_WIDTH and ADDR_WIDTH
module instruction_fetch_unit 
(
    input  logic                     clk,          // clock
	input  logic                     rst,          // reset
	
	input  logic  [ADDR_WIDTH - 1: 0]new_pc,       // new pc value for branch instruction
	input  logic                     is_branch,    // control signal for branch instruciton
	
	input  logic                     ARREADY,      // AXI_lite ARREADY
	input  logic                     ARVALID,	   // AXI_lite ARVALID
	
	output logic  [ADDR_WIDTH - 1: 0]instr_addr    // pc value
);
    logic [ADDR_WIDTH-1:0] pc; // pc register
	 
	 typedef enum logic [1:0] {
		State_zero         = 2'b00, // Reset PC
		State_wait         = 2'b01, // Save PC
		State_free_pipe    = 2'b10  // Update PC
	 } statetype;
	 statetype state, nextstate;
	 

	always_comb // FSM
	begin
	    nextstate = state;
	    case(state)
			State_zero:      if( ARREADY &  ARVALID)        nextstate <= State_free_pipe;
			State_wait:      if( ARREADY &  ARVALID)        nextstate <= State_free_pipe;
			State_free_pipe: if(!ARREADY | !ARVALID)        nextstate <= State_wait;
			default:                                        nextstate <= State_zero;
		endcase
	end
	
	always_ff @(posedge clk) // FSM
	begin
	    case(state)
		    State_zero:      pc <= 32'b0;
			State_wait:      pc <= pc;
			State_free_pipe: pc <= is_branch ? new_pc : pc + 4; // branch_instruction or next_instruction
			default:         pc <= 32'b0;                               
		endcase
	end

	always_ff @(posedge clk) // FSM
	begin
	    if     (!rst) state <= State_zero;
		else if( clk) state <= nextstate;
	end
	
	assign instr_addr = pc;
endmodule