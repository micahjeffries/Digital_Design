`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Micah Jeffries
// 
// Create Date: 02/24/2020 12:02:01 PM
// Design Name: 
// Module Name: csr
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module csr(
    input CLK,
    input RST,
    input INT_TAKEN,           
    input [11:0] ADDR,
    input [31:0] PC,
    input [31:0] WD,
    input WR_EN,
    output logic [31:0] RD,
    output logic [31:0] CSR_MEPC=0,  //- return from interrupt addr
    output logic [31:0] CSR_MTVEC=0, //- interrupt vector address  
    output logic CSR_MIE = 0      ); //- interrupt enable register

    
    //- CSR ADDResses
    typedef enum logic [11:0] {       
        MIE       = 12'h304,
        MTVEC     = 12'h305,
        MEPC      = 12'h341
    } csr_t;

    always_ff @ (posedge CLK)
    begin
        //- clear registers on reset
		if (RST) begin
            CSR_MTVEC <= 0;
            CSR_MEPC  <= 0;
            CSR_MIE   <= 1'b0;           
        end
       
	    //- write to registers 
	    if (WR_EN)
            case(ADDR)
                MTVEC: CSR_MTVEC <= WD;    //- vector addr
                MEPC:  CSR_MEPC  <= WD;    //- return addr
                MIE:   CSR_MIE   <= WD[0]; //- interrupt enable
            endcase
            
        //- load CSR_MEPC when acting on interrupt 
		if(INT_TAKEN)
        begin
           CSR_MEPC <= PC;
		   CSR_MIE <= 1'b0; 
        end         
    end
    
    //- read from registers
	always_comb
       case(ADDR)
            MTVEC:   RD = CSR_MTVEC;
            MEPC:    RD = CSR_MEPC;
            MIE:     RD ={{31{1'b0}},CSR_MIE};            
            default: RD = 32'd0;
       endcase
    
endmodule