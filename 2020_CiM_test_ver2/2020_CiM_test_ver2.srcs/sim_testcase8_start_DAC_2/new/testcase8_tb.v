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

module testcase8_tb();
    reg sys_clk_n;
    reg sys_clk_p;
    reg reset;
    reg requestDatafromDAC;
    wire start_DAC;
    wire chip_reset_n;
    wire sys_clk;
    wire needToLoadData;
    wire detectRequestData;
    
    testcase8_start_DAC_2 tb7_uut(
    .sys_clk_n(sys_clk_n),
    .sys_clk_p(sys_clk_p),
    .reset(reset),
    .start_DAC(start_DAC),
    .chip_reset_n(chip_reset_n),
    .sys_clk(sys_clk),
    .requestDatafromDAC(requestDatafromDAC),
    .needToLoadData(needToLoadData),
    .detectRequestData(detectRequestData)
    );
    
    initial sys_clk_p = 1'b1;
    always #(2.5) sys_clk_p = ~sys_clk_p;
    
    initial sys_clk_n = 1'b0;
    always #(2.5) sys_clk_n = ~sys_clk_n;

    initial begin
        reset = 1'b0;
        requestDatafromDAC = 0;
        #5;
        reset = 1'b1;
        #5;
        reset = 1'b0;
        #800
        requestDatafromDAC = 1;
        #20
        requestDatafromDAC = 0;
        #2100
        requestDatafromDAC = 1;
        #20
        requestDatafromDAC = 0;
        

    
    end

endmodule