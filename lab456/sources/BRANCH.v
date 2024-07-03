`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/08 14:48:59
// Design Name: 
// Module Name: BRANCH
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

module BRANCH(
    input                   [ 3 : 0]            br_type,//0:jal,1:jalr,2:beq,3:bne,4:blt,5:beg,6:bltu,7:bgeu,8:非跳转

    input                   [31 : 0]            br_src0,
    input                   [31 : 0]            br_src1,

    output      reg         [ 1 : 0]            npc_sel//0:pc+4,1:pc+offset,2:(pc+offset)&~1
);
always @(*) begin
    case(br_type)
        4'B0000:begin
            npc_sel = 1;
        end
        4'B0001:begin
            npc_sel = 2;
        end
        4'B0010:begin
            npc_sel = (br_src0 == br_src1) ? 1 : 0;
        end
        4'B0011:begin
            npc_sel = (br_src0 != br_src1) ? 1 : 0;
        end
        4'B0100:begin
            npc_sel = ($signed(br_src0)<$signed(br_src1)) ? 1 : 0;
        end
        4'B0101:begin
            npc_sel = ($signed(br_src0)<$signed(br_src1)) ? 0 : 1;
        end
        4'B0110:begin
            npc_sel = (br_src0 < br_src1) ? 1 : 0;
        end
        4'B0111:begin
            npc_sel = (br_src0 < br_src1) ? 0 : 1;
        end
        4'B1000:begin
            npc_sel = 0;
        end
        default:
            npc_sel = 0;
    endcase
end
endmodule
