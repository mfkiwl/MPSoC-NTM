@echo off
call ../../../../../../../settings64_msim.bat

vlib work
vcom -2008 -f system.vc
vsim -c -do run.do work.ntm_series_testbench
pause
