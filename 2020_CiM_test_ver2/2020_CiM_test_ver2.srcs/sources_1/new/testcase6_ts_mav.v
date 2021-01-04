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
    output signORunsign,
    output sys_clk_slow,
//    output clk_10M_valid,
    output ledEN
    );
    
    //parameter
    parameter signORunsign_param = 1'b1;
    parameter [2:0] weight_value = 3'b111;
    
    //state machin
    parameter IDLE = 5'd0,
                MUX = 5'd1,
                MUX1 = 5'd6,
                MUX2 = 5'd7,
                MUX3 = 5'd8,
                MUX4 = 5'd9,
                MUX5 = 5'd10,
                CHARGE_SHARE = 5'd2,
                CHARGE_SHARE1 = 5'd11,
                CHARGE_SHARE2 = 5'd12,
                CHARGE_SHARE3 = 5'd13,
                CHARGE_SHARE4 = 5'd14,
                CHARGE_SHARE5 = 5'd15,
                TEST_ENABLE = 5'd3,
                TEST_ENABLE1 = 5'd16,
                TEST_ENABLE2 = 5'd17,
                RESET = 5'd4,
                RESET_1 = 5'd5;
    
    //reg 
    reg [5:0] currentState, nextState;
    reg [32:0] clk_counter=32'd0;
    parameter DIVISOR = 32'd4;
    reg [2:0] state_count;
    //wire
    wire clk_100M;
    wire clk_10M;
    wire locked;
    wire clk_500M;
    wire clk_50M;
//    wire clk_10M_valid;
        
    clk_core clk_core_inst (.clk_in1_p(sys_clk_p), 
                            .clk_in1_n(sys_clk_n), 
                            .reset(fpga_reset), 
                            .sys_clk_100M(clk_100M), 
                            .scan_clk_10M(clk_10M), 
                            .locked(locked), 
                            .clk_500M(clk_500M),
                            .clk_50M(clk_50M));
    assign sys_clk = clk_100M & locked;
    assign chip_reset_n = ~fpga_reset; 
    assign clk_10M_valid = clk_10M & locked;
    assign signORunsign = signORunsign_param;
    assign weight_test = weight_value;
    
    wire clk_500M_valid, clk_50M_valid;
    assign clk_500M_valid = clk_500M & locked;
    assign clk_50M_valid = clk_50M & locked;
    
    //clock divisor
    always @(posedge clk_10M_valid)
    begin
        clk_counter <= clk_counter + 28'd1;
        if(clk_counter>=(DIVISOR-1))
        clk_counter <= 28'd0;
    end
    
//    wire sys_clk_slow;
    assign sys_clk_slow = (clk_counter<DIVISOR/2)? 1'b0 : 1'b1;
    assign ledEN = sys_clk_slow;
    
    always @ (negedge clk_10M_valid or posedge fpga_reset) begin
        if(fpga_reset) currentState <= IDLE;
        else currentState <= nextState;
    end
    always @ (currentState) begin
        case(currentState)
        IDLE: nextState <= MUX;
        MUX: nextState = MUX1;
        MUX1: nextState = MUX2;
        MUX2: nextState = MUX3;
        MUX3: nextState = MUX4;
        MUX4: nextState = MUX5;
        MUX5: nextState = RESET;
        RESET: nextState = CHARGE_SHARE;
        CHARGE_SHARE: nextState = CHARGE_SHARE1;
        CHARGE_SHARE1: nextState = CHARGE_SHARE2;
        CHARGE_SHARE2: nextState = CHARGE_SHARE3;
        CHARGE_SHARE3: nextState = CHARGE_SHARE4;
        CHARGE_SHARE4: nextState = CHARGE_SHARE5;
        CHARGE_SHARE5: nextState = RESET_1;
        RESET_1: nextState = IDLE;
        TEST_ENABLE: nextState = TEST_ENABLE1;
        TEST_ENABLE1: nextState = TEST_ENABLE2;
        TEST_ENABLE2: nextState = IDLE;
        endcase
    end
    always @ (posedge clk_10M_valid or posedge fpga_reset) begin
        if(fpga_reset) begin
            mav_mux_test <= 0;
            mav_cap_cs_test <= 0;
            test_enable <= 0;
        end
        else begin
        case(currentState)
        IDLE: begin
            state_count <= 0;
            mav_mux_test <= 0;
            mav_cap_cs_test <= 0;
            test_enable <= 0;
        end
        MUX: begin
            mav_mux_test <= 1;
            mav_cap_cs_test <= 0;
            test_enable <= 0;
        end
        MUX1: begin
            mav_mux_test <= 1;
            mav_cap_cs_test <= 0;
            test_enable <= 0;
        end
        MUX2: begin
            mav_mux_test <= 1;
            mav_cap_cs_test <= 0;
            test_enable <= 0;
        end
        MUX3: begin
            mav_mux_test <= 1;
            mav_cap_cs_test <= 0;
            test_enable <= 0;
        end
        MUX4: begin
            mav_mux_test <= 1;
            mav_cap_cs_test <= 0;
            test_enable <= 0;
        end
        MUX5: begin
            mav_mux_test <= 1;
            mav_cap_cs_test <= 0;
            test_enable <= 0;
        end
        RESET: begin
            mav_mux_test <= 0;
            mav_cap_cs_test <= 0;
            test_enable <= 0;
        end
        CHARGE_SHARE: begin
            mav_mux_test <= 0;
            mav_cap_cs_test <= 1;
            test_enable <= 0;
        end
        CHARGE_SHARE1: begin
            mav_mux_test <= 0;
            mav_cap_cs_test <= 1;
            test_enable <= 0;
        end
        CHARGE_SHARE2: begin
            mav_mux_test <= 0;
            mav_cap_cs_test <= 1;
            test_enable <= 0;
        end
        CHARGE_SHARE3: begin
            mav_mux_test <= 0;
            mav_cap_cs_test <= 1;
            test_enable <= 0;
        end
        CHARGE_SHARE4: begin
            mav_mux_test <= 0;
            mav_cap_cs_test <= 1;
            test_enable <= 0;
        end
        CHARGE_SHARE5: begin
            mav_mux_test <= 0;
            mav_cap_cs_test <= 1;
            test_enable <= 0;
        end
        RESET_1: begin
            mav_mux_test <= 0;
            mav_cap_cs_test <= 0;
            test_enable <= 0;
        end
        TEST_ENABLE: begin
            mav_mux_test <= 0;
            mav_cap_cs_test <= 0;
            test_enable <= 1;
        end
        TEST_ENABLE1: begin
            mav_mux_test <= 0;
            mav_cap_cs_test <= 0;
            test_enable <= 1;
        end
        TEST_ENABLE2: begin
            mav_mux_test <= 0;
            mav_cap_cs_test <= 0;
            test_enable <= 1;
        end
        
        endcase
        end
    end
    
    

endmodule
