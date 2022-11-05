`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Micah Jeffries
// 
// Create Date: 11/15/2019 03:35:40 PM
// Design Name: 
// Module Name: seq_detect
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: FSM that detects two of the following sequences based on a
// btn input: 110010 (btn is asserted), 110110 (btn is not asserted)
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module seq_detect(
    input clk,
    input btn,
    input x,
    output reg z
    );
    
    //- next state & present state variables
    reg [2:0] NS, PS; 
    //- bit-level state representations
    parameter [2:0] st_A=3'b000, st_B=3'b001, st_C=3'b010, st_D=3'b011;
    parameter [2:0] st_E=3'b100, st_F=3'b101, st_G=3'b110;
    
    //- model the state registers
    always @ (posedge clk)
          PS <= NS;
    
    //- model the next-state and output decoders      
    always @ (x,btn)
    begin
    z = 0;// assign all outputs
    case(PS)
        st_A:
        begin
            z = 0;        
            if (x == 1)
                NS = st_B;   
            else
                NS = st_A;
        end
        
        st_B:
        begin
            z = 0;        
            if (x == 1)
                NS = st_C;   
            else
                NS = st_A;
        end
        
        st_C:
        begin
            z = 0;        
            if (x == 1)
                NS = st_C;   
            else
                NS = st_D;
        end
        
        st_D:
        begin
            z = 0;        
            if (x == 1 & btn == 1)
                NS = st_A;
            else if (x == 1 & btn == 0)
                NS = st_E;
            else if (x == 0 & btn == 1)
                NS = st_F;   
            else
                NS = st_A;
        end
        
        st_E:
        begin
            z = 0;        
            if (x == 1)
                NS = st_F;   
            else
                NS = st_A;
        end
        
        st_F:
        begin
            z = 0;        
            if (x == 1)
                NS = st_C;   
            else
                NS = st_G;
        end
        
        st_G:
        begin
            z = 1;        
            if (x == 1)
                NS = st_B;   
            else
                NS = st_A;
        end
           
        default: NS = st_A; 
          
        endcase
    end
    
endmodule

