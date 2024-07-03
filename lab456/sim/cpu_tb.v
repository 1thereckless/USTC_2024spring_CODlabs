`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/10 16:12:08
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
    .imem_raddr(raddr),
    .imem_rdata(data),
    .dmem_addr(dmem_addr),
    .dmem_wdata(dmem_wdata),
    .dmem_we(dmem_we),
    .dmem_rdata(dmem_rdata)
);
INST_MEM my_inst(
    .a(raddr[10:2]),
    .d(),
    .clk(clk),
    .we(),
    .spo(data)
);
/*INST_MEM_1 my_inst1(
    .a(raddr[10:2]),
    .d(),
    .clk(clk),
    .we(),
    .spo(data)
);*/
DATA_MEM my_data(
    .a(dmem_addr[10:2]),
    .d(dmem_wdata),
    .clk(clk),
    .we(dmem_we),
    .spo(dmem_rdata)
);

reg    [ 0 : 0]            clk;
reg    [ 0 : 0]            rst;
reg    [ 0 : 0]            en;
wire   [31 : 0]            data;
wire   [31 : 0]            raddr;
wire   [31:0  ]            dmem_addr;
wire   [31:  0]            dmem_wdata;
wire   [0:   0]            dmem_we;
wire   [31:  0]            dmem_rdata;
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
    #15;
    rst = 0;
end

endmodule