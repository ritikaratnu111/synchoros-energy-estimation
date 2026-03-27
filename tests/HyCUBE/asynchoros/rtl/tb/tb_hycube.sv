`timescale 1ns/1ps

`define NUM_INST		    2564
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

    // Test sequence
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
        data = 16'hFFFF;
        data_addr_valid = 2'b00;
        scan_in = 0;
        scan_en = 0;
        scan_chain_sel_0 = 2'b00;
        scan_chain_sel_1 = 2'b00;
        scan_chain_sel_2 = 2'b00;
        scan_chain_sel_3 = 2'b00;
        #20; 

////////////////////////////////////////////////
//          DM 0                (2 cycle)
/////////////////////////////////////////////////
//0     
        reset = 0;
        chip_en = 1;
        scan_data_or_addr = 1;           //address         
        data = 16'h1002;                        
        data_addr_valid = 2'b11;
        #10; 

        scan_data_or_addr = 0;          //data          
        read_write = 0;
        data = 16'hDEAD;                          
        #10; 
//0     
        reset = 0;
        chip_en = 1;
        scan_data_or_addr = 1;           //address         
        data = 16'h1002;                        
        data_addr_valid = 2'b11;
        #10; 

        scan_data_or_addr = 0;          //data          
        read_write = 0;
        data = 16'hDEAD;                          
        #10; 
//1        
        reset = 0;
        chip_en = 1;
        scan_data_or_addr = 1;           //address         
        data = 16'h1004;                        
        data_addr_valid = 2'b11;
        #10; 

        scan_data_or_addr = 0;          //data          
        read_write = 0;
        data = 16'h0001;                          
        #10; 
//2        
        reset = 0;
        chip_en = 1;
        scan_data_or_addr = 1;           //address         
        data = 16'h1008;                        
        data_addr_valid = 2'b11;
        #10; 

        scan_data_or_addr = 0;          //data          
        read_write = 0;
        data = 16'h0002;                          
        #10; 
//3        
        reset = 0;
        chip_en = 1;
        scan_data_or_addr = 1;           //address         
        data = 16'h100C;                        
        data_addr_valid = 2'b11;
        #10; 

        scan_data_or_addr = 0;          //data          
        read_write = 0;
        data = 16'h0003;                          
        #10; 
//4     
        reset = 0;
        chip_en = 1;
        scan_data_or_addr = 1;           //address         
        data = 16'h1012;                        
        data_addr_valid = 2'b11;
        #10; 

        scan_data_or_addr = 0;          //data          
        read_write = 0;
        data = 16'h0004;                          
        #10; 
//5        
        reset = 0;
        chip_en = 1;
        scan_data_or_addr = 1;           //address         
        data = 16'h1014;                        
        data_addr_valid = 2'b11;
        #10; 

        scan_data_or_addr = 0;          //data          
        read_write = 0;
        data = 16'h0005;                          
        #10; 
//6        
        reset = 0;
        chip_en = 1;
        scan_data_or_addr = 1;           //address         
        data = 16'h1018;                        
        data_addr_valid = 2'b11;
        #10; 

        scan_data_or_addr = 0;          //data          
        read_write = 0;
        data = 16'h0006;                          
        #10; 
//7        
        reset = 0;
        chip_en = 1;
        scan_data_or_addr = 1;           //address         
        data = 16'h101C;                        
        data_addr_valid = 2'b11;
        #10; 

        scan_data_or_addr = 0;          //data          
        read_write = 0;
        data = 16'h0007;                          
        #10; 
//8     
        reset = 0;
        chip_en = 1;
        scan_data_or_addr = 1;           //address         
        data = 16'h1022;                        
        data_addr_valid = 2'b11;
        #10; 

        scan_data_or_addr = 0;          //data          
        read_write = 0;
        data = 16'h0008;                          
        #10; 
//9        
        reset = 0;
        chip_en = 1;
        scan_data_or_addr = 1;           //address         
        data = 16'h1024;                        
        data_addr_valid = 2'b11;
        #10; 

        scan_data_or_addr = 0;          //data          
        read_write = 0;
        data = 16'h0009;                          
        #10; 
