`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Micah Jeffries
// 
// Create Date: 02/24/2020 11:21:33 AM
// Design Name: 
// Module Name: immed_gen
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

module immed_gen(
    input [31:0] ir,
    output [31:0] Utype,
    output [31:0] Itype,
    output [31:0] Stype,
    output [31:0] Btype,
    output [31:0] Jtype
    );
    
    assign Itype = {{21{ir[31]}}, ir[30:25], ir[24:20]};
    assign Stype = {{21{ir[31]}}, ir[30:25], ir[11:7]};
    assign Btype = {{20{ir[31]}}, ir[7], ir[30:25], ir[11:8], 1'b0};
    assign Utype = {ir[31:12], 12'b000000000000};
    assign Jtype = {{12{ir[31]}}, ir[19:12], ir[20], ir[30:21], 1'b0};
    
    
endmodule