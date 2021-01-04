`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/09/2020 03:17:21 PM
// Design Name: 
// Module Name: testcase3_DAC
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


module testcase3_DAC(

input clk_100M_valid,
input clk_10M_valid,
input fpga_reset,
input startCompute,

output reg test_enable_DAC,
//output sys_clk,
output reg chip_reset_n_DAC,
//scan chain
output update_clk_inputArray,
output scanin_inputArray,
output scan_clk,
output se_inputArray,

//testchip
input refresh_finish_inputArray,
input requestDatafromDAC,
input ADC_finish,
input release_Va,
input start_DAC_fromMAV,

input mav_scan_finish,

output [3:0] inputArrayADDR,
output WE_inputArray, DRAM_EN_inputArray, DEC_EN_inputArray,
output reg start_refresh_inputArray,
output reg start_DAC,

output signORunsign,
input mav_finish

    );
    //config
    parameter signORunsign_param = 1'b0; //0:sign, 1:unsign
    
    //define input array parameters
    parameter maxCol_inputArray = 10'd257;
    parameter maxRow_inputArray = 2;
    parameter loadThisManyRowForComputation_inputArray = 2'd2;
    parameter inputArray = 0;
    reg writeORread_inputArray;
    
    
    //state machine
    parameter IDLE = 4'd0;
    parameter SCAN_DATA_TO_INPUT_ARRAY = 4'd1;
    parameter LOAD_FROM_INPUT_ARRAY_FOR_DAC = 4'd2;
    parameter START_COMPUTE = 4'd3;
    parameter WAIT_FOR_NEXT_ROUND = 4'd4;
    parameter RESET = 4'd5;
    parameter WAIT_FOR_MAV = 4'd6;
    parameter WAIT_FOR_MAV_SCAN = 4'd7;
    parameter TEST_READ_RESET = 4'd8;
    parameter TEST_READ = 4'd9;
    parameter TEST_WAIT = 4'd10;
    parameter DISABLE_START_SCAN = 4'd11;
    
    parameter wait_counter_max = 20;
    parameter load_timer_max = 3;
    //reg
    reg [3:0] currentState, nextState;
    reg startScan_inputArray, haveRecordRequestData;
    reg [2:0] currentInputArrayRow;
    reg [1:0] start_DAC_counter, reset_counter;
    reg WE_fromTop_inputArray, DRAM_EN_fromTop_inputArray, DEC_EN_fromTop_inputArray;
    reg [3:0] inputArrayADDR_fromTop;
    reg start_WAIT_state, finish_reset;
    
    reg [8:0] wait_counter;
    reg [8:0] idle_counter, test_counter, scan_counter, load_timer, WAIT_FOR_MAV_counter;
    
    //wire
    wire [3:0] inputArrayADDR_fromScan;
    wire scan_clk_EN_inputArray, update_clk_EN_inputArray;
    wire all_scan_done;
    wire WE_fromScan_inputArray, DRAM_EN_fromScan_inputArray, DEC_EN_fromScan_inputArray;
//    wire writeORread;
    
    wire sys_clk;
    assign sys_clk = clk_100M_valid;
    assign scan_clk = scan_clk_EN_inputArray & clk_10M_valid;
//    assign chip_reset_n = ~fpga_reset; 
    assign update_clk_inputArray = clk_10M_valid & update_clk_EN_inputArray;
//    assign clk_10M_valid = clk_10M & locked;
    
    assign signORunsign = signORunsign_param;
    
    scan_module scan_inputArray(
        .sys_clk(sys_clk),
        .scan_clk(clk_10M_valid),
        .reset(fpga_reset),
        .startScan(startScan_inputArray),
        .maxCol(maxCol_inputArray),
        .maxRow(maxRow_inputArray),
        .inputArrayORkernelArray(inputArray),
        .writeORread(writeORread_inputArray),
        .update_clk(update_clk_inputArray),
        .se(se_inputArray),
        .scanin(scanin_inputArray),
        .scan_clk_EN(scan_clk_EN_inputArray),
        .update_clk_EN(update_clk_EN_inputArray),
        .all_scan_done(all_scan_done),
        .inputArrayADDR(inputArrayADDR_fromScan),
        .WE(WE_fromScan_inputArray),
        .DRAM_EN(DRAM_EN_fromScan_inputArray),
        .DEC_EN(DEC_EN_fromScan_inputArray)
    );
    assign WE_inputArray = WE_fromTop_inputArray | WE_fromScan_inputArray;
    assign DRAM_EN_inputArray = DRAM_EN_fromTop_inputArray | DRAM_EN_fromScan_inputArray;
    assign DEC_EN_inputArray = DEC_EN_fromScan_inputArray | DEC_EN_fromTop_inputArray;
    assign inputArrayADDR = inputArrayADDR_fromScan | inputArrayADDR_fromTop;
    
    always @ (negedge sys_clk or posedge fpga_reset) begin
        if(fpga_reset) currentState <= IDLE;
        else currentState <= nextState;
    end
    
    //DAC
    always @ (currentState or startCompute or scan_counter 
                or load_timer or test_counter or idle_counter 
                or wait_counter or all_scan_done or currentInputArrayRow 
                or release_Va or requestDatafromDAC or mav_finish 
                or start_DAC_fromMAV or mav_scan_finish 
                or start_WAIT_state or finish_reset) begin
    case(currentState) 
    IDLE: begin
        if(idle_counter < 100) begin
           nextState = IDLE;
        end
        else begin
            nextState = SCAN_DATA_TO_INPUT_ARRAY;
        end
    end

    SCAN_DATA_TO_INPUT_ARRAY: begin
        if(scan_counter < 49) begin
            nextState = SCAN_DATA_TO_INPUT_ARRAY; 
        end
        else begin
            nextState = DISABLE_START_SCAN;
        end
//        if(all_scan_done) nextState = TEST_READ_RESET; ///CHANGE HERE!!!
//        else nextState = SCAN_DATA_TO_INPUT_ARRAY;
    end
    DISABLE_START_SCAN: begin
        if(mav_scan_finish) nextState = RESET; ///CHANGE STATE HERE!!! TEST_READ -- RESET //// all_scan_done -- mav_scan_finish
        else nextState = DISABLE_START_SCAN;
    end
    TEST_READ_RESET: begin
        nextState = TEST_READ;
    end
    TEST_READ: begin
        if(test_counter < 50) begin
            nextState = TEST_READ;
        end
        else begin
            nextState = TEST_WAIT;
        end
        
    end
    TEST_WAIT: begin
        if(all_scan_done) nextState = IDLE; ///CHANGE HERE!!!
        else nextState = TEST_WAIT;
    end
    WAIT_FOR_MAV_SCAN: begin
        if(mav_scan_finish) nextState = RESET;
        else nextState = WAIT_FOR_MAV_SCAN;
    end
    RESET: begin
        nextState <= LOAD_FROM_INPUT_ARRAY_FOR_DAC;
    end
    LOAD_FROM_INPUT_ARRAY_FOR_DAC: begin
        if(load_timer < load_timer_max) begin
            nextState = LOAD_FROM_INPUT_ARRAY_FOR_DAC;
        end
        else begin
            nextState = START_COMPUTE;
        end
        
    end
    
    START_COMPUTE: begin
        if(haveRecordRequestData) nextState = WAIT_FOR_MAV;  //CHANGE HERE WAIT_FOR_MAV -- IDLE
        else nextState = WAIT_FOR_NEXT_ROUND;
        
    end
    WAIT_FOR_NEXT_ROUND: begin
        if(wait_counter < wait_counter_max) begin
            nextState = WAIT_FOR_NEXT_ROUND;
        end
        else begin
            nextState = LOAD_FROM_INPUT_ARRAY_FOR_DAC;
        end
//        if(currentInputArrayRow == loadThisManyRowForComputation_inputArray - 1) begin
//            if(release_Va) nextState = IDLE; //last data and MAV sends release Va, so go back to idle 
//            else nextState = WAIT_FOR_NEXT_ROUND; //////CHANGE HERE
//        end
//        else begin
//            if(requestDatafromDAC && haveRecordRequestData == 0) nextState = RESET;
//            else if (start_DAC_fromMAV) nextState = RESET;
//            else nextState = WAIT_FOR_NEXT_ROUND;
//        end
    end
    
    WAIT_FOR_MAV: begin
        if(mav_finish) begin
            nextState = IDLE;
        end
        else nextState = WAIT_FOR_MAV;
    end
    endcase
    end
    
    always @ (posedge sys_clk or posedge fpga_reset) begin
        if(fpga_reset) begin
            WE_fromTop_inputArray <= 0;
            DRAM_EN_fromTop_inputArray <= 0;
            DEC_EN_fromTop_inputArray <= 0;
            start_DAC <= 0;
            start_refresh_inputArray <= 0;
            currentInputArrayRow <= 0;
            inputArrayADDR_fromTop <= 0;
            startScan_inputArray <= 0;
            start_DAC_counter <= 0;
            haveRecordRequestData <= 0;
            start_WAIT_state <= 0;
            finish_reset <= 0;
            wait_counter <= 0;
            idle_counter <= 0;
            test_enable_DAC <= 0;
            writeORread_inputArray <= 0;
            test_counter <= 0;
            scan_counter <= 0;
            load_timer <= 0;
        end
        else begin
        case(currentState) 
        IDLE: begin
            test_counter <= 0;
            scan_counter <= 0;
            load_timer <= 0;
            WAIT_FOR_MAV_counter <= 0;
            WE_fromTop_inputArray <= 0;
//            DRAM_EN_fromTop_inputArray <= 0;
//            DEC_EN_fromTop_inputArray <= 0;
            start_DAC <= 0;
            start_refresh_inputArray <= 0;
            currentInputArrayRow <= 0;
            
            startScan_inputArray <= 0;
            start_DAC_counter <= 0;
            haveRecordRequestData <= 0;
            start_WAIT_state <= 0;
            finish_reset <= 0;
            chip_reset_n_DAC <= 1;
            wait_counter <= 0;
            test_enable_DAC <= 0;
            if(idle_counter < 100) begin
                idle_counter <= idle_counter + 1;
            end
            else begin
                idle_counter <= 0;
            end
            //set DRAM-EN
            if(idle_counter == 21) begin
                DRAM_EN_fromTop_inputArray <= 1;
                DEC_EN_fromTop_inputArray <= 0;
            end
            else if(idle_counter == 22) begin
                DRAM_EN_fromTop_inputArray <= 0;
                DEC_EN_fromTop_inputArray <= 0;
                inputArrayADDR_fromTop <= 0;
            end
            
//            set test EN
//            if(idle_counter < 50) test_enable_DAC <= 1;
//            else test_enable_DAC <= 1;
        end
        SCAN_DATA_TO_INPUT_ARRAY: begin
            start_refresh_inputArray <= 0;
            writeORread_inputArray <= 0;
            test_enable_DAC <= 0;
            startScan_inputArray <= 1;
            inputArrayADDR_fromTop <= 0;
            if(scan_counter < 50) begin
                scan_counter <= scan_counter + 1;
            end
            else begin
                scan_counter <= 0;
            end
        end
        DISABLE_START_SCAN: begin
        
            scan_counter <= 0;
            startScan_inputArray <= 0;
        end
        
        ///// TEST //////
        TEST_READ_RESET: begin
            writeORread_inputArray <= 1;
            test_counter <= 0;
            test_enable_DAC <= 0;
            startScan_inputArray <= 0;
            inputArrayADDR_fromTop <= 0;
            
        end
        TEST_READ: begin
            writeORread_inputArray <= 1;
            startScan_inputArray <= 1;
            inputArrayADDR_fromTop <= 0;
            test_enable_DAC <= 0;
            if(test_counter < 50) begin
                test_counter <= test_counter + 1;
            end
            else begin
                test_counter <= 0;
            end
        end
        TEST_WAIT: begin
            test_counter <=0;
            startScan_inputArray <= 0;
        end
        WAIT_FOR_MAV_SCAN: begin
            startScan_inputArray <= 0;
        end
        RESET: begin
            test_enable_DAC <= 1;
            haveRecordRequestData <= 0;
            chip_reset_n_DAC <= 0;
            start_DAC <= 0;
            wait_counter <= 0;
        end
        LOAD_FROM_INPUT_ARRAY_FOR_DAC: begin
//            haveRecordRequestData <= 0;
            WE_fromTop_inputArray <= 0; //enable read
            
            if(load_timer == 0) begin
                DRAM_EN_fromTop_inputArray <= 1;
                DEC_EN_fromTop_inputArray <= 0;
            end
            else if(load_timer == 2) begin
                DRAM_EN_fromTop_inputArray <= 1;
                DEC_EN_fromTop_inputArray <= 1;
            end
            
            if(load_timer < load_timer_max) begin
                load_timer <= load_timer + 1;
            end
            else begin
                load_timer <= 0;
            end
            
            //// CHANGE HERE////
//            DRAM_EN_fromTop_inputArray <= 1;
//            DEC_EN_fromTop_inputArray <= 1;
            ///////////////////
            start_DAC <= 0;
            start_DAC_counter <= 0; //reset start DAC counter
            //define address
            inputArrayADDR_fromTop <= currentInputArrayRow;
        end
        START_COMPUTE: begin //start DAC
            test_enable_DAC <= 1;
            chip_reset_n_DAC <= 1;
            start_DAC <= 1;
            
            DRAM_EN_fromTop_inputArray <= 1;
            DEC_EN_fromTop_inputArray <= 1;
            inputArrayADDR_fromTop <= currentInputArrayRow;
            
//            if(start_DAC_counter<10) begin 
//                start_DAC <= 1; 
//                start_DAC_counter <= start_DAC_counter +1; 
//                start_WAIT_state <= 0;
//            end
//			else begin
//			    start_DAC_counter <= 0;
//			    start_DAC <= 0; 
//			    start_WAIT_state <= 1;
//            end
        end
        
		WAIT_FOR_NEXT_ROUND: begin	
            start_DAC <= 0;
            test_enable_DAC <= 1;
            haveRecordRequestData <= 1;
            if(wait_counter < wait_counter_max) begin
                wait_counter <= wait_counter + 1;
            end
            else begin
                wait_counter <= 0;
            end
            if(wait_counter == wait_counter_max-6) begin
                currentInputArrayRow <= currentInputArrayRow+1;
                DRAM_EN_fromTop_inputArray <= 0;
                DEC_EN_fromTop_inputArray <= 0;
            end
            else if(wait_counter == wait_counter_max-7) begin
                DRAM_EN_fromTop_inputArray <= 1;
                DEC_EN_fromTop_inputArray <= 0;
            end
//            start_WAIT_state <= 0;
//            if(currentInputArrayRow == loadThisManyRowForComputation_inputArray - 1) begin
//                if(release_Va) currentInputArrayRow <= 0;
//                else currentInputArrayRow <= currentInputArrayRow;
//			end
//			else begin
//			    if(requestDatafromDAC && haveRecordRequestData == 0) begin
//			        haveRecordRequestData <= 1;
//			        currentInputArrayRow <= currentInputArrayRow + 1; //next row
//			    end
//			    else if (start_DAC_fromMAV) currentInputArrayRow <= currentInputArrayRow + 1; //next row
//			    else currentInputArrayRow <= currentInputArrayRow;
//			end
        end
        WAIT_FOR_MAV: begin
            
            start_DAC <= 0;
            if(WAIT_FOR_MAV_counter < 100) begin
                WAIT_FOR_MAV_counter <= WAIT_FOR_MAV_counter + 1;
            end
            else begin
                WAIT_FOR_MAV_counter <= 0;
            end
            //set DRAM-EN
            if(WAIT_FOR_MAV_counter == 21) begin
                DRAM_EN_fromTop_inputArray <= 1;
                DEC_EN_fromTop_inputArray <= 0;
            end
            else if(WAIT_FOR_MAV_counter == 22) begin
                DRAM_EN_fromTop_inputArray <= 0;
                DEC_EN_fromTop_inputArray <= 0;
            end
            if(WAIT_FOR_MAV_counter < 32) test_enable_DAC <= 1;
            else test_enable_DAC <= 0;
        end
        endcase
        end
    end
endmodule
