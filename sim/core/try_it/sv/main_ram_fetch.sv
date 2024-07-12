import core_pkg::*;
module main_ram_fetch // module for fetch tests  
(
	input  logic						clk,
	 
	//Write to mem wtihout axi_lite
	input  logic  [31:0]				write_data,
	input  logic  [ 4:0]				write_addr,
	input  logic						write_en,
	 
	//AXI_LITE READ channel
	output logic  [DATA_WIDTH-1:0]		RDATA,
	output logic						RVALID,	
	input  logic						RREADY,
	 
	//AXI_lite READ ADDR channel
	output logic						ARREADY,
	input  logic  [4:0]					ARADDR,
	input  logic						ARVALID
);
    logic [31:0] mem [31:0];
	 
	assign ARREADY = 1'b1;
	assign RVALID  = 1'b1;
	 
	always_ff @(posedge clk)
	begin
		if (clk & write_en) begin
			mem[write_addr] <= write_data;
		end
	end
	 
	assign RDATA = mem[ARADDR];
endmodule

