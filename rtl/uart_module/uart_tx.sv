module uart_tx #(
  parameter 
  BUS_WIDTH  = 8,
  UART_SPEED = 115200,
  CLK_FREQ   = 50000000,

  localparam
  PULSE_WIDTH = CLK_FREQ / UART_SPEED,
  PULSE_CNT_WIDTH = $clog2(PULSE_WIDTH),
  DATA_CNT_WIDTH = $clog2(BUS_WIDTH)
)

(
  input clk,
  input [BUS_WIDTH - 1:0] data,
  input rst,
  input transmit,
  output tx
);

  enum bit[1:0]{
    ST_SEND,
    ST_STOP,
    ST_WAIT,
    ST_START
  } state, next_state;

  logic [DATA_CNT_WIDTH - 1:0] data_cnt;
  logic tx_r;
  logic [PULSE_CNT_WIDTH - 1:0] pulse_cnt;

  //Счётчик для скорости передатчика
  always_ff @(posedge clk)
  if(rst)
    pulse_cnt <= '0;
  else if(pulse_cnt == PULSE_WIDTH)
    pulse_cnt <= '0;
  else
    pulse_cnt <= pulse_cnt + 'd1;
    
  //Изменение состояния
  always_ff @(posedge clk)
    if(rst)
      state <= ST_WAIT;
    else
      state <= next_state;

  //Логика выхода передатчика
  always_ff @(posedge clk) begin
    if(rst)
      tx_r <= 1'd1;
    else if(state == ST_SEND)
      tx_r <= data[data_cnt];
    else if(state == ST_WAIT)
      tx_r <= 1'b1;
    else if(state == ST_STOP)
      tx_r <= 1'b1;
    else if(state == ST_START)
      tx_r <= 1'b0;
  end

  //Логика счётчика данных
  always_ff @(posedge clk) begin
    if(rst)
      data_cnt <= 3'd0;
    else if(state == ST_SEND && pulse_cnt == PULSE_WIDTH)
      data_cnt <= data_cnt + 3'd1;
    else if(state == ST_STOP && pulse_cnt == PULSE_WIDTH)
      data_cnt <= 3'd0;
  end

  //Логика изменения состояния
  always_comb begin
    next_state = state;
    case(state)
      
      ST_WAIT: begin
	if(transmit && pulse_cnt == PULSE_WIDTH)
	  next_state = ST_START;
      end

      ST_START: begin
	if(pulse_cnt == PULSE_WIDTH)
	  next_state = ST_SEND;
      end

      ST_SEND: begin
	if(data_cnt == (BUS_WIDTH - 1) && pulse_cnt == PULSE_WIDTH)
	  next_state = ST_STOP;
      end

      ST_STOP: begin
	if(pulse_cnt == PULSE_WIDTH)  
	  next_state = ST_WAIT;
      end
    endcase
  end

  assign tx = tx_r;
endmodule