//10        
        reset = 0;
        chip_en = 1;
        scan_data_or_addr = 1;           //address         
        data = 16'h1028;                        
        data_addr_valid = 2'b11;
        #10; 

        scan_data_or_addr = 0;          //data          
        read_write = 0;
        data = 16'h000A;                          
        #10; 
//11        
        reset = 0;
        chip_en = 1;
        scan_data_or_addr = 1;           //address         
        data = 16'h102C;                        
        data_addr_valid = 2'b11;
        #10; 

        scan_data_or_addr = 0;          //data          
        read_write = 0;
        data = 16'h000B;                          
        #10; 
//12     
        reset = 0;
        chip_en = 1;
        scan_data_or_addr = 1;           //address         
        data = 16'h1032;                        
        data_addr_valid = 2'b11;
        #10; 

        scan_data_or_addr = 0;          //data          
        read_write = 0;
        data = 16'h000C;                          
        #10; 
//13        
        reset = 0;
        chip_en = 1;
        scan_data_or_addr = 1;           //address         
        data = 16'h1034;                        
        data_addr_valid = 2'b11;
        #10; 

        scan_data_or_addr = 0;          //data          
        read_write = 0;
        data = 16'h000D;                          
        #10; 
//14        
        reset = 0;
        chip_en = 1;
        scan_data_or_addr = 1;           //address         
        data = 16'h1038;                        
        data_addr_valid = 2'b11;
        #10; 

        scan_data_or_addr = 0;          //data          
        read_write = 0;
        data = 16'h000E;                          
        #10; 
//15        
        reset = 0;
        chip_en = 1;
        scan_data_or_addr = 1;           //address         
        data = 16'h103C;                        
        data_addr_valid = 2'b11;
        #10; 

        scan_data_or_addr = 0;          //data          
        read_write = 0;
        data = 16'h000F;                          
        #10; 
/////////////////////////////////////////////////////
//              TILE 0,0 CM
////////////////////////////////////////////////////
//0. LOOP
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0000;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0002;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h8000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0004;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h1F0F;              
        #10;
        
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0006;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h8000;               
        #10;

//1. LOAD SET 
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0008;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'hF000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h000A;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h001F;              
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h000C;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;
        
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h000E;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

//2. LOAD CONST       
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0010;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;
        
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0012;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h00014;                           
        #10;
        
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0006;               
        #10;
        
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0016;                           
        #10;
        
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h4000;               
        #10;

//3. UPDATE EAST
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0018;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0004;               
        #10;
        
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h001A;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h001C;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;
        
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h001E;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;
//4. LOAD SET

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0020;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'hF000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0022;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h001F;              
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0024;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0026;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;              
        #10;

//5. LOAD CONST       
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h00028;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;
        
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h002A;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0002C;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0026;               
        #10;
        
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h002E;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h4000;               
        #10;

//6. UPDATE EAST
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0030;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0004;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0032;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0034;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;
        
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0036;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

//7. LOAD SET 
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0038;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'hF000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h003A;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h001F;              
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h003C;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h003E;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;              
        #10;

//8. LOAD CONST       
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h00040;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;
        
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0042;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h00044;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0046;               
        #10;
        
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0046;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h4000;               
        #10;

//9. UPDATE EAST
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0048;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0004;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h004A;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;
        
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h004C;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h004E;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;


//10. LOAD SET 
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0050;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'hF000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0052;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h001F;              
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0054;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0056;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;              
        #10;

//11. LOAD CONST       
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0058;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;
        
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h005A;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h005C;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0066;               
        #10;
        
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h005E;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h4000;               
        #10;

//12. UPDATE EAST
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0060;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0004;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0062;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;
        
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0064;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0066;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

//13. LOAD SET 
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0068;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'hF000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h006A;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h001F;              
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h006C;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h006E;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

//14. LOAD CONST       
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0070;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0072;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0074;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0086;               
        #10;
        
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0076;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h4000;               
        #10;

//15. UPDATE EAST
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0078;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0004;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h007A;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h007C;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h007E;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

