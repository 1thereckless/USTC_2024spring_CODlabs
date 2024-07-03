`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/08 15:13:00
// Design Name: 
// Module Name: NPC
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


module NPC(
    input [31:0] pc_add4,
    input [31:0] pc_addoffset,
    input [31:0] pc_0,
    input [1: 0] npc_sel,
    output reg [31:0] npc
    );
always @(*)begin
    case(npc_sel)
        2'B00:npc = pc_add4;
        2'B01:npc = pc_addoffset;
        2'B10:npc = pc_0;
        default:npc = pc_add4;
    endcase
end
endmodule
