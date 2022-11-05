`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Micah Jeffries
// 
// Create Date: 11/26/2019 12:50:36 PM
// Design Name: 
// Module Name: multiplier
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Multiplies two 6-bit numbers and displays the result on the seven 
// segment display.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module multiplier(
    input [5:0] A,
    input [5:0] B,
    input BTN,
    input CLK,
    output [7:0] SSEGS,
    output [3:0] AN
    );
    
    //Set up internal wiring
    wire SLOW_CLK, CLR, MUX2, LD;
    wire [1:0] SEL;
    wire [2:0] MUX;
    wire [11:0] C, D, data_in_reg1, data_out_reg;
    
    //Slow down the system clock from 100MHz to ~2Hz
    clk_divider_nbit #(.n(25)) MY_DIV (
        .clockin (CLK), 
        .clockout (SLOW_CLK)          );
    
    //Multiply the A input by 2 every clock cycle    
    usr_nb #(.n(12)) MY_USR (
       .data_in ({6'b000000, A}), 
       .dbit (1'b0), 
       .sel (SEL), 
       .clk (SLOW_CLK), 
       .clr (CLR), 
       .data_out (C)   );
    
    //MUX cycles through the B input one bit at a time
    mux_8t1_nb  #(.n(1)) my_8t1_mux  (
        .SEL   (MUX), 
        .D0    (B[0]), 
        .D1    (B[1]), 
        .D2    (B[2]), 
        .D3    (B[3]),
        .D4    (B[4]),
        .D5    (B[5]),
        .D6    (1'b0),
        .D7    (1'b0),
        .D_OUT (MUX2)                 );
    
    //If the B bit is 1, let the multiplied A pass through;
    //otherwise output 0.    
    mux_2t1_nb  #(.n(12)) my_2t1_mux  (
       .SEL   (MUX2), 
       .D0    (12'b000000000000), 
       .D1    (C), 
       .D_OUT (D)                     );
    
    //Accumulate the value from the register and the new value
    //from the 2:1 mux 
    rca_nb #(.n(12)) MY_RCA (
       .a (data_out_reg), 
       .b (D), 
       .cin (1'b0), 
       .sum (data_in_reg1), 
       .co ()               );
    
    //Store the new value from the rca in memory and feed the output
    //back to the rca  
    reg_nb #(12) MY_REG1 (
        .data_in  (data_in_reg1), 
        .ld       (LD), 
        .clk      (SLOW_CLK), 
        .clr      (CLR), 
        .data_out (data_out_reg));
        
    fsm_template MY_FSM (
        .reset_n (1'b1),
        .x_in (BTN),
        .clk (SLOW_CLK),
        .clr (CLR),
        .ld (LD),
        .mux (MUX),
        .sel (SEL));
        
    univ_sseg my_univ_sseg (
        .cnt1 ({2'b0, data_out_reg}), 
        .cnt2 (7'b0000000), 
        .valid (1'b1), 
        .dp_en (1'b0), 
        .dp_sel (2'b00), 
        .mod_sel (2'b00), 
        .sign (1'b0), 
        .clk (CLK), 
        .ssegs (SSEGS), 
        .disp_en (AN)    );
       
endmodule
