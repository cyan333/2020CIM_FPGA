set_property IOSTANDARD LVDS [get_ports sys_clk_p]
set_property IOSTANDARD LVDS [get_ports sys_clk_n]
set_property IOSTANDARD LVCMOS18 [get_ports {fpga_reset}]
set_property IOSTANDARD LVCMOS18 [get_ports {startCompute}]

set_property IOSTANDARD LVCMOS18 [get_ports {sys_clk}]
set_property IOSTANDARD LVCMOS18 [get_ports {chip_reset_n}]

#MAV
set_property IOSTANDARD LVCMOS18 [get_ports {update_clk_mavArray}]
set_property IOSTANDARD LVCMOS18 [get_ports {scanin_mavArray}]
set_property IOSTANDARD LVCMOS18 [get_ports {scan_clk}]
set_property IOSTANDARD LVCMOS18 [get_ports {se_mavArray}]
set_property IOSTANDARD LVCMOS18 [get_ports {refresh_finish_mavArray}]
set_property IOSTANDARD LVCMOS18 [get_ports {requestDatafromMAV}]
set_property IOSTANDARD LVCMOS18 [get_ports {start_ADC_fromchip}]
set_property IOSTANDARD LVCMOS18 [get_ports {start_ADC_fromOutside}]
set_property IOSTANDARD LVCMOS18 [get_ports {mavArrayADDR[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {mavArrayADDR[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {mavArrayADDR[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {mavArrayADDR[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {mavArrayADDR[4]}]
set_property IOSTANDARD LVCMOS18 [get_ports {start_refresh_mavArray}]
set_property IOSTANDARD LVCMOS18 [get_ports {WE_mavArray}]
set_property IOSTANDARD LVCMOS18 [get_ports {DRAM_EN_mavArray}]
set_property IOSTANDARD LVCMOS18 [get_ports {DEC_EN_mavArray}]
set_property IOSTANDARD LVCMOS18 [get_ports {finish_loading_mav}]


set_property IOSTANDARD LVCMOS18 [get_ports {test_enable}]

#######PACKAGE PIN########
set_property PACKAGE_PIN E19 [get_ports sys_clk_p]
set_property PACKAGE_PIN E18 [get_ports sys_clk_n]
set_property PACKAGE_PIN AV39 [get_ports {fpga_reset}]

#push botton S SW5
set_property PACKAGE_PIN AP40 [get_ports {startCompute}]

set_property PACKAGE_PIN K39 [get_ports {sys_clk}]
set_property PACKAGE_PIN L42 [get_ports {chip_reset_n}]

#MAV
set_property PACKAGE_PIN M32 [get_ports {update_clk_mavArray}]
set_property PACKAGE_PIN G23 [get_ports {scanin_mavArray}]
set_property PACKAGE_PIN J25 [get_ports {scan_clk}]
set_property PACKAGE_PIN H38 [get_ports {se_mavArray}]
set_property PACKAGE_PIN H26 [get_ports {refresh_finish_mavArray}]
set_property PACKAGE_PIN E37 [get_ports {requestDatafromMAV}]
set_property PACKAGE_PIN B37 [get_ports {start_ADC_fromchip}]
set_property PACKAGE_PIN H39 [get_ports {start_ADC_fromOutside}]
set_property PACKAGE_PIN J23 [get_ports {mavArrayADDR[0]}]
set_property PACKAGE_PIN K23 [get_ports {mavArrayADDR[1]}]
set_property PACKAGE_PIN J27 [get_ports {mavArrayADDR[2]}]
set_property PACKAGE_PIN K27 [get_ports {mavArrayADDR[3]}]
set_property PACKAGE_PIN G24 [get_ports {mavArrayADDR[4]}]
set_property PACKAGE_PIN G27 [get_ports {start_refresh_mavArray}]
set_property PACKAGE_PIN H23 [get_ports {WE_mavArray}]
set_property PACKAGE_PIN H25 [get_ports {DRAM_EN_mavArray}]
set_property PACKAGE_PIN G26 [get_ports {DEC_EN_mavArray}]
set_property PACKAGE_PIN B36 [get_ports {finish_loading_mav}]


set_property PACKAGE_PIN F39 [get_ports {test_enable}]


set_property SLEW FAST [get_ports -filter "direction==out"]
set_property DRIVE 16 [get_ports -filter "direction==out"]
set_load 10 [get_ports -filter "direction==out"]

#create_clock -name clock -period 40 -waveform "0 20" 
#set_input_delay -clock [get_clocks clock] 10 [get_ports data_out*]
#set_output_delay -clock [get_clocks clock] 10 [get_ports data_in*]

set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property CFGBVS GND [current_design]
set_property BITSTREAM.CONFIG.BPI_SYNC_MODE Type1 [current_design]
set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN div-1 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS FALSE [current_design]
set_property BITSTREAM.CONFIG.UNUSEDPIN Pulldown [current_design]
set_property CONFIG_MODE BPI16 [current_design]





