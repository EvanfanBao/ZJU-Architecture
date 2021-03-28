`timescale 1ns / 1ps

module WbStage (
		input mem2Reg, 	// WM2REG
		input [31:0] memoryData,
		input [31:0] aluOutput,
		output [31:0] registerWriteData
	);

	assign registerWriteData = mem2Reg ? memoryData : aluOutput;
endmodule
