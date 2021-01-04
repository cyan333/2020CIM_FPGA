`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/02/2020 11:01:30 AM
// Design Name: 
// Module Name: testcase4_MAV
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


module testcase6_adc(
input sys_clk_p,
input sys_clk_n,
input fpga_reset,
input startCompute,

output sys_clk,
output reg chip_reset_n,
//scan chain
output update_clk_mavArray,
output scanin_mavArray,
output scan_clk,
output se_mavArray,

//testchip
input refresh_finish_mavArray,
input requestDatafromMAV,
input start_ADC_fromchip,

output reg start_ADC_fromOutside,
output [4:0] mavArrayADDR,
output reg start_refresh_mavArray,
output WE_mavArray, DRAM_EN_mavArray, DEC_EN_mavArray,
output reg finish_loading_mav,
//to other module

output reg test_enable
);

    //define MAV array parameter
    parameter maxCol_mavArray = 10'd550;
    parameter maxRow_mavArray = 3'd1;
    parameter mavArray = 1; //mav=1; inputarray = 0;
    reg writeORread_mavArray;
    parameter loadThisManyRowForComputation_mavArray = 3'd1;
    
    //state machine
    parameter IDLE = 4'd0;
    parameter SCAN_DATA_TO_MAV_ARRAY = 4'd1;
    parameter ADC_RESET = 4'd2;
    parameter ADC_START = 4'd3;
    parameter WAIT_FOR_NEXT_ROUND = 4'd4;
    parameter RESET = 4'd5;
    parameter MAV_FINISHED = 4'd6;
    parameter START_ADC = 4'd7;
    parameter WAIT_TO_START_ADC = 4'd8;
    parameter TEST_READ_RESET = 4'd9;
    parameter DISABLE_START_SCAN = 4'd12;
    
    //reg
    reg [3:0] currentState, nextState;
    reg [3:0] start_ADC_counter;
    reg startScan_mavArray;
    reg [4:0] currentMavArrayRow;
    reg [4:0] mavArrayADDR_fromTop;
    reg WE_fromTop_mavArray, DRAM_EN_fromTop_mavArray, DEC_EN_fromTop_mavArray;
    
    reg [8:0] wait_counter;
    reg [8:0] idle_counter, adc_counter, adc_wait_counter, scan_counter;
    reg [9:0] test_counter;
    //Wire
    wire [4:0] mavArrayADDR_fromScan;
    wire scan_clk_EN_mavArray, update_clk_EN_mavArray;
    wire all_scan_done;
    wire WE_fromScan_mavArray, DRAM_EN_fromScan_mavArray, DEC_EN_fromScan_mavArray;
    
    //wire
    wire clk_100M;
    wire clk_10M;
    wire locked;
    wire clk_10M_valid;
    //wire sys_clk;
    wire clk_50M, clk_25M, clk_15M;
    clk_core clk_core_inst (
    .clk_in1_p(sys_clk_p), 
    .clk_in1_n(sys_clk_n), 
    .reset(fpga_reset), 
    .sys_clk_100M(clk_100M), 
    .scan_clk_10M(clk_10M), 
    .locked(locked),
    .clk_50M(clk_50M),
    .clk_25M(clk_25M),
    .clk_15M(clk_15M));  
    
    assign clk_100M_valid = clk_100M & locked;
    assign clk_10M_valid = clk_10M & locked;
    assign sys_clk = clk_50M_valid;
    
    assign scan_clk = scan_clk_EN_mavArray & clk_10M_valid;
    assign clk_50M_valid = clk_50M & locked;
    assign update_clk_mavArray = clk_10M_valid & update_clk_EN_mavArray;
    
    assign mav_scan_finish = all_scan_done;
    
    scan_module scan_mavArray(
        .sys_clk(sys_clk),
        .scan_clk(clk_10M_valid),
        .reset(fpga_reset),
        .startScan(startScan_mavArray),
        .maxCol(maxCol_mavArray),
        .maxRow(maxRow_mavArray),
        .inputArrayORkernelArray(mavArray),
        .writeORread(writeORread_mavArray),
        .update_clk(update_clk_mavArray),
        .se(se_mavArray),
        .scanin(scanin_mavArray),
        .scan_clk_EN(scan_clk_EN_mavArray),
        .update_clk_EN(update_clk_EN_mavArray),
        .all_scan_done(all_scan_done),
        .mavArrayADDR(mavArrayADDR_fromScan),
        .WE(WE_fromScan_mavArray),
        .DRAM_EN(DRAM_EN_fromScan_mavArray),
        .DEC_EN(DEC_EN_fromScan_mavArray)
    );
    
    assign WE_mavArray = WE_fromTop_mavArray | WE_fromScan_mavArray;
    assign DRAM_EN_mavArray = DRAM_EN_fromTop_mavArray | DRAM_EN_fromScan_mavArray;
    assign DEC_EN_mavArray = DEC_EN_fromScan_mavArray | DEC_EN_fromTop_mavArray;
    assign mavArrayADDR = mavArrayADDR_fromScan | mavArrayADDR_fromTop;
    
    always @ (negedge sys_clk or posedge fpga_reset) begin
        if(fpga_reset) currentState <= IDLE;
        else currentState <= nextState;
    end
    
    always @ (currentState or startCompute or test_counter or scan_counter or adc_wait_counter or adc_counter or all_scan_done or requestDatafromMAV or wait_counter or idle_counter) begin
    case(currentState)
    IDLE: begin
        if(idle_counter < 100) begin
           nextState = IDLE;
        end
        else begin
            nextState = SCAN_DATA_TO_MAV_ARRAY;
        end
    end

    SCAN_DATA_TO_MAV_ARRAY: begin
        if(scan_counter < 10) begin
            nextState = SCAN_DATA_TO_MAV_ARRAY;
        end
        else begin
            nextState = DISABLE_START_SCAN;
        end
//        if(all_scan_done) nextState = WAIT_FOR_REQUEST_DATA_FROM_MAV;
//        else nextState = SCAN_DATA_TO_MAV_ARRAY;
    end
    //////////////////////////
    DISABLE_START_SCAN: begin
        if(all_scan_done) nextState = ADC_RESET; ///CHANGE HERE!!!
        else nextState = DISABLE_START_SCAN;
    end
    ADC_RESET: begin
        nextState = ADC_START;
    end
    ADC_START: begin
        if(test_counter < 5900) begin
            nextState = ADC_START;
        end
        else begin
            nextState = IDLE;
        end
    end
   
    endcase
    
    end
    
    always @ (posedge sys_clk or posedge fpga_reset) begin
        if(fpga_reset) begin
            WE_fromTop_mavArray <= 0;
            DRAM_EN_fromTop_mavArray <= 0;
            DEC_EN_fromTop_mavArray <= 0;
            start_refresh_mavArray <= 0;
            mavArrayADDR_fromTop <= 0;
            startScan_mavArray <= 0;
            currentMavArrayRow <= 0;
            finish_loading_mav <= 0;
            wait_counter <= 0;
            adc_wait_counter <= 0;
            adc_counter <= 0;
            start_ADC_fromOutside <= 1'b0;
            writeORread_mavArray <= 0; 
            scan_counter <= 0;
            test_enable <= 0;
            chip_reset_n <= 1;
            test_counter <= 0;
            
        end
        else begin
        case(currentState)
        IDLE: begin
            start_ADC_fromOutside <= 1'b0;
            WE_fromTop_mavArray <= 0;
            DRAM_EN_fromTop_mavArray <= 0;
            DEC_EN_fromTop_mavArray <= 0;
            start_refresh_mavArray <= 0;
            mavArrayADDR_fromTop <= 0;
            startScan_mavArray <= 0;
            currentMavArrayRow <= 0;
            finish_loading_mav <= 0;
            adc_counter <= 0;
            writeORread_mavArray <= 0; 
            adc_wait_counter <= 0;
            scan_counter <= 0;
            if(idle_counter < 100) begin
                idle_counter <= idle_counter + 1;
            end
            else begin
                idle_counter <= 0;
            end
            chip_reset_n <= 1;
            test_enable <= 0;
            test_counter <= 0;
        end
        SCAN_DATA_TO_MAV_ARRAY: begin
             startScan_mavArray <= 1;
             mavArrayADDR_fromTop <= 0;   
             writeORread_mavArray <= 0;       
             if(scan_counter < 10) begin
                scan_counter <= scan_counter + 1;
            end
            else begin
                scan_counter <= 0;
            end
        end
        //testing
        DISABLE_START_SCAN: begin
            scan_counter <= 0;
            startScan_mavArray <= 0;
        end
        
        ///// TEST //////
        ADC_RESET: begin
            chip_reset_n <= 0;
            test_enable <= 0;
        end
        ADC_START: begin
            chip_reset_n <= 1;
            test_enable <= 1;
            if(test_counter < 5900) begin
                test_counter <= test_counter+1;
            end
            else begin
                test_counter <= 0;
            end
        end
        
        endcase
        end
    
    end



endmodule





