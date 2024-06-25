module gpio
#(
    DATA_WIDTH  = 32,
    ADDR_WIDTH  = 32,
    CONFIG_ADDR = 0,
    INPUT_ADDR  = 4,
    OUTPUT_ADDR = 8
)
(
    apb_if.slave                        apb_in,
    input   logic [DATA_WIDTH - 1 : 0]  gpio_in,
    output  logic [DATA_WIDTH - 1 : 0]  gpio_out,
    output  logic [DATA_WIDTH - 1 : 0]  gpio_en
);

    localparam REGISTER_COUNT = 3;

    wire clk = apb_in.PCLK;
    wire arst = ~apb_in.PRESETn;
    wire apb_wait_ans = apb_in.PSEL & apb_in.PENABLE & ~apb_in.PREADY;
    wire apb_write_ready = apb_wait_ans & apb_in.PWRITE;

    logic [DATA_WIDTH - 1:0] gpio_write_reg;
    logic [DATA_WIDTH - 1:0] gpio_read_reg;

    logic [DATA_WIDTH - 1:0] apb_prdata;
    
    genvar i;
    generate
        for (i = 0; i < DATA_WIDTH; i++) begin: g_gpio_bit_slices
            gpio_bit_slice slice (
                .clk,
                .arst,
                .gpio_pin_in(gpio_in[i]),
                .gpio_pin_write(gpio_write_reg[i]),
                .gpio_pin_en(gpio_en[i]),
                .gpio_pin_read(gpio_read_reg[i]),
                .gpio_pin_out(gpio_out[i])
            );
        end
    endgenerate

    // APB WRITE HANDLER
    always_ff @(posedge clk or posedge arst) begin
        if (arst) begin
            gpio_en        <= '0;
            gpio_write_reg <= '0;
            // gpio_read_reg  <= '0;
        end
        else if (apb_write_ready) begin
            case (apb_in.PADDR)
                CONFIG_ADDR: gpio_en <= apb_in.PWDATA;
                OUTPUT_ADDR: gpio_write_reg <= apb_in.PWDATA;
            endcase
        end
    end

    // APB READ HANDLER
    // Set data for read transaction
    always_comb
        case (apb_in.PADDR)
            CONFIG_ADDR:    apb_prdata = gpio_en;
            INPUT_ADDR:     apb_prdata = gpio_read_reg;
            OUTPUT_ADDR:    apb_prdata = gpio_write_reg;
            default:        apb_prdata = '0;
        endcase

    // Set data and ready to APB
    always_ff @(posedge clk or posedge arst) begin
        if (arst) begin
            apb_in.PREADY <= '0;
            apb_in.PRDATA <= '0;
        end
        else if (apb_wait_ans) begin
            apb_in.PREADY <= '1;
            apb_in.PRDATA <= apb_prdata;
        end
        else begin
            apb_in.PREADY <= '0;
            apb_in.PRDATA <= '0;
        end
    end

endmodule
