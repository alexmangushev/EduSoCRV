package alu_control_pkg;
  parameter ALU_WIDTH_CODE = 4;
  parameter alu_none       = 4'bxxxx;
  parameter alu_add        = 4'b0000;
  parameter alu_sub        = 4'b0001;
  parameter alu_and        = 4'b0010;
  parameter alu_or         = 4'b0011;
  parameter alu_slt        = 4'b0101;
  parameter alu_xor        = 4'b1000;
  parameter alu_sltu       = 4'b1101;
endpackage