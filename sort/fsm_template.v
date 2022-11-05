module fsm_template( 
    input  btn, gt1, gt2, gt3, clk,
    output reg sel_1, sel_2, sel_3, ld1, ld2, ld3,
    output reg mux_a, mux_d, clr, led,
    output reg [1:0] mux_b, mux_c
    );
     
    //- next state & present state variables
    reg [3:0] NS, PS; 
    //- bit-level state representations
    parameter [3:0] st_WAIT=4'b0000, st_init=4'b0001, st_1=4'b0010;
    parameter [3:0] st_2=4'b0011, st_3=4'b0100, st_4=4'b0101, st_5=4'b0110;
    parameter [3:0] st_6=4'b0111, st_7=4'b1000, st_8=4'b1001, st_9=4'b1010;
    parameter [3:0] st_10=4'b1011, st_11=4'b1100;
    parameter [3:0] st_DISPLAY=4'b1101; 
    

    //- model the state registers
    always @ (posedge clk)
          PS <= NS; 
    
    
    //- model the next-state and output decoders
    always @ (btn,PS)
    begin
       // assign all outputs
       sel_1 = 0; sel_2 = 0; sel_3 = 0; mux_a = 0; mux_b = 2'b00; mux_c = 2'b00;
       mux_d = 0; ld1 = 0; ld2 = 0; ld3 = 0; clr = 0; led = 0;
       case(PS)
          st_WAIT:
          begin
             sel_1 = 0; sel_2 = 0; sel_3 = 0; mux_a = 0; mux_b = 2'b00; mux_c = 2'b00;
             mux_d = 0; ld1 = 0; ld2 = 0; ld3 = 0; clr = 1; led = 1;        
             if (btn == 0)   
                NS = st_WAIT;  
             else
                NS = st_init;
          end
          
          st_init:
             begin
                ld1 = 1; ld2 = 1; ld3 = 1;
                NS = st_1;
             end   
             
          st_1:
             begin
                mux_a = 1; mux_b = 2'b00; sel_1 = 1; ld1 = gt1;
                NS = st_2;
             end
             
          st_2:
             begin
                 mux_b = 2'b01; sel_2 = 0; ld2 = 1; ld1 = 0;
                 NS = st_3;
             end
             
          st_3:
              begin
                 mux_b = 2'b01; mux_c = 2'b00; ld2 = gt2; sel_2 = 1;
                 NS = st_4;
              end
          
          st_4:
            begin
                mux_c = 2'b01; sel_3 = 0; ld3 = 1; ld2 = 0;
                NS = st_5;
            end
              
          st_5:
              begin
                 mux_c = 2'b01; mux_d = 1;
                 ld3 = gt3; sel_3 = 1;
                 NS = st_6;
              end
              
          st_6:
              begin
                  mux_a = 1; mux_b = 2'b10;
                  ld1 = gt1; sel_1 = 1; ld3 = 0;
                  NS = st_7;
              end
           
          st_7:
             begin
                mux_b = 2'b01; ld2 = 1; sel_2 = 0; ld1 = 0;
                NS = st_8;
             end
             
          st_8:
             begin
                 mux_b = 2'b01; mux_c = 2'b10;
                 ld2 = gt2; sel_2 = 1; 
                 NS = st_9;
             end
           
           st_9:
               begin
                  mux_a = 1; mux_b = 2'b10;
                  ld1 = gt1; sel_1 = 1; ld2 = 0;
                  NS = st_DISPLAY;
               end
            
          st_DISPLAY:
             begin
                mux_a = 1; mux_b = 2'b01; mux_c = 2'b01;
                mux_d = 1; clr = 0; led = 1; ld1 = 0;    
                if (btn == 0)   
                   NS = st_WAIT;  
                else
                   NS = st_DISPLAY;
             end
             
          default: NS = st_WAIT; 
            
          endcase
      end              
endmodule