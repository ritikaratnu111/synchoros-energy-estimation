`timescale 1ns/1ps

`define NUM_DATA		    8
`define NUM_INST		    8
`define CYCLE               (10)
`define HALF_CYCLE          (`CYCLE/2.0)

module tb;

    // Clock and Reset
    logic clk;
    logic reset;

    // Inputs
    logic chip_en;
    logic bist_en;
    logic scan_start_exec;
    logic scan_data_or_addr;
    logic read_write;
    logic scan_in;
    logic scan_en;

    logic [1:0] data_addr_valid;
    logic [15:0] data;
    logic [1:0] scan_chain_sel_0;
    logic [1:0] scan_chain_sel_1;
    logic [1:0] scan_chain_sel_2;
    logic [1:0] scan_chain_sel_3;

    // Outputs
    logic bist_success;
    logic data_out_valid;
    logic exec_end;
    logic [15:0] data_inout;
    logic [3:0] scan_out;

    reg [15:0] data_in;
    logic [31:0]				num_inst;

    assign data = (~read_write) ? data_in : {16{1'bz}};


    // Instantiate the DUT
    hycube uut (
        .clk(clk),
        .reset(reset),
        .chip_en(chip_en),
        .data(data),
        .data_inout(data_inout),
        .scan_data_or_addr(scan_data_or_addr),
        .read_write(read_write),
        .data_out_valid(data_out_valid),
        .data_addr_valid(data_addr_valid),
        .scan_start_exec(scan_start_exec),
        .exec_end(exec_end),
        .bist_success(bist_success),
        .bist_en(bist_en),
        .scan_out(scan_out),
        .scan_in(scan_in),
        .scan_en(scan_en),
        .scan_chain_sel_0(scan_chain_sel_0),
        .scan_chain_sel_1(scan_chain_sel_1),
        .scan_chain_sel_2(scan_chain_sel_2),
        .scan_chain_sel_3(scan_chain_sel_3)
    );

    // Clock generation
    always #`HALF_CYCLE clk = ~clk;  // 100 MHz

///////////////////////////////////////////////////
//                  TASKS
////////////////////////////////////////////////////
    task initialize_addrSRAM;
    begin
    reg [15:0] Memory1 [2563:0];
    integer tracefile1;
    
               tracefile1 <= $fopen("../rtl/SRAM_addr.trc", "r");
               $readmemb ("../rtl/SRAM_addr.trc", Memory1);
               data_in <= Memory1[num_inst];
               $fclose(tracefile1);
    end
    endtask
    
    task initialize_dataSRAM;
    begin
    reg [15:0] Memory0 [2563:0];
    integer tracefile0;
    
               tracefile0 <= $fopen("../rtl/SRAM_data.trc", "r");
               $readmemb ("../rtl/SRAM_data.trc", Memory0);
               data_in <= Memory0[num_inst];
               $fclose(tracefile0);
    end
    endtask

    task addr_SRAM;
    begin
        $display("[%16d] ASK : Control SRAM Initialize", $realtime);
            scan_start_exec <= 1'b0;
            chip_en <= 1'b1;
            scan_data_or_addr <= 1'b1; // it is address
            read_write <= 1'b0;
            data_addr_valid <= 2'b11;
    end
    endtask
    
    task data_SRAM;
    begin
            scan_start_exec <= 1'b0;
            chip_en <= 1'b1;
            scan_data_or_addr <= 1'b0; // it is data
            read_write <= 1'b0;
            data_addr_valid <= 2'b11;
    end
    endtask

    task initialize_addrCM;
    begin
    reg [15:0] Memory1 [2563:0];
    integer tracefile1;
    
               tracefile1 <= $fopen("../rtl/CM_addr.trc", "r");
               $readmemb ("../rtl/CM_addr.trc", Memory1);
               data_in <= Memory1[num_inst];
               $fclose(tracefile1);
    end
    endtask

    task initialize_dataCM;
    begin
    reg [15:0] Memory0 [2563:0];
    integer tracefile0;
    
               tracefile0 <= $fopen("../rtl/CM_data.trc", "r");
               $readmemb ("../rtl/CM_data.trc", Memory0);
               data_in <= Memory0[num_inst];
               $fclose(tracefile0);
    end
    endtask
 
    task addr_CM;
    begin
        $display("[%16d] ASK : Control CM Initialize", $realtime);
            scan_start_exec <= 1'b0;
            chip_en <= 1'b1;
            scan_data_or_addr <= 1'b1; // it is address
            read_write <= 1'b0;
            data_addr_valid <= 2'b11;
    end
    endtask
    
    task data_CM;
    begin
            scan_start_exec <= 1'b0;
            chip_en <= 1'b1;
            scan_data_or_addr <= 1'b0; // it is data
            read_write <= 1'b0;
            data_addr_valid <= 2'b11;
    end
    endtask



    initial begin
        $display("Starting testbench...");


//////////////////////////////////////////////////////
//                INITIALIZE SIGNALS   (1 cycle)                
/////////////////////////////////////////////////////
        
        clk = 1;
        reset = 1;
        chip_en = 0;
        bist_en = 0;
        scan_start_exec = 0;
        scan_data_or_addr = 0;
        read_write = 1;
        //data = 16'hFFFF;
        data_addr_valid = 2'b00;
        scan_in = 0;
        scan_en = 0;
        scan_chain_sel_0 = 2'b00;
        scan_chain_sel_1 = 2'b00;
        scan_chain_sel_2 = 2'b00;
        scan_chain_sel_3 = 2'b00;
        num_inst = 32'b0;
        #10; 
        reset = 0;
        chip_en = 1;
        read_write = 0;

///////////////////////////////////////////////////////////
//              UPDATE DM               //////////////////
/////////////////////////////////////////////////////////
    @(posedge clk);
    begin
    for (num_inst =0; num_inst< `NUM_DATA; num_inst++)
    begin
        @(posedge clk);
       	#1
        initialize_addrSRAM;
        addr_SRAM;
        @(posedge clk);
       	initialize_dataSRAM;
        data_SRAM;
    end
    end
    
///////////////////////////////////////////////////////////
//              UPDATE CM               //////////////////
/////////////////////////////////////////////////////////
    @(posedge clk);
    begin
    for (num_inst =0; num_inst< `NUM_INST; num_inst++)
    begin
        @(posedge clk);
        #1
        initialize_addrCM;
        addr_CM;
        @(posedge clk);
       	initialize_dataCM;
        data_CM;
    end
    end
//
///////////////////////////////////////////////////////////
//              START EXEC               //////////////////
/////////////////////////////////////////////////////////
    #`CYCLE
    #`CYCLE
    scan_start_exec = 1;
    end
endmodule

