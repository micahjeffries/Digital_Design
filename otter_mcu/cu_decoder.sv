`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Micah Jeffries
// 
// Create Date: 02/24/2020 11:17:54 AM
// Design Name: 
// Module Name: cu_decoder
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

module cu_decoder(
    input clk,
    input br_eq, 
	input br_lt, 
	input br_ltu,
    input [6:0] opcode,   //-  ir[6:0]
	input [6:0] func7,    //-  ir[31:25]
    input [2:0] func3,    //-  ir[14:12]
    input int_taken, 
    output logic [3:0] alu_fun,
    output logic [2:0] pcSource,
    output logic alu_srcA,
    output logic [1:0] alu_srcB, 
	output logic [1:0] rf_wr_sel   );
    
    //- datatypes for RISC-V opcode types
    typedef enum logic [6:0] {
        LUI    = 7'b0110111,
        AUIPC  = 7'b0010111,
        JAL    = 7'b1101111,
        JALR   = 7'b1100111,
        BRANCH = 7'b1100011,
        LOAD   = 7'b0000011,
        STORE  = 7'b0100011,
        OP_IMM = 7'b0010011,
        OP_RG3 = 7'b0110011,
        CSR    = 7'b1110011
    } opcode_t;
    opcode_t OPCODE; //- define variable of new opcode type
    
    assign OPCODE = opcode_t'(opcode); //- Cast input enum 
    
    //- datatypes for func7Symbols tied to values
    typedef enum logic [6:0] {
        SRA    = 7'b0100000,
        SRL    = 7'b0000000
    } func7_t;
    func7_t FUNC7; //- define variable of new opcode type
    
    assign FUNC7 = func7_t'(func7); //- Cast input enum

    //- datatype for func3Symbols tied to values
    typedef enum logic [2:0] {
        //BRANCH labels
        BEQ = 3'b000,
        BNE = 3'b001,
        BLT = 3'b100,
        BGE = 3'b101,
        BLTU = 3'b110,
        BGEU = 3'b111
    } func3_t;    
    func3_t FUNC3; //- define variable of new opcode type
    
    assign FUNC3 = func3_t'(func3); //- Cast input enum 
    
    always_comb
        begin 
            //- schedule all values to avoid latch
            alu_srcB <= 0; rf_wr_sel <= 0; alu_srcA <= 0; alu_fun <= 0;
            if (int_taken == 1'b1)
            begin
                pcSource <= 3'b100;
            end
            else
            begin
                pcSource <= 3'b000;
            end  
            
            case(OPCODE)
                LUI:
                begin
                    alu_fun <= 4'b1001; 
                    alu_srcA <= 1'd1;
                    alu_srcB <= 2'd0; 
                    rf_wr_sel <= 2'd3; 
                    if (int_taken == 1'b1)
                    begin
                        pcSource <= 3'b100;
                    end
                    else
                    begin
                        pcSource <= 3'b000;
                    end 
                end
                
                AUIPC:
                begin
                    alu_fun <= 4'b0000; 
                    alu_srcA <= 1'd1;
                    alu_srcB <= 2'd3; 
                    rf_wr_sel <= 2'd3; 
                    if (int_taken == 1'b1)
                    begin
                        pcSource <= 3'b100;
                    end
                    else
                    begin
                        pcSource <= 3'b000;
                    end
                end
                
                JAL:
                begin
                    alu_fun <= 4'b0000; 
                    alu_srcA <= 1'd0;
                    alu_srcB <= 2'd0;
                    //pcSource <= 3'd3; 
                    rf_wr_sel <= 2'd0;
                    if (int_taken == 1'b1)
                        begin
                            pcSource <= 3'b100;
                        end
                        else
                        begin
                            pcSource <= 3'b011;
                        end 
                end
                
                JALR:
                begin
                    alu_fun <= 4'b0000; 
                    alu_srcA <= 1'd0;
                    alu_srcB <= 2'd1;
                    rf_wr_sel <= 2'd0;
                    if (int_taken == 1'b1)
                        begin
                            pcSource <= 3'b100;
                        end
                        else
                        begin
                            pcSource <= 3'b001;
                        end 
                end
                
                BRANCH:
                begin
                    alu_fun <= 4'b0000; alu_srcA <= 1'd0; alu_srcB <= 2'd0; rf_wr_sel <= 2'd0;
                    
                    case(FUNC3)
                        BEQ:
                        begin
                                if (int_taken == 1)
                                    pcSource <= 3'd4;
                                
                                
                            else
                            begin    
                            if (br_eq == 1)
                                pcSource <= 3'd2;
                            else
                                pcSource <= 3'd0;
                            end
                            
                        end
                        
                        BNE:
                        begin
                            if (int_taken == 1)
                                pcSource <= 3'd4;
                        
                            else
                            begin
                            if (br_eq == 0)
                                pcSource <= 3'd2;
                            else
                                pcSource <= 3'd0;
                            end
                        end
                        
                        BLT:
                        begin
                            if (int_taken == 1)
                                pcSource <= 3'd4;
                                
                            else
                            begin
                            if (br_lt == 1)
                                pcSource <= 3'd2;
                            else
                                pcSource <= 3'd0;
                            end
                        end
                        
                        BGE:
                        begin
                            if (int_taken == 1)
                                pcSource <= 3'd4;
                                
                            else
                            begin
                            if (br_lt == 0)
                                pcSource <= 3'd2;
                            else
                                pcSource <= 3'd0;
                            end
                        end
                        
                        BLTU:
                        begin
                            if (int_taken == 1)
                                pcSource <= 3'd4;
                                
                            else
                            begin
                            if (br_ltu == 1)
                                pcSource <= 3'd2;
                            else
                                pcSource <= 3'd0;
                            end
                        end
                        
                        BGEU:
                        begin
                            if (int_taken == 1)
                                pcSource <= 3'd4;
                            
                            else
                            begin
                            if (br_ltu == 0)
                                pcSource <= 3'd2;
                            else
                                pcSource <= 3'd0;
                            end
                        end
                        
                        default:
                        begin
                             if (int_taken == 1)
                                pcSource <= 3'd4;
                             else
                             begin
                             pcSource <= 3'd0;
                             end 
                             alu_srcB <= 2'd0; 
                             rf_wr_sel <= 2'd0; 
                             alu_srcA <= 1'd0; 
                             alu_fun <= 4'b0000;
                        end
                        endcase
                        
                                   
                end
                
                LOAD: 
                begin
                    alu_fun <= 4'b0000; 
                    alu_srcA <= 1'd0; 
                    alu_srcB <= 2'd1; 
                    rf_wr_sel <= 2'd2;
                    pcSource <= 3'd0; 
                end
                
                STORE:
                begin
                    alu_fun <= 4'b0000; 
                    alu_srcA <= 1'd0; 
                    alu_srcB <= 2'd2; 
                    rf_wr_sel <= 2'd0;
                    if (int_taken == 1'b1)
                        begin
                            pcSource <= 3'b100;
                        end
                        else
                        begin
                            pcSource <= 3'b000;
                        end
                end
                
                OP_IMM:
                begin
                    alu_srcA <= 1'd0; alu_srcB <= 2'd1; rf_wr_sel <= 2'd3; 
                    if (int_taken == 1'b1)
                        begin
                            pcSource <= 3'b100;
                        end
                        else
                        begin
                            pcSource <= 3'b000;
                        end
                    case(FUNC3)
                        3'b000: // instr: ADDI
                            alu_fun <= 4'b0000;
                        
                        3'b010: // instr: SLTI
                            alu_fun <= 4'b0010;
                            
                        3'b011: // instr: SLTIU
                            alu_fun <= 4'b0011;
                        
                        3'b100: // instr: ORI
                            alu_fun <= 4'b0110;
                            
                        3'b110: // instr: XORI
                            alu_fun <= 4'b0100;
                        
                        3'b111: // instr: ANDI
                            alu_fun <= 4'b0111;
                            
                        3'b001: // instr: SLLI
                            alu_fun <= 4'b0001;
                        
                        3'b101: // instr: SRLI/SRAI
                        
                            case(FUNC7)
                            SRL:
                                alu_fun <= 4'b0101;
                            
                            SRA:
                                alu_fun <= 4'b0110;
                                
                            default:
                                alu_fun <= 4'b0000;
                                
                            endcase
                        
                        default: 
                        begin
                            pcSource <= 2'd0; 
                            alu_fun <= 4'b0000;
                            alu_srcA <= 1'd0; 
                            alu_srcB <= 2'd0; 
                            rf_wr_sel <= 2'd0; 
                        end
                    endcase
                end
                
                OP_RG3:
                begin
                    alu_srcA <= 1'd0; alu_srcB <= 2'd0; rf_wr_sel <= 2'd3; 
                    if (int_taken == 1'b1)
                        begin
                            pcSource <= 3'b100;
                        end
                        else
                        begin
                            pcSource <= 3'b000;
                        end
                    case(FUNC3)
                        3'b000: // instr: ADD
                            alu_fun <= 4'b0000;
                        
                        3'b010: // instr: SLT
                            alu_fun <= 4'b0010;
                            
                        3'b011: // instr: SLTU
                            alu_fun <= 4'b0011;
                        
                        3'b110: // instr: OR
                            alu_fun <= 4'b0110;
                            
                        3'b100: // instr: XOR
                            alu_fun <= 4'b0100;
                        
                        3'b111: // instr: AND
                            alu_fun <= 4'b0111;
                            
                        3'b001: // instr: SLL
                            alu_fun <= 4'b0001;
                        
                        3'b101: // instr: SRL/SRA
                        
                            case(FUNC7)
                            SRL:
                                alu_fun <= 4'b0101;
                            
                            SRA:
                                alu_fun <= 4'b0110;
                                
                            default:
                                alu_fun <= 4'b0000;
                                
                            endcase
                        
                        default: 
                        begin
                            if (int_taken == 1'b1)
                                begin
                                    pcSource <= 3'b100;
                                end
                                else
                                begin
                                    pcSource <= 3'b000;
                                end 
                            alu_fun <= 4'b0000;
                            alu_srcA <= 1'd0; 
                            alu_srcB <= 2'd0; 
                            rf_wr_sel <= 2'd0; 
                        end
                    endcase
                end
                
                CSR:
                 begin
                     alu_fun <= 4'b0000; 
                     alu_srcA <= 1'd0; 
                     alu_srcB <= 2'd2;
                     
                 case(FUNC3)
                     3'b001:
                     begin
                         rf_wr_sel <= 2'd1; 
                        if (int_taken == 1'b1)
                             begin
                                 pcSource <= 3'b100;
                             end
                             else
                             begin
                                 pcSource <= 3'b000;
                             end
                     end
                     
                     3'b000:
                     begin
                         rf_wr_sel <= 2'd0;                        
                         if (int_taken == 1'b1)
                             begin
                                 pcSource <= 3'b100;
                             end
                             else
                             begin
                                 pcSource <= 3'b101;
                             end
                     end
                     
                     default:
                     begin
                         rf_wr_sel <= 2'd0;
                         if (int_taken == 1'b1)
                             begin
                                 pcSource <= 3'b100;
                             end
                             else
                             begin
                                 pcSource <= 3'b000;
                             end
                     end
                 
                 endcase
                
                 end
                 
    
                default:
                begin
                     if (int_taken == 1'b1)
                        begin
                            pcSource <= 3'b100;
                        end
                        else
                        begin
                            pcSource <= 3'b000;
                        end 
                     alu_srcB <= 2'd0; 
                     rf_wr_sel <= 2'd0; 
                     alu_srcA <= 1'd0; 
                     alu_fun <= 4'b0000;
                end
                endcase
                

        end

endmodule