//--------------------------------------------------------------------
//- Module: clk_divider
//-
//- Description: parameterized clock divder
//- 
//- USAGE:  (example overrides width default)
//- 
//-      rca_nb #(16) MY_RCA (
//-          .clockin (my_clk_in), 
//-          .clockout (my_clk_out)
//-          );  
//--------------------------------------------------------------------
module clk_divider(clockin, clockout); 
    input clockin; 
    output wire clockout; 

    parameter n = 13; 
    reg [n:0] count; 

    always@(posedge clockin) 
    begin 
        count <= count + 1; 
    end 

    assign clockout = count[n]; 
endmodule 