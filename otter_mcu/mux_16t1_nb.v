
module mux_16t1_nb(SEL, D0, D1, D2, D3, D4, D5, D6, D7, D8, D9, D10, D11, D12, D13, D14, D15, D_OUT); 
       input  [3:0] SEL; 
       input  [n-1:0] D0, D1, D2, D3, D4, D5, D6, D7, D8, D9, D10, D11, D12, D13, D14, D15; 
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
		     8:  D_OUT = D8;
             9:  D_OUT = D9;
             10:  D_OUT = D10;
             11:  D_OUT = D11;
             12:  D_OUT = D12;
             13:  D_OUT = D13;
             14:  D_OUT = D14;
             15:  D_OUT = D15;
			 default: D_OUT = 0; 
		  endcase 
       end
                
endmodule