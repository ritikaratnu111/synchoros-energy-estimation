/* synopsys syn_black_box=1 */

module TS6N40LPA24X64M2F ( 
        input logic [4:0] AA,      
        input logic [63:0] D,       
        input logic [63:0] BWEB,   
        input logic WEB,     
        input logic CLKW,    
        input logic [4:0] AB,      
        input logic REB,     
        input logic CLKR,    
        input logic PD,      
        input logic [4:0] AMA,     
        input logic [63:0] DM,     
        input logic [63:0] BWEBM,  
        input logic WEBM,    
        input logic [4:0] AMB,     
        input logic REBM,    
        input logic BIST,    
        output logic [63:0] Q      
    );
endmodule
