# create modelsim working library
vlib work

# save list of files in variables
set inc ../../include/*.sv
set src ../../rtl/*.sv
set tb  ../../testbench/*.sv

# compile all the Verilog sources
vlog $inc $src $tb

# open the testbench module for simulation
vsim work.rv_core_testbench

#add wave -color orange -hex -group tb /rv_core_testbench/*
#add wave -hex -group top /rv_core_testbench/dut/core/*
#add wave -hex -group fetch /rv_core_testbench/dut/core/i_fetch_stage/*
#add wave -hex -group fetch /rv_core_testbench/dut/core/i_fetch_stage/i_fetch_unit/*
#add wave -hex -group decode /rv_core_testbench/dut/core/i_decode_stage/*
#add wave -hex -group decode /rv_core_testbench/dut/core/i_decode_stage/i_gpr/rf_reg

#add wave -recursive /rv_core_testbench/dut/core/*
#add wave /rv_core_testbench/dut/core/*
#add wave -recursive *

# run the simulation
run -all

# expand the signals time diagram
wave zoom full