`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/09/2020 03:25:29 PM
// Design Name: 
// Module Name: scan_module
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


module scan_module(
    input sys_clk,
    input scan_clk,
    input reset,
    input startScan,
    
    //scan parameter
    input [2:0] maxCol,
    input [2:0] maxRow,
    
    //config
    input inputArrayORkernelArray,
    input writeORread,
    //output
    output update_clk,
    output reg se,
    output reg scanin,
    
    output reg scan_clk_EN,
    output reg update_clk_EN,
    output reg all_scan_done,
    
    output reg [3:0] inputArrayADDR,
    output reg [4:0] mavArrayADDR,
    output reg WE, DRAM_EN, DEC_EN
    );
    
    parameter IDLE = 3'd0;
    parameter WRITE = 3'd1;
    parameter UPDATE = 3'd2;
    parameter UPDATE_VALUE = 3'd3;
    parameter RESET = 3'd4;
    parameter READ = 3'd5;
    parameter SCANOUT = 3'd6;
    
    
    
    reg [20:0] inputArrayRowValue[2:0]; //left: column: right: row
    reg [20:0] kernelArrayRowValue[2:0]; //left: column: right: row
    reg [2:0] currentState, nextState;
    reg [4:0] currentAccessRow;
    reg [3:0] this_scancol; //track: which scan bit it is currently scanning
    reg [20:0] thisRowValue;
    reg scan_done; //indicate: scan has finished for one row.
    
    reg [1:0] update_count;
    reg didUpdateRowValue;
    reg update_done;
    reg last_row;
    reg haveScanedAlready;
    reg readyRead, read_done;
    reg [1:0] read_timer;
    reg finish_scan;
    
    initial begin
        $readmemb("D:/PHD/2019_CiM/Testing/FPGA/memData/firstMemFile.mem", inputArrayRowValue);
        $readmemb("D:/PHD/2019_CiM/Testing/FPGA/memData/kernalArray.mem", kernelArrayRowValue);

    end
//    assign all_scan_done = update_done & last_row;
    always @ (negedge scan_clk) begin
        if (finish_scan) begin
            all_scan_done <= 1;
            finish_scan <= 0;
        end
        else all_scan_done <= 0;
    end
    always @ (posedge scan_clk) begin
        if (update_done & last_row) begin
            finish_scan <= 1;
        end
        else finish_scan <= 0;
    end
    always @ (posedge scan_clk or posedge reset) begin
        if(reset) currentState <= IDLE;
        else currentState <= nextState;
    end
    
    always @ (currentState or startScan or scan_done or didUpdateRowValue or update_done or last_row or read_done or readyRead) begin
        case(currentState) 
        IDLE: begin
            if(startScan & ~haveScanedAlready & ~writeORread) nextState = UPDATE_VALUE;
            else if (startScan & ~haveScanedAlready & writeORread) nextState = RESET;
            else nextState = IDLE;
        end
        
        UPDATE_VALUE: begin
            if(didUpdateRowValue) nextState = WRITE;
            else nextState = UPDATE_VALUE;
        end
        
        WRITE: begin
            if(scan_done) nextState = UPDATE;
            else nextState = WRITE;
        end
        UPDATE: begin
            if(update_done) begin
                if(!last_row) nextState = UPDATE_VALUE;
                else nextState = IDLE;  //change the state here
            end
            else nextState = UPDATE;     
        end
        RESET: begin
            if (readyRead) nextState = READ;
            else nextState = RESET;
        end
        READ: begin
//            if (read_done) nextState = SCANOUT;
//            else nextState = READ;
            nextState = SCANOUT;
        end
        SCANOUT: begin
            if(scan_done) begin
                if(~last_row) nextState = RESET;
                else nextState = IDLE;
            end
            else nextState = SCANOUT;
        end
        endcase
    end
    
    always @ (negedge scan_clk or posedge reset) begin
        if(reset) begin
            read_timer <= 0;
            read_done <= 0;
            readyRead <= 0;
            last_row <= 0;
            this_scancol <= 0;
            scan_clk_EN <= 0;
            scanin <= 0;
            scan_done <= 0;
            thisRowValue <= 0;
            didUpdateRowValue <= 0;
            update_count <= 0;
            currentAccessRow <= 0;
            update_done <= 0;
            update_clk_EN <= 0;
            se <= 0;
            haveScanedAlready <= 0;
            WE <= 0;
            DRAM_EN <= 0;
            DEC_EN <= 0;
            inputArrayADDR <= 4'b0;
            mavArrayADDR <= 5'b0;
        end
        else begin
            case(currentState) 
                IDLE: begin
                    read_timer <= 0;
                    read_done <= 0;
                    readyRead <= 0;
                    last_row <= 0;
                    update_done <= 0;
                    this_scancol <= 0;
                    scan_clk_EN <= 0;
                    scanin <= 0;
                    scan_done <= 0;
                    didUpdateRowValue <= 0;  
                    update_count <= 0;    
                    currentAccessRow <= 0;
                    update_clk_EN <= 0;
                    se <= 0;   
                    thisRowValue <= 0;
                    WE <= 0;
                    DRAM_EN <= 0;
                    DEC_EN <= 0;
                    inputArrayADDR <= 4'b0;
                    mavArrayADDR <= 5'b0;
                end
                UPDATE_VALUE: begin
                    if(inputArrayORkernelArray) thisRowValue <= kernelArrayRowValue[currentAccessRow];
                    else thisRowValue <= inputArrayRowValue[currentAccessRow];
                    didUpdateRowValue <= 1;
                    update_count <= 0;
                    update_done <= 0;
                end
                WRITE: begin
                    WE <= 1;
                    DRAM_EN <= 0;
                    DEC_EN <= 0;
                    last_row <= 0;
                    se <= 1;
                    update_done <= 0;
                    if(this_scancol < maxCol) begin 
                        scan_clk_EN <= 1'b1; 
                        scanin <= thisRowValue[this_scancol]; 
                        this_scancol <= this_scancol + 1; 
                    end 
                    else begin 
                        this_scancol <= 0; 
                        didUpdateRowValue <= 0;  
                        scan_done <= 1; 
                        scan_clk_EN <= 1'b0; 
                    end     
                end
                UPDATE: begin
                    WE <= 1;
                    DRAM_EN <= 1;
                    DEC_EN <= 1;
                    se <= 0;
                    scan_done <= 0;
                    if(inputArrayORkernelArray) mavArrayADDR <= currentAccessRow;
                    else inputArrayADDR <= currentAccessRow;
                    
                    if(update_count < 2) begin
                        update_clk_EN <= 1;
                        update_count <= update_count + 1;
                    end
                    else begin
                        update_clk_EN <= 0;
                        update_done <= 1;
                        if(currentAccessRow < maxRow-1) begin
                            last_row <= 1'b0;
                            currentAccessRow <= currentAccessRow + 1;
                        end
                        else begin
                            last_row <= 1'b1;
                            haveScanedAlready <= 1'b1;
                            currentAccessRow <= 0;
                            
                        end
                    end
                end
                
                RESET: begin
                    WE = 0;
                    DRAM_EN = 0;
                    DEC_EN = 0;
                    update_done <= 0;
                    read_timer <= 0;
                    read_done <= 0;
                    se <= 0;
                    scan_done <= 0;
                    this_scancol <= 0;
                    last_row <= 0;
                    readyRead <= 1;
                end
                
                READ: begin
                    WE = 0;
                    DRAM_EN = 1;
                    DEC_EN = 1;
                    readyRead <= 0;
//                    if(read_timer < 1) begin
//                        read_timer <= read_timer + 1;
//                        read_done <= 0;
//                    end
//                    else begin
//                        read_done <= 1;
//                        //read_timer <= 0;
//                    end
                    if(inputArrayORkernelArray) mavArrayADDR <= currentAccessRow;
                    else inputArrayADDR <= currentAccessRow;
                end
                
                SCANOUT: begin
                    read_done <= 0;
                    if(this_scancol < maxCol) begin 
                        scan_clk_EN <= 1'b1; 
                        this_scancol <= this_scancol + 1; 
                        if(this_scancol == 0) se <= 0;
                        else se <= 1;
                    end
                    else begin 
                        se <= 0;
                        this_scancol <= 0; 
                        scan_done <= 1; 
                        scan_clk_EN <= 1'b0; 
                        if(currentAccessRow < maxRow-1) begin
                            last_row <= 1'b0;
                            currentAccessRow <= currentAccessRow + 1;
                        end
                        else begin
                            last_row <= 1'b1;
                            haveScanedAlready <= 1'b1;
                        end
                    end  
                end
            endcase
        end
    end
endmodule
