module gpio_bit_slice (
    input clk,
    input arst,
    
    input logic gpio_pin_in,        // is input value
    input logic gpio_pin_write,     // value to write output 
    input logic gpio_pin_en,        // enbale pin to control invertor

    output logic gpio_pin_read,     // read input value
    output logic gpio_pin_out       // write pin to output
);
    // gpio input
    localparam DEPTH_SYNC = 3;
    logic [DEPTH_SYNC - 1:0] in_value;

    always_ff @(posedge clk or posedge arst)
        if (arst) in_value <= 'b0;
        else if (!gpio_pin_en) in_value <= {in_value[DEPTH_SYNC - 2:0], gpio_pin_in};
    assign gpio_pin_read = in_value[DEPTH_SYNC - 1];
    // ...

    // gpio output
    always_ff @(posedge clk or posedge arst)
        if (arst) gpio_pin_out <= 1'b0;
        else if(gpio_pin_en) gpio_pin_out <= gpio_pin_write;
    // ...

endmodule
