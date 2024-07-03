`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/05 15:17:27
// Design Name: 
// Module Name: DECODE
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

module DECODE (
    input                      [31 : 0]            inst,

    output           reg       [ 3 : 0]            dmem_access,//0:非访存,1:lb,2:lh,3:lw,4:lbu,5:lhu,6:sb,7:sh,8:sw
    output           reg       [ 0 : 0]            dmem_we,  

    output           reg       [ 1 : 0]            rf_wd_sel,//写回寄存器信号来源,0来自PC+4,1来自ALU,2来自从内存读的值,3来自0
    output           reg       [ 3 : 0]            br_type,//0:jal,1:jalr,2:beq,3:bne,4:blt,5:beg,6:bltu,7:bgeu
    output           reg       [ 4 : 0]            alu_op,
    output           reg       [31 : 0]            imm,

    output           reg       [ 4 : 0]            rf_ra0,
    output           reg       [ 4 : 0]            rf_ra1,
    output           reg       [ 4 : 0]            rf_wa,
    output           reg       [ 0 : 0]            rf_we,

    output           reg       [ 0 : 0]            alu_src0_sel,//1来自寄存器堆,0来自PC
    output           reg       [ 0 : 0]            alu_src1_sel //1来自寄存器堆,0来自立即数
);
always @(*)begin
    case(inst[6:0])
        //R-type
        7'b011_0011:begin
            case(inst[31:25])
                7'b000_0000:begin
                    case(inst[14:12])
                        3'b000: begin
                            dmem_we = 0; 
                            rf_ra0 = inst[19:15];
                            rf_ra1 = inst[24:20];
                            alu_src0_sel = 1;
                            alu_src1_sel = 1;
                            rf_wa = inst[11:7];
                            rf_we = 1;
                            imm = 0;
                            rf_wd_sel=1;
                            br_type = 8;
                            dmem_access  = 0;
                            alu_op = 5'B00000;         //add
                        end
                        3'b001: begin
                            dmem_we = 0; 
                            rf_ra0 = inst[19:15];
                            rf_ra1 = inst[24:20];
                            alu_src0_sel = 1;
                            alu_src1_sel = 1;
                            rf_wa = inst[11:7];
                            rf_we = 1;
                            imm = 0;
                            rf_wd_sel=1;
                            br_type = 8;
                            dmem_access  = 0;
                            alu_op = 5'B01110;         //sll
                         end
                        3'b010: begin
                            dmem_we = 0; 
                            rf_ra0 = inst[19:15];
                            rf_ra1 = inst[24:20];
                            alu_src0_sel = 1;
                            alu_src1_sel = 1;
                            rf_wa = inst[11:7];
                            rf_we = 1;
                            imm = 0;
                            rf_wd_sel=1;
                            br_type = 8;
                            dmem_access  = 0;
                            alu_op = 5'B00100;         //slt
                        end
                        3'b011: begin
                            dmem_we = 0; 
                            rf_ra0 = inst[19:15];
                            rf_ra1 = inst[24:20];
                            alu_src0_sel = 1;
                            alu_src1_sel = 1;
                            rf_wa = inst[11:7];
                            rf_we = 1;
                            imm = 0;
                            rf_wd_sel=1;
                            br_type = 8;
                            dmem_access  = 0;
                            alu_op = 5'B00101;         //sltu
                        end
                        3'b100: begin
                            dmem_we = 0; 
                            rf_ra0 = inst[19:15];
                            rf_ra1 = inst[24:20];
                            alu_src0_sel = 1;
                            alu_src1_sel = 1;
                            rf_wa = inst[11:7];
                            rf_we = 1;
                            imm = 0;
                            rf_wd_sel=1;
                            br_type = 8;
                            dmem_access  = 0;
                            alu_op = 5'B01011;         //xor
                        end
                        3'b101: begin
                            dmem_we = 0; 
                            rf_ra0 = inst[19:15];
                            rf_ra1 = inst[24:20];
                            alu_src0_sel = 1;
                            alu_src1_sel = 1;
                            rf_wa = inst[11:7];
                            rf_we = 1;
                            imm = 0;
                            rf_wd_sel=1;
                            br_type = 8;
                            dmem_access  = 0;
                            alu_op = 5'B01111;         //srl
                        end
                        3'b110: begin
                            dmem_we = 0; 
                            rf_ra0 = inst[19:15];
                            rf_ra1 = inst[24:20];
                            alu_src0_sel = 1;
                            alu_src1_sel = 1;
                            rf_wa = inst[11:7];
                            rf_we = 1;
                            imm = 0;
                            rf_wd_sel=1;
                            br_type = 8;
                            dmem_access  = 0;
                            alu_op = 5'B01010;         //or
                        end
                        3'b111: begin
                            dmem_we = 0; 
                            rf_ra0 = inst[19:15];
                            rf_ra1 = inst[24:20];
                            alu_src0_sel = 1;
                            alu_src1_sel = 1;
                            rf_wa = inst[11:7];
                            rf_we = 1;
                            imm = 0;
                            rf_wd_sel=1;
                            br_type = 8;
                            dmem_access  = 0;
                            alu_op = 5'B01001;         //and
                        end
                    endcase
                end
                7'b010_0000:begin
                    case(inst[14:12])
                        3'b000: begin
                            dmem_we = 0; 
                            rf_ra0 = inst[19:15];
                            rf_ra1 = inst[24:20];
                            alu_src0_sel = 1;
                            alu_src1_sel = 1;
                            rf_wa = inst[11:7];
                            rf_we = 1;
                            imm = 0;
                            rf_wd_sel=1;
                            br_type = 8;
                            dmem_access  = 0;
                            alu_op = 5'B00010;         //sub
                        end
                        3'b101: begin
                            dmem_we = 0; 
                            rf_ra0 = inst[19:15];
                            rf_ra1 = inst[24:20];
                            alu_src0_sel = 1;
                            alu_src1_sel = 1;
                            rf_wa = inst[11:7];
                            rf_we = 1;
                            imm = 0;
                            rf_wd_sel=1;
                            br_type = 8;
                            dmem_access  = 0;
                            alu_op = 5'B10000;         //sra
                        end
                    endcase
                end
            endcase
        end
        //I-type
        7'b001_0011:begin
            case(inst[14:12])
                3'b000: begin
                    dmem_we = 0; 
                    rf_ra0 = inst[19:15];
                    rf_ra1 = 0;
                    alu_src0_sel = 1;
                    alu_src1_sel = 0;
                    rf_wa = inst[11:7];
                    rf_we = 1;
                    imm = {{20{inst[31]}},inst[31:20]};
                    rf_wd_sel=1;
                    br_type = 8;
                    dmem_access  = 0;
                    alu_op = 5'B00000;                 //addi
                end
                3'b010: begin
                    dmem_we = 0; 
                    rf_ra0 = inst[19:15];
                    rf_ra1 = 0;
                    alu_src0_sel = 1;
                    alu_src1_sel = 0;
                    rf_wa = inst[11:7];
                    rf_we = 1;
                    imm = {{20{inst[31]}},inst[31:20]};
                    rf_wd_sel=1;
                    br_type = 8;
                    dmem_access  = 0;
                    alu_op = 5'B00100;                 //slti
                end
                3'b011: begin
                    dmem_we = 0; 
                    rf_ra0 = inst[19:15];
                    rf_ra1 = 0;
                    alu_src0_sel = 1;
                    alu_src1_sel = 0;
                    rf_wa = inst[11:7];
                    rf_we = 1;
                    imm = {{20{inst[31]}},inst[31:20]};
                    rf_wd_sel=1;
                    br_type = 8;
                    dmem_access  = 0;
                    alu_op = 5'B00101;                 //sltiu
                end
                3'b100: begin
                    dmem_we = 0; 
                    rf_ra0 = inst[19:15];
                    rf_ra1 = 0;
                    alu_src0_sel = 1;
                    alu_src1_sel = 0;
                    rf_wa = inst[11:7];
                    rf_we = 1;
                    imm = {{20{inst[31]}},inst[31:20]};
                    rf_wd_sel=1;
                    br_type = 8;
                    dmem_access  = 0;
                    alu_op = 5'B01011;                 //xori
                end
                3'b110: begin
                    dmem_we = 0; 
                    rf_ra0 = inst[19:15];
                    rf_ra1 = 0;
                    alu_src0_sel = 1;
                    alu_src1_sel = 0;
                    rf_wa = inst[11:7];
                    rf_we = 1;
                    imm = {{20{inst[31]}},inst[31:20]};
                    rf_wd_sel=1;
                    br_type = 8;
                    dmem_access  = 0;
                    alu_op = 5'B01010;                 //ori
                end
                3'b111: begin
                    dmem_we = 0; 
                    rf_ra0 = inst[19:15];
                    rf_ra1 = 0;
                    alu_src0_sel = 1;
                    alu_src1_sel = 0;
                    rf_wa = inst[11:7];
                    rf_we = 1;
                    imm = {{20{inst[31]}},inst[31:20]};
                    rf_wd_sel=1;
                    br_type = 8;
                    dmem_access  = 0;
                    alu_op = 5'B01001;                 //andi
                end
                3'b001: begin
                    dmem_we = 0; 
                    rf_ra0 = inst[19:15];
                    rf_ra1 = 0;
                    alu_src0_sel = 1;
                    alu_src1_sel = 0;
                    rf_wa = inst[11:7];
                    rf_we = 1;
                    imm = inst[24:20];
                    rf_wd_sel=1;
                    br_type = 8;
                    dmem_access  = 0;
                    alu_op = 5'B01110;                 //slli
                end
                3'b101:begin
                    case(inst[31:25])
                        7'b000_0000: begin
                            dmem_we = 0; 
                            rf_ra0 = inst[19:15];
                            rf_ra1 = 0;
                            alu_src0_sel = 1;
                            alu_src1_sel = 0;
                            rf_wa = inst[11:7];
                            rf_we = 1;
                            imm = inst[24:20];
                            rf_wd_sel=1;
                            br_type = 8;
                            dmem_access  = 0;
                            alu_op = 5'B01111;    //srli
                        end
                        7'b010_0000: begin
                            dmem_we = 0; 
                            rf_ra0 = inst[19:15];
                            rf_ra1 = 0;
                            alu_src0_sel = 1;
                            alu_src1_sel = 0;
                            rf_wa = inst[11:7];
                            rf_we = 1;
                            imm = inst[24:20];
                            rf_wd_sel=1;
                            br_type = 8;
                            dmem_access  = 0;
                            alu_op = 5'B10000;    //srai
                        end
                    endcase
                end
            endcase
        end
        //I-type
        7'b000_0011:begin
            case(inst[14:12])
                3'b000:begin
                    dmem_we = 0; 
                    rf_ra0 =inst[19:15];
                    rf_ra1 =0;
                    alu_src0_sel=1;
                    alu_src1_sel=0;
                    rf_wa=inst[11:7];
                    rf_we=1;
                    imm={{20{inst[31]}},inst[31:20]};
                    rf_wd_sel=2;
                    br_type = 8;
                    dmem_access  = 1;
                    alu_op= 5'B00000;
                    //lb
                end
                3'b001:begin
                    dmem_we = 0; 
                    rf_ra0 =inst[19:15];
                    rf_ra1 =0;
                    alu_src0_sel=1;
                    alu_src1_sel=0;
                    rf_wa=inst[11:7];
                    rf_we=1;
                    imm={{20{inst[31]}},inst[31:20]};
                    rf_wd_sel=2;
                    br_type = 8;
                    dmem_access  = 2;
                    alu_op= 5'B00000;
                    //lh
                end
                3'b010:begin
                    dmem_we = 0; 
                    rf_ra0 =inst[19:15];
                    rf_ra1 =0;
                    alu_src0_sel=1;
                    alu_src1_sel=0;
                    rf_wa=inst[11:7];
                    rf_we=1;
                    imm={{20{inst[31]}},inst[31:20]};
                    rf_wd_sel=2;
                    br_type = 8;
                    dmem_access  = 3;
                    alu_op= 5'B00000;
                    //lw
                end
                3'b100:begin
                    dmem_we = 0; 
                    rf_ra0 =inst[19:15];
                    rf_ra1 =0;
                    alu_src0_sel=1;
                    alu_src1_sel=0;
                    rf_wa=inst[11:7];
                    rf_we=1;
                    imm={{20{inst[31]}},inst[31:20]};
                    rf_wd_sel=2;
                    br_type = 8;
                    dmem_access  = 4;
                    alu_op= 5'B00000;
                    //lbu
                end
                3'b101:begin
                    dmem_we = 0; 
                    rf_ra0 =inst[19:15];
                    rf_ra1 =0;
                    alu_src0_sel=1;
                    alu_src1_sel=0;
                    rf_wa=inst[11:7];
                    rf_we=1;
                    imm={{20{inst[31]}},inst[31:20]};
                    rf_wd_sel=2;
                    br_type = 8;
                    dmem_access  = 5;
                    alu_op= 5'B00000;
                    //lhu
                end
            endcase
        end
        //S-type
        7'b010_0011: begin
            case(inst[14:12])
                3'b000:begin
                    dmem_we = 1; 
                    rf_ra0 =inst[19:15];
                    rf_ra1 =inst[24:20];
                    alu_src0_sel=1;
                    alu_src1_sel=0;
                    rf_wa=0;
                    rf_we=0;
                    imm={{20{inst[31]}},inst[31:25],inst[11:7]};
                    rf_wd_sel=3;
                    br_type = 8;
                    dmem_access  = 6;
                    alu_op= 5'B00000;
                    //sb
                end
                3'b001:begin
                    dmem_we = 1; 
                    rf_ra0 =inst[19:15];
                    rf_ra1 =inst[24:20];
                    alu_src0_sel=1;
                    alu_src1_sel=0;
                    rf_wa=0;
                    rf_we=0;
                    imm={{20{inst[31]}},inst[31:25],inst[11:7]};
                    rf_wd_sel=3;
                    br_type = 8;
                    dmem_access  = 7;
                    alu_op= 5'B00000;
                    //sh
                end
                3'b010:begin
                    dmem_we = 1; 
                    rf_ra0 =inst[19:15];
                    rf_ra1 =inst[24:20];
                    alu_src0_sel=1;
                    alu_src1_sel=0;
                    rf_wa=0;
                    rf_we=0;
                    imm={{20{inst[31]}},inst[31:25],inst[11:7]};
                    rf_wd_sel=3;
                    br_type = 8;
                    dmem_access  = 8;
                    alu_op= 5'B00000;
                    //sw
                end
            endcase
        end
        //J-type
        7'b110_1111: begin
            dmem_we = 0; 
            rf_ra0 =0;
            rf_ra1 =0;
            alu_src0_sel=0;
            alu_src1_sel=0;
            rf_wa=inst[11:7];
            rf_we=1;
            imm={{12{inst[31]}},inst[31],inst[19:12],inst[20],inst[30:21]}<<1;
            rf_wd_sel=0;
            br_type = 0;
            dmem_access  = 0;
            alu_op= 5'B00000;
            //jal
        end
        //I-type
        7'b110_0111:begin
            dmem_we = 0; 
            rf_ra0 =inst[19:15];
            rf_ra1 =0;
            alu_src0_sel=1;
            alu_src1_sel=0;
            rf_wa=inst[11:7];
            rf_we=1;
            imm={{20{inst[31]}},inst[31:20]};
            rf_wd_sel=0;
            br_type = 1;
            dmem_access  = 0;
            alu_op= 5'B00000;
            //jalr            
        end
        //B-type
        7'b110_0011:begin
            case(inst[14:12])
                3'b000:begin
                    dmem_we = 0; 
                    rf_ra0 =inst[19:15];
                    rf_ra1 =inst[24:20];
                    alu_src0_sel=0;
                    alu_src1_sel=0;
                    rf_wa=0;
                    rf_we=0;
                    imm={{20{inst[31]}},inst[31],inst[7],inst[30:25],inst[11:8]}<<1;
                    rf_wd_sel=1;
                    br_type = 2;
                    dmem_access  = 0;
                    alu_op= 5'B00000;
                    //beq
                end
                3'b001:begin
                    dmem_we = 0; 
                    rf_ra0 =inst[19:15];
                    rf_ra1 =inst[24:20];
                    alu_src0_sel=0;
                    alu_src1_sel=0;
                    rf_wa=0;
                    rf_we=0;
                    imm={{20{inst[31]}},inst[31],inst[7],inst[30:25],inst[11:8]}<<1;
                    rf_wd_sel=1;
                    br_type = 3;
                    dmem_access  = 0;
                    alu_op= 5'B00000;
                    //bne  
                end
                3'b100:begin
                    dmem_we = 0; 
                    rf_ra0 =inst[19:15];
                    rf_ra1 =inst[24:20];
                    alu_src0_sel=0;
                    alu_src1_sel=0;
                    rf_wa=0;
                    rf_we=0;
                    imm={{20{inst[31]}},inst[31],inst[7],inst[30:25],inst[11:8]}<<1;
                    rf_wd_sel=1;
                    br_type = 4;
                    dmem_access  = 0;
                    alu_op= 5'B00000;
                    //blt                    
                end
                3'b101:begin
                    dmem_we = 0; 
                    rf_ra0 =inst[19:15];
                    rf_ra1 =inst[24:20];
                    alu_src0_sel=0;
                    alu_src1_sel=0;
                    rf_wa=0;
                    rf_we=0;
                    imm={{20{inst[31]}},inst[31],inst[7],inst[30:25],inst[11:8]}<<1;
                    rf_wd_sel=1;
                    br_type = 5;
                    dmem_access  = 0;
                    alu_op= 5'B00000;
                    //bge                    
                end
                3'b110:begin
                    dmem_we = 0; 
                    rf_ra0 =inst[19:15];
                    rf_ra1 =inst[24:20];
                    alu_src0_sel=0;
                    alu_src1_sel=0;
                    rf_wa=0;
                    rf_we=0;
                    imm={{20{inst[31]}},inst[31],inst[7],inst[30:25],inst[11:8]}<<1;
                    rf_wd_sel=1;
                    br_type = 6;
                    dmem_access  = 0;
                    alu_op= 5'B00000;
                    //bltu                
                end
                3'b111:begin
                    dmem_we = 0; 
                    rf_ra0 =inst[19:15];
                    rf_ra1 =inst[24:20];
                    alu_src0_sel=0;
                    alu_src1_sel=0;
                    rf_wa=0;
                    rf_we=0;
                    imm={{20{inst[31]}},inst[31],inst[7],inst[30:25],inst[11:8]}<<1;
                    rf_wd_sel=1;
                    br_type = 7;
                    dmem_access  = 0;
                    alu_op= 5'B00000;
                    //bgeu
                end
            endcase
        end
        //U-type
        7'b011_0111: begin
            dmem_we = 0; 
            rf_ra0 = 0;
            rf_ra1 = 0;
            alu_src0_sel = 1;
            alu_src1_sel = 0;
            rf_wa = inst[11:7];
            rf_we = 1;
            imm = {{12{inst[31]}},inst[31:12]}<<12;
            rf_wd_sel=1;
            br_type = 8;
            dmem_access  = 0;
            alu_op = 5'B10010;                    //lui
        end
        7'b001_0111: begin
            dmem_we = 0; 
            rf_ra0 = 0;
            rf_ra1 = 0;
            alu_src0_sel = 0;
            alu_src1_sel = 0;
            rf_wa = inst[11:7];
            rf_we = 1;
            imm = {{12{inst[31]}},inst[31:12]}<<12;
            rf_wd_sel=1;
            br_type = 8;
            dmem_access  = 0;
            alu_op = 5'B00000;                    //auipc
        end
    endcase
end
endmodule
