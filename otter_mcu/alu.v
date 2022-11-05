`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Micah Jeffries
// 
// Create Date: 02/24/2020 11:21:33 AM
// Design Name: 
// Module Name: alu
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

module alu(
    input [31:0] srcA,
    input [31:0] srcB,
    input [3:0] alu_fun,
    input [31:0] result
    );
    
    //Set up internal wiring
    wire [31:0] ADD, SUB, OR, AND, XOR, SRL, SLL, SRA, SLT, SLTU, LUI;
    wire [31:0] neg_srcA, neg_srcB;
    wire slt, sltu, signa, signb, slta, sltb;
    reg [1:0] sel;
    
    //The output of the alu depends on the operation currently being performed 
    mux_16t1_nb  #(.n(32)) my_16t1_mux  (
           .SEL   (alu_fun), 
           .D0    (ADD), 
           .D1    (SLL), 
           .D2    (SLT), 
           .D3    (SLTU),
           .D4    (XOR),
           .D5    (SRL),
           .D6    (OR),
           .D7    (AND),
           .D8    (SUB), 
           .D9    (LUI), 
           .D10    (32'h00000000), 
           .D11    (32'h00000000),
           .D12    (32'h00000000),
           .D13    (SRA),
           .D14    (32'h00000000),
           .D15    (32'h00000000),
           .D_OUT (result) );
      
      //The output for the add operation     
      rca_nb #(.n(32)) MY_ADD (
             .a (srcA), 
             .b (srcB), 
             .cin (1'b0), 
             .sum (ADD), 
             .co ());
      
      //Negate both operands for later use       
      nb_twos_comp #(.n(32)) my_sign_changer1 (
            .a (srcA), 
            .a_min (neg_srcA));
      
      nb_twos_comp #(.n(32)) my_sign_changer (
           .a (srcB), 
           .a_min (neg_srcB));
      
      //The output for the subtraction operation     
      rca_nb #(.n(32)) MY_SUB (
            .a (srcA), 
            .b (neg_srcB), 
            .cin (1'b0), 
            .sum (SUB), 
            .co ());
       
       //The output for the OR operation     
       assign OR = srcA | srcB;
       //The output for the AND operation
       assign AND = srcA & srcB;
       //The output for the XOR operation
       assign XOR = (~srcA & srcB)|(srcA & ~srcB);
       //The output for the SRL operation
       assign SRL = srcA >> srcB;
       //The output for the SLL operation
       assign SLL = srcA << srcB;
       //The output for the SRA operation
       assign SRA = srcA >>> srcB;
       //The output for the LUI operation
       assign LUI = srcA;
       
       //Set up for the SLTU operation
       comp_nb #(.n(32)) MY_COMP (
             .a (srcA), 
             .b (srcB), 
             .eq (), 
             .gt (), 
             .lt (sltu));
       
       //The output for the SLTU operation      
       assign SLTU = 32'h00000000 + sltu;
       
       //Set up for the SLT
       assign signa = srcA[31];
       assign signb = srcB[31];
       
       comp_nb #(.n(32)) MY_COMP1 (
            .a (srcA), 
            .b (srcB), 
            .eq (), 
            .gt (), 
            .lt (slta));
                    
       comp_nb #(.n(32)) MY_COMP2 (
             .a (neg_srcA), 
             .b (neg_srcB), 
             .eq (), 
             .gt (sltb), 
             .lt ());
       
       
       mux_4t1_nb  #(.n(1)) my_4t1_mux  (
            .SEL   (sel), 
            .D0    (slta), 
            .D1    (sltb), 
            .D2    (1'b1), 
            .D3    (1'b0),
            .D_OUT (slt) );
       
       always @ (signa,signb)
           begin
              sel = 0;      
              if (~signa & ~signb )
                 sel = 0;   
              else if (signa & signb)     
                 sel = 1;
              else if (signa & ~signb)     
                 sel = 2;
              else if (~signa & signb)     
                 sel = 3;
              else
                 sel = 0; 
           end
       
       //The output for the SLT operation    
       assign SLT = 32'h00000000 + slt;
           
endmodule