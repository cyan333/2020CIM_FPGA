set_property IOSTANDARD LVDS [get_ports sys_clk_p]
set_property IOSTANDARD LVDS [get_ports sys_clk_n]
set_property IOSTANDARD LVCMOS18 [get_ports {fpga_reset}]
set_property IOSTANDARD LVCMOS18 [get_ports {chip_reset_n}]
set_property IOSTANDARD LVCMOS18 [get_ports {sys_clk}]
set_property IOSTANDARD LVCMOS18 [get_ports {weight_test[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {weight_test[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {weight_test[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {mav_mux_test}]
set_property IOSTANDARD LVCMOS18 [get_ports {mav_cap_cs_test}]
set_property IOSTANDARD LVCMOS18 [get_ports {test_enable}]
set_property IOSTANDARD LVCMOS18 [get_ports {signORunsign}]

set_property IOSTANDARD LVCMOS18 [get_ports {sys_clk_slow}]



set_property PACKAGE_PIN E19 [get_ports sys_clk_p]
set_property PACKAGE_PIN E18 [get_ports sys_clk_n]
set_property PACKAGE_PIN AV39 [get_ports {fpga_reset}]

set_property PACKAGE_PIN L42 [get_ports {chip_reset_n}]
set_property PACKAGE_PIN K39 [get_ports {sys_clk}]
set_property PACKAGE_PIN A39 [get_ports {weight_test[0]}]
set_property PACKAGE_PIN B39 [get_ports {weight_test[1]}]
set_property PACKAGE_PIN C34 [get_ports {weight_test[2]}]
set_property PACKAGE_PIN B32 [get_ports {mav_mux_test}]
set_property PACKAGE_PIN E39 [get_ports {mav_cap_cs_test}]
set_property PACKAGE_PIN F39 [get_ports {test_enable}]
set_property PACKAGE_PIN K42 [get_ports {signORunsign}]

set_property PACKAGE_PIN K32 [get_ports {sys_clk_slow}]

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





