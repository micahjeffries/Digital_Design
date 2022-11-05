module rca_nb(
    input [n-1:0] a,
    input [n-1:0] b,
    input cin,
    output reg [n-1:0] sum,
    output reg co
    );
	
    parameter n = 8;
    
    always @(a,b,cin)
    begin
       {co,sum} = a + b + cin;    
    end
    
endmodule