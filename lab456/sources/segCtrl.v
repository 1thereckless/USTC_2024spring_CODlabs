`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/02 22:59:51
// Design Name: 
// Module Name: segCtrl
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


module segCtrl(
    input [0:0] rf_we_ex,
    input [1:0] rf_wd_sel_ex,
    input [4:0] rf_wa_ex,
    input [4:0] rf_ra0_id,
    input [4:0] rf_ra1_id,
    input [1:0] npc_sel_ex,
    
    output reg [0:0] stall_pc,
    output reg [0:0] stall_if_id,
    output reg [0:0] flush_if_id,
    output reg [0:0] flush_id_ex
);
//Load-use
always @(*)begin
    if(rf_we_ex && rf_wa_ex!=0 && (rf_wa_ex==rf_ra0_id||rf_wa_ex==rf_ra1_id) && rf_wd_sel_ex==2'B10)begin
        stall_pc = 1;
        stall_if_id = 1;
        flush_if_id = 0;
        flush_id_ex = 1;
    end
    else if(npc_sel_ex==2'B01||npc_sel_ex==2'B10)begin
        stall_pc = 0;
        stall_if_id = 0;
        flush_if_id = 1;
        flush_id_ex = 1;
    end
    else begin
        stall_pc = 0;
        stall_if_id = 0;
        flush_if_id = 0;
        flush_id_ex = 0;
    end
end
endmodule
