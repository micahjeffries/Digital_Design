`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Micah Jeffries and Jonathan Badal
// 
// Create Date: 01/06/2020 07:21:35 PM
// Design Name: 
// Module Name: fibonacci
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: This module loads the first 16 numbers of the fibonacci sequence
// into a ram module and displays the results on the seven segment display.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module fibonacci(
    input BTN,
    input CLK,
    output [7:0] SSEGS,
    output [3:0] AN,
    output [3:0] LEDS
    );
    
    //Set up internal wiring
    wire SLOW_CLK, RCO, UP, CLR, WE, LD;
    wire [3:0] COUNT;
    wire [10:0] data, data_out;
    
    //Slow down the system clock from 100MHz to ~2Hz
    clk_divider_nbit #(.n(25)) MY_DIV (
        .clockin (CLK), 
        .clockout (SLOW_CLK)          );
    
    //Generate the first 16 numbers of the fibonacci sequence
    FIB_SEQ my_fib (
    .BTN (BTN),
    .CLK (CLK),
    .DATA (data));
    
    //This counter cycles through each ram address.
    cntr_up_clr_nb #(.n(4)) MY_CNTR (
      .clk   (SLOW_CLK), 
      .clr   (CLR), 
      .up    (UP), 
      .ld    (LD), 
      .D     (4'b0000), 
      .count (COUNT), 
      .rco   (RCO)   );
    
    //Store the first 16 numbers of the fibonacci sequence into memory  
    ram_single_port #(.n(4),.m(8)) my_ram (
        .data_in (data),  // m spec
        .addr (COUNT), // n spec 
        .we  (WE),
        .clk (SLOW_CLK),
        .data_out (data_out));
        
    //This fsm has 3 states: display (when the button is not pressed),
    //load (clear the registers and load 0 into the counter),
    //fibonacci (load sequence into ram while the counter counts up to 16)
    fsm1 my_fsm (
        .x_in ({BTN, RCO}),
        .clk (SLOW_CLK),
        .we (WE),
        .clr (CLR),
        .up (UP),
        .ld (LD));    
    
  //Display the fibonacci sequence on the seven segment display.
  univ_sseg my_univ_sseg (
      .cnt1 ({3'b000, data_out}), 
      .cnt2 (7'b0000000), 
      .valid (1'b1), 
      .dp_en (1'b0), 
      .dp_sel (2'b00), 
      .mod_sel (2'b00), 
      .sign (1'b0), 
      .clk (CLK), 
      .ssegs (SSEGS), 
      .disp_en (AN)     );
      
   assign LEDS = COUNT;
    
endmodule
