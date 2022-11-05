`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/18/2019 10:37:20 PM
// Design Name: 
// Module Name: Design_2
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


module usr_nb(data_in, dbit, sel, clk, clr, data_out); 
    input  wire [n-1:0] data_in; 
    input  wire dbit; 
    input  wire clk;  
	input  wire clr; 
    input  wire [1:0] sel; 
    output reg [n-1:0] data_out; 

    parameter n = 8; 
    
    always @(posedge clr, posedge clk)
    begin 
        if (clr == 1)     // asynch reset
           data_out <= 0;
        else 
           case (sel) 
              0: data_out <= data_out;                // hold value
              1: data_out <= data_in;                 // load
              2: data_out <= {data_out[n-2:0],dbit};  // shift left
              3: data_out <= {dbit,data_out[n-1:1]};  // shift right
              default data_out <= 0; 
           endcase 
    end
    
endmodule

module nb_twos_comp(
    input [n-1:0] a,
    output reg [n-1:0] a_min
    );
	
    parameter n = 8;
    
    always @(a)
    begin
       a_min = ~a + 1;    
    end
    
endmodule

module mux_2t1_nb(SEL, D0, D1, D_OUT); 
       input  SEL; 
       input  [n-1:0] D0, D1; 
       output reg [n-1:0] D_OUT;  
       
       parameter n = 8; 
        
       always @ (*)
       begin 
          if      (SEL == 0)  D_OUT = D0;
          else if (SEL == 1)  D_OUT = D1; 
          else                D_OUT = 0; 
       end
                
endmodule

module cntr_up_clr_nb(clk, clr, up, ld, D, count, rco); 
    input  clk, clr, up, ld; 
    input  [n-1:0] D; 
    output   reg [n-1:0] count; 
    output   reg rco; 

    //- default data-width 
    parameter n = 8; 
    
    always @(posedge clr, posedge clk)
    begin 
        if (clr == 1)       // asynch reset
           count <= 0;
        else if (ld == 1)   // load new value
           count <= D; 
        else if (up == 1)   // count up (increment)
           count <= count + 1;  
    end 
       
    
    //- handles the RCO, which is direction dependent
    always @(count, up)
    begin 
       if ( up == 1 && &count == 1'b1)
          rco = 1'b1;
       else if (up == 0 && |count == 1'b0)
          rco = 1'b1;
       else 
          rco = 1'b0; 
    end
    
endmodule

module rca_nb(
    input [n-1:0] a,
    input [n-1:0] b,
    input cin,
    output reg [n-1:0] sum,
    output reg co
    );
	
    parameter n = 8;
    
    always @(a,b,cin)
    begin
       {co,sum} = a + b + cin;    
    end
    
endmodule

module reg_nb(data_in, clk, clr, ld, data_out); 
    input  [n-1:0] data_in; 
    input  clk, clr, ld; 
    output reg [n-1:0] data_out; 

    parameter n = 8; 
    
    always @(posedge clr, posedge clk)
    begin 
       if (clr == 1)     // asynch clr
          data_out <= 0;
       else if (ld == 1) 
          data_out <= data_in; 
    end
    
endmodule

module comp_nb(a, b, eq, lt, gt); 
    input  [n-1:0] a,b; 
    output reg eq, lt, gt; 
  
    parameter n = 8;
    
    always @ (a,b)
    begin      
       if (a == b)
       begin     
          eq = 1; lt = 0;  gt = 0;   
       end
       else if (a > b)   
       begin     
          eq = 0; lt = 0;  gt = 1; 
       end
       else if (a < b)  
       begin     
          eq = 0; lt = 1;  gt = 0; end
       else
       begin     
          eq = 0; lt = 0;  gt = 0; 
       end  
    end 

endmodule
