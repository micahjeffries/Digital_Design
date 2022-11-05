`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Micah Jeffries
// 
// Create Date: 02/24/2020 11:17:54 AM
// Design Name: 
// Module Name: regfile
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

 module regfile(
     input [31:0] wd,
     input clk, 
     input en,
     input [4:0] adr1,
     input [4:0] adr2,
     input [4:0] wa,
     output logic [31:0] rs1, 
     output logic [31:0] rs2     );
     
     logic [31:0] reg_file [0:31];
     
     //- init registers to zero
     initial
     begin
         int i;
         for (i=0; i<32; i++)
             reg_file[i] = 0;
     end
     
     always_ff @( posedge clk)
     begin
         if ( (en == 1) && (wa != 0) )
             reg_file[wa] <= wd;       
     end
     
     //- asynchronous reads
     assign rs1 = reg_file[adr1];
     assign rs2 = reg_file[adr2];
     
 endmodule
 

