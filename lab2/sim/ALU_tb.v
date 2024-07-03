`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/31 17:21:49
// Design Name: 
// Module Name: ALU_tb
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


module ALU_tb();
    reg [31:0] src0,src1;
    reg [4:0] sel;
    wire [31:0] res;
    ALU alu(
        .alu_src0(src0),
        .alu_src1(src1),
        .alu_res(res),
        .alu_op(sel)
    );
    initial begin
        src0=32'hffff_0000; src1=32'h0000_00ff; sel=0;
        #20;
        repeat(32) begin
            sel = sel + 1;
            #20;
        end
    end
endmodule