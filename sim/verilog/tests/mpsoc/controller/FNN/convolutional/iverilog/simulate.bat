@echo off
call ../../../../../../../../settings64_iverilog.bat

iverilog -g2012 -o system.vvp -c system.vc -s ntm_convolutional_fnn_testbench
vvp system.vvp
pause
