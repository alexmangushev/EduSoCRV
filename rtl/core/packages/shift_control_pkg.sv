package shift_control_pkg;
  parameter SHIFT_WIDTH_CODE = 2;
  parameter shift_none       = 2'bxx;
  parameter shift_sll        = 2'b00;
  parameter shift_srl        = 2'b01;
  parameter shift_sra        = 2'b11;
endpackage