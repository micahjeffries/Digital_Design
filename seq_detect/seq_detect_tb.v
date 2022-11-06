`include "seq_detect.v"

module seq_detect_tb;

    reg btn, x, clk = 0;
    wire z;

    always #1 clk = ~clk;

    seq_detect DUT (
        .clk(clk),
        .btn(btn),
        .x(x),
        .z(z)
    ); 

    initial begin
        $dumpon;
        $dumpfile("seq_detect_tb.vcd");
        $dumpvars(0,seq_detect_tb);

        #2;
        btn = 1;
        x = 1; #2; x = 1; #2; x = 0; #2; x = 0; #2; x = 1; #2; x = 0; #2;

        btn = 0;
        x = 1; #2; x = 1; #2; x = 0; #2; x = 1; #2; x = 1; #2; x = 0; #4;

        $finish;
    end

endmodule