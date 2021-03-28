`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   17:21:53 10/29/2020
// Design Name:   Cpu
// Module Name:   C:/labs/cpu20/cpu_test.v
// Project Name:  Cpu
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: Cpu
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////
`include "Constants.vh"
`include "define.vh"
`include "function.vh"

module cpu_test;

  // Inputs
  reg clock;
  reg reset;
  reg debug_en;
  reg debug_step;
  reg [6:0] debug_addr;

  // Outputs
  wire [31:0] debug_data;

  // Instantiate the Unit Under Test (UUT)
  Cpu uut (
    .clock(clock), 
    .reset(reset), 
    .debug_en(debug_en), 
    .debug_step(debug_step), 
    .debug_addr(debug_addr), 
    .debug_data(debug_data)
  );

  initial begin
    // Initialize Inputs
    clock = 0;
    reset = 1;
    debug_en = 1;
    debug_step = 0;
    debug_addr = 0;

    // Wait 100 ns for global reset to finish
    #100;
      reset = 0;  
    // Add stimulus here
	 
	 debug_step = ~debug_step;
	 #1;
	 debug_step = ~debug_step;
	 #20;
	 
	 debug_step = ~debug_step;
	 #1;
	 debug_step = ~debug_step;
	 #20;
	 
	 debug_step = ~debug_step;
	 #1;
	 debug_step = ~debug_step;
	 #20;
	 
	 debug_step = ~debug_step;
	 #1;
	 debug_step = ~debug_step;
	 #20;
	 
	 debug_step = ~debug_step;
	 #1;
	 debug_step = ~debug_step;
	 #20;
	 
	 debug_step = ~debug_step;
	 #1;
	 debug_step = ~debug_step;
	 #20;
	 
	 debug_step = ~debug_step;
	 #1;
	 debug_step = ~debug_step;
	 #20;
	 
	 debug_step = ~debug_step;
	 #1;
	 debug_step = ~debug_step;
	 #20;
	 
	 debug_step = ~debug_step;
	 #1;
	 debug_step = ~debug_step;
	 #20;
	 
	 debug_step = ~debug_step;
	 #1;
	 debug_step = ~debug_step;
	 #20;
	 
	 debug_step = ~debug_step;
	 #1;
	 debug_step = ~debug_step;
	 #20;
	 
	 debug_step = ~debug_step;
	 #1;
	 debug_step = ~debug_step;
	 #20;
	 
	 debug_step = ~debug_step;
	 #1;
	 debug_step = ~debug_step;
	 #20;
	 
	 debug_step = ~debug_step;
	 #1;
	 debug_step = ~debug_step;
	 #20;
	 
	 debug_step = ~debug_step;
	 #1;
	 debug_step = ~debug_step;
	 #20;
	 
	 debug_step = ~debug_step;
	 #1;
	 debug_step = ~debug_step;
	 #20;
	 
	 debug_step = ~debug_step;
	 #1;
	 debug_step = ~debug_step;
	 #20;
	 
	 debug_step = ~debug_step;
	 #1;
	 debug_step = ~debug_step;
	 #20;
	 
	 debug_step = ~debug_step;
	 #1;
	 debug_step = ~debug_step;
	 #20;
	 
	 debug_step = ~debug_step;
	 #1;
	 debug_step = ~debug_step;
	 #20;
	 
	 debug_step = ~debug_step;
	 #1;
	 debug_step = ~debug_step;
	 #20;
	 
	 debug_step = ~debug_step;
	 #1;
	 debug_step = ~debug_step;
	 #20;
	 
	 debug_step = ~debug_step;
	 #1;
	 debug_step = ~debug_step;
	 #20;
	 
	 debug_step = ~debug_step;
	 #1;
	 debug_step = ~debug_step;
	 #20;
	 
	 debug_step = ~debug_step;
	 #1;
	 debug_step = ~debug_step;
	 #20;
	 
	 debug_step = ~debug_step;
	 #1;
	 debug_step = ~debug_step;
	 #20;
	 
	 debug_step = ~debug_step;
	 #1;
	 debug_step = ~debug_step;
	 #20;
	 
	 debug_step = ~debug_step;
	 #1;
	 debug_step = ~debug_step;
	 #20;
    
  
  end
   
  always begin
  forever
  begin
  clock = ~clock;
  #5;  
  end
  end
  
  always begin
  forever
  begin
  debug_addr = debug_addr + 1;
  #11;  
  end
  end
   
endmodule