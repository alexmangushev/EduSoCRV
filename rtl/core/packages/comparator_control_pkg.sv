package comparator_control_pkg;
  parameter COMPARATOR_WIDTH_CODE = 3;
  parameter comparator_none       = 3'bxxx;
  parameter comparator_beq        = 3'b000;
  parameter comparator_bne        = 3'b001;
  parameter comparator_blt        = 3'b010;
  parameter comparator_bge        = 3'b011;
  parameter comparator_bltu       = 3'b100;
  parameter comparator_bgeu       = 3'b101;
endpackage