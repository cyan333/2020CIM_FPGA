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


module testcase4_MAV(
input sys_clk_p,
input sys_clk_n,
input fpga_reset,
input startCompute,

output sys_clk,
output chip_reset_n,
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
output mav_scan_finish
);

    //define MAV array parameter
    parameter maxCol_mavArray = 3'd4;
    parameter maxRow_mavArray = 3'd4;
    parameter mavArray = 1; //mav=1; inputarray = 0;
    parameter writeORread_mavArray = 0;
    parameter loadThisManyRowForComputation_mavArray = 3'd3;
    //state machine
    parameter IDLE = 3'd0;
    parameter SCAN_DATA_TO_MAV_ARRAY = 3'd1;
    parameter WAIT_FOR_REQUEST_DATA_FROM_MAV = 3'd2;
    parameter START_READ = 3'd3;
    parameter WAIT_FOR_NEXT_ROUND = 3'd4;
    
    //reg
    reg [2:0] currentState, nextState;
    reg [3:0] start_ADC_counter;
    reg startScan_mavArray;
    reg [4:0] currentMavArrayRow;
    reg [4:0] mavArrayADDR_fromTop;
    reg WE_fromTop_mavArray, DRAM_EN_fromTop_mavArray, DEC_EN_fromTop_mavArray;
    reg haveRecordRequestData;
    reg [1:0] finish_loading_counter;
    reg start_WAIT_state, start_READ_state;
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
        
    clk_core clk_core_inst (.clk_in1_p(sys_clk_p), .clk_in1_n(sys_clk_n), .reset(fpga_reset), .sys_clk_100M(clk_100M), .scan_clk_10M(clk_10M), .locked(locked));
    assign sys_clk = clk_100M & locked;
    assign scan_clk = scan_clk_EN_mavArray & clk_10M & locked;
    assign chip_reset_n = ~fpga_reset; 
    assign update_clk_mavArray = clk_10M_valid & update_clk_EN_mavArray;
    assign clk_10M_valid = clk_10M & locked;
    
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
    
    always @ (currentState or startCompute or all_scan_done or start_READ_state or start_WAIT_state or requestDatafromMAV) begin
    case(currentState)
    IDLE: begin
        if(startCompute) begin
            nextState = SCAN_DATA_TO_MAV_ARRAY;
        end
        else nextState = IDLE;
    end
    SCAN_DATA_TO_MAV_ARRAY: begin
        if(all_scan_done) nextState = WAIT_FOR_REQUEST_DATA_FROM_MAV;
        else nextState = SCAN_DATA_TO_MAV_ARRAY;
    end
    WAIT_FOR_REQUEST_DATA_FROM_MAV: begin
        if(start_READ_state) nextState = START_READ;
        else nextState = WAIT_FOR_REQUEST_DATA_FROM_MAV;
    end
    START_READ: begin
        if(start_WAIT_state == 1) nextState = WAIT_FOR_NEXT_ROUND; 
        else nextState = START_READ;
    end
    WAIT_FOR_NEXT_ROUND: begin
        if(currentMavArrayRow == loadThisManyRowForComputation_mavArray - 1) nextState = IDLE;
        else begin
            if(start_READ_state) nextState = START_READ;
            else nextState = WAIT_FOR_NEXT_ROUND;
            
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
            haveRecordRequestData <= 0;
            currentMavArrayRow <= 0;
            finish_loading_mav <= 0;
            finish_loading_counter <= 0;
            start_WAIT_state <= 0;
            start_READ_state <= 0;
        end
        else begin
        case(currentState)
        IDLE: begin
            WE_fromTop_mavArray <= 0;
            DRAM_EN_fromTop_mavArray <= 0;
            DEC_EN_fromTop_mavArray <= 0;
            start_refresh_mavArray <= 0;
            mavArrayADDR_fromTop <= 0;
            startScan_mavArray <= 0;
            haveRecordRequestData <= 0;
            currentMavArrayRow <= 0;
            finish_loading_mav <= 0;
            finish_loading_counter <= 0;
            start_WAIT_state <= 0;
            start_READ_state <= 0;
        end
        SCAN_DATA_TO_MAV_ARRAY: begin
             startScan_mavArray <= 1;
             mavArrayADDR_fromTop <= 0;          
        end
        WAIT_FOR_REQUEST_DATA_FROM_MAV: begin
            if(requestDatafromMAV) begin
                haveRecordRequestData <= 1;
                start_READ_state <= 1;
            end
            else begin
                haveRecordRequestData <= 0;
                start_READ_state <= 0;
            end
        end
        START_READ: begin
            
            start_READ_state <= 0;
            WE_fromTop_mavArray <= 0; //read
            DRAM_EN_fromTop_mavArray <= 1;
            DEC_EN_fromTop_mavArray <= 1;
            
            mavArrayADDR_fromTop <= currentMavArrayRow;
            
            //finish loading signal
            if(finish_loading_counter<2) begin
                finish_loading_mav <= 1;
                finish_loading_counter <= finish_loading_counter+1;
                start_WAIT_state <= 0;
            end
            else begin
                finish_loading_mav <= 0;
                haveRecordRequestData <= 0;
                start_WAIT_state <= 1;
                finish_loading_counter <= 0;
            end
            
        end
        WAIT_FOR_NEXT_ROUND: begin //define currentMavArrayRow
            finish_loading_counter <= 0;
            start_WAIT_state <= 0;
            if(currentMavArrayRow == loadThisManyRowForComputation_mavArray - 1) begin
                currentMavArrayRow <= 0;                
            end
            else begin
                if(requestDatafromMAV && haveRecordRequestData == 0) begin
                    haveRecordRequestData <= 1;
                    currentMavArrayRow <= currentMavArrayRow + 1; //next row
                    start_READ_state <= 1;
                end
                else begin
                    currentMavArrayRow <= currentMavArrayRow;
                    start_READ_state <= 0;
                end
            end
        end
        
        endcase
        end
    
    end

    always @ (posedge sys_clk or posedge fpga_reset) begin
        if(fpga_reset) begin
            start_ADC_fromOutside <= 0;
        end
        else begin
            if(start_ADC_fromchip == 1'b1) begin
                if(start_ADC_counter < 4'd8) begin
                    start_ADC_fromOutside <= 0;
                    start_ADC_counter <= start_ADC_counter + 1'b1;
                end
                else begin
                    start_ADC_fromOutside <= 1'b1;
                end
            end
            else begin
                start_ADC_fromOutside <= 0;
                start_ADC_counter <= 0;
            end
        end
    end



endmodule





