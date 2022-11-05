`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Micah Jeffries
// 
// Create Date: 02/24/2020 11:16:41 AM
// Design Name: 
// Module Name: otter_mcu
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

module otter_mcu(
    input RST,
    input intr,
    input clk,
    output [31:0] iobus_in,
    output [31:0] iobus_out,
    output [31:0] iobus_addr,
    output iobus_wr
    );
    
    //Set up internal wiring
    wire PCWrite, memRDEN1, memRDEN2, memWE2, alu_srcA, regWrite, rst;
    wire br_eq, br_lt, br_ltu;
    wire int_taken, csr_WE, mie;
    wire [1:0] alu_srcB, rf_wr_sel;
    wire [2:0] pcSource;
    wire [3:0] alu_fun;
    wire [31:0] jalr, branch, jal, pc_data, ir, memDOUT2, addr;
    wire [31:0] Utype, Itype, Stype, Btype, Jtype;
    wire [31:0] rs1, rs2, srcA, srcB;
    wire [31:0] mem_addr, wd, mtvec, mepc, RD;
    
    //Register that keeps track of where we are in the program
    Program_Counter MY_PROGRAM_COUNTER (
        .rst (rst),
        .PCWrite (PCWrite),
        .jalr (jalr),
        .branch (branch),
        .jal (jal),
        .mtvec (mtvec),
        .mepc (mepc),
        .pcSource (pcSource),
        .clk (clk),
        .addr (pc_data));
     
     //Memory module that stores instructions and data in two different
     //areas of memory   
     Memory OTTER_MEMORY (
            .MEM_CLK   (clk),
            .MEM_RDEN1 (memRDEN1), 
            .MEM_RDEN2 (memRDEN2), 
            .MEM_WE2  (memWE2),
            .MEM_ADDR1 (pc_data[15:2]),
            .MEM_ADDR2 (iobus_addr),
            .MEM_WD    (),  
            .MEM_SIZE  (ir[13:12]),
            .MEM_SIGN  (ir[14]),
            .IO_IN     (iobus_in),
            .IO_WR     (iobus_wr),
            .MEM_DOUT1 (ir),
            .MEM_DOUT2 (memDOUT2)  );
      
      //Next address in memory that is fed into the register file      
      assign mem_addr = pc_data + 3'b100;
      //Output of our MCU
      assign iobus_out = rs2;
      
      //General purpose register file
      RegFile  MY_REG_FILE (
        .wd (wd),
        .clk (clk),
        .en (regWrite),
        .adr1 (ir[19:15]),
        .adr2 (ir[24:20]),
        .wa (ir[11:7]),
        .rs1 (rs1),
        .rs2 (rs2));
       
      //Mux tht determines what is fed into the register file      
      mux_4t1_nb  #(.n(32)) my_mux_4t1_nb  (
                       .SEL   (rf_wr_sel), 
                       .D0    (mem_addr), 
                       .D1    (RD), 
                       .D2    (memDOUT2), 
                       .D3    (iobus_addr),
                       .D_OUT (wd) );
      
      //Generate each instruction type based on the current instruction      
      IMMED_GEN My_imm_gen (
         .ir (ir),
         .Utype (Utype),
         .Itype (Itype),
         .Stype (Stype),
         .Btype (Btype),
         .Jtype (Jtype)); 
      
      //Generate absolute addresses for I,B, and J tpye instructions   
      BRANCH_ADDR_GEN My_branch_gen (
         .addr (pc_data),
         .rs (rs1),
         .Itype (Itype),
         .Btype (Btype),
         .Jtype (Jtype),
         .jal (jal),
         .branch (branch),
         .jalr (jalr));
     
     //Mux that determines source A for the ALU    
     mux_2t1_nb  #(.n(32)) ALU_SRCA  (
                .SEL   (alu_srcA), 
                .D0    (rs1), 
                .D1    (Utype), 
                .D_OUT (srcA) );
     
     //Mux that determines source B for the ALU           
     mux_4t1_nb  #(.n(32)) ALU_SRCB  (
           .SEL   (alu_srcB), 
           .D0    (rs2), 
           .D1    (Itype), 
           .D2    (Stype), 
           .D3    (pc_data),
           .D_OUT (srcB) );    
     
     //Takes in two inputs and spits out iobus_addr based on the current operation     
     alu MY_ALU (
        .srcA (srcA),
        .srcB (srcB),
        .alu_fun (alu_fun),
        .result (iobus_addr));
     
     //Generate branch status signals to be fed into CU_DCDR   
     BRANCH_COND_GEN My_Branch (
        .rs1 (rs1),
        .rs2 (rs2),
        .br_eq (br_eq),
        .br_lt (br_lt),
        .br_ltu (br_ltu));
     
     //Control unit decoder   
     CU_DCDR MY_Dcdr (
        .br_eq (br_eq),
        .br_lt (br_lt),
        .br_ltu (br_ltu),
        .opcode (ir[6:0]),
        .func7 (ir[31:25]),
        .func3 (ir[14:12]),
        .alu_fun (alu_fun),
        .pcSource (pcSource),
        .alu_srcA (alu_srcA),
        .alu_srcB (alu_srcB),
        .rf_wr_sel (rf_wr_sel));
     
     //Control unit FSM   
     CU_FSM MY_FSM (
        .intr (intr && mie),
        .clk (clk),
        .RST (RST),
        .opcode (ir[6:0]),
        .func3 (ir[14:12]),
        .pcWrite (PCWrite),
        .regWrite (regWrite),
        .memWE2 (memWE2),
        .memRDEN1 (memRDEN1),
        .memRDEN2 (memRDEN2),
        .rst (rst),
        .csr_WE (csr_WE),
        .int_taken (int_taken));
      
      //Control and State Register  
      CSR  my_csr (
            .CLK       (clk),
            .RST       (rst),
            .INT_TAKEN (int_taken),
            .ADDR      (ir[31:20]),
            .PC        (pc_data),
            .WD        (rs1),
            .WR_EN     (csr_WE), 
            .RD        (RD),
            .CSR_MEPC  (mepc),  
            .CSR_MTVEC (mtvec), 
            .CSR_MIE   (mie)    );
        
    
endmodule
