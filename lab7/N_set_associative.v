`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/28 20:45:24
// Design Name: 
// Module Name: N_set_associative
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


module N_set_associative #(
    parameter INDEX_WIDTH       = 3,    // Cache索引位宽 2^3=8行
    parameter LINE_OFFSET_WIDTH = 2,    // 行偏移位宽，决定了一行的宽度 2^2=4字
    parameter SPACE_OFFSET      = 2,    // 一个地址空间占1个字节，因此一个字需要4个地址空间，由于假设为整字读取，处理地址的时候可以默认后两位为0
    parameter WAY_NUM           = 16     // Cache N路组相联(N=1的时候是直接映射)
)(
    input                     clk,    
    input                     rstn,
    /* CPU接口 */  
    input [31:0]              addr,   // CPU地址
    input                     r_req,  // CPU读请求
    input                     w_req,  // CPU写请求
    input [31:0]              w_data,  // CPU写数据
    output [31:0]             r_data,  // CPU读数据
    output reg                miss,   // 缓存未命中
    /* 内存接口 */  
    output reg                     mem_r,  // 内存读请求
    output reg                     mem_w,  // 内存写请求
    output reg [31:0]              mem_addr,  // 内存地址
    output reg [127:0] mem_w_data,  // 内存写数据 一次写一行
    input      [127:0] mem_r_data,  // 内存读数据 一次读一行
    input                          mem_ready  // 内存就绪信号
);

    // Cache参数
    localparam
        // Cache行宽度
        LINE_WIDTH = 32 << LINE_OFFSET_WIDTH,
        // 标记位宽度
        TAG_WIDTH = 32 - INDEX_WIDTH - LINE_OFFSET_WIDTH - SPACE_OFFSET,
        // Cache行数
        SET_NUM   = 1 << INDEX_WIDTH;
    
    // Cache相关寄存器
    reg [31:0]           addr_buf;    // 请求地址缓存-用于保留CPU请求地址
    reg [31:0]           w_data_buf;  // 写数据缓存
    reg op_buf;  // 读写操作缓存，用于在MISS状态下判断是读还是写，如果是写则需要将数据写回内存 0:读 1:写
    reg [LINE_WIDTH-1:0] ret_buf;     // 返回数据缓存-用于保留内存返回数据

    // Cache导线
    wire [INDEX_WIDTH-1:0] r_index;  // 索引读地址
    wire [INDEX_WIDTH-1:0] w_index;  // 索引写地址
    wire [LINE_WIDTH-1:0]  r_line_1;   // Data Bram读数据
    wire [LINE_WIDTH-1:0]  r_line_2;
    wire [LINE_WIDTH-1:0]  r_line_3;
    wire [LINE_WIDTH-1:0]  r_line_4;
    wire [LINE_WIDTH-1:0]  r_line_5;
    wire [LINE_WIDTH-1:0]  r_line_6;
    wire [LINE_WIDTH-1:0]  r_line_7;
    wire [LINE_WIDTH-1:0]  r_line_8;
    wire [LINE_WIDTH-1:0]  r_line_9;
    wire [LINE_WIDTH-1:0]  r_line_10;
    wire [LINE_WIDTH-1:0]  r_line_11;
    wire [LINE_WIDTH-1:0]  r_line_12;
    wire [LINE_WIDTH-1:0]  r_line_13;
    wire [LINE_WIDTH-1:0]  r_line_14;
    wire [LINE_WIDTH-1:0]  r_line_15;
    wire [LINE_WIDTH-1:0]  r_line_16;
    wire [LINE_WIDTH-1:0]  r_line;
    wire [LINE_WIDTH-1:0]  w_line;   // Data Bram写数据
    wire [LINE_WIDTH-1:0]  w_line_mask;  // Data Bram写数据掩码
    wire [LINE_WIDTH-1:0]  w_data_line;  // 输入写数据移位后的数据
    wire [TAG_WIDTH-1:0]   tag;      // CPU请求地址中分离的标记 用于比较 也可用于写入
    wire [TAG_WIDTH-1:0]   r_tag_1;    // Tag Bram读数据 用于比较
    wire [TAG_WIDTH-1:0]   r_tag_2;
    wire [TAG_WIDTH-1:0]   r_tag_3;
    wire [TAG_WIDTH-1:0]   r_tag_4;
    wire [TAG_WIDTH-1:0]   r_tag_5;
    wire [TAG_WIDTH-1:0]   r_tag_6;
    wire [TAG_WIDTH-1:0]   r_tag_7;
    wire [TAG_WIDTH-1:0]   r_tag_8;
    wire [TAG_WIDTH-1:0]   r_tag_9;
    wire [TAG_WIDTH-1:0]   r_tag_10;
    wire [TAG_WIDTH-1:0]   r_tag_11;
    wire [TAG_WIDTH-1:0]   r_tag_12;
    wire [TAG_WIDTH-1:0]   r_tag_13;
    wire [TAG_WIDTH-1:0]   r_tag_14;
    wire [TAG_WIDTH-1:0]   r_tag_15;
    wire [TAG_WIDTH-1:0]   r_tag_16;
    wire [LINE_OFFSET_WIDTH-1:0] word_offset;  // 字偏移
    reg  [31:0]            cache_data;  // Cache数据
    reg  [31:0]            mem_data;    // 内存数据
    wire [31:0]            dirty_mem_addr; // 通过读出的tag和对应的index，偏移等得到脏块对应的内存地址并写回到正确的位置
    wire valid_1;  // Cache有效位
    wire valid_2;
    wire valid_3;
    wire valid_4;
    wire valid_5;
    wire valid_6;
    wire valid_7;
    wire valid_8;
    wire valid_9;
    wire valid_10;
    wire valid_11;
    wire valid_12;
    wire valid_13;
    wire valid_14;
    wire valid_15;
    wire valid_16;
    wire dirty;
    wire dirty_1;  // Cache脏位.
    wire dirty_2;
    wire dirty_3;
    wire dirty_4;
    wire dirty_5;
    wire dirty_6;
    wire dirty_7;
    wire dirty_8;
    wire dirty_9;
    wire dirty_10;
    wire dirty_11;
    wire dirty_12;
    wire dirty_13;
    wire dirty_14;
    wire dirty_15;
    wire dirty_16;
    reg  w_valid;  // Cache写有效位
    reg  w_dirty;  // Cache写脏位
    wire hit;
    wire hit_1;    // Cache命中
    wire hit_2; 
    wire hit_3; 
    wire hit_4; 
    wire hit_5; 
    wire hit_6; 
    wire hit_7; 
    wire hit_8; 
    wire hit_9; 
    wire hit_10; 
    wire hit_11; 
    wire hit_12; 
    wire hit_13; 
    wire hit_14; 
    wire hit_15;
    wire hit_16; 

    // Cache相关控制信号
    reg addr_buf_we;  // 请求地址缓存写使能
    reg ret_buf_we;   // 返回数据缓存写使能
    reg data_we_1;      // Cache写使能
    reg data_we_2;
    reg data_we_3;
    reg data_we_4;
    reg data_we_5;
    reg data_we_6;
    reg data_we_7;
    reg data_we_8;
    reg data_we_9;
    reg data_we_10;
    reg data_we_11;
    reg data_we_12;
    reg data_we_13;
    reg data_we_14;
    reg data_we_15;
    reg data_we_16;
    reg tag_we_1;       // Cache标记写使能
    reg tag_we_2;
    reg tag_we_3;
    reg tag_we_4;
    reg tag_we_5;
    reg tag_we_6;
    reg tag_we_7;
    reg tag_we_8;
    reg tag_we_9;
    reg tag_we_10;
    reg tag_we_11;
    reg tag_we_12;
    reg tag_we_13;
    reg tag_we_14;
    reg tag_we_15;
    reg tag_we_16;
    reg data_from_mem;  // 从内存读取数据
    reg refill;       // 标记需要重新填充，在MISS状态下接受到内存数据后置1,在IDLE状态下进行填充后置0

    reg [SET_NUM*16-1:0] age;
    reg [3:0] line_sel,line_sel_ready;

    //利用树的特点,age为1表示更年轻
    always @(posedge clk) begin
        //8
        if(hit_1||hit_2||hit_3||hit_4||hit_5||hit_6||hit_7||hit_8 != 0 || line_sel <= 7)begin
            age[r_index*16+0] <= 0;
        end
        else if(hit_9||hit_10||hit_11||hit_12||hit_13||hit_14||hit_15||hit_16 != 0 || line_sel<=15)begin
            age[r_index*16+0] <= 1;
        end
        //4
        if(hit_1||hit_2||hit_3||hit_4 != 0 || line_sel <= 3)begin
            age[r_index*16+1] <= 0;
        end
        else if(hit_5||hit_6||hit_7||hit_8 != 0 || line_sel <= 7)begin
            age[r_index*16+1] <= 1;
        end
        else if(hit_9||hit_10||hit_11||hit_12 != 0 || line_sel <= 11)begin
            age[r_index*16+2] <= 0;
        end
        else if(hit_13||hit_14||hit_15||hit_16!= 0 || line_sel <=15)begin
            age[r_index*16+2] <= 1;
        end
        //2
        if(hit_1||hit_2 != 0 || line_sel <= 1)begin
            age[r_index*16+3] <= 0;
        end
        else if(hit_3||hit_4 != 0 || line_sel <= 3)begin
            age[r_index*16+3] <= 1;
        end
        else if(hit_5||hit_6 != 0 || line_sel <= 5)begin
            age[r_index*16+4] <= 0;
        end
        else if(hit_7||hit_8 != 0 || line_sel <= 7)begin
            age[r_index*16+4] <= 1;
        end
        else if(hit_9||hit_10 != 0 || line_sel <= 9)begin
            age[r_index*16+5] <= 0;
        end
        else if(hit_11||hit_12 != 0 || line_sel <= 11)begin
            age[r_index*16+5] <= 1;
        end
        else if(hit_13||hit_14 != 0 || line_sel <= 13)begin
            age[r_index*16+6] <= 0;
        end
        else if(hit_15||hit_16 != 0 || line_sel <= 15)begin
            age[r_index*16+6] <= 1;
        end
        //1
        if(hit_1 != 0 || line_sel <= 0)begin
            age[r_index*16+7] <= 0;
        end
        else if(hit_2 != 0 || line_sel <= 1)begin
            age[r_index*16+7] <= 1;
        end
        else if(hit_3 != 0 || line_sel <= 2)begin
            age[r_index*16+8] <= 0;
        end
        else if(hit_4 != 0 || line_sel <= 3)begin
            age[r_index*16+8] <= 1;
        end
        else if(hit_5 != 0 || line_sel <= 4)begin
            age[r_index*16+9] <= 0;
        end
        else if(hit_6 != 0 || line_sel <= 5)begin
            age[r_index*16+9] <= 1;
        end
        else if(hit_7 != 0 || line_sel <= 6)begin
            age[r_index*16+10] <= 0;
        end
        else if(hit_8 != 0 || line_sel <= 7)begin
            age[r_index*16+10] <= 1;
        end
        else if(hit_9 != 0 || line_sel <= 8)begin
            age[r_index*16+11] <= 0;
        end
        else if(hit_10 != 0 || line_sel <= 9)begin
            age[r_index*16+11] <= 1;
        end
        else if(hit_11 != 0 || line_sel <= 10)begin
            age[r_index*16+12] <= 0;
        end
        else if(hit_12 != 0 || line_sel <= 11)begin
            age[r_index*16+12] <= 1;
        end
        else if(hit_13 != 0 || line_sel <= 12)begin
            age[r_index*16+13] <= 0;
        end
        else if(hit_14 != 0 || line_sel <= 13)begin
            age[r_index*16+13] <= 1;
        end
        else if(hit_15 != 0 || line_sel <= 14)begin
            age[r_index*16+14] <= 0;
        end
        else if(hit_16 != 0 || line_sel <= 15)begin
            age[r_index*16+14] <= 1;
        end
    end
    //age为1表示更年轻
    always @(posedge clk) begin
        if(WAY_NUM==1)begin
            line_sel_ready <= 0;
        end

        if(WAY_NUM==2)begin
            if(age[r_index*16+7])begin
                line_sel_ready <= 0;
            end
            else begin
                line_sel_ready <= 1;
            end
        end

        if(WAY_NUM==4)begin
            if(age[r_index*16+3])begin
                if(age[r_index*16+7])begin
                    line_sel_ready <= 0;
                end
                else begin
                    line_sel_ready <= 1;
                end
            end
            else begin
                if(age[r_index*16+8])begin
                    line_sel_ready <= 2;
                end
                else begin
                    line_sel_ready <= 3;
                end
            end
        end

        if (WAY_NUM==8) begin
            if(age[r_index*16+1])begin
                if(age[r_index*16+3])begin
                    if(age[r_index*16+7])begin
                        line_sel_ready <= 0;
                    end
                    else begin
                        line_sel_ready <= 1;
                    end
                end
                else begin
                    if(age[r_index*16+8])begin
                        line_sel_ready <= 2;
                    end
                    else begin
                        line_sel_ready <= 3;
                    end
                end
            end
            else begin
                if(age[r_index*16+4])begin
                    if(age[r_index*16+9])begin
                        line_sel_ready <= 4; 
                    end
                    else begin
                        line_sel_ready <= 5;
                    end
                end
                else begin
                    if(age[r_index*16+10])begin
                        line_sel_ready <= 6; 
                    end
                    else begin
                        line_sel_ready <= 7;
                    end
                end
            end
        end

        if(WAY_NUM==16)begin
            if(age[r_index*16+0])begin
                if(age[r_index*16+1])begin
                    if(age[r_index*16+3])begin
                        if(age[r_index*16+7])begin
                            line_sel_ready <= 0;
                        end
                        else begin
                            line_sel_ready <= 1;
                        end
                    end
                    else begin
                        if(age[r_index*16+8])begin
                            line_sel_ready <= 2;
                        end
                        else begin
                            line_sel_ready <= 3;
                        end
                    end
                end
                else begin
                    if(age[r_index*16+4])begin
                        if(age[r_index*16+9])begin
                            line_sel_ready <= 4; 
                        end
                        else begin
                            line_sel_ready <= 5;
                        end
                    end
                    else begin
                        if(age[r_index*16+10])begin
                            line_sel_ready <= 6; 
                        end
                        else begin
                            line_sel_ready <= 7;
                        end
                    end
                end
            end
            else begin
                if(age[r_index*16+2])begin
                    if(age[r_index*16+5])begin
                        if(age[r_index*16+11])begin
                            line_sel_ready <= 8;
                        end
                        else begin
                            line_sel_ready <= 9;
                        end
                    end
                    else begin
                        if(age[r_index*16+12])begin
                            line_sel_ready <= 10;
                        end
                        else begin
                            line_sel_ready <= 11;
                        end
                    end
                end
                else begin
                    if(age[r_index*16+6])begin
                        if(age[r_index*16+13])begin
                            line_sel_ready <= 12; 
                        end
                        else begin
                            line_sel_ready <= 13;
                        end
                    end
                    else begin
                        if(age[r_index*16+14])begin
                            line_sel_ready <= 14; 
                        end
                        else begin
                            line_sel_ready <= 15;
                        end
                    end
                end
            end
        end
    end
    // 状态机信号
    localparam 
        IDLE      = 3'd0,  // 空闲状态
        READ      = 3'd1,  // 读状态
        MISS      = 3'd2,  // 缺失时等待主存读出新块
        WRITE     = 3'd3,  // 写状态
        W_DIRTY   = 3'd4;  // 写缺失时等待主存写入脏块
    reg [2:0] CS;  // 状态机当前状态
    reg [2:0] NS;  // 状态机下一状态

    // 状态机
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            CS <= IDLE;
        end else begin
            CS <= NS;
        end
    end

    // 中间寄存器保留初始的请求地址和写数据，可以理解为addr_buf中的地址为当前Cache正在处理的请求地址，而addr中的地址为新的请求地址
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            addr_buf <= 0;
            ret_buf <= 0;
            w_data_buf <= 0;
            op_buf <= 0;
            refill <= 0;
            age <=0;
        end else begin
            if (addr_buf_we) begin
                addr_buf <= addr;
                w_data_buf <= w_data;
                op_buf <= w_req;
                line_sel <= line_sel_ready;
            end
            if (ret_buf_we) begin
                ret_buf <= mem_r_data;
            end
            if (CS == MISS && mem_ready) begin
                refill <= 1;
            end
            if (CS == IDLE) begin
                refill <= 0;
            end
        end
    end

    // 对输入地址进行解码
    assign r_index = addr[INDEX_WIDTH+LINE_OFFSET_WIDTH+SPACE_OFFSET - 1: LINE_OFFSET_WIDTH+SPACE_OFFSET];
    assign w_index = addr_buf[INDEX_WIDTH+LINE_OFFSET_WIDTH+SPACE_OFFSET - 1: LINE_OFFSET_WIDTH+SPACE_OFFSET];
    assign tag = addr_buf[31:INDEX_WIDTH+LINE_OFFSET_WIDTH+SPACE_OFFSET];
    assign word_offset = addr_buf[LINE_OFFSET_WIDTH+SPACE_OFFSET-1:SPACE_OFFSET];

    // 脏块地址计算
    assign dirty_mem_addr = line_sel == 4'd0 ? {r_tag_1, w_index}<<(LINE_OFFSET_WIDTH+SPACE_OFFSET) : 
                            line_sel == 4'd1 ? {r_tag_2, w_index}<<(LINE_OFFSET_WIDTH+SPACE_OFFSET) :
                            line_sel == 4'd2 ? {r_tag_3, w_index}<<(LINE_OFFSET_WIDTH+SPACE_OFFSET) :
                            line_sel == 4'd3 ? {r_tag_4, w_index}<<(LINE_OFFSET_WIDTH+SPACE_OFFSET) :
                            line_sel == 4'd4 ? {r_tag_5, w_index}<<(LINE_OFFSET_WIDTH+SPACE_OFFSET) :
                            line_sel == 4'd5 ? {r_tag_6, w_index}<<(LINE_OFFSET_WIDTH+SPACE_OFFSET) :
                            line_sel == 4'd6 ? {r_tag_7, w_index}<<(LINE_OFFSET_WIDTH+SPACE_OFFSET) :
                            line_sel == 4'd7 ? {r_tag_8, w_index}<<(LINE_OFFSET_WIDTH+SPACE_OFFSET) :
                            line_sel == 4'd8 ? {r_tag_9, w_index}<<(LINE_OFFSET_WIDTH+SPACE_OFFSET) :
                            line_sel == 4'd9 ? {r_tag_10, w_index}<<(LINE_OFFSET_WIDTH+SPACE_OFFSET) :
                            line_sel == 4'd10 ? {r_tag_11, w_index}<<(LINE_OFFSET_WIDTH+SPACE_OFFSET) :
                            line_sel == 4'd11 ? {r_tag_12, w_index}<<(LINE_OFFSET_WIDTH+SPACE_OFFSET) :
                            line_sel == 4'd12 ? {r_tag_13, w_index}<<(LINE_OFFSET_WIDTH+SPACE_OFFSET) :
                            line_sel == 4'd13 ? {r_tag_14, w_index}<<(LINE_OFFSET_WIDTH+SPACE_OFFSET) :
                            line_sel == 4'd14 ? {r_tag_15, w_index}<<(LINE_OFFSET_WIDTH+SPACE_OFFSET) :
                            line_sel == 4'd15 ? {r_tag_16, w_index}<<(LINE_OFFSET_WIDTH+SPACE_OFFSET) :
                                        {{(TAG_WIDTH){1'b0}},w_index}<<(LINE_OFFSET_WIDTH+SPACE_OFFSET);

    // 写回地址、数据寄存器
    reg [31:0] dirty_mem_addr_buf;
    reg [127:0] dirty_mem_data_buf;
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            dirty_mem_addr_buf <= 0;
            dirty_mem_data_buf <= 0;
        end else begin
            if (CS == READ || CS == WRITE) begin
                dirty_mem_addr_buf <= dirty_mem_addr;
                case(line_sel)
                    4'd0:dirty_mem_data_buf <= r_line_1;
                    4'd1:dirty_mem_data_buf <= r_line_2;
                    4'd2:dirty_mem_data_buf <= r_line_3;
                    4'd3:dirty_mem_data_buf <= r_line_4;
                    4'd4:dirty_mem_data_buf <= r_line_5;
                    4'd5:dirty_mem_data_buf <= r_line_6;
                    4'd6:dirty_mem_data_buf <= r_line_7;
                    4'd7:dirty_mem_data_buf <= r_line_8;
                    4'd8:dirty_mem_data_buf <= r_line_9;
                    4'd9:dirty_mem_data_buf <= r_line_10;
                    4'd10:dirty_mem_data_buf <= r_line_11;
                    4'd11:dirty_mem_data_buf <= r_line_12;
                    4'd12:dirty_mem_data_buf <= r_line_13;
                    4'd13:dirty_mem_data_buf <= r_line_14;
                    4'd14:dirty_mem_data_buf <= r_line_15;
                    4'd15:dirty_mem_data_buf <= r_line_16;
                    default:;
                endcase
            end
        end
    end

    // Tag Bram
    bram #(
        .ADDR_WIDTH(INDEX_WIDTH),
        .DATA_WIDTH(TAG_WIDTH + 2) // 最高位为有效位，次高位为脏位，低位为标记位
    ) tag_bram_1(
        .clk(clk),
        .raddr(r_index),
        .waddr(w_index),
        .din({w_valid, w_dirty, tag}),
        .we(tag_we_1),
        .dout({valid_1, dirty_1, r_tag_1})
    );
    bram #(
        .ADDR_WIDTH(INDEX_WIDTH),
        .DATA_WIDTH(TAG_WIDTH + 2) // 最高位为有效位，次高位为脏位，低位为标记位
    ) tag_bram_2(
        .clk(clk),
        .raddr(r_index),
        .waddr(w_index),
        .din({w_valid, w_dirty, tag}),
        .we(tag_we_2),
        .dout({valid_2, dirty_2, r_tag_2})
    );
    bram #(
        .ADDR_WIDTH(INDEX_WIDTH),
        .DATA_WIDTH(TAG_WIDTH + 2) // 最高位为有效位，次高位为脏位，低位为标记位
    ) tag_bram_3(
        .clk(clk),
        .raddr(r_index),
        .waddr(w_index),
        .din({w_valid, w_dirty, tag}),
        .we(tag_we_3),
        .dout({valid_3, dirty_3, r_tag_3})
    );
    bram #(
        .ADDR_WIDTH(INDEX_WIDTH),
        .DATA_WIDTH(TAG_WIDTH + 2) // 最高位为有效位，次高位为脏位，低位为标记位
    ) tag_bram_4(
        .clk(clk),
        .raddr(r_index),
        .waddr(w_index),
        .din({w_valid, w_dirty, tag}),
        .we(tag_we_4),
        .dout({valid_4, dirty_4, r_tag_4})
    );
    bram #(
        .ADDR_WIDTH(INDEX_WIDTH),
        .DATA_WIDTH(TAG_WIDTH + 2) // 最高位为有效位，次高位为脏位，低位为标记位
    ) tag_bram_5(
        .clk(clk),
        .raddr(r_index),
        .waddr(w_index),
        .din({w_valid, w_dirty, tag}),
        .we(tag_we_5),
        .dout({valid_5, dirty_5, r_tag_5})
    );
    bram #(
        .ADDR_WIDTH(INDEX_WIDTH),
        .DATA_WIDTH(TAG_WIDTH + 2) // 最高位为有效位，次高位为脏位，低位为标记位
    ) tag_bram_6(
        .clk(clk),
        .raddr(r_index),
        .waddr(w_index),
        .din({w_valid, w_dirty, tag}),
        .we(tag_we_6),
        .dout({valid_6, dirty_6, r_tag_6})
    );
    bram #(
        .ADDR_WIDTH(INDEX_WIDTH),
        .DATA_WIDTH(TAG_WIDTH + 2) // 最高位为有效位，次高位为脏位，低位为标记位
    ) tag_bram_7(
        .clk(clk),
        .raddr(r_index),
        .waddr(w_index),
        .din({w_valid, w_dirty, tag}),
        .we(tag_we_7),
        .dout({valid_7, dirty_7, r_tag_7})
    );
    bram #(
        .ADDR_WIDTH(INDEX_WIDTH),
        .DATA_WIDTH(TAG_WIDTH + 2) // 最高位为有效位，次高位为脏位，低位为标记位
    ) tag_bram_8(
        .clk(clk),
        .raddr(r_index),
        .waddr(w_index),
        .din({w_valid, w_dirty, tag}),
        .we(tag_we_8),
        .dout({valid_8, dirty_8, r_tag_8})
    );
    bram #(
        .ADDR_WIDTH(INDEX_WIDTH),
        .DATA_WIDTH(TAG_WIDTH + 2) // 最高位为有效位，次高位为脏位，低位为标记位
    ) tag_bram_9(
        .clk(clk),
        .raddr(r_index),
        .waddr(w_index),
        .din({w_valid, w_dirty, tag}),
        .we(tag_we_9),
        .dout({valid_9, dirty_9, r_tag_9})
    );
    bram #(
        .ADDR_WIDTH(INDEX_WIDTH),
        .DATA_WIDTH(TAG_WIDTH + 2) // 最高位为有效位，次高位为脏位，低位为标记位
    ) tag_bram_10(
        .clk(clk),
        .raddr(r_index),
        .waddr(w_index),
        .din({w_valid, w_dirty, tag}),
        .we(tag_we_10),
        .dout({valid_10, dirty_10, r_tag_10})
    );
    bram #(
        .ADDR_WIDTH(INDEX_WIDTH),
        .DATA_WIDTH(TAG_WIDTH + 2) // 最高位为有效位，次高位为脏位，低位为标记位
    ) tag_bram_11(
        .clk(clk),
        .raddr(r_index),
        .waddr(w_index),
        .din({w_valid, w_dirty, tag}),
        .we(tag_we_11),
        .dout({valid_11, dirty_11, r_tag_11})
    );
    bram #(
        .ADDR_WIDTH(INDEX_WIDTH),
        .DATA_WIDTH(TAG_WIDTH + 2) // 最高位为有效位，次高位为脏位，低位为标记位
    ) tag_bram_12(
        .clk(clk),
        .raddr(r_index),
        .waddr(w_index),
        .din({w_valid, w_dirty, tag}),
        .we(tag_we_12),
        .dout({valid_12, dirty_12, r_tag_12})
    );
    bram #(
        .ADDR_WIDTH(INDEX_WIDTH),
        .DATA_WIDTH(TAG_WIDTH + 2) // 最高位为有效位，次高位为脏位，低位为标记位
    ) tag_bram_13(
        .clk(clk),
        .raddr(r_index),
        .waddr(w_index),
        .din({w_valid, w_dirty, tag}),
        .we(tag_we_13),
        .dout({valid_13, dirty_13, r_tag_13})
    );
    bram #(
        .ADDR_WIDTH(INDEX_WIDTH),
        .DATA_WIDTH(TAG_WIDTH + 2) // 最高位为有效位，次高位为脏位，低位为标记位
    ) tag_bram_14(
        .clk(clk),
        .raddr(r_index),
        .waddr(w_index),
        .din({w_valid, w_dirty, tag}),
        .we(tag_we_14),
        .dout({valid_14, dirty_14, r_tag_14})
    );
    bram #(
        .ADDR_WIDTH(INDEX_WIDTH),
        .DATA_WIDTH(TAG_WIDTH + 2) // 最高位为有效位，次高位为脏位，低位为标记位
    ) tag_bram_15(
        .clk(clk),
        .raddr(r_index),
        .waddr(w_index),
        .din({w_valid, w_dirty, tag}),
        .we(tag_we_15),
        .dout({valid_15, dirty_15, r_tag_15})
    );
    bram #(
        .ADDR_WIDTH(INDEX_WIDTH),
        .DATA_WIDTH(TAG_WIDTH + 2) // 最高位为有效位，次高位为脏位，低位为标记位
    ) tag_bram_16(
        .clk(clk),
        .raddr(r_index),
        .waddr(w_index),
        .din({w_valid, w_dirty, tag}),
        .we(tag_we_16),
        .dout({valid_16, dirty_16, r_tag_16})
    );

    // Data Bram
    bram #(
        .ADDR_WIDTH(INDEX_WIDTH),
        .DATA_WIDTH(LINE_WIDTH)
    ) data_bram_1(
        .clk(clk),
        .raddr(r_index),
        .waddr(w_index),
        .din(w_line),
        .we(data_we_1),
        .dout(r_line_1)
    );
    bram #(
        .ADDR_WIDTH(INDEX_WIDTH),
        .DATA_WIDTH(LINE_WIDTH)
    ) data_bram_2(
        .clk(clk),
        .raddr(r_index),
        .waddr(w_index),
        .din(w_line),
        .we(data_we_2),
        .dout(r_line_2)
    );
    bram #(
        .ADDR_WIDTH(INDEX_WIDTH),
        .DATA_WIDTH(LINE_WIDTH)
    ) data_bram_3(
        .clk(clk),
        .raddr(r_index),
        .waddr(w_index),
        .din(w_line),
        .we(data_we_3),
        .dout(r_line_3)
    );
    bram #(
        .ADDR_WIDTH(INDEX_WIDTH),
        .DATA_WIDTH(LINE_WIDTH)
    ) data_bram_4(
        .clk(clk),
        .raddr(r_index),
        .waddr(w_index),
        .din(w_line),
        .we(data_we_4),
        .dout(r_line_4)
    );
    bram #(
        .ADDR_WIDTH(INDEX_WIDTH),
        .DATA_WIDTH(LINE_WIDTH)
    ) data_bram_5(
        .clk(clk),
        .raddr(r_index),
        .waddr(w_index),
        .din(w_line),
        .we(data_we_5),
        .dout(r_line_5)
    );
    bram #(
        .ADDR_WIDTH(INDEX_WIDTH),
        .DATA_WIDTH(LINE_WIDTH)
    ) data_bram_6(
        .clk(clk),
        .raddr(r_index),
        .waddr(w_index),
        .din(w_line),
        .we(data_we_6),
        .dout(r_line_6)
    );
    bram #(
        .ADDR_WIDTH(INDEX_WIDTH),
        .DATA_WIDTH(LINE_WIDTH)
    ) data_bram_7(
        .clk(clk),
        .raddr(r_index),
        .waddr(w_index),
        .din(w_line),
        .we(data_we_7),
        .dout(r_line_7)
    );
    bram #(
        .ADDR_WIDTH(INDEX_WIDTH),
        .DATA_WIDTH(LINE_WIDTH)
    ) data_bram_8(
        .clk(clk),
        .raddr(r_index),
        .waddr(w_index),
        .din(w_line),
        .we(data_we_8),
        .dout(r_line_8)
    );
    bram #(
        .ADDR_WIDTH(INDEX_WIDTH),
        .DATA_WIDTH(LINE_WIDTH)
    ) data_bram_9(
        .clk(clk),
        .raddr(r_index),
        .waddr(w_index),
        .din(w_line),
        .we(data_we_9),
        .dout(r_line_9)
    );
    bram #(
        .ADDR_WIDTH(INDEX_WIDTH),
        .DATA_WIDTH(LINE_WIDTH)
    ) data_bram_10(
        .clk(clk),
        .raddr(r_index),
        .waddr(w_index),
        .din(w_line),
        .we(data_we_10),
        .dout(r_line_10)
    );
    bram #(
        .ADDR_WIDTH(INDEX_WIDTH),
        .DATA_WIDTH(LINE_WIDTH)
    ) data_bram_11(
        .clk(clk),
        .raddr(r_index),
        .waddr(w_index),
        .din(w_line),
        .we(data_we_11),
        .dout(r_line_11)
    );
    bram #(
        .ADDR_WIDTH(INDEX_WIDTH),
        .DATA_WIDTH(LINE_WIDTH)
    ) data_bram_12(
        .clk(clk),
        .raddr(r_index),
        .waddr(w_index),
        .din(w_line),
        .we(data_we_12),
        .dout(r_line_12)
    );
    bram #(
        .ADDR_WIDTH(INDEX_WIDTH),
        .DATA_WIDTH(LINE_WIDTH)
    ) data_bram_13(
        .clk(clk),
        .raddr(r_index),
        .waddr(w_index),
        .din(w_line),
        .we(data_we_13),
        .dout(r_line_13)
    );

    bram #(
        .ADDR_WIDTH(INDEX_WIDTH),
        .DATA_WIDTH(LINE_WIDTH)
    ) data_bram_14(
        .clk(clk),
        .raddr(r_index),
        .waddr(w_index),
        .din(w_line),
        .we(data_we_14),
        .dout(r_line_14)
    );bram #(
        .ADDR_WIDTH(INDEX_WIDTH),
        .DATA_WIDTH(LINE_WIDTH)
    ) data_bram_15(
        .clk(clk),
        .raddr(r_index),
        .waddr(w_index),
        .din(w_line),
        .we(data_we_15),
        .dout(r_line_15)
    );
    bram #(
        .ADDR_WIDTH(INDEX_WIDTH),
        .DATA_WIDTH(LINE_WIDTH)
    ) data_bram_16(
        .clk(clk),
        .raddr(r_index),
        .waddr(w_index),
        .din(w_line),
        .we(data_we_16),
        .dout(r_line_16)
    );
    
    // 判定Cache是否命中
    assign hit_1 = valid_1 && r_tag_1 == tag;
    assign hit_2 = valid_2 && r_tag_2 == tag;
    assign hit_3 = valid_3 && r_tag_3 == tag;
    assign hit_4 = valid_4 && r_tag_4 == tag;
    assign hit_5 = valid_5 && r_tag_5 == tag;
    assign hit_6 = valid_6 && r_tag_6 == tag;
    assign hit_7 = valid_7 && r_tag_7 == tag;
    assign hit_8 = valid_8 && r_tag_8 == tag;
    assign hit_9 = valid_9 && r_tag_9 == tag;
    assign hit_10 = valid_10 && r_tag_10 == tag;
    assign hit_11 = valid_11 && r_tag_11 == tag;
    assign hit_12 = valid_12 && r_tag_12 == tag;
    assign hit_13 = valid_13 && r_tag_13 == tag;
    assign hit_14 = valid_14 && r_tag_14 == tag;
    assign hit_15 = valid_15 && r_tag_15 == tag;
    assign hit_16 = valid_16 && r_tag_16 == tag;
    assign hit = hit_1||hit_2||hit_3||hit_4||hit_5||hit_6||hit_7||hit_8||hit_9||hit_10||hit_11||hit_12||hit_13||hit_14||hit_15||hit_16;
    assign r_line = hit_1 ? r_line_1 :
                    hit_2 ? r_line_2 :
                    hit_3 ? r_line_3 :
                    hit_4 ? r_line_4 :
                    hit_5 ? r_line_5 :
                    hit_6 ? r_line_6 :
                    hit_7 ? r_line_7 :
                    hit_8 ? r_line_8 :
                    hit_9 ? r_line_9 :
                    hit_10 ? r_line_10 :
                    hit_11 ? r_line_11 :
                    hit_12 ? r_line_12 :
                    hit_13 ? r_line_13 :
                    hit_14 ? r_line_14 :
                    hit_15 ? r_line_15 :
                    hit_16 ? r_line_16 :{(LINE_WIDTH){1'b0}};

    // 写入Cache 这里要判断是命中后写入还是未命中后写入
    assign w_line_mask = 32'hFFFFFFFF << (word_offset*32);   // 写入数据掩码
    assign w_data_line = w_data_buf << (word_offset*32);     // 写入数据移位
    assign w_line = (CS == IDLE && op_buf) ? ret_buf & ~w_line_mask | w_data_line : // 写入未命中，需要将内存数据与写入数据合并
                    (CS == IDLE) ? ret_buf : // 读取未命中
                    r_line & ~w_line_mask | w_data_line; // 写入命中,需要对读取的数据与写入的数据进行合并

    // 选择输出数据 从Cache或者从内存 这里的选择与行大小有关，因此如果你调整了行偏移位宽，这里也需要调整
    always @(*) begin
        case (word_offset)
            0: begin
                cache_data = r_line[31:0];
                mem_data = ret_buf[31:0];
            end
            1: begin
                cache_data = r_line[63:32];
                mem_data = ret_buf[63:32];
            end
            2: begin
                cache_data = r_line[95:64];
                mem_data = ret_buf[95:64];
            end
            3: begin
                cache_data = r_line[127:96];
                mem_data = ret_buf[127:96];
            end
            default: begin
                cache_data = 0;
                mem_data = 0;
            end
        endcase
    end

    assign r_data = data_from_mem ? mem_data : hit ? cache_data : 0;

    assign dirty = line_sel==4'd0 ? dirty_1:
                   line_sel==4'd1 ? dirty_2:
                   line_sel==4'd2 ? dirty_3:
                   line_sel==4'd3 ? dirty_4:
                   line_sel==4'd4 ? dirty_5:
                   line_sel==4'd5 ? dirty_6:
                   line_sel==4'd6 ? dirty_7:
                   line_sel==4'd7 ? dirty_8:
                   line_sel==4'd8 ? dirty_9:
                   line_sel==4'd9 ? dirty_10:
                   line_sel==4'd10 ? dirty_11:
                   line_sel==4'd11 ? dirty_12:
                   line_sel==4'd12 ? dirty_13:
                   line_sel==4'd13 ? dirty_14:
                   line_sel==4'd14 ? dirty_15:
                   line_sel==4'd15 ? dirty_16:1'b0;

    // 状态机更新逻辑
    always @(*) begin
        case(CS)
            IDLE: begin
                if (r_req) begin
                    NS = READ;
                end else if (w_req) begin
                    NS = WRITE;
                end else begin
                    NS = IDLE;
                end
            end
            READ: begin
                if (miss&& !dirty) begin
                    NS = MISS;
                end else if (miss && dirty) begin
                    NS = W_DIRTY;
                end else if (r_req) begin
                    NS = READ;
                end else if (w_req) begin
                    NS = WRITE;
                end else begin
                    NS = IDLE;
                end
            end
            MISS: begin
                if (mem_ready) begin // 这里回到IDLE的原因是为了延迟一周期，等待主存读出的新块写入Cache中的对应位置
                    NS = IDLE;
                end else begin
                    NS = MISS;
                end
            end
            WRITE: begin
                if (miss && !dirty) begin
                    NS = MISS;
                end else if (miss && dirty) begin
                    NS = W_DIRTY;
                end else if (r_req) begin
                    NS = READ;
                end else if (w_req) begin
                    NS = WRITE;
                end else begin
                    NS = IDLE;
                end
            end
            W_DIRTY: begin
                if (mem_ready) begin  // 写完脏块后回到MISS状态等待主存读出新块
                    NS = MISS;
                end else begin
                    NS = W_DIRTY;
                end
            end
            default: begin
                NS = IDLE;
            end
        endcase
    end

    // 状态机控制信号
    always @(*) begin
        addr_buf_we   = 1'b0;
        ret_buf_we    = 1'b0;
        data_we_1       = 1'b0;
        data_we_2       = 1'b0;
        data_we_3       = 1'b0;
        data_we_4       = 1'b0;
        data_we_5       = 1'b0;
        data_we_6       = 1'b0;
        data_we_7       = 1'b0;
        data_we_8       = 1'b0;
        data_we_9       = 1'b0;
        data_we_10       = 1'b0;
        data_we_11       = 1'b0;
        data_we_12       = 1'b0;
        data_we_13       = 1'b0;
        data_we_14       = 1'b0;
        data_we_15       = 1'b0;
        data_we_16       = 1'b0;
        tag_we_1        = 1'b0;
        tag_we_2        = 1'b0;
        tag_we_3        = 1'b0;
        tag_we_4        = 1'b0;
        tag_we_5        = 1'b0;
        tag_we_6        = 1'b0;
        tag_we_7        = 1'b0;
        tag_we_8        = 1'b0;
        tag_we_9        = 1'b0;
        tag_we_10        = 1'b0;
        tag_we_11        = 1'b0;
        tag_we_12        = 1'b0;
        tag_we_13        = 1'b0;
        tag_we_14        = 1'b0;
        tag_we_15        = 1'b0;
        tag_we_16        = 1'b0;
        w_valid       = 1'b0;
        w_dirty       = 1'b0;
        data_from_mem = 1'b0;
        miss          = 1'b0;
        mem_r         = 1'b0;
        mem_w         = 1'b0;
        mem_addr      = 32'b0;
        mem_w_data    = 0;
        case(CS)
            IDLE: begin
                addr_buf_we = 1'b1; // 请求地址缓存写使能
                miss = 1'b0;
                ret_buf_we = 1'b0;
                if(refill) begin
                    data_from_mem = 1'b1;
                    w_valid = 1'b1;
                    w_dirty = 1'b0;
                    case(line_sel)
                        4'd0:begin
                            data_we_1 = 1;
                            tag_we_1 = 1;
                        end
                        4'd1:begin
                            data_we_2 = 1;
                            tag_we_2 = 1;
                        end
                        4'd2:begin
                            data_we_3 = 1;
                            tag_we_3 = 1;
                        end
                        4'd3:begin
                            data_we_4 = 1;
                            tag_we_4 = 1;
                        end
                        4'd4:begin
                            data_we_5 = 1;
                            tag_we_5 = 1;
                        end
                        4'd5:begin
                            data_we_6 = 1;
                            tag_we_6 = 1;
                        end
                        4'd6:begin
                            data_we_7 = 1;
                            tag_we_7 = 1;
                        end
                        4'd7:begin
                            data_we_8 = 1;
                            tag_we_8 = 1;
                        end
                        4'd8:begin
                            data_we_9 = 1;
                            tag_we_9 = 1;
                        end
                        4'd9:begin
                            data_we_10 = 1;
                            tag_we_10 = 1;
                        end
                        4'd10:begin
                            data_we_11 = 1;
                            tag_we_11 = 1;
                        end
                        4'd11:begin
                            data_we_12 = 1;
                            tag_we_12 = 1;
                        end
                        4'd12:begin
                            data_we_13 = 1;
                            tag_we_13 = 1;
                        end
                        4'd13:begin
                            data_we_14 = 1;
                            tag_we_14 = 1;
                        end
                        4'd14:begin
                            data_we_15 = 1;
                            tag_we_15 = 1;
                        end
                        4'd15:begin
                            data_we_16 = 1;
                            tag_we_16 = 1;
                        end
                        default:;
                    endcase
                    if (op_buf) begin // 写
                        w_dirty = 1'b1;
                    end 
                end
            end
            READ: begin
                data_from_mem = 1'b0;
                if (hit) begin // 命中
                    miss = 1'b0;
                    addr_buf_we = 1'b1; // 请求地址缓存写使能
                end else begin // 未命中
                    miss = 1'b1;
                    addr_buf_we = 1'b0; 
                    if (dirty) begin // 脏数据需要写回
                        mem_w = 1'b1;
                        mem_addr = dirty_mem_addr;
                        mem_w_data = r_line; // 写回数据
                    end
                end
            end
            MISS: begin
                miss = 1'b1;
                mem_r = 1'b1;
                mem_addr = addr_buf;
                if (mem_ready) begin
                    mem_r = 1'b0;
                    ret_buf_we = 1'b1;
                end 
            end
            WRITE: begin
                data_from_mem = 1'b0;
                if (hit) begin // 命中
                    miss = 1'b0;
                    addr_buf_we = 1'b1; // 请求地址缓存写使能
                    w_valid = 1'b1;
                    w_dirty = 1'b1;
                    if(hit_1)begin
                        data_we_1 = 1;
                        tag_we_1 = 1;
                    end
                    else if(hit_2)begin
                        data_we_2 = 1;
                        tag_we_2 = 1;
                    end
                    else if(hit_3)begin
                        data_we_3 = 1;
                        tag_we_3 = 1;
                    end
                    else if(hit_4)begin
                        data_we_4 = 1;
                        tag_we_4 = 1;
                    end
                    else if(hit_5)begin
                        data_we_5 = 1;
                        tag_we_5 = 1;
                    end
                    else if(hit_6)begin
                        data_we_6 = 1;
                        tag_we_6 = 1;
                    end

                    else if(hit_7)begin
                        data_we_7 = 1;
                        tag_we_7 = 1;
                    end
                    else if(hit_8)begin
                        data_we_8 = 1;
                        tag_we_8 = 1;
                    end
                    else if(hit_9)begin
                        data_we_9 = 1;
                        tag_we_9 = 1;
                    end
                    else if(hit_10)begin
                        data_we_10 = 1;
                        tag_we_10 = 1;
                    end
                    else if(hit_11)begin
                        data_we_11 = 1;
                        tag_we_11 = 1;
                    end
                    else if(hit_12)begin
                        data_we_12 = 1;
                        tag_we_12 = 1;
                    end
                    else if(hit_13)begin
                        data_we_13 = 1;
                        tag_we_13 = 1;
                    end
                    else if(hit_14)begin
                        data_we_14 = 1;
                        tag_we_14 = 1;
                    end
                    else if(hit_15)begin
                        data_we_15 = 1;
                        tag_we_15 = 1;
                    end
                    else if(hit_16)begin
                        data_we_16 = 1;
                        tag_we_16 = 1;
                    end
                end else begin // 未命中
                    miss = 1'b1;
                    addr_buf_we = 1'b0; 
                    if (dirty) begin // 脏数据需要写回
                        mem_w = 1'b1;
                        mem_addr = dirty_mem_addr;
                        mem_w_data = r_line; // 写回数据
                    end
                end
            end
            W_DIRTY: begin
                miss = 1'b1;
                mem_w = 1'b1;
                mem_addr = dirty_mem_addr_buf;
                mem_w_data = dirty_mem_data_buf;
                if (mem_ready) begin
                    mem_w = 1'b0;
                end
            end
            default:;
        endcase
    end

endmodule
