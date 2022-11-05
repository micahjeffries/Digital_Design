`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Micah Jeffries
// 
// Create Date: 12/18/2019 10:36:42 PM
// Design Name: 
// Module Name: divider
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


module divider(
    input [5:0] A,
    input [5:0] B,
    input BTN,
    input CLK,
    output [5:0] Q,
    output [5:0] R
    );
    
    wire RCO, SEL0, CLR, LD, LD2, UP, GT;
    wire [1:0] SEL1, SEL2;
    wire [12:0] S_B, NEG_B, NEW_A, NEW_B, SUM, C;
    
    usr_nb #(.n(13)) MY_USR1 (
     .data_in ({2'b00,B,5'b00000}), 
     .dbit (1'b0), 
     .sel (SEL1), 
     .clk (CLK), 
     .clr (1'b0), 
     .data_out (S_B)   );
    
    nb_twos_comp #(.n(13)) my_sign_changer (
       .a (S_B), 
       .a_min (NEG_B)      );
       
    mux_2t1_nb  #(.n(13)) my_2t1_mux1  (
      .SEL   (GT), 
      .D0    (NEG_B), 
      .D1    (13'b0000000000000), 
      .D_OUT (NEW_B) );
       
    comp_nb #(.n(13)) MY_COMP (
         .a (S_B), 
         .b ({7'b000000,A}), 
         .eq (), 
         .gt (GT), 
         .lt ()          );
         
    rca_nb #(.n(13)) MY_RCA (
       .a (NEW_A), 
       .b (NEW_B), 
       .cin (1'b0), 
       .sum (SUM), 
       .co ()          );
       
     mux_2t1_nb  #(.n(13)) my_2t1_mux2  (
         .SEL   (SEL0), 
         .D0    ({7'b0000000,A}), 
         .D1    (SUM), 
         .D_OUT (C) );
       
     reg_nb #(13) MY_REG (
         .data_in  (C), 
         .ld       (LD), 
         .clk      (CLK), 
         .clr      (1'b0), 
         .data_out (NEW_A)  );
         
     usr_nb #(.n(6)) MY_USR2 (
          .data_in (6'b000000), 
          .dbit (~GT), 
          .sel (SEL2), 
          .clk (CLK), 
          .clr (CLR), 
          .data_out (Q)   );
          
     assign R = NEW_A[5:0];
     
     cntr_up_clr_nb #(.n(3)) MY_CNTR (
           .clk   (CLK), 
           .clr   (1'b0), 
           .up    (UP), 
           .ld    (RCO), 
           .D     (3'b010), 
           .count (), 
           .rco   (RCO)   );
       
      fsm_template MY_FSM (
        .btn (BTN),
        .rco (RCO),
        .clk (CLK),
        .sel0 (SEL0),
        .sel1 (SEL1),
        .sel2 (SEL2),
        .clr (CLR),
        .ld (LD),
        .ld2 (LD2),
        .up (UP));     
    
endmodule

module fsm_template(btn, rco, clk, sel0, sel1, sel2, clr, ld, ld2, up); 
    input  btn, rco, clk;
    output reg sel0, clr, ld, ld2, up;
    output reg [1:0] sel1, sel2;
     
    //- next state & present state variables
    reg [1:0] NS, PS; 
    //- bit-level state representations
    parameter [1:0] st_WAIT=2'b00, st_LOAD=2'b01, st_SHIFT=2'b10; 
    

    //- model the state registers
    always @ (posedge clk)
          PS <= NS; 
    
    
    //- model the next-state and output decoders
    always @ (btn, rco, PS)
    begin
       sel0 = 0; sel1 = 2'b00; sel2 = 2'b00; clr = 0; ld = 0; up = 0; // assign all outputs
       case(PS)
          st_WAIT:
          begin
             sel0 = 0; sel1 = 2'b00; sel2 = 2'b00; ld = 0; up = 0; ld2 = 0;      
             if (btn == 0)
             begin
                clr = 0;   
                NS = st_WAIT; 
             end  
             else
             begin
                clr = 1; 
                NS = st_LOAD; 
             end  
          end
          
          st_LOAD:
             begin
                sel0 = 0; sel1 = 2'b01; sel2 = 2'b00; clr = 0; ld = 1; up = 0; ld2 = 1;
                NS = st_SHIFT;
             end   
             
          st_SHIFT:
             begin
                 sel0 = 1; sel1 = 2'b11; sel2 = 2'b10; clr = 0; ld = 1; up = 1; ld2 = 0;
                 if (rco == 0)
                    NS = st_SHIFT;  
                 else
                    NS = st_WAIT;  
             end
             
          default: NS = st_WAIT; 
            
          endcase
      end              
endmodule
