module uart_rx
#(
  parameter
  BUS_WIDTH = 8,
  UART_SPEED = 115200,
  CLK_FREQ = 50000000,
  localparam
  PULSE_WIDTH = CLK_FREQ / UART_SPEED,
  PULSE_CNT_WIDTH = $clog2(PULSE_WIDTH),
  DATA_CNT_WIDTH = $clog2(BUS_WIDTH),
  HALF_PULSE = PULSE_WIDTH / 2
)
(
  input clk,
  input rst,
  input rx,
  output [BUS_WIDTH - 1:0] data
);

  enum bit[1:0]{
    ST_START,
    ST_RECIEVE,
    ST_STOP,
    ST_WAIT
  } state, next_state;

  logic [DATA_CNT_WIDTH - 1:0] data_cnt;
  logic [BUS_WIDTH - 1:0] data_r;
  logic [PULSE_CNT_WIDTH - 1: 0] pulse_cnt;

  //Счётчик для скорости приёмника
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

  //Изменение счётчика данных
  always_ff @(posedge clk)
    if(rst)
      data_cnt <= 3'd0;
    else if(state == ST_STOP)
      data_cnt <= 3'd0;
    else if(state == ST_RECIEVE && pulse_cnt == PULSE_WIDTH)
      data_cnt <= data_cnt + 3'd1;

  //Регистр поступающих данных
  always_ff @(posedge clk)
    if(rst)
      data_r <= 8'd0;
    else if(state == ST_WAIT) 
      data_r <= 8'd0;
    else if(state == ST_RECIEVE)
      data_r[data_cnt] <= rx;

  //Логика изменения состояний
  always_comb begin
    next_state = state;
    case(state)
      ST_RECIEVE: begin
        if(data_cnt == (BUS_WIDTH - 1) && pulse_cnt == PULSE_WIDTH)
	  next_state = ST_STOP;
      end

      ST_WAIT: begin
        if(~rx)
	  next_state = ST_START;
      end

      ST_STOP: begin
	if(pulse_cnt == PULSE_WIDTH)
	  next_state = ST_WAIT;
      end

      ST_START: begin
	if(pulse_cnt == PULSE_WIDTH)
	  next_state = ST_RECIEVE;
      end
    endcase
  end

  assign data = data_r;

endmodule
