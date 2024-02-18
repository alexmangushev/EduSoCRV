# create modelsim working library
vlib work

# save list of files in variables
set inc ../../../rtl/interfaces/apb_if.sv
set src ../../../rtl/gpio/gpio.sv
set tb  ../gpio_tb.sv

# compile all the Verilog sources
vlog +acc $inc $src $tb

# open the testbench module for simulation
vsim work.gpio_tb

add wave -hex *

# show apb signals
add wave -hex /gpio_tb/apb/*

# run the simulation
run -all

# expand the signals time diagram
wave zoom full