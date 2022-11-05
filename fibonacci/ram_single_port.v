module ram_single_port (
	input wire [m-1:0] data_in,
	input wire [n-1:0] addr,
	input wire we, 
	input wire clk,
	output wire [m-1:0] data_out  );

    parameter n = 6;   // address bus width
	parameter m = 8;   // data bus width
	
	// Declare the memory variable
	reg [m-1:0] memory[2**n-1:0];
	
    // synchronous write
	always @ (posedge clk)
	begin
		if (we)
			memory[addr] <= data_in;
	end
  
    // asynchronous reads
	assign data_out = memory[addr];
	
endmodule