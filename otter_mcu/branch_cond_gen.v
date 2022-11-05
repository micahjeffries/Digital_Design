`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Micah Jeffries
// 
// Create Date: 02/24/2020 11:23:39 AM
// Design Name: 
// Module Name: branch_cond_gen
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

module branch_cond_gen(
    input [31:0] rs1,
    input [31:0] rs2,
    output br_eq,
    output br_lt,
    output br_ltu
    );
    
    wire signa, signb, slta, sltb;
    reg [1:0] sel;
    wire [31:0] neg_rs1, neg_rs2;
    
    comp_nb #(.n(32)) MY_COMP (
                 .a (rs1), 
                 .b (rs2), 
                 .eq (br_eq), 
                 .gt (), 
                 .lt (br_ltu));

    //Negate both operands for later use       
      nb_twos_comp #(.n(32)) my_sign_changer1 (
            .a (rs1), 
            .a_min (neg_rs1));
      
      nb_twos_comp #(.n(32)) my_sign_changer (
           .a (rs2), 
           .a_min (neg_rs2));


    //Set up for the SLT
       assign signa = rs1[31];
       assign signb = rs2[31];
       
       comp_nb #(.n(32)) MY_COMP1 (
            .a (rs1), 
            .b (rs2), 
            .eq (), 
            .gt (), 
            .lt (slta));
                    
       comp_nb #(.n(32)) MY_COMP2 (
             .a (neg_rs1), 
             .b (neg_rs2), 
             .eq (), 
             .gt (sltb), 
             .lt ());
       
       
       mux_4t1_nb  #(.n(1)) my_4t1_mux  (
            .SEL   (sel), 
            .D0    (slta), 
            .D1    (sltb), 
            .D2    (1'b1), 
            .D3    (1'b0),
            .D_OUT (br_lt) );
       
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
    
endmodule
