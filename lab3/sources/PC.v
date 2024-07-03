`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/05 16:13:59
// Design Name: 
// Module Name: PC
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

module PC (
    input                   [ 0 : 0]            clk,
    input                   [ 0 : 0]            rst,
    input                   [ 0 : 0]            en,
    input                   [31 : 0]            npc,
    input                   [0  : 0]            flush,
    input                   [0  : 0]            stall,
    output      reg         [31 : 0]            pc
);
always @(posedge clk) begin
    if (rst) begin
        pc <= 32'h0040_0000;
    end
    else if (en) begin
        if(flush) begin
            pc <= 32'h0040_0000;
        end
        else if(stall) begin
            pc <= pc;
        end
        else begin
            pc <= npc;
        end
    end
    else begin
        pc <= pc;
    end
end
endmodule