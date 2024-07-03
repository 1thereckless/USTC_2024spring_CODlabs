`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/31 21:19:56
// Design Name: 
// Module Name: Top
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

module Top(
    input                   [ 0 : 0]        clk,
    input                   [ 0 : 0]        rst,
    input                   [ 0 : 0]        enable,

    input                   [ 4 : 0]        in,
    input                   [ 1 : 0]        ctrl,

    output                  [ 3 : 0]        seg_data,
    output                  [ 2 : 0]        seg_an
);
wire [31:0] data;
wire [4:0] sel;
wire [31:0] src0,src1,out;
reg [4:0] sel0;
reg [31:0] src00,src10,out0;
ALU ALU(
    .alu_src0(src0),
    .alu_src1(src1),
    .alu_op(sel),
    .alu_res(data)
);
Segment segment(
    .clk(clk),
    .rst(rst),
    .output_data(out),
    .seg_data(seg_data),
    .seg_an(seg_an)
);
always @(posedge clk) begin
    if(rst)begin
        sel0 <=0;
        src00 <=0;
        src10 <=0;
        out0 <=0;
    end
    else begin
        if(enable) begin
            case(ctrl)
                2'b00:sel0 <= in;
                2'b01: src00 <= {{27{in[4]}}, in};
                2'b10: src10 <= {{27{in[4]}}, in};
                2'b11: out0  <= data;
            endcase
        end
    end
end
assign sel = sel0;
assign out = out0;
assign src0=src00;
assign src1=src10;
endmodule