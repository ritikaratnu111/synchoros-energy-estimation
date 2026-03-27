`timescale 1ns/1ps
//import TopPkg::ScanControl;
import TopPkg::*;
import SMARTPkg::*;

module tb;

    // Parameters
    parameter NUM_INPUT_PORTS = 6;
    parameter NUM_OUTPUT_PORTS = 7;

    // Clock and Reset
    logic clk;
    logic reset;

    // Inputs
    FlitFixed i__flit_in [NUM_INPUT_PORTS-3:0]; // Only ports [0:3]
    logic [63:0] control_reg_data;
    logic [63:0] look_up_table;
    logic is_dm_tile;
    logic start_exec;
    logic [31:0] data_out_dm;

    // Outputs
    FlitFixed o__flit_out [NUM_OUTPUT_PORTS-4:0]; // Only ports [0:3]
    logic [4:0] loop_start;
    logic [4:0] loop_end;
    logic [8:0] addr_dm;
    logic [31:0] bit_en;
    logic [31:0] data_in_dm;
    logic rd_en_dm;
    logic wr_en_dm;

    // Clock Generation
    always #5 clk = ~clk;

    // DUT instantiation
    tile dut (
        .clk(clk),
        .reset(reset),
        .i__flit_in(i__flit_in),
        .o__flit_out(o__flit_out),
        .control_reg_data(control_reg_data),
        .look_up_table(look_up_table),
        .is_dm_tile(is_dm_tile),
        .start_exec(start_exec),
        .loop_start(loop_start),
        .loop_end(loop_end),
        .addr_dm(addr_dm),
        .bit_en(bit_en),
        .data_in_dm(data_in_dm),
        .data_out_dm(data_out_dm),
        .rd_en_dm(rd_en_dm),
        .wr_en_dm(wr_en_dm)
    );

    // Test Sequence
    initial begin
        $display("Starting simulation...");

        // Initialize signals
        clk = 0;
        reset = 1;
        start_exec = 0;
        control_reg_data = 64'b0;
        look_up_table = 64'b0;
        is_dm_tile = 0;
        data_out_dm = 32'hDEADBEEF;

        #12;
        reset = 0;

        // Apply first instruction
        #10;
        control_reg_data    = 64'h0000_0000_4000_0001;  // Dummy values for now
        look_up_table       = 64'h0000_0000_0000_0001;
        i__flit_in[0].data  = 33'd5; // 33-bit value
        i__flit_in[1].data  = 33'd10; // 33-bit value
        i__flit_in[2].data  = 33'd20; // 33-bit value
        i__flit_in[3].data  = 33'd30; // 33-bit value
        start_exec = 1;

        #10;
        start_exec = 0;

        // Let it run for a few cycles
        #30;

        $display("Ending simulation...");
        $finish;
    end

endmodule

