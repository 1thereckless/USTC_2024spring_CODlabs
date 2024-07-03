`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/05 16:20:58
// Design Name: 
// Module Name: REGFILE
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

module REG_FILE (
    input                   [ 0 : 0]        clk,

    input                   [ 4 : 0]        rf_ra0,
    input                   [ 4 : 0]        rf_ra1,   
    input                   [ 4 : 0]        rf_wa,//
    input                   [ 0 : 0]        rf_we,//
    input                   [31 : 0]        rf_wd,//
    input                   [ 4 : 0]        debug_reg_ra,

    output                  [31 : 0]        rf_rd0,//
    output                  [31 : 0]        rf_rd1,//
    output                  [31 : 0]        debug_reg_rd
);

    reg [31 : 0] reg_file [0 : 31];

    // 用于初始化寄存器
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1)
            reg_file[i] = 0;
    end
    //写
    always @(posedge clk) begin
        if(rf_we)begin
            if (rf_wa ==0)
                reg_file[rf_wa] <= reg_file[rf_wa];
            else
                reg_file[rf_wa] <= rf_wd;
        end
        else
            reg_file[rf_wa] <= reg_file[rf_wa];
    end
    //读
    assign rf_rd0 = (rf_ra0==rf_wa && rf_wa!=0) ? rf_wd : reg_file[rf_ra0];
    assign rf_rd1 = (rf_ra1==rf_wa && rf_wa!=0) ? rf_wd : reg_file[rf_ra1];
    assign debug_reg_rd = reg_file[debug_reg_ra];
endmodule

