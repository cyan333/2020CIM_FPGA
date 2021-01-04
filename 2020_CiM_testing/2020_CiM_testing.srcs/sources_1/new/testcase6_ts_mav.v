`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/05/2020 10:33:11 PM
// Design Name: 
// Module Name: testcase6_ts_mav
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


module testcase6_ts_mav(
    input sys_clk_p,
    input sys_clk_n,
    input fpga_reset,
    output chip_reset_n,
    output sys_clk,
    output [2:0] weight_test,

    output reg mav_mux_test,
    output reg mav_cap_cs_test,
    output reg test_enable,
    output signORunsign
    );
    
    //parameter
    parameter signORunsign_param = 1'b0;
    parameter [2:0] weight_value = 3'b111;
    
    //state machin
    parameter IDLE = 3'd0,
                MUX = 3'd1,
                CHARGE_SHARE = 3'd2,
                TEST_ENABLE = 3'd3,
                RESET = 3'd4,
                RESET_1 = 3'd5;
    
    //reg 
    reg [2:0] currentState, nextState;
    reg [27:0] clk_counter=28'd0;
    parameter DIVISOR = 28'd4;
    wire sys_clk_slow;
    
    //wire
    wire clk_100M;
    wire clk_10M;
    wire locked;
    wire clk_10M_valid;
        
    clk_core clk_core_inst (.clk_in1_p(sys_clk_p), .clk_in1_n(sys_clk_n), .reset(fpga_reset), .sys_clk_100M(clk_100M), .scan_clk_10M(clk_10M), .locked(locked));
    assign sys_clk = clk_100M & locked;
    assign chip_reset_n = ~fpga_reset; 
    assign clk_10M_valid = clk_10M & locked;
    
    assign signORunsign = signORunsign_param;
    assign weight_test = weight_value;
    
    //clock divisor
    always @(posedge sys_clk)
    begin
        clk_counter <= clk_counter + 28'd1;
        if(clk_counter>=(DIVISOR-1))
        clk_counter <= 28'd0;
    end
    assign sys_clk_slow = (clk_counter<DIVISOR/2)? 1'b0 : 1'b1;
    
    always @ (negedge clk_10M_valid or posedge fpga_reset) begin
        if(fpga_reset) currentState <= IDLE;
        else currentState <= nextState;
    end
    
    always @ (posedge sys_clk_slow or posedge fpga_reset) begin
        if(fpga_reset) begin
            mav_mux_test <= 0;
            mav_cap_cs_test <= 0;
            test_enable <= 0;
            nextState <= IDLE;
        end
        else begin
        case(currentState)
        IDLE: begin
            mav_mux_test <= 0;
            mav_cap_cs_test <= 0;
            test_enable <= 0;
            nextState <= MUX;
        end
        MUX: begin
            mav_mux_test <= 1;
            mav_cap_cs_test <= 0;
            test_enable <= 0;
            nextState <= RESET;
        end
        RESET: begin
            mav_mux_test <= 0;
            mav_cap_cs_test <= 0;
            test_enable <= 0;
            nextState <= CHARGE_SHARE;
        end
        CHARGE_SHARE: begin
            mav_mux_test <= 0;
            mav_cap_cs_test <= 1;
            test_enable <= 0;
            nextState <= RESET_1;
        end
        RESET_1: begin
            mav_mux_test <= 0;
            mav_cap_cs_test <= 0;
            test_enable <= 0;
            nextState <= TEST_ENABLE;
        end
        TEST_ENABLE: begin
            mav_mux_test <= 0;
            mav_cap_cs_test <= 0;
            test_enable <= 1;
            nextState <= IDLE;
        end
        
        endcase
        end
    end
    
    

endmodule
