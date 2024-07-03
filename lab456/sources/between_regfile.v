`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/23 16:33:41
// Design Name: 
// Module Name: between_regfile
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


module between_regfile(
    input [0 :0] rst,
    input [0: 0] clk,
    input [0:0 ] en,
    input [0: 0] flush,
    input [0: 0] stall,
    //commit
    input      [0: 0] commit_in,
    //if
    input      [31:0] inst_in,
    input      [31:0] pc_in,
    input      [31:0] pcadd4_in,
    //id
    input      [4:0 ] rf_ra0_in,
    input      [4:0 ] rf_ra1_in,
    input      [31:0] rf_rd0_in,
    input      [31:0] rf_rd1_in,
    input      [31:0] imm_in,
    input      [ 4:0] rf_wa_in,
    input      [0: 0] rf_we_in,
    input      [1: 0] rf_wd_sel_in,
    input       [4:0] alu_op_in,
    input       [3:0] br_type_in,
    input       [0:0] alu_src0_sel_in,
    input      [0:0]  alu_src1_sel_in,
    input      [0:0 ] dmem_we_in,
    input      [3:0 ] dmem_access_in,
    //ex
    input      [31:0] alu_res_in,
    //mem
    input      [31:0] dmem_rd_out_in,
    input      [31:0] dmem_wd_in,

    //commit
    output reg [0: 0] commit_out,
    //if
    output reg [31:0] inst_out,
    output reg [31:0] pc_out,
    output reg [31:0] pcadd4_out,
    //id
    output reg [4:0 ] rf_ra0_out,
    output reg [4:0 ] rf_ra1_out,
    output reg [31:0] rf_rd0_out,
    output reg [31:0] rf_rd1_out,
    output reg [31:0] imm_out,
    output reg [ 4:0] rf_wa_out,
    output reg [ 0:0] rf_we_out,
    output reg [ 3 : 0]    dmem_access_out,//0:非访存,1:lb,2:lh,3:lw,4:lbu,5:lhu,6:sb,7:sh,8:sw
    output reg [ 0 : 0]    dmem_we_out,  
    output reg [ 1 : 0]    rf_wd_sel_out,//写回寄存器信号来源,0来自PC+4,1来自ALU,2来自从内存读的值,3来自0
    output reg [ 3 : 0]    br_type_out,//0:jal,1:jalr,2:beq,3:bne,4:blt,5:beg,6:bltu,7:bgeu
    output reg [ 4 : 0]    alu_op_out,
    output reg [ 0 : 0]    alu_src0_sel_out,//1来自寄存器堆,0来自PC
    output reg [ 0 : 0]    alu_src1_sel_out,
    //ex
    output reg [31:0] alu_res_out,
    //mem
    output reg [31:0] dmem_rd_out_out,
    output reg [31:0] dmem_wd_out
    );
always @(posedge clk) begin
    if (rst) begin
        // rst 操作的逻辑
        commit_out <=0;

        inst_out <= 32'H0000_0013;
        pc_out <= 32'H00400000;
        pcadd4_out <= 32'H00400000+32'H4;
        
        rf_ra0_out <= 0;
        rf_ra1_out <= 0;
        rf_rd0_out <= 0;
        rf_rd1_out <= 0;
        imm_out <= 0;
        rf_wa_out <= 0;
        rf_we_out <= 0;
        dmem_access_out <=0;
        dmem_we_out<= 0;
        rf_wd_sel_out<=3;
        alu_op_out<=5'B00000;
        br_type_out<=4'B1000;
        alu_src0_sel_out<=1;  
        alu_src1_sel_out<=1;

        alu_res_out <= 0;

        dmem_rd_out_out <= 0;
        dmem_wd_out <= 0;
    end
    else if (en) begin
        // flush 和 stall 操作的逻辑, flush 的优先级更高
        if (flush) begin
            commit_out <=0;

            inst_out <= 32'H0000_0013;
            pc_out <= 32'H00400000;
            pcadd4_out <= 32'H00400000+32'H4;

            rf_ra0_out <= 0;
            rf_ra1_out <= 0;
            rf_rd0_out <= 0;
            rf_rd1_out <= 0;
            imm_out <= 0;
            rf_wa_out <= 0;
            rf_we_out <= 0;
            dmem_access_out <=0;
            dmem_we_out<= 0;
            rf_wd_sel_out<=3;
            alu_op_out<=5'B00000;
            br_type_out<=4'B1000;
            alu_src0_sel_out<=1;  
            alu_src1_sel_out<=1;

            alu_res_out <= 0;

            dmem_rd_out_out <= 0;
            dmem_wd_out <= 0;
        end
        else if(stall) begin
                commit_out <= commit_out;

                inst_out <= inst_out;
                pc_out <= pc_out;
                pcadd4_out <= pcadd4_out;

                rf_ra0_out <= rf_ra0_out;
                rf_ra1_out <= rf_ra1_out;
                rf_rd0_out <= rf_rd0_out;
                rf_rd1_out <= rf_rd1_out;
                imm_out <= imm_out;
                rf_wa_out <= rf_wa_out;
                rf_we_out <= rf_we_out;
                dmem_access_out <=dmem_access_out;
                dmem_we_out<= dmem_we_out;
                rf_wd_sel_out<= rf_wd_sel_out;
                alu_op_out<= alu_op_out;
                br_type_out<= br_type_out;
                alu_src0_sel_out<= alu_src0_sel_out;  
                alu_src1_sel_out<= alu_src1_sel_out;

                alu_res_out <= alu_res_out;

                dmem_rd_out_out <= dmem_rd_out_out;
                dmem_wd_out <= dmem_wd_out;
            end
        else begin
                commit_out <= commit_in;

                inst_out <= inst_in;
                pc_out <= pc_in;
                pcadd4_out <= pcadd4_in;

                rf_ra0_out <= rf_ra0_in;
                rf_ra1_out <= rf_ra1_in;
                rf_rd0_out <= rf_rd0_in;
                rf_rd1_out <= rf_rd1_in;
                imm_out <= imm_in;
                rf_wa_out <= rf_wa_in;
                rf_we_out <= rf_we_in;
                dmem_access_out <=dmem_access_in;
                dmem_we_out<= dmem_we_in;
                rf_wd_sel_out<= rf_wd_sel_in;
                alu_op_out<= alu_op_in;
                br_type_out<= br_type_in;
                alu_src0_sel_out<= alu_src0_sel_in;  
                alu_src1_sel_out<= alu_src1_sel_in;

                alu_res_out <= alu_res_in;

                dmem_rd_out_out <= dmem_rd_out_in;
                dmem_wd_out <= dmem_wd_in;
            end
        end
    else begin
        commit_out <= commit_out;

        inst_out <= inst_out;
        pc_out <= pc_out;
        pcadd4_out <= pcadd4_out;

        rf_ra0_out <= rf_ra0_out;
        rf_ra1_out <= rf_ra1_out;
        rf_rd0_out <= rf_rd0_out;
        rf_rd1_out <= rf_rd1_out;
        imm_out <= imm_out;
        rf_wa_out <= rf_wa_out;
        rf_we_out <= rf_we_out;
        dmem_access_out <=dmem_access_out;
        dmem_we_out<= dmem_we_out;
        rf_wd_sel_out<= rf_wd_sel_out;
        alu_op_out<= alu_op_out;
        br_type_out<= br_type_out;
        alu_src0_sel_out<= alu_src0_sel_out;  
        alu_src1_sel_out<= alu_src1_sel_out;

        alu_res_out <= alu_res_out;

        dmem_rd_out_out <= dmem_rd_out_out;
        dmem_wd_out <= dmem_wd_out;
    end
end    
endmodule