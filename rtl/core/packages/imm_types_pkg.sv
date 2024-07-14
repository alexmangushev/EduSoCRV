package imm_types_pkg;
  parameter IMM_WIDTH_CODE = 3;
  parameter imm_i_use      = 3'b000;
  parameter imm_s_use      = 3'b001;
  parameter imm_b_use      = 3'b010;
  parameter imm_u_use      = 3'b011;
  parameter imm_j_use      = 3'b100;
  parameter imm_none       = 3'bxxx;
endpackage