`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Micah Jeffries and Yale Hone
// 
// Create Date: 11/26/2019 12:50:36 PM
// Design Name: 
// Module Name: Six_Multiplier
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


module Six_Multiplier(
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

module fsm_template(reset_n, x_in, clk, clr, ld, mux, sel); 
    input  reset_n, x_in, clk; 
    output reg clr, ld;
    output reg [1:0] sel;
    output reg [2:0] mux;
     
    //- next state & present state variables
    reg [2:0] NS, PS; 
    //- bit-level state representations
    parameter [2:0] st_WAIT=3'b000, st_START=3'b001;
    parameter [2:0] st_SHIFT_0=3'b010, st_SHIFT_1=3'b011;
    parameter [2:0] st_SHIFT_2=3'b100, st_SHIFT_3=3'b101;
    parameter [2:0] st_SHIFT_4=3'b110, st_SHIFT_5=3'b111;
    
    //Set up internal wiring
    wire btn;
    assign btn = x_in;

    //- model the state registers
    always @ (negedge reset_n, posedge clk)
       if (reset_n == 0) 
          PS <= st_WAIT; 
       else
          PS <= NS;
    
    //- model the next-state and output decoders
    always @ (btn,PS)
    begin
        clr = 0; ld = 0; mux = 3'b000; sel = 2'b00; // assign all outputs
        case(PS)
            st_WAIT:
            begin
                ld = 0; mux = 3'b000; sel = 2'b00;
                if (btn == 0)
                    begin
                        clr = 0;
                        NS = st_WAIT;
                    end
                else
                    begin
                        clr = 1;
                        NS = st_START;
                    end
            end
            
            st_START:
            begin
                clr = 0; ld = 1; mux = 3'b000; sel = 2'b01;
                NS = st_SHIFT_0;
            end
            
            st_SHIFT_0:
            begin
                ld = 1; mux = 3'b000; sel = 2'b10;
                NS = st_SHIFT_1;
            end
            
            st_SHIFT_1:
            begin
                ld = 1; mux = 3'b001; sel = 2'b10;
                NS = st_SHIFT_2;
            end
            
            st_SHIFT_2:
            begin
                ld = 1; mux = 3'b010; sel = 2'b10;
                NS = st_SHIFT_3;
            end
            
            st_SHIFT_3:
            begin
                ld = 1; mux = 3'b011; sel = 2'b10;
                NS = st_SHIFT_4;
            end
            
            st_SHIFT_4:
            begin
                ld = 1; mux = 3'b100; sel = 2'b10;
                NS = st_SHIFT_5;
            end
            
            st_SHIFT_5:
            begin
                ld = 1; mux = 3'b101; sel = 2'b10;
                NS = st_WAIT;
            end
             
            default: NS = st_WAIT; 
            
        endcase
    end              
endmodule
