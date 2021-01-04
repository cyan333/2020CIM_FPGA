`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/26/2020 01:21:56 PM
// Design Name: 
// Module Name: testcase1_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module testcase1_tb();
reg sys_clk_p; //input to FPGA, coming from on board oscillator
reg sys_clk_n; //input to FPGA, coming from on board oscillator
reg fpga_reset_n;

wire sys_clk;
wire scan_clk;
wire update_clk;
wire chip_reset_n;

testcase1_singleReadWrite_scanChain testcase1_uut(sys_clk_p, sys_clk_n, fpga_reset_n, sys_clk, scan_clk, update_clk, chip_reset_n);

initial sys_clk_p = 1'b1;
always #(2.5) sys_clk_p = ~sys_clk_p;

initial sys_clk_n = 1'b0;
always #(2.5) sys_clk_n = ~sys_clk_n;
    
    
    initial begin
        fpga_reset_n = 1'b1;
        #5;
        fpga_reset_n = 1'b0;
        #5;
        fpga_reset_n = 1'b1;
    
    end
    
    
    
    
    
    
    
    
    
    
    
endmodule
