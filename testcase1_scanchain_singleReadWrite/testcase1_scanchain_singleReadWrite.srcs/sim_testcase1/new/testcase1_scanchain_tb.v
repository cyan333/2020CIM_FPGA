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


module testcase1_scanchain_tb();
reg sys_clk_p; //input to FPGA, coming from on board oscillator
reg sys_clk_n; //input to FPGA, coming from on board oscillator
reg fpga_reset_n;

reg refresh_finish;
reg start_from_fpga;

wire sys_clk;
wire scan_clk;
wire update_clk;
wire chip_reset_n;

//Input array control signals
wire [3:0] ADDR;
wire WE, DRAM_EN, DEC_EN;

//refresh controller
wire start_refresh;

//DAC control signals
wire start_DAC;

//scan chain
wire se;
wire scanin;

testcase1_singleReadWrite_scanChain testcase1_uut(
    .sys_clk_p(sys_clk_p), 
    .sys_clk_n(sys_clk_n), 
    .fpga_reset_n(fpga_reset_n), 
    .refresh_finish(refresh_finish),
    .start_from_fpga(start_from_fpga),
    .sys_clk(sys_clk), 
    .chip_reset_n(chip_reset_n),
    .ADDR(ADDR),
    .WE(WE),
    .DRAM_EN(DRAM_EN),
    .DEC_EN(DEC_EN),
    .start_refresh(start_refresh),
    .start_DAC(start_DAC),
    .se(se),
    .scan_clk(scan_clk), 
    .update_clk(update_clk), 
    .scanin(scanin)
    );


initial sys_clk_p = 1'b1;
always #(2.5) sys_clk_p = ~sys_clk_p;

initial sys_clk_n = 1'b0;
always #(2.5) sys_clk_n = ~sys_clk_n;
    
    
    initial begin
        fpga_reset_n = 1'b1;
        refresh_finish = 1'b0;
        start_from_fpga = 1'b0;
        #5;
        fpga_reset_n = 1'b0;
        #5;
        fpga_reset_n = 1'b1;
        #360
        start_from_fpga = 1'b1;
    
    end
    
    
    
    
    
endmodule
