`timescale 1ns/1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/11/2019 12:39:37 PM
// Design Name: 
// Module Name: Design_2
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

`include "clk_divider.v"
`include "cnt_convert_7b.v"
`include "cnt_convert_14b.v"

module univ_sseg(
    input [13:0] cnt1,
    input [6:0] cnt2,
    input valid,
    input dp_en,
    input [1:0] dp_sel,
    input [1:0] mod_sel,
    input sign,
    input clk,
    output reg [7:0] ssegs,
    output reg [3:0] disp_en
    ); 
   
    wire [3:0] c1_d3;  // nodes for cnt1 convert results
    wire [3:0] c1_d2; 
    wire [3:0] c1_d1; 
    wire [3:0] c1_d0; 
 
    wire [3:0] c2_d1;   // nodes for cnt2 convert results
    wire [3:0] c2_d0; 
    
    reg [3:0] A_1000_digit; // final digit-based BCD values
    reg [3:0] B_100_digit; 
    reg [3:0] C_10_digit; 
    reg [3:0] D_1_digit; 
    
    reg [3:0] final_BCD; 
    reg [1:0] m_cnt;        // multiplex counter output

    reg [7:0] seg_val;      // intermediate segment value

    // instantiate 14-bit code converter
    cnt_convert_14b CC_14(cnt1, mod_sel, c1_d3, c1_d2, c1_d1, c1_d0); 
    
    // instantiate 7-bit code converter
    cnt_convert_7b CC_7(cnt2, c2_d1, c2_d0); 
      
    // clock divider
    clk_divider CLK_DIV (clk,sclk); 
        
    //- handle 1000's digit
    //- mode 0: case 0 & 4
    //- mode 1: case 1 & 5
    //- mode 2: case 2 & 6
    //- mode 3: case 3 & 7
    always @ (sign,mod_sel,c1_d1,c1_d3)
    begin
       case ({sign,mod_sel})
          0: A_1000_digit = 'hF;
          1: A_1000_digit = c1_d1; 
          2: A_1000_digit = c1_d3;
          3: A_1000_digit = 0;
          4: A_1000_digit = 'hA;  // dash
          5: A_1000_digit = c1_d1; 
          6: A_1000_digit = c1_d3;
          7: A_1000_digit = 0;
          default A_1000_digit = 'hA; 
       endcase 
    end 
 
    //- handle 100's digit
    always @ (mod_sel,c1_d2,c1_d0)
    begin
       case (mod_sel)
          0: B_100_digit = c1_d2; 
          1: B_100_digit = c1_d0; 
          2: B_100_digit = c1_d2;
          3: B_100_digit = 0;
          default B_100_digit = 0; 
       endcase 
    end 
 
    //- handle 10's digit
    always @ (mod_sel,c1_d1,c2_d1)
    begin
       case (mod_sel)
          0: C_10_digit = c1_d1; 
          1: C_10_digit = c2_d1; 
          2: C_10_digit = c1_d1;
          3: C_10_digit = 0;
          default C_10_digit = 0; 
       endcase 
    end 

    //- handle 1's digit
    always @ (mod_sel,c1_d0,c2_d0)
    begin
       case (mod_sel)
          0: D_1_digit = c1_d0; 
          1: D_1_digit = c2_d0; 
          2: D_1_digit = c1_d0;
          3: D_1_digit = 0;
          default D_1_digit = 0; 
       endcase 
    end 

    //- MUX to handle digits 
    always @ (m_cnt, A_1000_digit, B_100_digit, C_10_digit, D_1_digit)
    begin
       case (m_cnt)
          3: final_BCD = D_1_digit; 
          2: final_BCD = C_10_digit; 
          1: final_BCD = B_100_digit;
          0: final_BCD = A_1000_digit;
          default final_BCD = 0; 
       endcase 
    end 
    
    //- standard decoder for display multiplex 
    always @ (m_cnt)
    begin
       case (m_cnt)
          0: disp_en = 4'b1110;  
          1: disp_en = 4'b1101; 
          2: disp_en = 4'b1011;
          3: disp_en = 4'b0111;
          default disp_en = 0; 
       endcase 
    end 
    
    //- 7 seg decoder for display multiplex
    always @ (final_BCD)
    begin
       case (final_BCD)
          0: seg_val  = 'h03;  // one
          1: seg_val  = 'h9F;  // two
          2: seg_val  = 'h25;  // three
          3: seg_val  = 'h0D;
          4: seg_val  = 'h99;  
          5: seg_val  = 'h49;  
          6: seg_val  = 'h41;  
          7: seg_val  = 'h1F;  
          8: seg_val  = 'h01;  
          9: seg_val  = 'h09;  
          10: seg_val = 'hFD;   // dash
          15: seg_val = 'hFF;   // off  
          default seg_val = 0; 
       endcase 
    end 

    //- handle the decimal point stuff
    always @ (dp_sel, m_cnt, dp_en, seg_val, valid)
    begin
       if (valid == 0)     //- handles valid
          ssegs = 'hFD; 
       else 
          begin
          if (dp_sel == m_cnt)
             ssegs = {seg_val[7:1],~dp_en}; 
          else 
             ssegs = seg_val;
          end          
    end

         
    //- counter that drives the mulitplexed display 
    always @ (posedge sclk)
    begin 
       m_cnt <= m_cnt + 1'b1;
    end 

endmodule