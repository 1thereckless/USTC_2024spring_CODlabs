`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/03 17:03:43
// Design Name: 
// Module Name: IP
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


module IP(
    input [5:0] a,
    input [15:0] d,
    input clk,
    input we,
    output [15:0] spo
    );
dist_mem_gen_1 dist_mem_gen_1(
    .a(a),
    .d(d),
    .clk(clk),
    .we(we),
    .spo(spo)
);
endmodule
