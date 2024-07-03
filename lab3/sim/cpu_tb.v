`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/08 00:41:35
// Design Name: 
// Module Name: cpu_tb
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


module cpu_tb();
CPU cpu(
    .clk(clk),
    .rst(rst),
    .global_en(en),
    .imem_raddr(),
    .imem_rdata(data)
);

reg    [ 0 : 0]            clk;
reg    [ 0 : 0]            rst;
reg    [ 0 : 0]            en;
reg    [31 : 0]            data;

INST_MEM my_inst(
    .a(),
    .d(),
    .clk(clk),
    .we(),
    .spo(data)
);
initial begin
    clk=0;
    forever begin
        #5;
        clk=~clk;
    end
end

initial begin
    en = 1;
    rst = 1;
    #5;
    rst = 0;
end

endmodule
