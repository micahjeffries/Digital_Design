`timescale 1ns/1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Micah Jeffries
// 
// Create Date: 11/08/2019 03:56:15 PM
// Design Name: 
// Module Name: counter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Counter that displays its present state on the seven segment
// display. This counter includes the following control inputs: reset, up, 
// even, odd, and hold.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////

`include "clk_divider_nbit.v"
`include "fsm.v"
`include "univ_sseg.v"

module counter(
    input RESET,
    input UP,
    input EVEN,
    input ODD,
    input HOLD,
    input CLK,
    output [7:0] SSEGS,
    output [3:0] AN
    );
    
    //Set up internal wiring
    wire ns, ps, REG_CLK;
    wire [3:0] data_in;
    
    //Set up the control inputs for the FSM module
    assign data_in = {HOLD, ODD, EVEN, UP};
    
    //Slow down the system clock from 100Mz to 2 Hz
    clk_divider_nbit #(.n(25)) MY_DIV (
        .clockin (CLK),
        .clockout (REG_CLK)           );
    
    //FSM that keeps track of the present and next state of the counter
    fsm MY_FSM (
        .reset_n (RESET),
        .x_in (data_in),
        .clk (REG_CLK),
        .NS (ns),
        .PS (ps)       );
    
    //Display the present state on the seven segment display    
    univ_sseg my_univ_sseg (
        .cnt1 ({11'b00000000000, ps}),
        .cnt2 (7'b0000000),
        .valid (1'b1),
        .dp_en (1'b0),
        .dp_sel (2'b00),
        .mod_sel (2'b00),
        .sign (1'b0),
        .clk (CLK),
        .ssegs (SSEGS),
        .disp_en (AN)     ); 
    
endmodule
