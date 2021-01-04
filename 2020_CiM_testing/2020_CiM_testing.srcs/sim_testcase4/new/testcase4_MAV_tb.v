module testcase4_MAV_tb();
reg sys_clk_p;
reg sys_clk_n;
reg fpga_reset;
reg startCompute;

wire sys_clk;
wire chip_reset_n;
//scan chain
wire update_clk_mavArray;
wire scanin_mavArray;
wire scan_clk;
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
wire mav_scan_finish;

testcase4_MAV tb4_uut(
.sys_clk_p(sys_clk_p),
.sys_clk_n(sys_clk_n),
.fpga_reset(fpga_reset),
.startCompute(startCompute),
.sys_clk(sys_clk),
.chip_reset_n(chip_reset_n),
.update_clk_mavArray(update_clk_mavArray),
.scanin_mavArray(scanin_mavArray),
.scan_clk(scan_clk),
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
.mav_scan_finish(mav_scan_finish)

);

initial sys_clk_p = 1'b1;
always #(2.5) sys_clk_p = ~sys_clk_p;

initial sys_clk_n = 1'b0;
always #(2.5) sys_clk_n = ~sys_clk_n;

initial begin
fpga_reset = 1'b0;
startCompute = 1'b0;
refresh_finish_mavArray = 1'b0;
requestDatafromMAV = 1'b0;
start_ADC_fromchip = 1'b0;
#5;
fpga_reset = 1'b1;

#5;
fpga_reset = 1'b0;
#360;
startCompute = 1'b1;

#3500
requestDatafromMAV = 1'b1;
#20
requestDatafromMAV = 1'b0;
#1000
start_ADC_fromchip = 1'b1;
#600
start_ADC_fromchip = 1'b0;
#1000
requestDatafromMAV = 1'b1;
#20
requestDatafromMAV = 1'b0;
end






endmodule