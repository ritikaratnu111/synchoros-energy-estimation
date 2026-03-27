onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/uut/clk
add wave -noupdate /tb/uut/reset
add wave -noupdate /tb/uut/data_mem0/AA
add wave -noupdate /tb/uut/data_mem0/DA
add wave -noupdate /tb/uut/data_mem0/memoryA
add wave -noupdate /tb/uut/data_mem0/WEBA
add wave -noupdate {/tb/uut/y[0]/x[0]/tile/addr_dm}
add wave -noupdate {/tb/uut/y[0]/x[0]/tile/control_reg_data}
add wave -noupdate -expand {/tb/uut/y[0]/x[0]/tile/o__flit_out}
add wave -noupdate {/tb/uut/y[0]/x[0]/tile/current_loop}
add wave -noupdate {/tb/uut/y[0]/x[0]/tile/data_out_dm}
add wave -noupdate {/tb/uut/y[0]/x[0]/tile/o__flit_out}
add wave -noupdate {/tb/uut/y[0]/x[0]/tile/loop_end}
add wave -noupdate {/tb/uut/y[0]/x[0]/tile/loop_start}
add wave -noupdate -expand {/tb/uut/y[0]/x[1]/tile/i__flit_in}
add wave -noupdate {/tb/uut/y[0]/x[1]/tile/control_reg_data}
add wave -noupdate {/tb/uut/y[0]/x[1]/tile/a25_simple_alu/result}
add wave -noupdate {/tb/uut/y[0]/x[1]/tile/o__flit_out}
add wave -noupdate {/tb/uut/y[0]/x[1]/control_mem/memoryA}
add wave -noupdate {/tb/uut/y[0]/x[1]/tile/treg}
add wave -noupdate {/tb/uut/y[0]/x[1]/tile/router/xbar_bypass/o__data_out}
add wave -noupdate {/tb/uut/y[0]/x[1]/tile/o__flit_out_wire}
add wave -noupdate {/tb/uut/y[0]/x[1]/tile/alu_out}
add wave -noupdate {/tb/uut/y[0]/x[1]/tile/tile_out}
add wave -noupdate {/tb/uut/y[0]/x[1]/tile/a25_simple_alu/op_LHS}
add wave -noupdate {/tb/uut/y[0]/x[1]/tile/a25_simple_alu/op_RHS}
add wave -noupdate {/tb/uut/y[0]/x[1]/tile/a25_simple_alu/operation}
add wave -noupdate {/tb/uut/y[0]/x[1]/tile/a25_simple_alu/result}
add wave -noupdate {/tb/uut/y[0]/x[1]/tile/router/xbar_bypass/w__flit_in}
add wave -noupdate {/tb/uut/y[0]/x[1]/tile/router/xbar_bypass/i__sel}
add wave -noupdate {/tb/uut/y[0]/x[2]/tile/i__flit_in}
add wave -noupdate {/tb/uut/y[0]/x[2]/control_mem/memoryA}
add wave -noupdate {/tb/uut/y[0]/x[2]/tile/control_reg_data}
add wave -noupdate {/tb/uut/y[0]/x[2]/tile/a25_simple_alu/op_LHS}
add wave -noupdate {/tb/uut/y[0]/x[2]/tile/a25_simple_alu/op_RHS}
add wave -noupdate {/tb/uut/y[0]/x[2]/tile/a25_simple_alu/result}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1669 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 290
configure wave -valuecolwidth 330
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {1643 ns} {1703 ns}
bookmark add wave bookmark0 {{0 ns} {84 ns}} 0
