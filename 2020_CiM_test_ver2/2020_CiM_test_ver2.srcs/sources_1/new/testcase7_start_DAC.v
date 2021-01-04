`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/12/2020 09:54:19 PM
// Design Name: 
// Module Name: testcase7_startDAC
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


module testcase7_start_DAC(
    input sys_clk_n,
    input sys_clk_p,
    input reset,
    output reg start_DAC,
    output reg chip_reset_n,
    output sys_clk
    );
    
    parameter IDLE = 3'd0;
    parameter RESET = 3'd1;
    parameter START = 3'd2;
    
    
    reg [2:0] currentState, nextState;
    reg [3:0] start_counter;
    
    wire clk_10M, locked, clk_100M, clk_50M, clk_500M;
    clk_core clk_core_inst (.clk_in1_p(sys_clk_p), 
                            .clk_in1_n(sys_clk_n), 
                            .reset(reset), 
                            .sys_clk_100M(clk_100M), 
                            .scan_clk_10M(clk_10M), 
                            .locked(locked), 
                            .clk_500M(clk_500M),
                            .clk_50M(clk_50M));
    wire clk_10M_valid;
    assign clk_10M_valid = clk_10M & locked;
    assign sys_clk = clk_100M & locked;
    
    always @ (negedge sys_clk or posedge reset) begin
        if(reset) currentState <= IDLE;
        else currentState <= nextState;
    end
    
    always @ (posedge sys_clk) begin
        case(currentState) 
        IDLE: begin
            chip_reset_n <= 1;
            start_DAC <= 0;
            start_counter <= 0;
            nextState <= RESET;
        end
        RESET: begin
            chip_reset_n <= 0;
            start_DAC <= 0;
            start_counter <= 0;
            nextState <= START;
        end
        START: begin
            chip_reset_n <= 1;
            start_DAC <= 1;
            if(start_counter < 3) begin
                start_counter <= start_counter + 1;
                nextState <= START;
            end
            else begin
                start_counter <= 0;
                nextState <= IDLE;
            end
        end
        
        endcase
    end
    
endmodule
