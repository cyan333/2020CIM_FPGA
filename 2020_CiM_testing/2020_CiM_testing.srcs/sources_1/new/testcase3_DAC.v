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

input sys_clk_p,
input sys_clk_n,
input fpga_reset,
input startCompute,

output sys_clk,
output chip_reset_n,
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

output signORunsign

    );
    //config
    parameter signORunsign_param = 1'b0; //0:sign, 1:unsign
    
    //define input array parameters
    parameter maxCol_inputArray = 3'd4;
    parameter maxRow_inputArray = 3'd3;
    parameter loadThisManyRowForComputation_inputArray = 2'd2;
    parameter inputArray = 1;
    parameter writeORread_inputArray = 0;
    
    
    //state machine
    parameter IDLE = 3'd0;
    parameter SCAN_DATA_TO_INPUT_ARRAY = 3'd1;
    parameter LOAD_FROM_INPUT_ARRAY_FOR_DAC = 3'd2;
    parameter START_COMPUTE = 3'd3;
    parameter WAIT_FOR_NEXT_ROUND = 3'd4;
    parameter RESET = 3'd5;
    
    
    //reg
    reg [2:0] currentState, nextState;
    reg startScan_inputArray, haveRecordRequestData;
    reg [3:0] currentInputArrayRow;
    reg [1:0] start_DAC_counter, reset_counter;
    reg WE_fromTop_inputArray, DRAM_EN_fromTop_inputArray, DEC_EN_fromTop_inputArray;
    reg [3:0] inputArrayADDR_fromTop;
    reg start_WAIT_state, finish_reset;
    //wire
    wire [3:0] inputArrayADDR_fromScan;
    wire scan_clk_EN_inputArray, update_clk_EN_inputArray;
    wire all_scan_done;
    wire WE_fromScan_inputArray, DRAM_EN_fromScan_inputArray, DEC_EN_fromScan_inputArray;
//    wire writeORread;
    
    //wire
    wire clk_100M;
    wire clk_10M;
    wire locked;
    wire clk_10M_valid;
        
    clk_core clk_core_inst (.clk_in1_p(sys_clk_p), .clk_in1_n(sys_clk_n), .reset(fpga_reset), .sys_clk_100M(clk_100M), .scan_clk_10M(clk_10M), .locked(locked));
    assign sys_clk = clk_100M & locked;
    assign scan_clk = scan_clk_EN_inputArray & clk_10M & locked;
    assign chip_reset_n = ~fpga_reset; 
    assign update_clk_inputArray = clk_10M_valid & update_clk_EN_inputArray;
    assign clk_10M_valid = clk_10M & locked;
    
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
    always @ (currentState or startCompute or all_scan_done or currentInputArrayRow or release_Va or requestDatafromDAC or start_DAC_fromMAV or mav_scan_finish or start_WAIT_state or finish_reset) begin
    case(currentState) 
    IDLE: begin
        if(startCompute) begin
            nextState = SCAN_DATA_TO_INPUT_ARRAY;
        end
        else nextState = IDLE;
    end
    SCAN_DATA_TO_INPUT_ARRAY: begin
        if(mav_scan_finish) nextState = LOAD_FROM_INPUT_ARRAY_FOR_DAC;
        else nextState = SCAN_DATA_TO_INPUT_ARRAY;
    end
    RESET: begin
        if(finish_reset) nextState = LOAD_FROM_INPUT_ARRAY_FOR_DAC;
        else nextState = RESET;
    end
    LOAD_FROM_INPUT_ARRAY_FOR_DAC: begin
            nextState = START_COMPUTE;
    end
    START_COMPUTE: begin
        if(start_WAIT_state == 0) begin 
            nextState = START_COMPUTE;
        end
        else begin
            nextState = WAIT_FOR_NEXT_ROUND;
        end
        
    end
    WAIT_FOR_NEXT_ROUND: begin
        if(currentInputArrayRow == loadThisManyRowForComputation_inputArray - 1) begin
            if(release_Va) nextState = IDLE; //last data and MAV sends release Va, so go back to idle 
            else nextState = WAIT_FOR_NEXT_ROUND;
        end
        else begin
            if(requestDatafromDAC && haveRecordRequestData == 0) nextState = RESET;
            else if (start_DAC_fromMAV) nextState = RESET;
            else nextState = WAIT_FOR_NEXT_ROUND;
        end
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
        end
        else begin
        case(currentState) 
        IDLE: begin
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
        end
        SCAN_DATA_TO_INPUT_ARRAY: begin
            startScan_inputArray <= 1;
            inputArrayADDR_fromTop <= 0;
        end
        RESET: begin
            if(reset_counter < 2) begin
                finish_reset <= 0;
                reset_counter <= reset_counter + 1;
            end
            else begin
                finish_reset <= 1;
                reset_counter <= 0;
            end
        end
        LOAD_FROM_INPUT_ARRAY_FOR_DAC: begin
            haveRecordRequestData <= 0;
            WE_fromTop_inputArray <= 0; //enable read
            DRAM_EN_fromTop_inputArray <= 1;
            DEC_EN_fromTop_inputArray <= 1;
            start_DAC <= 0;
            start_DAC_counter <= 0; //reset start DAC counter
            //define address
            inputArrayADDR_fromTop <= currentInputArrayRow;
        end
        START_COMPUTE: begin //start DAC
            //pull down start_DAC after 2 cycles
            if(start_DAC_counter<2) begin 
                start_DAC <= 1; 
                start_DAC_counter <= start_DAC_counter +1; 
                start_WAIT_state <= 0;
            end
			else begin
			    start_DAC_counter <= 0;
			    start_DAC <= 0; 
			    start_WAIT_state <= 1;
            end
        end
        
		WAIT_FOR_NEXT_ROUND: begin	
            start_WAIT_state <= 0;
            if(currentInputArrayRow == loadThisManyRowForComputation_inputArray - 1) begin
                if(release_Va) currentInputArrayRow <= 0;
                else currentInputArrayRow <= currentInputArrayRow;
			end
			else begin
			    if(requestDatafromDAC && haveRecordRequestData == 0) begin
			        haveRecordRequestData <= 1;
			        currentInputArrayRow <= currentInputArrayRow + 1; //next row
			    end
			    else if (start_DAC_fromMAV) currentInputArrayRow <= currentInputArrayRow + 1; //next row
			    else currentInputArrayRow <= currentInputArrayRow;
			end
        end
        endcase
        end
    end
endmodule
