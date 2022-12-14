`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Micah Jeffries and Joathan Badal
// 
// Create Date: 01/07/2020 11:37:57 AM
// Design Name: 
// Module Name: FIB_SEQ
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: This module generates the fisrt 16 numbers of the
// fibonacci sequence.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module FIB_SEQ(
    input BTN,
    input CLK,
    output [10:0] DATA
    );
    
    //Set up internal wiring
    wire SLOW_CLK, CLR, LD1, LD2, LD3, SEL, UP, RCO;
    wire [1:0] MUX;
    wire [10:0] A,B,C,NEG_C, SUM, MAG_SUM, data_in_reg1;
    
    //Slow down the system clock from 100MHz to ~2Hz
    clk_divider_nbit #(.n(25)) MY_DIV (
        .clockin (CLK), 
        .clockout (SLOW_CLK)          );
    
    //When the button is pressed and the sequence begins, 1 (D0) is hard coded
    //into the register. Otherwise; the mux outputs the sum of 
    //n-1 & n-2 (D0).
    mux_2t1_nb  #(.n(11)) my_2t1_mux  (
        .SEL   (MUX), 
        .D0    (MAG_SUM), 
        .D1    (11'b0000000001), 
        .D_OUT (data_in_reg1) );
    
    //This register represents n-1 of the fibonacci sequence.
    //Its data input is the mux output.
    reg_nb #(.n(11)) MY_REG1 (
        .data_in  (data_in_reg1), 
        .ld       (LD1), 
        .clk      (CLK), 
        .clr      (CLR), 
        .data_out (A)        );
    
    //This register represents n-2 of the fibonacci sequence.
    //Its data input is n-1 from the previous register.
    reg_nb #(.n(11)) MY_REG2 (
        .data_in  (A), 
        .ld       (LD2), 
        .clk      (CLK), 
        .clr      (CLR), 
        .data_out (C)        ); 
    
    //This rca outputs the sum of n-1 & n-2 generating the fibonacci sequence.
    rca_nb #(.n(11)) MY_RCA (
        .a (A), 
        .b (C), 
        .cin (1'b0), 
        .sum (SUM), 
        .co ()              );
    
    //Get the magnitude of the sum from the rca
    mag MY_MAG (
        .A (SUM),
        .B (MAG_SUM) );
    
    //We are generating 16 numbers of the fibonacci sequence in this experiment.
    //Therefore we need a counter that counts up to 16 to keep track of what
    //point we are in the fibonacci sequence.
    cntr_up_clr_nb #(.n(4)) MY_CNTR (
        .clk   (CLK), 
        .clr   (1'b0), 
        .up    (UP), 
        .ld    (LD3), 
        .D     (4'b0000), 
        .count (), 
        .rco   (RCO)                );
    
    //This fsm has 3 states: wait (when the button is not pressed),
    //load (clear the registers and load 0 into the counter),
    //fibonacci (generate sequence while the counter counts up to 16)
    fsm my_fsm (
        .x_in ({BTN, RCO}),
        .clk (CLK),
        .mux (MUX),
        .clr (CLR),
        .up (UP),
        .ld1 (LD1),
        .ld2 (LD2),
        .ld3 (LD3));
        
     assign DATA = C;
    
endmodule

