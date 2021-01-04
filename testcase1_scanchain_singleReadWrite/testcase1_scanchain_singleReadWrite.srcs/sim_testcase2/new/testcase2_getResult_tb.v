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



module testcase2_getResult_tb();

reg dataRdy;
reg data;
reg fpga_reset_n;

testcase2_getResult testcase2_uut (
    .dataRdy(dataRdy),
    .data(data),
    .fpga_reset_n(fpga_reset_n)
);

initial dataRdy = 1'b1;
always #(2.5) dataRdy = ~dataRdy;

    initial begin
    fpga_reset_n = 1'b1;
    data = 1'b1;
    #18
    fpga_reset_n = 1'b0;
    #19
    fpga_reset_n = 1'b1;
    end





endmodule