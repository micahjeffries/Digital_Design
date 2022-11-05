`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Micah Jeffries
// 
// Create Date: 12/04/2019 02:48:28 PM
// Design Name: 
// Module Name: Four_Sort
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Sorts 4 numbers in ascending order in BCD format and displays
// them on the 4 Digit BCD Display Multiplexor.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module sort(
    input [3:0] A,
    input [3:0] B,
    input [3:0] C,
    input [3:0] D,
    input BTN,
    input CLK,
    output [7:0] SSEGS,
    output [3:0] AN,
    output LED
    );
    
    //Set up internal wiring
    wire MUX_A, MUX_D, CLR, SLOW_CLK;
    wire [3:0] DISP_A, DISP_B, DISP_C, DISP_D;
    wire [3:0] data_out_reg1, data_out_reg2, data_out_reg3;
    wire [3:0] data_out_reg4, data_out_reg5, data_out_reg6;
    wire [3:0] data_in_reg1, data_in_reg2, data_in_reg3;
    wire [3:0] data_in_reg4, data_in_reg5, data_in_reg6;
    wire GT1, GT2, GT3, SEL_1, SEL_2, SEL_3, LD1, LD2, LD3;      
    wire [1:0] MUX_B, MUX_C;
    
    //Slow down the system clock from 100Mhz to ~2Hz
    clk_divider_nbit #(.n(25)) MY_DIV (
             .clockin (CLK), 
             .clockout (SLOW_CLK));
    
    //Next 4 muxes take the original 4 inputs and decides passes them through
    //on the first comparison. After that, the muxes choose the appropriate
    //signal from the six registers.
    mux_2t1_nb  #(.n(4)) my_2t1_mux7  (
       .SEL   (MUX_A), 
       .D0    (A), 
       .D1    (data_out_reg1), 
       .D_OUT (DISP_A) );
       
    mux_4t1_nb  #(.n(4)) my_4t1_mux1  (
       .SEL   (MUX_B), 
       .D0    (B), 
       .D1    (data_out_reg2), 
       .D2    (data_out_reg3), 
       .D3    (4'b0000),
       .D_OUT (DISP_B) );
       
    mux_4t1_nb  #(.n(4)) my_4t1_mux2  (
       .SEL   (MUX_C), 
       .D0    (C), 
       .D1    (data_out_reg4), 
       .D2    (data_out_reg5), 
       .D3    (4'b0000),
       .D_OUT (DISP_C) );
           
    mux_2t1_nb  #(.n(4)) my_2t1_mux8  (
      .SEL   (MUX_D), 
      .D0    (D), 
      .D1    (data_out_reg6), 
      .D_OUT (DISP_D) );
    
    //The next three comparators compare the values of the mux outputs.
    //If the a input is greater than the b input, than the greater than
    //signal is triggered and is sent to the fsm to swap the values.
    comp_nb #(.n(4)) MY_COMP1 (
        .a (DISP_A), 
        .b (DISP_B), 
        .eq (), 
        .gt (GT1), 
        .lt ());
        
     comp_nb #(.n(4)) MY_COMP2 (
        .a (DISP_B), 
        .b (DISP_C), 
        .eq (), 
        .gt (GT2), 
        .lt ());
                
      comp_nb #(.n(4)) MY_COMP3 (
        .a (DISP_C), 
        .b (DISP_D), 
        .eq (), 
        .gt (GT3), 
        .lt ());
      
      //The next six muxes have to choose between the original value
      //and the swapped value. The original signal is always sent to 
      //the D0 input and the swapped value is sent to the D1 input.
      //The output of each of these muxes goes to the six registers.
      mux_2t1_nb  #(.n(4)) my_2t1_mux1  (
          .SEL   (SEL_1), 
          .D0    (DISP_A), 
          .D1    (data_out_reg2), 
          .D_OUT (data_in_reg1) );
          
      mux_2t1_nb  #(.n(4)) my_2t1_mux2  (
        .SEL   (SEL_1), 
        .D0    (DISP_B), 
        .D1    (data_out_reg1), 
        .D_OUT (data_in_reg2) );
                
      mux_2t1_nb  #(.n(4)) my_2t1_mux3  (
          .SEL   (SEL_2), 
          .D0    (DISP_B), 
          .D1    (data_out_reg4), 
          .D_OUT (data_in_reg3) );
                      
      mux_2t1_nb  #(.n(4)) my_2t1_mux4  (
        .SEL   (SEL_2), 
        .D0    (DISP_C), 
        .D1    (data_out_reg3), 
        .D_OUT (data_in_reg4) );
                            
      mux_2t1_nb  #(.n(4)) my_2t1_mux5  (
          .SEL   (SEL_3), 
          .D0    (DISP_C), 
          .D1    (data_out_reg6), 
          .D_OUT (data_in_reg5) );
                                  
      mux_2t1_nb  #(.n(4)) my_2t1_mux6  (
        .SEL   (SEL_3), 
        .D0    (DISP_D), 
        .D1    (data_out_reg5), 
        .D_OUT (data_in_reg6) );
      
      //These registers are responsible for storing the original value
      //and the swapped value where appropriate. The swapped value will
      //only be loaded into the register if the greater than signal from
      //the comparator is triggered.
      reg_nb #(16) MY_REG1 (
          .data_in  (data_in_reg1), 
          .ld       (LD1), 
          .clk      (SLOW_CLK), 
          .clr      (CLR), 
          .data_out (data_out_reg1));
          
      reg_nb #(4) MY_REG2 (
        .data_in  (data_in_reg2), 
        .ld       (LD1), 
        .clk      (SLOW_CLK), 
        .clr      (CLR), 
        .data_out (data_out_reg2));
                    
       reg_nb #(16) MY_REG3 (
          .data_in  (data_in_reg3), 
          .ld       (LD2), 
          .clk      (SLOW_CLK), 
          .clr      (CLR), 
          .data_out (data_out_reg3));
                              
        reg_nb #(16) MY_REG4 (
            .data_in  (data_in_reg4), 
            .ld       (LD2), 
            .clk      (SLOW_CLK), 
            .clr      (CLR), 
            .data_out (data_out_reg4));
                                        
        reg_nb #(16) MY_REG5 (
          .data_in  (data_in_reg5), 
          .ld       (LD3), 
          .clk      (SLOW_CLK), 
          .clr      (CLR), 
          .data_out (data_out_reg5));
                                                  
        reg_nb #(16) MY_REG6 (
            .data_in  (data_in_reg6), 
            .ld       (LD3), 
            .clk      (SLOW_CLK), 
            .clr      (CLR), 
            .data_out (data_out_reg6));
        
        //Display the 4 sorted numbers on the seven segment display
        display_mux_4_BCD  my_disp_mux(
             .bcd0 (DISP_A),
             .bcd1 (DISP_B),
             .bcd2 (DISP_C),
             .bcd3 (DISP_D),
             .clk  (CLK),
             .seg  (SSEGS),
             .an   (AN)    );
             
         //FSM that controls the swapping mechanism, the inputs that
         //are sent to the registers, the values to be sent to the 
         //comparators, and the triggering of the LED.
         fsm_template MY_FSM (
            .btn (BTN),
            .gt1 (GT1),
            .gt2 (GT2),
            .gt3 (GT3),
            .clk (SLOW_CLK),
            .sel_1 (SEL_1),
            .sel_2 (SEL_2),
            .sel_3 (SEL_3),
            .ld1 (LD1),
            .ld2 (LD2),
            .ld3 (LD3),
            .mux_a (MUX_A),
            .mux_d (MUX_D),
            .clr (CLR),
            .led (LED),
            .mux_b (MUX_B),
            .mux_c (MUX_C));
    
endmodule