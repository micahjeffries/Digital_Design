module usr_nb(data_in, dbit, sel, clk, clr, data_out); 
    input  wire [n-1:0] data_in; 
    input  wire dbit; 
    input  wire clk;  
	input  wire clr; 
    input  wire [1:0] sel; 
    output reg [n-1:0] data_out; 

    parameter n = 8; 
    
    always @(posedge clr, posedge clk)
    begin 
        if (clr == 1)     // asynch reset
           data_out <= 0;
        else 
           case (sel) 
              0: data_out <= data_out;                // hold value
              1: data_out <= data_in;                 // load
              2: data_out <= {data_out[n-2:0],dbit};  // shift left
              3: data_out <= {dbit,data_out[n-1:1]};  // shift right
              default data_out <= 0; 
           endcase 
    end
    
endmodule
