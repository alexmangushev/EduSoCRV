module gpio_tb;

localparam DATA_WIDTH  = 32;
localparam ADDR_WIDTH  = 32;

logic clk;
logic arstn;

logic [DATA_WIDTH - 1 : 0] gpio_in;
logic [DATA_WIDTH - 1 : 0] gpio_out;
logic [DATA_WIDTH - 1 : 0] gpio_en;

apb_if apb(clk, arstn);

gpio dut 
(
    .apb_in      (   apb         ),
    .gpio_in     (   gpio_in     ),
    .gpio_out    (   gpio_out    ),
    .gpio_en     (   gpio_en     )
);

initial begin
    clk = 0;
    arstn = 0;

    for (int i = 0; i < 3; i++)
        @(posedge clk);
    arstn <= '1;
    @(posedge clk);

    // set all output to 1
    apb.PSEL    <= '1;
    apb.PENABLE <= '0;
    apb.PADDR   <= 'h0000_0000; //config register
    apb.PWRITE  <= '1;
    apb.PWDATA  <= '1;
    @(posedge clk);
    apb.PENABLE <= '1;
    while(!apb.PREADY)
        @(posedge clk);

    apb.PSEL    <= '0;
    apb.PENABLE <= '0;
    @(posedge clk);


    // set all output to 1
    apb.PSEL    <= '1;
    apb.PENABLE <= '0;
    apb.PADDR   <= 'h0000_0008; //config register
    apb.PWRITE  <= '1;
    apb.PWDATA  <= '1;
    @(posedge clk);
    apb.PENABLE <= '1;
    while(!apb.PREADY)
        @(posedge clk);

    apb.PSEL    <= '0;
    apb.PENABLE <= '0;
    @(posedge clk);

    $stop();
end

always
    #1 clk <= !clk;

endmodule
