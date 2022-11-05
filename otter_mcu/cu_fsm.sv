`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Micah Jeffries
// 
// Create Date: 02/24/2020 11:17:54 AM
// Design Name: 
// Module Name: cu_fsm
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

module cu_fsm(
    input intr,
    input clk,
    input RST,
    input [6:0] opcode,     // ir[6:0]
    input [2:0] func3,    //-  ir[14:12]
    output logic pcWrite,
    output logic regWrite,
    output logic memWE2,
    output logic memRDEN1,
    output logic memRDEN2,
    output logic rst,
    output logic csr_WE,
    output logic int_taken
  );
    
    reg [1:0] NS, PS;
    
    //- State register bit assignments
    parameter [1:0] st_irFetch = 2'b00, st_DCDR = 2'b01, st_writeBack = 2'b10, st_interrupt = 2'b11;
  
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
	opcode_t OPCODE;    //- symbolic names for instruction opcodes
     
	assign OPCODE = opcode_t'(opcode); //- Cast input as enum 
	
	//- datatype for func3Symbols tied to values
    typedef enum logic [2:0] {
        //BRANCH labels
        CSRRW = 3'b001,
        MRET  = 3'b000
    } func3_t;    
    func3_t FUNC3; //- define variable of new opcode type
    
    assign FUNC3 = func3_t'(func3); //- Cast input enum 
	 
	 
	//- state register (PS)
	always_ff @ (posedge clk)  
    begin
        if(RST == 1)
        begin
            PS = st_irFetch;
            rst = 1;
        end 
        else
            rst = 0; 
            PS = NS;
    end
       
    always_comb
    begin              
        //- schedule all output to avoid latch
        pcWrite = 0;    regWrite = 0;    csr_WE = 0;    int_taken = 0;  
		memWE2 = 0;     memRDEN1 = 0;    memRDEN2 = 0;   
                   
        case (PS)
            st_irFetch: //waiting state  
            begin
                pcWrite = 0;
                regWrite = 0;
                memWE2 = 0;
                memRDEN1 = 1;
                memRDEN2 = 0;
                csr_WE = 1'b0;
                int_taken = intr;
                
                if (intr == 1'b0)
                    begin
                      pcWrite = 0;
                      NS = st_DCDR;  
                    end
                    
                  else
                    begin
                        pcWrite = 1;
                        NS = st_interrupt;  
                    end
                   
                //NS = st_DCDR; 
            end
              
            st_DCDR: //decode + execute
            begin
                memRDEN1 = 0;
 
				case (OPCODE)
				   LUI: 
                   begin
                      regWrite = 1;
                      memWE2 = 0;
                      memRDEN2 = 0;
                      csr_WE = 1'b0;
                      int_taken = intr;
                      
                      if (intr == 1'b0)
                        begin
                          pcWrite = 1;
                          NS = st_irFetch;  
                        end
                        
                      else
                        begin
                            pcWrite = 1;
                            NS = st_interrupt;  
                        end
                      
                   end
                   
                   AUIPC:
                   begin
                     regWrite = 1;
                     memWE2 = 0;
                     memRDEN2 = 0;
                     csr_WE = 1'b0;
                     int_taken = intr;
                     
                     if (intr == 1'b0)
                       begin
                         pcWrite = 1;
                         NS = st_irFetch;  
                       end
                       
                     else
                       begin
                           pcWrite = 1;
                           NS = st_interrupt;  
                       end
                     
                   end
                   
                   JAL: 
                   begin
                     regWrite = 1;
                     memWE2 = 0;
                     memRDEN2 = 0;
                     csr_WE = 1'b0;
                     int_taken = intr;
                     
                     if (intr == 1'b0)
                       begin
                         pcWrite = 1;
                         NS = st_irFetch;  
                       end
                       
                     else
                       begin
                           pcWrite = 1;
                           NS = st_interrupt;  
                       end
                     
                   end
                   
                   JALR: 
                   begin
                    regWrite = 1;
                    memWE2 = 0;
                    memRDEN2 = 0;
                    csr_WE = 1'b0;
                    int_taken = intr;
                    
                    if (intr == 1'b0)
                      begin
                        pcWrite = 1;
                        NS = st_irFetch;  
                      end
                      
                    else
                      begin
                          pcWrite = 1;
                          NS = st_interrupt;  
                      end
                    
                   end
                   
                   BRANCH: 
                   begin
                     regWrite = 0;
                     memWE2 = 0;
                     memRDEN2 = 0;
                     csr_WE = 1'b0;
                     int_taken = intr;
                     
                     if (intr == 1'b0)
                       begin
                         pcWrite = 1;
                         NS = st_irFetch;  
                       end
                       
                     else
                       begin
                           pcWrite = 1;
                           NS = st_interrupt;  
                       end
                       
                   end
                   
				    LOAD: 
                       begin
                          pcWrite = 0;
                          regWrite = 0;
                          memWE2 = 0;
                          memRDEN2 = 1;
                          csr_WE = 1'b0;
                          int_taken = intr;
                          NS = st_writeBack;
                       end
                    
					STORE: 
                       begin
                          regWrite = 0;
                          memWE2 = 1;
                          memRDEN2 = 0;
                          csr_WE = 1'b0;
                          int_taken = intr;
                          
                          if (intr == 1'b0)
                            begin
                              pcWrite = 1;
                              NS = st_irFetch;  
                            end
                            
                          else
                            begin
                                pcWrite = 1;
                                NS = st_interrupt;  
                            end
                          
                       end
					  
					OP_IMM: 
					   begin 
					      regWrite = 1;
					      memWE2 = 0;
                          memRDEN2 = 0;
                          csr_WE = 1'b0;
                          int_taken = intr;
                          
                          if (intr == 1'b0)
                            begin
                              pcWrite = 1;
                              NS = st_irFetch;  
                            end
                            
                          else
                            begin
                                pcWrite = 1;
                                NS = st_interrupt;  
                            end
                          
					   end
					   
					OP_RG3: 
                      begin 
                         regWrite = 1;
                         memWE2 = 0;
                         memRDEN2 = 0;
                         csr_WE = 1'b0;
                         int_taken = intr;
                         
                         if (intr == 1'b0)
                           begin
                             pcWrite = 1;
                             NS = st_irFetch;  
                           end
                           
                         else
                           begin
                               pcWrite = 1;
                               NS = st_interrupt;  
                           end
                         
                      end
                      
                    CSR:
                    begin
                    regWrite = 1;
                    memWE2 = 0;
                    memRDEN2 = 0;
                    int_taken = intr;
                    
                    if (intr == 1'b0)
                       begin
                         pcWrite = 1;
                         NS = st_irFetch;  
                       end
                       
                     else
                       begin
                           pcWrite = 1;
                           NS = st_interrupt;  
                       end
                    
                    case(FUNC3)
                        CSRRW:
                        begin
                            csr_WE = 1'b1;
                        end
                        
                        MRET:
                        begin
                            csr_WE = 1'b0;
                        end
                        
                        default:
                        begin
                            csr_WE = 1'b0;
                        end
                        
                    
                    endcase
                    
                    end
					 
                    default:  
					   begin 
					      pcWrite = 1;
					      NS = st_irFetch;
					   end
					
                endcase
            end
               
            st_writeBack:
            begin
               regWrite = 1;
               memRDEN2 = 1'b1;
               csr_WE = 1'b0;
               int_taken = intr;
               
               if (intr == 1'b0)
               begin 
                    pcWrite = 1;
                    NS = st_irFetch;
               end
               else
               begin
                    pcWrite = 1;
                    NS = st_interrupt;
               end
               
            end
            
            st_interrupt:
            begin
                 pcWrite = 0;
                 regWrite = 0;
                 memWE2 = 0;
                 memRDEN1 = 0;
                 memRDEN2 = 0;
                 csr_WE = 1'b0;
                 int_taken = 1'b0;
                 NS = st_irFetch; 
            end
 
            default: NS = st_irFetch;
           
        endcase //- case statement for FSM states
    end
           
endmodule