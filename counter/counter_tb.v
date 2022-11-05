`timescale 1ns/1ps
`include "counter.v"

module counter_tb;
    
    reg RESET;
    reg UP;
    reg EVEN;
    reg ODD;
    reg HOLD;
    reg CLK = 0;
    wire [7:0] SSEGS;
    wire [3:0] AN;

    always #1 CLK = ~CLK;

    counter cntr (
        .RESET(RESET),
        .UP (UP),
        .EVEN (EVEN),
        .ODD (ODD),
        .HOLD (HOLD),
        .CLK (CLK),
        .SSEGS (SSEGS),
        .AN (AN)
    );

    initial begin
        $dumpon;
        $dumpfile("counter_tb.vcd");
        $dumpvars(0, counter_tb);

        RESET = 1; UP = 0; EVEN = 0; ODD = 0; HOLD = 0; #5;
        RESET = 0; UP = 1; EVEN = 0; ODD = 0; HOLD = 0; #50;
        RESET = 0; UP = 0; EVEN = 1; ODD = 0; HOLD = 0; #5;
        RESET = 0; UP = 0; EVEN = 0; ODD = 1; HOLD = 0; #5;
        RESET = 0; UP = 0; EVEN = 0; ODD = 0; HOLD = 1; #5;
        $finish;
    end

endmodule