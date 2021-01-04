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


module testcase6_tb();
    reg sys_clk_p;
    reg sys_clk_n;
    reg fpga_reset;
    wire chip_reset_n;
    wire sys_clk;
    wire [2:0] weight_test;

    wire mav_mux_test;
    wire mav_cap_cs_test;
    wire test_enable;
    wire signORunsign;
    wire sys_clk_slow;
    wire ledEN;

testcase6_ts_mav tb6_uut(
    .sys_clk_p(sys_clk_p),
    .sys_clk_n(sys_clk_n),
    .fpga_reset(fpga_reset),
    .chip_reset_n(chip_reset_n),
    .sys_clk(sys_clk),
    .weight_test(weight_test),
    .mav_mux_test(mav_mux_test),
    .mav_cap_cs_test(mav_cap_cs_test),
    .test_enable(test_enable),
    .signORunsign(signORunsign),
    .sys_clk_slow(sys_clk_slow),
    .ledEN(ledEN)
);

initial sys_clk_p = 1'b1;
always #(2.5) sys_clk_p = ~sys_clk_p;

initial sys_clk_n = 1'b0;
always #(2.5) sys_clk_n = ~sys_clk_n;

initial begin
    fpga_reset = 1'b0;
    #5;
    fpga_reset = 1'b1;
    #5;
    fpga_reset = 1'b0;
    

end

endmodule