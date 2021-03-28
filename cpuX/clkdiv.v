`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:16:15 10/28/2019 
// Design Name: 
// Module Name:    clkdiv 
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
module clkdiv(input clk,
				  input rst,
				  output reg[31:0]clkdiv
				  );
//clock divider
	always @ (posedge clk or posedge rst) begin
		if(rst) clkdiv <= 0;
		else clkdiv <= clkdiv + 1'b1;
	end

endmodule
