`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/05/2020 02:00:25 PM
// Design Name: 
// Module Name: testcase5_top_DACandMAV
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


module testcase5_top_DACandMAV(
input sys_clk_p,
input sys_clk_n,
input fpga_reset,
input startCompute,

output sys_clk,
output chip_reset_n,
////////----MAV----///////
//scan chain
output update_clk_mavArray,
output scanin_mavArray,
output scan_clk_mavArray,
output se_mavArray,
//testchip
input refresh_finish_mavArray,
input requestDatafromMAV,
input start_ADC_fromchip,

output start_ADC_fromOutside,
output [4:0] mavArrayADDR,
output start_refresh_mavArray,
output WE_mavArray, DRAM_EN_mavArray, DEC_EN_mavArray,
output finish_loading_mav,
//to other module

////////----DAC----///////
//scanchain
output update_clk_inputArray,
output scanin_inputArray,
output scan_clk_inputArray,
output se_inputArray,

//testchip
input refresh_finish_inputArray,
input requestDatafromDAC,
input ADC_finish,
input release_Va,
input start_DAC_fromMAV,

output [3:0] inputArrayADDR,
output WE_inputArray, DRAM_EN_inputArray, DEC_EN_inputArray,
output start_refresh_inputArray,
output start_DAC,
output test_enable,
output signORunsign
);

    wire mav_scan_finish;
    wire mav_finish;
    //clock
    wire clk_100M;
    wire clk_10M;
    wire locked;
    wire clk_10M_valid, clk_100M_valid, clk_50M_valid, clk_25M_valid,clk_15M_valid;
    wire clk_50M, clk_25M, clk_15M;
    
    clk_core clk_core_inst (
    .clk_in1_p(sys_clk_p), 
    .clk_in1_n(sys_clk_n), 
    .reset(fpga_reset), 
    .sys_clk_100M(clk_100M), 
    .scan_clk_10M(clk_10M), 
    .locked(locked),
    .clk_50M(clk_50M),
    .clk_25M(clk_25M),
    .clk_15M(clk_15M));
    
    assign clk_100M_valid = clk_100M & locked;
    assign clk_10M_valid = clk_10M & locked;
    assign clk_50M_valid = clk_50M & locked;
    assign clk_25M_valid = clk_25M & locked;
    assign clk_15M_valid = clk_15M & locked;
    //reset
//    assign chip_reset_n = ~fpga_reset; 
    //sys clk
    assign sys_clk = clk_50M_valid;
    wire test_enable_DAC, test_enable_mav;
    assign test_enable = test_enable_mav | test_enable_DAC;
    
    testcase4_MAV tc4_uut(
        .clk_100M_valid(clk_50M_valid),
        .clk_10M_valid(clk_10M_valid),
        .fpga_reset(fpga_reset),
        .startCompute(startCompute),
//        .sys_clk(sys_clk),
//        .chip_reset_n(chip_reset_n),
        .update_clk_mavArray(update_clk_mavArray),
        .scanin_mavArray(scanin_mavArray),
        .scan_clk(scan_clk_mavArray),
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
        .mav_scan_finish(mav_scan_finish),
        .mav_finish(mav_finish),
        .test_enable_mav(test_enable_mav)
    );
   
    testcase3_DAC tc3_uut(
        .clk_100M_valid(clk_50M_valid),
        .clk_10M_valid(clk_10M_valid),
        .fpga_reset(fpga_reset),
        .startCompute(startCompute),
//        .sys_clk(sys_clk),
        .test_enable_DAC(test_enable_DAC),
        .chip_reset_n_DAC(chip_reset_n),  //comment out this line
        .update_clk_inputArray(update_clk_inputArray),
        .scanin_inputArray(scanin_inputArray),
        .scan_clk(scan_clk_inputArray),
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
        .signORunsign(signORunsign),
        .mav_scan_finish(mav_scan_finish),
        .mav_finish(mav_finish)
    );
    
    
    
endmodule
