
module nb_twos_comp(
    input [n-1:0] a,
    output reg [n-1:0] a_min
    );
	
    parameter n = 8;
    
    always @(a)
    begin
       a_min = ~a + 1;    
    end
    
endmodule