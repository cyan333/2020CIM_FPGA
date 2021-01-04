set_property IOSTANDARD LVDS [get_ports sys_clk_p]
set_property IOSTANDARD LVDS [get_ports sys_clk_n]
set_property IOSTANDARD LVCMOS18 [get_ports {reset}]

set_property IOSTANDARD LVCMOS18 [get_ports {sys_clk}]
set_property IOSTANDARD LVCMOS18 [get_ports {chip_reset_n}]
set_property IOSTANDARD LVCMOS18 [get_ports {start_DAC}]

#set_property IOSTANDARD LVCMOS18 [get_ports {requestDatafromDAC}]
#set_property IOSTANDARD LVCMOS18 [get_ports {needToLoadData}]

#set_property IOSTANDARD LVCMOS18 [get_ports {buttonPressed}]
#set_property IOSTANDARD LVCMOS18 [get_ports {buttonIsPressed}]
#set_property IOSTANDARD LVCMOS18 [get_ports {detectRequestData}]
#set_property IOSTANDARD LVCMOS18 [get_ports {haveRecordRequestData}]
#set_property IOSTANDARD LVCMOS18 [get_ports {currentState[0]}]
#set_property IOSTANDARD LVCMOS18 [get_ports {currentState[1]}]
#set_property IOSTANDARD LVCMOS18 [get_ports {currentState[2]}]



#######PACKAGE PIN########
set_property PACKAGE_PIN E19 [get_ports sys_clk_p]
set_property PACKAGE_PIN E18 [get_ports sys_clk_n]
set_property PACKAGE_PIN AV39 [get_ports {reset}]

set_property PACKAGE_PIN K39 [get_ports {sys_clk}]
set_property PACKAGE_PIN L42 [get_ports {chip_reset_n}]

set_property PACKAGE_PIN L41 [get_ports {start_DAC}]
#set_property PACKAGE_PIN J25 [get_ports {requestDatafromDAC}]
#set_property PACKAGE_PIN G32 [get_ports {needToLoadData}]

#set_property PACKAGE_PIN AV30 [get_ports {buttonPressed}]
#set_property PACKAGE_PIN AM39 [get_ports {buttonIsPressed}]
#set_property PACKAGE_PIN H23 [get_ports {detectRequestData}]
#set_property PACKAGE_PIN H26 [get_ports {haveRecordRequestData}]
#set_property PACKAGE_PIN J23 [get_ports {currentState[0]}]
#set_property PACKAGE_PIN G26 [get_ports {currentState[1]}]
#set_property PACKAGE_PIN G27 [get_ports {currentState[2]}]


set_property SLEW FAST [get_ports -filter "direction==out"]
set_property DRIVE 16 [get_ports -filter "direction==out"]
set_load 10 [get_ports -filter "direction==out"]


set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property CFGBVS GND [current_design]
set_property BITSTREAM.CONFIG.BPI_SYNC_MODE Type1 [current_design]
set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN div-1 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS FALSE [current_design]
set_property BITSTREAM.CONFIG.UNUSEDPIN Pulldown [current_design]
set_property CONFIG_MODE BPI16 [current_design]


