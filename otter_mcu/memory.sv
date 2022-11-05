`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Micah Jeffries
// 
// Create Date: 02/24/2020 11:17:54 AM
// Design Name: 
// Module Name: memory
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

module memory (
    input MEM_CLK,
    input MEM_RDEN1,        // read enable Instruction
    input MEM_RDEN2,        // read enable data
    input MEM_WE2,          // write enable.
    input [13:0] MEM_ADDR1, // Instruction Memory word Addr (Connect to PC[15:2])
    input [31:0] MEM_ADDR2, // Data Memory Addr
    input [31:0] MEM_WD,    // Data to save
    input [1:0] MEM_SIZE,   // 0-Byte, 1-Half, 2-Word
    input MEM_SIGN,         // 1-unsigned 0-signed
    input [31:0] IO_IN,     // Data from IO     
    //output ERR,
    output logic IO_WR,     // IO 1-write 0-read
    output logic [31:0] MEM_DOUT1,  // Instruction
    output logic [31:0] MEM_DOUT2); // Data
    
    logic [13:0] wordAddr1, wordAddr2;
    logic [31:0] memReadWord, ioBuffer, memReadSized;
    logic [1:0] byteOffset;
    logic weAddrValid;      // active when saving (WE) to valid memory address
       
    (* rom_style="{distributed | block}" *)
    (* ram_decomp = "power" *) logic [31:0] memory [0:16383];
    
    initial begin
        $readmemh("otter_memory1.mem", memory, 0, 16383);
    end
    
    assign wordAddr2 = MEM_ADDR2[15:2];
    assign byteOffset = MEM_ADDR2[1:0];     // byte offset of memory address
         
    // NOT USED IN OTTER
    //Check for misalligned or out of bounds memory accesses 
    //assign ERR = ((MEM_ADDR1 >= 2**ACTUAL_WIDTH)|| (MEM_ADDR2 >= 2**ACTUAL_WIDTH)
    //                || MEM_ADDR1[1:0] != 2'b0 || MEM_ADDR2[1:0] !=2'b0)? 1 : 0;
            
    // buffer the IO input for reading
    always_ff @(posedge MEM_CLK) begin
        if(MEM_RDEN2)
            ioBuffer <= IO_IN;
    end
    
    // BRAM requires all reads and writes to occur synchronously
    always_ff @(posedge MEM_CLK) begin
    
      // save data (WD) to memory (ADDR2)
      if (weAddrValid == 1) begin  //(MEM_WE == 1) && (MEM_ADDR2 < 16'hFFFD)) begin   // write enable and valid address space
        case({MEM_SIZE,byteOffset})
            4'b0000: memory[wordAddr2][7:0]   <= MEM_WD[7:0];     // sb at byte offsets
            4'b0001: memory[wordAddr2][15:8]  <= MEM_WD[7:0];
            4'b0010: memory[wordAddr2][23:16] <= MEM_WD[7:0];
            4'b0011: memory[wordAddr2][31:24] <= MEM_WD[7:0];
            4'b0100: memory[wordAddr2][15:0]  <= MEM_WD[15:0];    // sh at byte offsets
            4'b0101: memory[wordAddr2][23:8]  <= MEM_WD[15:0];
            4'b0110: memory[wordAddr2][31:16] <= MEM_WD[15:0];
            4'b1000: memory[wordAddr2]        <= MEM_WD;          // sw
			default: memory[wordAddr2]        <= 32'b0; 
        endcase
      end

        // read all data synchronously required for BRAM
        if(MEM_RDEN1)                       // need EN for extra load cycle to not change instruction
            MEM_DOUT1 <= memory[MEM_ADDR1];

        if(MEM_RDEN2)                         // Read word from memory
            memReadWord <= memory[wordAddr2];
    end
       
    // Change the data word into sized bytes and sign extend 
    always_comb begin
        case({MEM_SIGN,MEM_SIZE,byteOffset})
            5'b00011: memReadSized = {{24{memReadWord[31]}},memReadWord[31:24]};    // signed byte
            5'b00010: memReadSized = {{24{memReadWord[23]}},memReadWord[23:16]};
            5'b00001: memReadSized = {{24{memReadWord[15]}},memReadWord[15:8]};
            5'b00000: memReadSized = {{24{memReadWord[7]}},memReadWord[7:0]};
                                    
            5'b00110: memReadSized = {{16{memReadWord[31]}},memReadWord[31:16]};    // signed half
            5'b00101: memReadSized = {{16{memReadWord[23]}},memReadWord[23:8]};
            5'b00100: memReadSized = {{16{memReadWord[15]}},memReadWord[15:0]};
            
            5'b01000: memReadSized = memReadWord;                   // word
               
            5'b10011: memReadSized = {24'd0,memReadWord[31:24]};    // unsigned byte
            5'b10010: memReadSized = {24'd0,memReadWord[23:16]};
            5'b10001: memReadSized = {24'd0,memReadWord[15:8]};
            5'b10000: memReadSized = {24'd0,memReadWord[7:0]};
               
            5'b10110: memReadSized = {16'd0,memReadWord[31:16]};    // unsigned half
            5'b10101: memReadSized = {16'd0,memReadWord[23:8]};
            5'b10100: memReadSized = {16'd0,memReadWord[15:0]};
            
            default:    memReadSized=32'b0; // unsupported size, byte offset combination 
        endcase
    end
 
    // Memory Mapped IO 
    always_comb begin
        if(MEM_ADDR2 >= 32'h00010000) begin  // MMIO address range
            IO_WR = MEM_WE2;             // IO Write
            MEM_DOUT2 = ioBuffer;       // IO read from buffer
            weAddrValid = 0;            // address beyond memory range
        end 
        else begin
            IO_WR = 0;                  // not MMIO
            MEM_DOUT2 = memReadSized;   // output sized and sign extended data
            weAddrValid = MEM_WE2;       // address in valid memory range
        end
    end
        
 endmodule