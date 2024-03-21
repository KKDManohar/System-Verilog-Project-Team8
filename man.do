vlib work

vlog -lint -source 8088if.svp
vlog -lint -source iom.sv
vlog -lint -source Intel8088Pins.sv
vlog -lint -source top-3.sv

vsim -voptargs=+acc work.top
add wave sim:/top/*
add wave sim:/top/m1.CURRENT_STATE
add wave sim:/top/m1.NEXT_STATE
add wave sim:/top/m2.CURRENT_STATE
add wave sim:/top/m2.NEXT_STATE
add wave sim:/top/m3.CURRENT_STATE
add wave sim:/top/m3.NEXT_STATE
add wave sim:/top/m4.CURRENT_STATE
add wave sim:/top/m4.NEXT_STATE

run -all