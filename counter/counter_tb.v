`include "fsm.v"

module counter_tb;
    
    reg RESET;
    reg UP;
    reg EVEN;
    reg ODD;
    reg HOLD;
    reg CLK = 0;

    //Set up internal wiring
    wire [2:0] ns, ps;
    wire [3:0] data_in;

    always #1 CLK = ~CLK;

    assign data_in = {HOLD, ODD, EVEN, UP};

    //FSM that keeps track of the present and next state of the counter
    fsm MY_FSM (
        .reset_n (RESET),
        .x_in (data_in),
        .clk (CLK),
        .NS (ns),
        .PS (ps)       );

    initial begin
        $dumpon;
        $dumpfile("counter_tb.vcd");
        $dumpvars(0, counter_tb);

        RESET = 0; UP = 0; EVEN = 0; ODD = 0; HOLD = 0; #5;
        RESET = 1; UP = 1; EVEN = 0; ODD = 0; HOLD = 0; #5;
        RESET = 1; UP = 0; EVEN = 1; ODD = 0; HOLD = 0; #5;
        RESET = 1; UP = 0; EVEN = 0; ODD = 1; HOLD = 0; #5;
        RESET = 1; UP = 0; EVEN = 0; ODD = 0; HOLD = 1; #5;
        $finish;
    end

endmodule