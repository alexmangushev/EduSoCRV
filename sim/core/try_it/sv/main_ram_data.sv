import core_pkg::*;
module main_ram_data // module for data
(
	input  logic						    clk,

    input  logic  [31:0]                    write_data,
    input  logic  [4:0]                     write_addr,
    input  logic                            write_en,

	//AXI_LITE READ channel
	output logic  [DATA_WIDTH-1:0]		    RDATA,
	output logic						    RVALID,	
	input  logic						    RREADY,
	 
	//AXI_lite READ ADDR channel
	output logic						    ARREADY,
	input  logic  [31:0]					ARADDR,
	input  logic						    ARVALID,

    //AXI_lite Write Address Channel
	input  logic [31:0]						AWADDR,
	input  logic 							AWVALID,
	output logic							AWREADY,

	//AXI_lite Write Data Channel
	input  logic [DATA_WIDTH-1:0]			WDATA,
	output logic 							WREADY,
	input  logic 							WVALID
);
    logic [31:0] mem [31:0];
    logic [4:0] addr;
    logic [31:0] data;

	assign ARREADY  = 1'b1;
	assign RVALID   = 1'b1;
    assign AWREADY  = 1'b1;
    assign WREADY 	= 1'b1;

    assign addr = write_en ? write_addr : AWADDR;

	always_comb
	begin
		data = 'bx;		
		if(write_en) data = write_data;
		else begin
			for(int i = 0; i < 32; i++) begin
				if		(WDATA[i] 	 | !WDATA[i]) 		data[i] = WDATA[i];
				else if(mem[addr][i] | !mem[addr][i])	data[i] = mem[addr][i];
				else 									data[i] = 0;
			end
		end
	end
    
	always_ff @(posedge clk)
	begin
		if (clk & ((AWVALID & WVALID) | write_en)) begin
			mem[addr] <= data;
		end
	end
	 
	assign RDATA = mem[ARADDR];
endmodule