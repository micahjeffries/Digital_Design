//Module that determines the magnitude of a given input in RC format
module mag(
    input [10:0] A,
    output [10:0] B
    );
    
    //Set up internal wiring
    wire [10:0] NEG_A;
    
    //Generate the negative of the input A
    nb_twos_comp #(.n(11)) TWOS_COMP (
        .a (A),
        .a_min (NEG_A)     );
        
    //The sign bit of the input determines if A or NEG_A will be the output    
    mux_2t1_nb #(.n(11)) MUX (
        .SEL (A[10]),
        .D0 (A),
        .D1 (NEG_A),
        .D_OUT (B)        );
        
endmodule