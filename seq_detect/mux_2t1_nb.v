module mux_2t1_nb(SEL, D0, D1, D_OUT); 
       input  SEL; 
       input  [n-1:0] D0, D1; 
       output reg [n-1:0] D_OUT;  
       
       parameter n = 8; 
        
       always @(SEL, D0, D1)
       begin 
          if      (SEL == 0)  D_OUT = D0;
          else if (SEL == 1)  D_OUT = D1; 
          else                D_OUT = 0; 
       end
                
endmodule