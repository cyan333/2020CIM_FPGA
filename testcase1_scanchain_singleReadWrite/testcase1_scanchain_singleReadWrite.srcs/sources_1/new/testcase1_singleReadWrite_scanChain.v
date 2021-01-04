`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/25/2020 09:56:05 PM
// Design Name: 
// Module Name: testcase1_singleReadWrite_scanChain
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


module testcase1_singleReadWrite_scanChain(
    input sys_clk_p, //input to FPGA, coming from on board oscillator
    input sys_clk_n, //input to FPGA, coming from on board oscillator
    input fpga_reset_n,
    
    //refresh controller
    input refresh_finish,
    
    input start_from_fpga,
    
    output sys_clk,
    output chip_reset_n,
    
    //Input array control signals
    output reg [3:0] ADDR,
    output reg WE, DRAM_EN, DEC_EN,
    
    //refresh controller
    output reg start_refresh,
    
    //DAC control signals
    output reg start_DAC,
    
    //scan chain
    output reg se,
    output update_clk,
    output reg scanin,
    output scan_clk
    
    );
    
    parameter IDLE = 3'd0;
    parameter WRITE = 3'd1;
    parameter UPDATE = 3'd2;
    parameter UPDATE_VALUE = 3'd3;
    parameter RESET = 3'd4;
    parameter READ = 3'd5;
    parameter SCANOUT = 3'd6;
    
    
    parameter maxCol = 4;
    parameter maxRow = 3;
    
    
    reg [2:0] currentState, nextState;
    reg [1:0] currentAccessRow;
    //register
    reg scan_clk_EN;
    reg [3:0] this_scancol; //track: which scan bit it is currently scanning
    reg [20:0] thisRowValue;
    reg [20:0] rowValue[2:0]; //left: column: right: row
    reg scan_done; //indicate: scan has finished for one row
    
    reg [1:0] update_count;
    reg update_clk_EN;
    reg didUpdateRowValue;
    reg update_done;
    reg last_row;
    reg haveScanedAlready;
    reg readyRead, read_done;
    reg [1:0] read_timer;
    
    //wire
    wire clk_100M;
    wire clk_10M;
    wire locked;
    wire clk_10M_valid;
    
    wire clk_reset;
    assign clk_reset = ~fpga_reset_n;
    
    clk_core clk_core_inst (.clk_in1_p(sys_clk_p), .clk_in1_n(sys_clk_n), .reset(clk_reset), .sys_clk_100M(clk_100M), .scan_clk_10M(clk_10M), .locked(locked));
    
    assign sys_clk = clk_100M & locked;
    assign scan_clk = scan_clk_EN & clk_10M & locked;
    assign chip_reset_n = fpga_reset_n; 
    assign update_clk = clk_10M_valid & update_clk_EN;
    assign clk_10M_valid = clk_10M & locked;
    
    initial begin
        $readmemb("D:/PHD/2019_CiM/Testing/FPGA/memData/firstMemFile.mem", rowValue);
    end
    
    always @ (negedge sys_clk or negedge fpga_reset_n) begin
        if(!fpga_reset_n) currentState <= IDLE;
        else currentState <= nextState;
    end
    
    always @ (currentState or start_from_fpga or scan_done or didUpdateRowValue or update_done or last_row or read_done or readyRead) begin
        case(currentState) 
        IDLE: begin
            //rowValue[0] <= 20'd3; 
            //rowValue[1] <= 20'd4; 
            //rowValue[2] <= 20'd13; 
            if(start_from_fpga & ~haveScanedAlready) nextState = UPDATE_VALUE;
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
                else nextState = RESET;  //change the state here
            end
            else nextState = UPDATE;     
        end
        
        RESET: begin
            if (readyRead) nextState = READ;
            else nextState = RESET;
        end
        
        READ: begin
            if (read_done) nextState = SCANOUT;
            else nextState = READ;
        
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
    
    always @ (negedge clk_10M_valid or negedge fpga_reset_n) begin
        if(!fpga_reset_n) begin
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
                end
                UPDATE_VALUE: begin
                    thisRowValue <= rowValue[currentAccessRow];
                    didUpdateRowValue <= 1;
                    update_count <= 0;
                    update_done <= 0;
                end
                WRITE: begin
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
                    se <= 0;
                    scan_done <= 0;
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
                    readyRead <= 0;
                    if(read_timer < 1) begin
                        read_timer <= read_timer + 1;
                        read_done <= 0;
                    end
                    else begin
                        read_done <= 1;
                        //read_timer <= 0;
                    end
                    
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
    
//    always @ (posedge clk_10M_valid or negedge fpga_reset_n) begin
//        if(!fpga_reset_n) begin 
//            this_scancol <= 0;
//        end
//        else begin
//            case(currentState) 
//                IDLE: this_scancol <= 0;
//                WRITE: begin
//                    if(this_scancol < maxCol) begin 
//                        this_scancol <= this_scancol + 1; 
//                    end 
//                    else begin 
//                        this_scancol <= 0; 
//                    end     
//                end
//            endcase
//        end
//    end
    
    //define write enable DRAM control signal
    always @ (currentState) begin
        case(currentState)
        IDLE: begin
            start_refresh <= 0;
            start_DAC <= 0;
            WE <= 1'b0; 
            DRAM_EN <= 1'b0; 
            DEC_EN <= 1'b0; 
            ADDR <= 4'd0;
        end
        WRITE: begin
            ADDR <= 4'd0;
            WE <= 1'b0; 
            DRAM_EN <= 1'b0; 
            DEC_EN <= 1'b0;                        
        end
        UPDATE: begin
            WE <= 1'b1; 
            DRAM_EN <= 1'b1; 
            DEC_EN <= 1'b1; 
            case(currentAccessRow)  
                2'b00: ADDR <= 4'd0; 
                2'b01: ADDR <= 4'd1; 
                2'b10: ADDR <= 4'd2; 
                2'b11: ADDR <= 4'd3; 
            endcase            
        end
        RESET: begin
            WE <= 1'b0; 
            DRAM_EN <= 1'b0; 
            DEC_EN <= 1'b0; 
            ADDR <= 4'd0;
        end
        READ: begin
            WE <= 1'b0;
            DRAM_EN <= 1'b1;
            DEC_EN <= 1'b1;
            case(currentAccessRow)  
                2'b00: ADDR <= 4'd0; 
                2'b01: ADDR <= 4'd1; 
                2'b10: ADDR <= 4'd2; 
                2'b11: ADDR <= 4'd3; 
            endcase 
        end
        
        SCANOUT: begin
        
        
        end 
       
        endcase
    end
    
    
    
    
    
    
    
    
    
    
    
    
    
    
endmodule
