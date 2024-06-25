module uart_top
#(
    DATA_WIDTH = 32,
    UART_WIDTH = 8,
    UART_SPEED = 115200,
    CTRL_ADDR  = 0,
    STUS_ADDR  = 4,
    RX_ADDR    = 8,
    TX_ADDR    = 12
)
(
    uart_if.slave uart_apb_in,
    input         rx,
    output        tx
);
    localparam reg_count = 4;


    logic apb_wait;
    logic clk;
    logic arstn;
    logic tx_transmit;

    //Регистры приёмо-передатчика
    logic [reg_count * DATA_WIDTH - 1:0] registers;

    logic [DATA_WIDTH - 1:0]             apb_prdata;

    //Сигналы
    assign apb_wait    = uart_apb_in.PSEL & uart_apb_in.PENABLE;
    assign clk         = uart_apb_in.PCLK;
    assign arstn       = uart_apb_in.PRESETn;
    assign tx_transmit = uart_apb_in.PADDR[3:0] == TX_ADDR & uart_apb_in.PWRITE;

    //Запись в регистры
    always_ff @(posedge clk or negedge arstn)
        if(~arstn)
            registers <= '0;
        else if(apb_wait & uart_apb_in.PWRITE)
            registers[uart_apb_in.PADDR << 3 +: DATA_WIDTH] <= uart_apb_in.PWDATA;

    //Чтение с регистров
    always_comb
    begin
        case(uart_apb_in.PADDR[3:0])
            CTRL_ADDR: apb_prdata = registers[DATA_WIDTH - 1:0];
            STUS_ADDR: apb_prdata = registers[STUS_ADDR << 3 +: DATA_WIDTH];
            RX_ADDR:   apb_prdata = registers[RX_ADDR   << 3 +: DATA_WIDTH];
            TX_ADDR:   apb_prdata = registers[TX_ADDR   << 3 +: DATA_WIDTH];
            default:   apb_prdata ='0;
        endcase
    end

    //Выставление pready и отправка данных
    always_ff @(posedge clk or negedge arstn)
        if(~arstn)
        begin
            uart_apb_in.PREADY <= '0;
            uart_apb_in.PRDATA <= '0;
        end
        else if(apb_wait)
        begin
            uart_apb_in.PREADY <= '0;
            uart_apb_in.PRDATA <= apb_prdata;
        end
        else
        begin
            uart_apb_in.PREADY <= '0;
            uart_apb_in.PRDATA <= '0;
        end

    //Подключение модулей приёмо-передатчика
    uart_tx #(.BUS_WIDTH(UART_WIDTH), .UART_SPEED(UART_SPEED)) transmitter 
    (
        .clk(clk),
        .data(registers[TX_ADDR << 3 +: UART_WIDTH]),
        .rst(~arstn),
        .transmit(tx_transmit),
        .tx(tx)
    );

    uart_rx #(.BUS_WIDTH(UART_WIDTH), .UART_SPEED(UART_SPEED)) reciever
    (
        .clk(clk),
        .rst(~arstn),
        .rx(rx),
        .data(registers[RX_ADDR << 3 +: UART_WIDTH])
    );

endmodule
