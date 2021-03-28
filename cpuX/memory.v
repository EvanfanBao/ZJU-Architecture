`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:54:46 12/17/2020 
// Design Name: 
// Module Name:    memory 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module memory(
		input cpu_rst,  // cpu reset signal
		input clock,

		input [31:0] addr,
		input [31:0] data,		
		
		input writeMemoryEnable,
		input cs,
		
		output reg ack = 0,
		output [31:0] memoryData
    );
	 //如何使用ack和cs达成同步呢？
	 always@(negedge clock)
	 begin
		if(cs==1)begin
			ack<=1;		
		end
		else begin
			ack<=0;
		end
	 end
	 
	 DataMemory dataMemory(
		.clka(~clock),
		.addra(addr[11:2]),
		.douta(memoryData[31:0]),
		.wea(writeMemoryEnable & ~cpu_rst),
		.dina(data[31:0])
	 );

endmodule
