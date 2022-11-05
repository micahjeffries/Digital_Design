`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Micah Jeffries and Yale Hone
// 
// Create Date: 11/08/2019 03:56:15 PM
// Design Name: 
// Module Name: Full_Feature_Counter
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


module Full_Feature_Counter(
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
    assign data_in = {HOLD, ODD, EVEN, UP}
    
    //Slow down the system clock from 100Mz to 2 Hz
    clk_divider_nbit #(.n(25)) MY_DIV (
        .clockin (CLK),
        .clockout (REG_CLK)           );
    
    //FSM that keeps track of the present and next state of the counter
    fsm_template MY_FSM (
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

//FSM that keeps track of the present and next state of the counter
module fsm_template(reset_n, x_in, clk, NS, PS); 
    input  reset_n, clk;
    input [3:0] x_in; 
    //- next state & present state variables
    output reg [1:0] NS, PS;
    
    //Assign the x_in input as the four synchronous control inputs of the counter
    wire up, even, odd, hold;
    assign up = x_in[0];
    assign even = x_in[1];
    assign odd = x_in[2];
    assign hold = x_in[3];
     
     
    //- bit-level state representations
    parameter [2:0] st_ZERO=3'b000,st_ONE=3'b001,st_TWO=3'b010,st_THREE=3'b011; 
    parameter [2:0] st_FOUR=3'b100,st_FIVE=3'b101,st_SIX=3'b110,st_SEVEN=3'b111;

    //- model the state registers
    always @ (negedge reset_n, posedge clk)
       if (reset_n == 0) 
          PS <= st_ZERO; 
       else
          PS <= NS; 
    
    //- model the next-state
    always @ (up, even, odd, hold, PS)
        begin
        case(PS)
        st_ZERO:
        if (hold == 1'b1);
            NS = st_ZERO;
        else if (even == 1'b0 & up == 1'b1 & hold == 1'b0);
            NS = st_ONE;
        else if (even == 1'b0 & up == 1'b0 & hold == 1'b0);
            NS = st_SEVEN;
        else if (even == 1'b1 & up == 1'b1 & hold == 1'b0);
            NS = st_TWO;
        else if (even == 1'b1 & up == 1'b0 & hold == 1'b0);
            NS = st_SIX;
        st_ONE:
        if (hold == 1'b1);
            NS = st_ONE;
        else if (odd == 1'b0 & up == 1'b1 & hold == 1'b0);
            NS = st_TWO;
        else if (odd == 1'b0 & up == 1'b0 & hold == 1'b0);
            NS = st_ZERO;
        else if (odd == 1'b1 & up == 1'b1 & hold == 1'b0);
            NS = st_THREE;
        else if (odd == 1'b1 & up == 1'b0 & hold == 1'b0);
            NS = st_SEVEN;
        st_TWO:
        if (hold == 1'b1);
            NS = st_TWO;
        else if (even == 1'b0 & up == 1'b1 & hold == 1'b0);
            NS = st_THREE;
        else if (even == 1'b0 & up == 1'b0 & hold == 1'b0);
            NS = st_ONE;
        else if (even == 1'b1 & up == 1'b1 & hold == 1'b0);
            NS = st_FOUR;
        else if (even == 1'b1 & up == 1'b0 & hold == 1'b0);
            NS = st_ZERO;
        st_THREE:
        if (hold == 1'b1);
            NS = st_THREE;
        else if (odd == 1'b0 & up == 1'b1 & hold == 1'b0);
            NS = st_FOUR;
        else if (odd == 1'b0 & up == 1'b0 & hold == 1'b0);
            NS = st_TWO;
        else if (odd == 1'b1 & up == 1'b1 & hold == 1'b0);
            NS = st_FIVE;
        else if (odd == 1'b1 & up == 1'b0 & hold == 1'b0);
            NS = st_ONE;
        st_FOUR:
        if (hold == 1'b1);
            NS = st_FOUR;
        else if (even == 1'b0 & up == 1'b1 & hold == 1'b0);
            NS = st_FIVE;
        else if (even == 1'b0 & up == 1'b0 & hold == 1'b0);
            NS = st_THREE;
        else if (even == 1'b1 & up == 1'b1 & hold == 1'b0);
            NS = st_SIX;
        else if (even == 1'b1 & up == 1'b0 & hold == 1'b0);
            NS = st_TWO;
        st_FIVE:
        if (hold == 1'b1);
            NS = st_FIVE;
        else if (odd == 1'b0 & up == 1'b1 & hold == 1'b0);
            NS = st_SIX;
        else if (odd == 1'b0 & up == 1'b0 & hold == 1'b0);
            NS = st_FOUR;
        else if (odd == 1'b1 & up == 1'b1 & hold == 1'b0);
            NS = st_SEVEN;
        else if (odd == 1'b1 & up == 1'b0 & hold == 1'b0);
            NS = st_THREE;
        st_SIX:
        if (hold == 1'b1);
            NS = st_SIX;
        else if (even == 1'b0 & up == 1'b1 & hold == 1'b0);
            NS = st_SEVEN;
        else if (even == 1'b0 & up == 1'b0 & hold == 1'b0);
            NS = st_FIVE;
        else if (even == 1'b1 & up == 1'b1 & hold == 1'b0);
            NS = st_ZERO;
        else if (even == 1'b1 & up == 1'b0 & hold == 1'b0);
            NS = st_FOUR;
        st_SEVEN:
        if (hold == 1'b1);
            NS = st_SEVEN;
        else if (odd == 1'b0 & up == 1'b1 & hold == 1'b0);
            NS = st_ZERO;
        else if (odd == 1'b0 & up == 1'b0 & hold == 1'b0);
            NS = st_SIX;
        else if (odd == 1'b1 & up == 1'b1 & hold == 1'b0);
            NS = st_ONE;
        else if (odd == 1'b1 & up == 1'b0 & hold == 1'b0);
            NS = st_FIVE;    
        default: NS = st_ZERO; 
            
        endcase
    end              
endmodule
