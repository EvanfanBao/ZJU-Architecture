`timescale 1ns / 1ps

module RegisterFile (

		input clock,
		input reset,

		input [4:0] readAddressA,
		output [31:0] readDataA,
		input [4:0] readAddressB,
		output [31:0] readDataB,

		input shouldWrite,
		input [4:0] writeAddress,
		input [31:0] writeData,

		input wire [4:0] debug_addr,  // debug address
		output wire [31:0] debug_data  // debug data
		
	);

	reg [31:0] registers [1:31];
	integer i;
	initial begin
		for (i = 1; i < 32; i = i + 1) begin
			registers[i] = 0;
		end
	end

	//两个读数据
	assign readDataA = readAddressA == 0 ? 32'b0 : registers[readAddressA];
	assign readDataB = readAddressB == 0 ? 32'b0 : registers[readAddressB];

	//wb写数据
	integer j;
	always @(negedge clock) begin
		if (reset) begin
			for (j = 1; j < 32; j = j + 1) begin
				registers[j] <= 0;
			end
		end else if (shouldWrite && writeAddress != 0) begin
			registers[writeAddress] <= writeData;
		end
	end
	
	assign debug_data = (debug_addr == 0) ? 0 : registers[debug_addr]; //debug数据输出

endmodule
