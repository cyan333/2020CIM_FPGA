`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/25/2020 10:19:10 PM
// Design Name: 
// Module Name: clk_core_tb
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

`define clk_period 5

module clk_core_tb();

 wire        sys_clk_100M;
 wire        scan_clk_10M;
 reg         reset;
 wire        locked;
 reg         clk_in1_p;
 reg         clk_in1_n;

clk_core clk_core_clk_wiz_uut ( sys_clk_100M, scan_clk_10M, reset, locked, clk_in1_p, clk_in1_n );

initial clk_in1_p = 1'b1;
always #(2.5) clk_in1_p = ~clk_in1_p;

initial clk_in1_n = 1'b0;
always #(2.5) clk_in1_n = ~clk_in1_n;

initial begin
    reset = 1'b1;
    #(`clk_period);
    reset = 1'b0;
    #(`clk_period);

end

endmodule
