module mux_4t1_nb(SEL, D0, D1, D2, D3, D_OUT); 
       input  [1:0] SEL; 
       input  [n-1:0] D0, D1, D2, D3; 
       output reg [n-1:0] D_OUT;  
       
       parameter n = 8; 
        
       always @(*)
       begin 
          case (SEL) 
          0:      D_OUT = D0;
          1:      D_OUT = D1;
          2:      D_OUT = D2;
          3:      D_OUT = D3;
          default D_OUT = 0;
          endcase 
	   end
                
endmodule