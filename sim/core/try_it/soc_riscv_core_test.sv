module soc_riscv_core_test(
    input logic                     clk,          // clock
	 input logic                     rst,          // reset
	 
	 //Memory write channel
	 input logic  [31:0]             mem_write_data,
	 input logic  [4:0]              mem_write_addr,
	 input logic                     mem_write_en
);	 
    //Memory AXI_LITE READ channel
    logic  [31:0]   mem_RDATA;
	 logic                     mem_RVALID;
	 logic                     mem_RREADY;
	  
	 //Memory AXI_lite READ ADDR channel
	 logic                     mem_ARREADY;
	 logic  [4:0]              mem_ARADDR;
	 logic                     mem_ARVALID;
	 
    //Core fetch AXI_lite READ channel
	 logic  [31:0]   core_instr_RDATA;
	 logic                     core_instr_RVALID;
	 logic                     core_instr_RREADY;
	 
	 //Core fetch AXI_lite READ ADDR channel
	 logic                     core_instr_ARREADY;
	 logic  [31:0]   core_instr_ARADDR;
	 logic                     core_instr_ARVALID;
	
	 main_ram_fetch ram_fetch(
	 .clk           (clk           ),
	 .write_data    (mem_write_data),
	 .write_addr    (mem_write_addr),
	 .write_en      (mem_write_en  ),
	 .RDATA         (mem_RDATA     ),
	 .RVALID        (mem_RVALID    ),
	 .RREADY        (mem_RREADY    ),
	 .ARADDR        (mem_ARADDR    ),
	 .ARREADY       (mem_ARREADY   ),
	 .ARVALID       (mem_ARVALID   )
	 );
	 
	 assign core_instr_RDATA   = mem_RDATA;
	 assign core_instr_RVALID  = mem_RVALID;
	 assign core_instr_ARREADY = mem_ARREADY;
	 assign mem_RREADY         = core_instr_RREADY;
	 assign mem_ARADDR         = core_instr_ARADDR >> 2;
	 assign mem_ARVALID        = core_instr_ARVALID;
	 
	 soc_riscv_core core (
	 .clk               (clk                ),
	 .rst               (rst                ),
	 .core_instr_RDATA  (core_instr_RDATA   ),
	 .core_instr_RVALID (core_instr_RVALID  ),
	 .core_instr_RREADY (core_instr_RREADY  ),
	 .core_instr_ARREADY(core_instr_ARREADY ),
	 .core_instr_ARADDR (core_instr_ARADDR  ),
	 .core_instr_ARVALID(core_instr_ARVALID )
	 );
	 
	 
endmodule