//16. LOAD SET 
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0080;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'hF000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0082;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h001F;              
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0084;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0086;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

//17. LOAD CONST       
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0088;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h008A;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h008C;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h00A6;               
        #10;
        
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h008E;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h4000;               
        #10;

//18. UPDATE EAST
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0090;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0004;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0092;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0094;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0096;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

//19. LOAD SET 
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0098;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'hF000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h009A;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h001F;              
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h009C;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h009E;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

//20. LOAD CONST       
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h00A0;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h00A2;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h000A4;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h00C6;               
        #10;
        
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h00A6;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h4000;               
        #10;

//21. UPDATE EAST
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h00a8;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0004;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h00aa;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h00ac;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h00ae;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

//22. LOAD SET 
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h00B0;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'hF000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h00B2;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h001F;              
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h00B4;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h00B6;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;              
        #10;

//23. LOAD CONST       
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h000B8;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;
        
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h00BA;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h000BC;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h00E6;               
        #10;
        
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h00BE;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h4000;               
        #10;

//24. UPDATE EAST
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h00C0;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0004;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h00C2;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h00C4;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h00C6;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

//25. LOAD SET 
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h00C8;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'hF000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h00CA;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h001F;              
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h00CC;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h00CE;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

//26. LOAD CONST       
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h000D0;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;
        
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h000D2;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;
        
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h000D4;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0106;               
        #10;
        
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h00D6;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h4000;               
        #10;

//27. UPDATE EAST
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h00D8;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0004;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h00DA;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h00DC;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h00DE;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

//28. LOAD SET 
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h00E0;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'hF000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h00E2;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h001F;              
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h00E4;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;              
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h00E6;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;              
        #10;

//29. LOAD CONST       
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h000E8;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;
        
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h000EA;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;
        
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h000EC;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0126;               
        #10;
        
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h00EE;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h4000;               
        #10;

//30. UPDATE EAST
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h00F0;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0004;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h00F2;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h00F4;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h00F6;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

/////////////////////////////////////////////////////
//              TILE 1,0 CM
////////////////////////////////////////////////////

//0. LOOP
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0100;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0102;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h8000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0104;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h060F;              
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0106;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

//1. ALU        
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0108;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0004;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h010A;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h4200;               
        #10;
        
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h010C;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;
        
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h010E;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

//2. NOP
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0110;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0112;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0114;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0116;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

//3. READ WEST
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0118;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h7000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h011A;                           
        #10;
        
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h4001;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h011C;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h011E;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

//4. UPDATE TREG
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0120;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0122;                           
        #10;
        
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h4200;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0124;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0126;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;
//5. NOP
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0128;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h012A;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h012C;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h012E;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

//6. READ WEST
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0130;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h5000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0132;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0001;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0134;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0136;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

/////////////////////////////////////////////////////
//              TILE 2,0 CM
////////////////////////////////////////////////////

//0. LOOP
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0200;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0202;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h8000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0204;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h060F;              
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0206;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

//1. LHS <- WEST
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0208;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h7000;               
        #10;
        
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h020A;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h4001;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h020C;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h020E;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

//2. LHS <- WEST
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0210;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0212;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h4200;               
        #10;
        
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0214;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0216;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

//3. NOP
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0218;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h021A;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h021C;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h021E;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

//4. NOP
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0220;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0222;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0224;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0226;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

//5. NOP
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0228;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h022A;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h022C;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h022E;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

//6. NOP
        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0230;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0232;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0234;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;

        scan_data_or_addr = 1;         //address           
        data_addr_valid = 2'b11;
        data = 16'h0236;                           
        #10;
        scan_data_or_addr = 0;                    
        read_write = 0;
        data_addr_valid = 2'b11;
        data = 16'h0000;               
        #10;
//
//////////////////////////////////////////////////////////
//            PREPARING TO START...  (1 cycle)            
//////////////////////////////////////////////////////////

        scan_data_or_addr = 1;         //clear address           
        data_addr_valid = 2'b11;
        data = 16'h0002;                           
        #10;
        
        scan_start_exec = 1;                 

end
endmodule
