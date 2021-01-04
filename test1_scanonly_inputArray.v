module test1_scanonly_inputArray( 
CLK, 
ADDR,  
WE,
DRAM_EN, 
DEC_EN, 
refresh_finish, 
start_refresh, 
start_DAC, 
se, 
scan_clk, 
update_clk, 
scanin, 
scanclk_out);

/////Input Ports//////
//Clock port
input CLK;

//Scan 
input scan_clk;
output se, update_clk, scanin, scanclk_out

//Control port for input array
input start;

//Refresh Controller
input refresh_finish, requestDatafromDAC, requestData_fromMAV, ADC_finish





