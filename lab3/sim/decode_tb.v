`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/08 13:11:21
// Design Name: 
// Module Name: decode_tb
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


module decode_tb( );
DECODE decode(
    .inst(inst),
    .alu_op(op),
    .imm(imm),
    .rf_ra0(ra0),
    .rf_ra1(ra1),
    .rf_wa(wa),
    .rf_we(we),
    .alu_src0_sel(src0),//1来自寄存器堆,0来自PC
    .alu_src1_sel(src1)
);
reg [31:0] inst;
wire   [ 4 : 0]            op;
               wire       [31 : 0]            imm;

               wire       [ 4 : 0]            ra0;
               wire       [ 4 : 0]            ra1;
              wire       [ 4 : 0]            wa;
             wire       [ 0 : 0]            we;

wire       [ 0 : 0]            src0;//1来自寄存器堆,0来自PC
wire       [ 0 : 0]            src1;//1来自寄存器堆,0来自立即数
initial begin
    inst = 32'h0000_6013;
    #20;
    inst = 32'h0000_30b7;
end
endmodule
