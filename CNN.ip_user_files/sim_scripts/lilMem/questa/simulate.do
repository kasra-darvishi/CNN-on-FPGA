onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib lilMem_opt

do {wave.do}

view wave
view structure
view signals

do {lilMem.udo}

run -all

quit -force
