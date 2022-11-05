
module fsm_template(reset_n, x_in, clk, clr, ld, mux, sel); 
    input  reset_n, x_in, clk; 
    output reg clr, ld;
    output reg [1:0] sel;
    output reg [2:0] mux;
     
    //- next state & present state variables
    reg [2:0] NS, PS; 
    //- bit-level state representations
    parameter [2:0] st_WAIT=3'b000, st_START=3'b001;
    parameter [2:0] st_SHIFT_0=3'b010, st_SHIFT_1=3'b011;
    parameter [2:0] st_SHIFT_2=3'b100, st_SHIFT_3=3'b101;
    parameter [2:0] st_SHIFT_4=3'b110, st_SHIFT_5=3'b111;
    
    //Set up internal wiring
    wire btn;
    assign btn = x_in;

    //- model the state registers
    always @ (negedge reset_n, posedge clk)
       if (reset_n == 0) 
          PS <= st_WAIT; 
       else
          PS <= NS;
    
    //- model the next-state and output decoders
    always @ (btn,PS)
    begin
        clr = 0; ld = 0; mux = 3'b000; sel = 2'b00; // assign all outputs
        case(PS)
            st_WAIT:
            begin
                ld = 0; mux = 3'b000; sel = 2'b00;
                if (btn == 0)
                    begin
                        clr = 0;
                        NS = st_WAIT;
                    end
                else
                    begin
                        clr = 1;
                        NS = st_START;
                    end
            end
            
            st_START:
            begin
                clr = 0; ld = 1; mux = 3'b000; sel = 2'b01;
                NS = st_SHIFT_0;
            end
            
            st_SHIFT_0:
            begin
                ld = 1; mux = 3'b000; sel = 2'b10;
                NS = st_SHIFT_1;
            end
            
            st_SHIFT_1:
            begin
                ld = 1; mux = 3'b001; sel = 2'b10;
                NS = st_SHIFT_2;
            end
            
            st_SHIFT_2:
            begin
                ld = 1; mux = 3'b010; sel = 2'b10;
                NS = st_SHIFT_3;
            end
            
            st_SHIFT_3:
            begin
                ld = 1; mux = 3'b011; sel = 2'b10;
                NS = st_SHIFT_4;
            end
            
            st_SHIFT_4:
            begin
                ld = 1; mux = 3'b100; sel = 2'b10;
                NS = st_SHIFT_5;
            end
            
            st_SHIFT_5:
            begin
                ld = 1; mux = 3'b101; sel = 2'b10;
                NS = st_WAIT;
            end
             
            default: NS = st_WAIT; 
            
        endcase
    end              
endmodule
