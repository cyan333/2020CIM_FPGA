`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/10/2020 10:08:06 AM
// Design Name: 
// Module Name: testcase5_top_tb
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


module testcase5_top_tb();

reg sys_clk_p;
reg sys_clk_n;
reg fpga_reset;
reg startCompute;

wire sys_clk;
wire chip_reset_n;
////////----MAV----///////
//scan chain
wire update_clk_mavArray;
wire scanin_mavArray;
wire scan_clk_mavArray;
wire se_mavArray;
//testchip
reg refresh_finish_mavArray;
reg requestDatafromMAV;
reg start_ADC_fromchip;

wire start_ADC_fromOutside;
wire [4:0] mavArrayADDR;
wire start_refresh_mavArray;
wire WE_mavArray, DRAM_EN_mavArray, DEC_EN_mavArray;
wire finish_loading_mav;
//to other module

////////----DAC----///////
//scanchain
wire update_clk_inputArray;
wire scanin_inputArray;
wire scan_clk_inputArray;
wire se_inputArray;

//testchip
reg refresh_finish_inputArray;
reg requestDatafromDAC;
reg ADC_finish;
reg release_Va;
reg start_DAC_fromMAV;

wire [3:0] inputArrayADDR;
wire WE_inputArray, DRAM_EN_inputArray, DEC_EN_inputArray;
wire start_refresh_inputArray;
wire start_DAC;

wire signORunsign;

testcase5_top_DACandMAV tb5_uut(
.sys_clk_p(sys_clk_p),
.sys_clk_n(sys_clk_n),
.fpga_reset(fpga_reset),
.startCompute(startCompute),
.sys_clk(sys_clk),
.chip_reset_n(chip_reset_n),
.update_clk_mavArray(update_clk_mavArray),
.scanin_mavArray(scanin_mavArray),
.scan_clk_mavArray(scan_clk_mavArray),
.se_mavArray(se_mavArray),
.refresh_finish_mavArray(refresh_finish_mavArray),
.requestDatafromMAV(requestDatafromMAV),
.start_ADC_fromchip(start_ADC_fromchip),
.start_ADC_fromOutside(start_ADC_fromOutside),
.mavArrayADDR(mavArrayADDR),
.start_refresh_mavArray(start_refresh_mavArray),
.WE_mavArray(WE_mavArray),
.DRAM_EN_mavArray(DRAM_EN_mavArray),
.DEC_EN_mavArray(DEC_EN_mavArray),
.finish_loading_mav(finish_loading_mav),

.update_clk_inputArray(update_clk_inputArray),
.scanin_inputArray(scanin_inputArray),
.scan_clk_inputArray(scan_clk_inputArray),
.se_inputArray(se_inputArray),
.refresh_finish_inputArray(refresh_finish_inputArray),
.requestDatafromDAC(requestDatafromDAC),
.ADC_finish(ADC_finish),
.release_Va(release_Va),
.start_DAC_fromMAV(start_DAC_fromMAV),
.inputArrayADDR(inputArrayADDR),
.WE_inputArray(WE_inputArray),
.DRAM_EN_inputArray(DRAM_EN_inputArray),
.DEC_EN_inputArray(DEC_EN_inputArray),
.start_refresh_inputArray(start_refresh_inputArray),
.start_DAC(start_DAC),
.signORunsign(signORunsign)
);

initial sys_clk_p = 1'b1;
always #(2.5) sys_clk_p = ~sys_clk_p;

initial sys_clk_n = 1'b0;
always #(2.5) sys_clk_n = ~sys_clk_n;

initial begin
    fpga_reset = 1'b0;
    startCompute = 1'b0;
    refresh_finish_inputArray = 1'b0;
    requestDatafromDAC = 1'b0;
    requestDatafromMAV = 1'b0;
    refresh_finish_mavArray = 1'b0;
    start_ADC_fromchip = 1'b0;
    ADC_finish = 1'b0;
    release_Va = 1'b0;
    start_DAC_fromMAV = 1'b0;
    
    #5;
    fpga_reset = 1'b1;
    #5;
    fpga_reset = 1'b0;
    #360
    startCompute = 1'b1;
    #4600
    requestDatafromDAC = 1'b1;
    #10
    requestDatafromDAC = 1'b0;
    //MAV
    #2000
    requestDatafromMAV = 1'b1;
    #20
    requestDatafromMAV = 1'b0;
    #1000
    start_ADC_fromchip = 1'b1;
    #600
    start_ADC_fromchip = 1'b0;
end


endmodule
