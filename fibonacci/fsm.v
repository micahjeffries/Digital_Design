module fsm(x_in, clk, mux, clr, up, ld1, ld2, ld3); 
    input  clk;
    input [1:0] x_in; 
    output reg clr, up, ld1, ld2, ld3, mux;
     
    //- next state & present state variables
    reg [1:0] NS, PS; 
    //- bit-level state representations
    parameter [1:0] st_WAIT=2'b00, st_LOAD=2'b01;
    parameter [1:0] st_FIB=2'b10;
    
    //- status inputs
    wire btn, rco;
    assign rco = x_in[0];
    assign btn = x_in[1]; 

    //- model the state registers
    always @ (posedge clk)
        PS <= NS; 
    
    
    //- model the next-state and output decoders
    always @ (x_in,PS)
    begin
       mux = 1'b0; clr = 1'b0; up = 1'b0; ld1 = 1'b0; ld2 = 1'b0; ld3 = 1'b0;
       case(PS)
          st_WAIT:
          begin
             up = 1'b0; ld1 = 1'b0; ld2 = 1'b0; ld3 = 1'b0;
             if (btn == 0)
                begin
                    mux = 1'b0; clr = 1'b0;
                    NS = st_WAIT;
                end         
             else
                begin
                    mux= 1'b1; clr = 1'b1;
                    NS = st_LOAD;
                end 
          end
             
          st_LOAD:
             begin
                 mux = 1'b1; clr = 1'b0; up = 1'b1; ld1 = 1'b1; ld2 = 1'b0; ld3 = 1'b1;
                 NS = st_FIB;
             end
             
          st_FIB:
             begin
                 up = 1'b1; ld1 = 1'b1; ld2 = 1'b1; ld3 = 1'b0;
                 if (rco == 0)
                    begin
                        mux = 1'b0; clr = 1'b0;
                        NS = st_FIB;
                    end
                 else
                    begin
                        mux = 1'b0; clr = 1'b0;
                        NS = st_WAIT;
                    end
             end
             
          default: NS = st_WAIT; 
            
          endcase
      end              
endmodule
