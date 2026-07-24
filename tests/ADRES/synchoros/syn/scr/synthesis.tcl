puts [pwd]
set CPU_NUM 12
set EFFORT high

source ../syn/scr/library.tcl

# Directories for output material
set TOP_NAME ADRES
set REPORT_DIR  ../syn/rpt;      # synthesis reports: timing, area, etc.
set OUT_DIR ../syn/db;           # output files: netlist, sdf sdc etc.
set SOURCE_DIR ../rtl/rtl;           # rtl code that should be synthesised
set SYN_DIR ../syn;              # synthesis directory, synthesis scripts constraints etc.

#library setup
set search_path ${LIB_SEARCH_PATH}
set target_library ${LIB_NAME}
set link_library "* ${LIB_NAME} ${synthetic_library}"

# syn setup
set compile_timing_high_effort true
set_host_options -max_cores ${CPU_NUM}

set hierarchy_files [split [read [open ${SOURCE_DIR}/ADRES_tile_hierarchy.txt r]] "\n"]

foreach filename [lrange ${hierarchy_files} 0 end-1] {
    if {![string equal [string index $filename 0] "#"]} {
        if {[string equal [file extension $filename] ".vhd"]} {
            analyze -format vhdl -lib WORK ${SOURCE_DIR}/${filename}
        } elseif {[string equal [file extension $filename] ".sv"]} {
            analyze -format sverilog -lib WORK ${SOURCE_DIR}/${filename}
        }
    }
}
elaborate adres_tile
current_design adres_tile
source ${SYN_DIR}/constraints.sdc
link
compile

analyze -format sverilog -lib WORK ${SOURCE_DIR}/global_controller.sv
elaborate global_controller
current_design global_controller
source ${SYN_DIR}/constraints.sdc
link 
compile

analyze -format sverilog -lib WORK ${SOURCE_DIR}/data_mem.sv
elaborate adres_data_memory
current_design adres_data_memory
source ${SYN_DIR}/constraints.sdc
link 
compile

analyze -format sverilog -lib WORK ${SOURCE_DIR}/adres_control_status.sv
elaborate adres_control_status
current_design adres_control_status
source ${SYN_DIR}/constraints.sdc
link 
compile

analyze -format sverilog -lib WORK ${SOURCE_DIR}/adres_tile_array.sv
elaborate adres_tile_array
current_design adres_tile_array
source ${SYN_DIR}/constraints.sdc
link 
set_dont_touch \
    [get_cells -hierarchical -filter "ref_name == adres_tile"] true
compile

analyze -format sverilog -lib WORK ${SOURCE_DIR}/adres_endpoints.sv
elaborate adres_endpoints
current_design adres_endpoints
source ${SYN_DIR}/constraints.sdc
link 
compile

analyze -format sverilog -lib WORK ${SOURCE_DIR}/adres_memory_subsystem.sv
elaborate adres_memory_subsystem
current_design adres_memory_subsystem
source ${SYN_DIR}/constraints.sdc
link 
dont_touch adres_data_memory true
compile

analyze -format sverilog -lib WORK ${SOURCE_DIR}/adres_checks.sv
elaborate adres_checks
current_design adres_checks
source ${SYN_DIR}/constraints.sdc
link 
compile

analyze -format sverilog -lib WORK ${SOURCE_DIR}/ADRES.sv
elaborate ADRES
current_design ADRES
source ${SYN_DIR}/constraints.sdc
set_clock_uncertainty 0.20 [get_clocks clk]
set_max_transition 0.08 [current_design]
set_max_fanout 4 [current_design]
link 
dont_touch adres_control_status true
dont_touch adres_tile_array true
dont_touch adres_endpoints true
dont_touch adres_memory_subsystem true
dont_touch adres_checks true
compile

report_timing > "${REPORT_DIR}/${TOP_NAME}_timing.txt"
report_power  > "${REPORT_DIR}/${TOP_NAME}_power.txt"
report_area   > "${REPORT_DIR}/${TOP_NAME}_area.txt"

write_file -format verilog -hier -output "${OUT_DIR}/${TOP_NAME}.v"
write_file -format ddc     -hier -output "${OUT_DIR}/${TOP_NAME}.ddc"
write_sdc "${OUT_DIR}/${TOP_NAME}.sdc"
write_sdf "${OUT_DIR}/${TOP_NAME}.sdf"
exit
