`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/10/2020 10:08:06 AM
// Design Name: 
// Module Name: testcase3_DAC_tb
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


module testcase3_DAC_tb();

reg sys_clk_p;
reg sys_clk_n;
reg fpga_reset;
reg startCompute;

reg refresh_finish_inputArray;
reg requestDatafromDAC;
reg requestDatafromMAV;
reg ADC_finish;
reg release_Va;
reg start_DAC_fromMAV;

reg mav_scan_finish;

wire [3:0] inputArrayADDR;
wire WE_inputArray;
wire DRAM_EN_inputArray;
wire DEC_EN_inputArray;
wire start_refresh_inputArray;
wire start_DAC;
wire signORunsign;

wire sys_clk;
wire chip_reset_n;

//scan chain
wire update_clk_inputArray;
wire scanin_inputArray;
wire scan_clk;
wire se_inputArray;

testcase3_DAC tb3_uut(
    .sys_clk_p(sys_clk_p),
    .sys_clk_n(sys_clk_n),
    .fpga_reset(fpga_reset),
    .startCompute(startCompute),
    .sys_clk(sys_clk),
    .chip_reset_n(chip_reset_n),
    .update_clk_inputArray(update_clk_inputArray),
    .scanin_inputArray(scanin_inputArray),
    .scan_clk(scan_clk),
    .se_inputArray(se_inputArray),
    .refresh_finish_inputArray(refresh_finish_inputArray),
    .requestDatafromDAC(requestDatafromDAC),
    .requestDatafromMAV(requestDatafromMAV),
    .ADC_finish(ADC_finish),
    .release_Va(release_Va),
    .start_DAC_fromMAV(start_DAC_fromMAV),
    .inputArrayADDR(inputArrayADDR),
    .WE_inputArray(WE_inputArray),
    .DRAM_EN_inputArray(DRAM_EN_inputArray),
    .DEC_EN_inputArray(DEC_EN_inputArray),
    .start_refresh_inputArray(start_refresh_inputArray),
    .start_DAC(start_DAC),
    .signORunsign(signORunsign),
    .mav_scan_finish(mav_scan_finish)
    
);

initial sys_clk_p = 1'b1;
always #(2.5) sys_clk_p = ~sys_clk_p;

initial sys_clk_n = 1'b0;
always #(2.5) sys_clk_n = ~sys_clk_n;

    initial begin
        mav_scan_finish = 1'b1;
        fpga_reset = 1'b0;
        startCompute = 1'b0;
        refresh_finish_inputArray = 1'b0;
        requestDatafromDAC = 1'b0;
        requestDatafromMAV = 1'b0;
        ADC_finish = 1'b0;
        release_Va = 1'b0;
        start_DAC_fromMAV = 1'b0;
        #5;
        fpga_reset = 1'b1;
        #5;
        fpga_reset = 1'b0;
        #360
        startCompute = 1'b1;
        #3600
        requestDatafromDAC = 1'b1;
        #10
        requestDatafromDAC = 1'b0;
        
    end

endmodule
