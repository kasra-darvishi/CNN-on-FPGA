@echo off
set xv_path=D:\\Program_files\\Xilinx\\Vivado\\2015.4\\bin
call %xv_path%/xsim testBench_behav -key {Behavioral:sim_1:Functional:testBench} -tclbatch testBench.tcl -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
