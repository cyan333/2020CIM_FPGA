`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/07/2020 11:14:04 PM
// Design Name: 
// Module Name: testcase2_getResult
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


module testcase2_getResult(
input dataRdy,
input data,
input fpga_reset_n
    );
    reg thisData;
    always @ (posedge dataRdy or negedge fpga_reset_n) begin
        if(!fpga_reset_n) thisData = 0;
        else thisData = data;
    
    
    end
endmodule
