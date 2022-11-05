module mux_8t1_nb(SEL, D0, D1, D2, D3, D4, D5, D6, D7, D_OUT); 
       input  [2:0] SEL; 
       input  [n-1:0] D0, D1, D2, D3, D4, D5, D6, D7; 
       output reg [n-1:0] D_OUT;  
       
       parameter n = 8; 
        
       always @(*)
       begin 
          case (SEL)
		     0:  D_OUT = D0;
		     1:  D_OUT = D1;
		     2:  D_OUT = D2;
		     3:  D_OUT = D3;
		     4:  D_OUT = D4;
		     5:  D_OUT = D5;
		     6:  D_OUT = D6;
		     7:  D_OUT = D7;
			 default: D_OUT = 0; 
		  endcase 
       end
                
endmodule