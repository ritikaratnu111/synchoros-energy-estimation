/* synopsys syn_black_box=1 */

module TSDN40LPA512X32M4F (
        input [8:0] AA,     
        input [31:0] DA,     
        input [31:0] BWEBA, 
        input WEBA,   
        input CEBA ,  
        input CLKA ,  
        input [8:0] AB,     
        input [31:0] DB,     
        input [31:0] BWEBB,  
        input WEBB,  
        input CEBB, 
        input CLKB,
        input PD,    
        input [8:0] AMA,    
        input [31:0] DMA,   
        input [31:0] BWEBMA,
        input WEBMA,  
        input CEBMA,  
        input [8:0] AMB,    
        input [31:0] DMB,   
        input [31:0] BWEBMB,
        input WEBMB,  
        input CEBMB,  
        input BIST,   
        input CLKM,   
        output [31:0] QA,    
        output [31:0] QB   
    );
endmodule;

