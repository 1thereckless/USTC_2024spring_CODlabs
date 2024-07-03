`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/08 15:27:20
// Design Name: 
// Module Name: RF_WD_MUX
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

module MUX4 # (
    parameter               WIDTH                   = 32
)(
    input                   [WIDTH-1 : 0]           src0, src1, src2, src3,
    input                   [      1 : 0]           sel,//写回寄存器信号来源,0来自PC+4,1来自ALU,2来自从数据寄存器读的值,3来自0

    output                  [WIDTH-1 : 0]           res
);
    assign res = sel[1] ? (sel[0] ? src3 : src2) : (sel[0] ? src1 : src0);
endmodule
