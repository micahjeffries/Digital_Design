`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Micah Jeffries
// 
// Create Date: 02/24/2020 11:21:33 AM
// Design Name: 
// Module Name: program_counter
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

module program_counter(
    input rst,
    input PCWrite,
    input [31:0] jalr,
    input [31:0] branch,
    input [31:0] jal,
    input [31:0] mtvec,
    input [31:0] mepc,
    input [2:0] pcSource,
    input clk,
    output [31:0] addr
    );
    
    // Set up internal wiring.
     wire [31:0] data, new_addr;
    
    // The program counter is a specialized counter that counts sequentially
    // by 4 specifically for the RISC-V OTTER. This counter can also jump or 
    // branch to other locations in the program depending on the mux output.
    cntr_up_clr_nb #(.n(32)) MY_CNTR (
              .clk   (clk), 
              .clr   (rst), 
              .up    (1'b0), 
              .ld    (PCWrite), 
              .D     (data), 
              .count (addr), 
              .rco   ()   );
              
    assign new_addr = addr + 3'b100;
    
    // This mux determines what goes into the program counter. For D0, the 
    // counter sequentially counts by 4. Otherwise, the mux output will either
    // be a jump or branch to other locations in the program.
    mux_8t1_nb  #(.n(32)) my_8t1_mux  (
             .SEL   (pcSource), 
             .D0    (new_addr), 
             .D1    (jalr), 
             .D2    (branch), 
             .D3    (jal),
             .D4    (mtvec),
             .D5    (mepc),
             .D6    (32'b0),
             .D7    (32'b0),
             .D_OUT (data) );
    
endmodule