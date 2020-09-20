@echo off
set xv_path=D:\\Program_files\\Xilinx\\Vivado\\2015.4\\bin
call %xv_path%/xelab  -wto 86d849823be94ca997f110a492c06b44 -m64 --debug typical --relax --mt 2 -L xil_defaultlib -L secureip --snapshot testBench_behav xil_defaultlib.testBench -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
