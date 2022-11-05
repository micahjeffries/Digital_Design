module comp_nb(a, b, eq, lt, gt); 
    input  [n-1:0] a,b; 
    output reg eq, lt, gt; 
  
    parameter n = 8;
    
    always @ (a,b)
    begin      
       if (a == b)
       begin     
          eq = 1; lt = 0;  gt = 0;   
       end
       else if (a > b)   
       begin     
          eq = 0; lt = 0;  gt = 1; 
       end
       else if (a < b)  
       begin     
          eq = 0; lt = 1;  gt = 0; end
       else
       begin     
          eq = 0; lt = 0;  gt = 0; 
       end  
    end 

endmodule
