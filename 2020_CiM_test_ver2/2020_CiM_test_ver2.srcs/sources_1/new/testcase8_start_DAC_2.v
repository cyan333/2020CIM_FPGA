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


module testcase8_start_DAC_2(
    input sys_clk_n,
    input sys_clk_p,
    input reset,
    output reg start_DAC,
    output reg chip_reset_n,
    output sys_clk,
    input requestDatafromDAC,
    output reg needToLoadData,
    input buttonPressed,
    output reg buttonIsPressed,
    output reg detectRequestData,
    output reg haveRecordRequestData
    );

    parameter IDLE = 4'b0000;
    parameter RESET = 4'd1;
    parameter START = 4'd2;
    parameter WAIT_FOR_NEXT_ROUND = 4'd4;
    
    
    reg [3:0] nextState, currentState;
    reg [8:0] start_counter;
    reg [8:0] idle_counter;
    
    
    wire clk_10M, locked, clk_100M, clk_50M, clk_500M;
    clk_core clk_core_inst (.clk_in1_p(sys_clk_p), 
                            .clk_in1_n(sys_clk_n), 
                            .reset(reset), 
                            .sys_clk_100M(clk_100M), 
                            .scan_clk_10M(clk_10M), 
                            .locked(locked), 
                            .clk_500M(clk_500M),
                            .clk_50M(clk_50M));
    wire clk_10M_valid, clk_500M_valid;
    assign clk_10M_valid = clk_10M & locked;
    assign sys_clk = clk_100M & locked;
    assign clk_500M_valid = clk_500M & locked;
    assign clk_50M_valid = clk_50M & locked;
       
    always @ (posedge clk_500M_valid or posedge reset) begin
        if (reset) begin
            detectRequestData <= 0;
        end
        else begin
            //use faster clock to detect signal - requestDatafromDAC
            if(requestDatafromDAC) begin
                detectRequestData <= 1;
            end
            else begin
                detectRequestData <= 0;
                
            end
            if(buttonPressed) buttonIsPressed <= 1;
            else buttonIsPressed <= 0; 
        end
    end
    
    always @ (negedge sys_clk or posedge reset) begin
        if(reset) currentState <= IDLE;
        else currentState <= nextState;
    end
    
    always @ (currentState or idle_counter or start_counter) begin
        case(currentState)
        IDLE: begin
            if(idle_counter < 30) begin
               nextState = IDLE;
            end
            else begin
                nextState = RESET;
            end
        end
        RESET: begin
            nextState = START;
        end
        START: begin
            if(haveRecordRequestData) nextState = IDLE;
            else nextState = WAIT_FOR_NEXT_ROUND;
            
        end
        
        WAIT_FOR_NEXT_ROUND: begin
            if(start_counter < 19) begin
                nextState = WAIT_FOR_NEXT_ROUND;
            end
            else begin
                nextState = START;
            end
        end
        endcase
    end
    
    always @ (posedge sys_clk or posedge reset) begin
    if(reset) begin
        idle_counter <= 0;
    end
    else begin
        case(currentState) 
        IDLE: begin
            haveRecordRequestData <= 0;
            chip_reset_n <= 1;
            start_DAC <= 0;
            start_counter <= 0;
            if(idle_counter < 30) begin
                idle_counter <= idle_counter + 1;
            end
            else begin
                idle_counter <= 0;
            end
        end
        RESET: begin
            haveRecordRequestData <= 0;
            chip_reset_n <= 0;
            start_DAC <= 0;
            start_counter <= 0;
            
        end
        START: begin
            chip_reset_n <= 1;
            start_DAC <= 1;
            
        end
    
        WAIT_FOR_NEXT_ROUND: begin	
            start_DAC <= 0;
            if(start_counter < 19) begin
                start_counter <= start_counter + 1;
            end
            else begin
                start_counter <= 0;
                haveRecordRequestData <= 1;
            end
//            start_DAC <= 0;
//            if(detectRequestData==1 && haveRecordRequestData == 0) begin
//                nextState <= START;
//                haveRecordRequestData <= 1;
//                start_counter <= 0;
//            end
//            else nextState <= WAIT_FOR_NEXT_ROUND;
	   end
        endcase
    end
    end

endmodule