`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Micah Jeffries
// 
// Create Date: 02/24/2020 11:21:33 AM
// Design Name: 
// Module Name: branch_addr_gen
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

module branch_addr_gen(
    input [31:0] addr,
    input [31:0] rs,
    input [31:0] Itype,
    input [31:0] Btype,
    input [31:0] Jtype,
    output [31:0] jal,
    output [31:0] branch,
    output [31:0] jalr
    );
    
    //assigning jal address 
    assign jal = Jtype + addr;
    
    //assigning jalr address
    assign jalr = Itype + rs;
    
    //assigning branch address
    assign branch = Btype + addr;

endmodule