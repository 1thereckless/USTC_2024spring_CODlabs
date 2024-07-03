`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/08 15:23:25
// Design Name: 
// Module Name: SLU
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

module SLU (
    input                   [31 : 0]                addr,
    input                   [ 3 : 0]                dmem_access,//0:非访存,1:lb,2:lh,3:lw,4:lbu,5:lhu,6:sb,7:sh,8:sw

    input                   [31 : 0]                rd_in,
    input                   [31 : 0]                wd_in,
     
    output      reg         [31 : 0]                rd_out,
    output      reg         [31 : 0]                wd_out
);
reg [1:0] mod;
always @(*)begin
    case(addr%4)
        0:mod=0;
        1:mod=1;
        2:mod=2;
        3:mod=3;
    endcase
end
always @(*)begin
    case(dmem_access)
        0:begin
        end//非访存
        1:begin
            case(mod)
                0:rd_out={{24{rd_in[7]}},rd_in[7:0]};
                1:rd_out={{24{rd_in[15]}},rd_in[15:8]};
                2:rd_out={{24{rd_in[23]}},rd_in[23:16]};
                3:rd_out={{24{rd_in[31]}},rd_in[31:24]};
            endcase
        end//lb
        2:begin
            case(mod)
                0:rd_out={{16{rd_in[15]}},rd_in[15:0]};
                1:rd_out=rd_in;
                2:rd_out={{16{rd_in[31]}},rd_in[31:16]};
                3:rd_out=rd_in;
            endcase
        end//lh
        3:begin
            rd_out = rd_in;
        end//lw
        4:begin
            case(mod)
                0:rd_out={{24{1'b0}},rd_in[7:0]};
                1:rd_out={{24{1'b0}},rd_in[15:8]};
                2:rd_out={{24{1'b0}},rd_in[23:16]};
                3:rd_out={{24{1'b0}},rd_in[31:24]};
            endcase
        end//lbu
        5:begin
            case(mod)
                0:rd_out={{16{1'b0}},rd_in[15:0]};
                1:rd_out=rd_in;
                2:rd_out={{16{1'b0}},rd_in[31:16]};
                3:rd_out=rd_in;
            endcase
        end//lhu
        6:begin
            case(mod)
                0:wd_out={rd_in[31:8],wd_in[7:0]};
                1:wd_out={rd_in[31:16],wd_in[7:0],rd_in[7:0]};
                2:wd_out={rd_in[31:24],wd_in[7:0],rd_in[15:0]};
                3:wd_out={wd_in[7:0],rd_in[23:0]};
            endcase
        end//sb
        7:begin
            case(mod)
                0:wd_out={rd_in[31:16],wd_in[15:0]};
                1:wd_out= wd_in;
                2:wd_out={wd_in[15:0],rd_in[15:0]};
                3:wd_out= wd_in;
            endcase
        end//sh
        8:begin
            wd_out = wd_in;
        end//sw
        default:begin
        end
    endcase
end
endmodule