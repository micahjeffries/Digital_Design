module reg_nb(data_in, clk, clr, ld, data_out); 
    input  [n-1:0] data_in; 
    input  clk, clr, ld; 
    output reg [n-1:0] data_out; 

    parameter n = 8; 
    
    always @(posedge clr, posedge clk)
    begin 
       if (clr == 1)     // asynch clr
          data_out <= 0;
       else if (ld == 1) 
          data_out <= data_in; 
    end
    
endmodule