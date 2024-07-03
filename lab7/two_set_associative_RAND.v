`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/28 20:13:23
// Design Name: 
// Module Name: two_set_associative_RAND
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


module two_set_associative_RAND #(
    parameter INDEX_WIDTH       = 3,    // Cache索引位宽 2^3=8�?
    parameter LINE_OFFSET_WIDTH = 2,    // 行偏移位宽，决定了一行的宽度 2^2=4�?
    parameter SPACE_OFFSET      = 2,    // �?个地�?空间�?1个字节，因此�?个字�?�?4个地�?空间，由于假设为整字读取，处理地�?的时候可以默认后两位�?0
    parameter WAY_NUM           = 2     // Cache N路组相联(N=1的时候是直接映射)
)(
    input                     clk,    
    input                     rstn,
    /* CPU接口 */  
    input [31:0]              addr,   // CPU地址
    input                     r_req,  // CPU读请�?
    input                     w_req,  // CPU写请�?
    input [31:0]              w_data,  // CPU写数�?
    output [31:0]             r_data,  // CPU读数�?
    output reg                miss,   // 缓存未命�?
    /* 内存接口 */  
    output reg                     mem_r,  // 内存读请�?
    output reg                     mem_w,  // 内存写请�?
    output reg [31:0]              mem_addr,  // 内存地址
    output reg [127:0] mem_w_data,  // 内存写数�? �?次写�?�?
    input      [127:0] mem_r_data,  // 内存读数�? �?次读�?�?
    input                          mem_ready  // 内存就绪信号
);

    // Cache参数
    localparam
        // Cache行宽�?
        LINE_WIDTH = 32 << LINE_OFFSET_WIDTH,
        // 标记位宽�?
        TAG_WIDTH = 32 - INDEX_WIDTH - LINE_OFFSET_WIDTH - SPACE_OFFSET,
        // Cache行数
        SET_NUM   = 1 << INDEX_WIDTH;
    
    // Cache相关寄存�?
    reg [31:0]           addr_buf;    // 请求地址缓存-用于保留CPU请求地址
    reg [31:0]           w_data_buf;  // 写数据缓�?
    reg op_buf;  // 读写操作缓存，用于在MISS状�?�下判断是读还是写，如果是写则需要将数据写回内存 0:�? 1:�?
    reg [LINE_WIDTH-1:0] ret_buf;     // 返回数据缓存-用于保留内存返回数据

    // Cache导线
    wire [INDEX_WIDTH-1:0] r_index;  // 索引读地�?
    wire [INDEX_WIDTH-1:0] w_index;  // 索引写地�?  
    wire [LINE_WIDTH-1:0]  r_line_1; // Data Bram读数�?
    wire [LINE_WIDTH-1:0]  r_line_2;
    wire [LINE_WIDTH-1:0]  r_line;
    wire [LINE_WIDTH-1:0]  w_line;   // Data Bram写数�?
    wire [LINE_WIDTH-1:0]  w_line_mask;  // Data Bram写数据掩�?
    wire [LINE_WIDTH-1:0]  w_data_line;  // 输入写数据移位后的数�?
    wire [TAG_WIDTH-1:0]   tag;      // CPU请求地址中分离的标记 用于比较 也可用于写入
    wire [TAG_WIDTH-1:0]   r_tag_1;    // Tag Bram读数�? 用于比较
    wire [TAG_WIDTH-1:0]   r_tag_2;    // Tag Bram读数�? 用于比较
    wire [LINE_OFFSET_WIDTH-1:0] word_offset;  // 字偏�?
    reg  [31:0]            cache_data;  // Cache数据
    reg  [31:0]            mem_data;    // 内存数据
    wire [31:0]            dirty_mem_addr; // 通过读出的tag和对应的index，偏移等得到脏块对应的内存地�?并写回到正确的位�?
    wire valid;
    wire valid_1;
    wire valid_2;  // Cache有效�?
    wire dirty;
    wire dirty_1;
    wire dirty_2;
    reg  w_valid;  // Cache写有效位
    reg  w_dirty;  // Cache写脏�?
    wire hit;    // Cache命中
    wire hit_1;
    wire hit_2;

    reg [SET_NUM*2-1:0] age;
    reg [0:0] line_sel,line_sel_ready;
    // 根据age选择替换set
    always @(posedge clk) begin
        if(age[r_index*2])begin
            line_sel_ready <= 0;
        end
        else begin
            line_sel_ready <= 1;
        end
    end
    //随机维护age
    always @(posedge clk) begin
        age[r_index*2] <= $random % 2;
    end
    // Cache相关控制信号
    reg addr_buf_we;  // 请求地址缓存写使�?
    reg ret_buf_we;   // 返回数据缓存写使�?
    reg  data_we_1;
    reg  data_we_2;     // Cache写使�?
    reg  tag_we_1;
    reg  tag_we_2;      // Cache标记写使�?
    reg data_from_mem;  // 从内存读取数�?
    reg refill;       // 标记�?要重新填充，在MISS状�?�下接受到内存数据后�?1,在IDLE状�?�下进行填充后置0

    // 状�?�机信号
    localparam 
        IDLE      = 3'd0,  // 空闲状�??
        READ      = 3'd1,  // 读状�?
        MISS      = 3'd2,  // 缺失时等待主存读出新�?
        WRITE     = 3'd3,  // 写状�?
        W_DIRTY   = 3'd4;  // 写缺失时等待主存写入脏块
    reg [2:0] CS;  // 状�?�机当前状�??
    reg [2:0] NS;  // 状�?�机下一状�??

    // 状�?�机
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            CS <= IDLE;
        end else begin
            CS <= NS;
        end
    end

    // 中间寄存器保留初始的请求地址和写数据，可以理解为addr_buf中的地址为当前Cache正在处理的请求地�?，�?�addr中的地址为新的请求地�?
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            addr_buf <= 0;
            ret_buf <= 0;
            w_data_buf <= 0;
            op_buf <= 0;
            refill <= 0;
            age <= 0;
        end else begin
            if (addr_buf_we) begin
                addr_buf <= addr;
                w_data_buf <= w_data;
                op_buf <= w_req;
                line_sel <= line_sel_ready;//需要写的时候使能
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

    // 对输入地�?进行解码
    assign r_index = addr[INDEX_WIDTH+LINE_OFFSET_WIDTH+SPACE_OFFSET - 1: LINE_OFFSET_WIDTH+SPACE_OFFSET];
    assign w_index = addr_buf[INDEX_WIDTH+LINE_OFFSET_WIDTH+SPACE_OFFSET - 1: LINE_OFFSET_WIDTH+SPACE_OFFSET];
    assign tag = addr_buf[31:INDEX_WIDTH+LINE_OFFSET_WIDTH+SPACE_OFFSET];
    assign word_offset = addr_buf[LINE_OFFSET_WIDTH+SPACE_OFFSET-1:SPACE_OFFSET];

    // 脏块地址计算
    assign dirty_mem_addr = line_sel == 1'd0 ? {r_tag_1, w_index}<<(LINE_OFFSET_WIDTH+SPACE_OFFSET) : 
                            line_sel == 1'd1 ? {r_tag_2, w_index}<<(LINE_OFFSET_WIDTH+SPACE_OFFSET) :
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
                dirty_mem_data_buf <=   line_sel == 1'd0 ? r_line_1 : 
                                        line_sel == 1'd1 ? r_line_2 : 
                                                    {(LINE_WIDTH){1'b0}};
            end
        end
    end

    // Tag Bram
    bram #(
        .ADDR_WIDTH(INDEX_WIDTH),
        .DATA_WIDTH(TAG_WIDTH + 2) // �?高位为有效位，次高位为脏位，低位为标记位
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
        .DATA_WIDTH(TAG_WIDTH + 2) // �?高位为有效位，次高位为脏位，低位为标记位
    ) tag_bram_2(
        .clk(clk),
        .raddr(r_index),
        .waddr(w_index),
        .din({w_valid, w_dirty, tag}),
        .we(tag_we_2),
        .dout({valid_2, dirty_2, r_tag_2})
    );

    assign dirty = line_sel ? dirty_2 : dirty_1;
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

    // 判定Cache是否命中
    assign hit_1 = valid_1 && (r_tag_1 == tag);
    assign hit_2 = valid_2 && (r_tag_2 == tag);
    assign hit = hit_1||hit_2;
    assign r_line = hit_1 ? r_line_1 :(hit_2 ? r_line_2 :{(LINE_WIDTH){1'b0}});

    // 写入Cache 这里要判断是命中后写入还是未命中后写�?
    assign w_line_mask = 32'hFFFFFFFF << (word_offset*32);   // 写入数据掩码
    assign w_data_line = w_data_buf << (word_offset*32);     // 写入数据移位
    assign w_line = (CS == IDLE && op_buf) ? ret_buf & ~w_line_mask | w_data_line : // 写入未命中，�?要将内存数据与写入数据合�?
                    (CS == IDLE) ? ret_buf : // 读取未命�?
                    r_line & ~w_line_mask | w_data_line; // 写入命中,�?要对读取的数据与写入的数据进行合�?

    // 选择输出数据 从Cache或�?�从内存 这里的�?�择与行大小有关，因此如果你调整了行偏移位宽，这里也�?要调�?
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

    // 状�?�机更新逻辑
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
                if (mem_ready) begin // 这里回到IDLE的原因是为了延迟�?周期，等待主存读出的新块写入Cache中的对应位置
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
                if (mem_ready) begin  // 写完脏块后回到MISS状�?�等待主存读出新�?
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

    // 状�?�机控制信号
    always @(*) begin
        addr_buf_we   = 1'b0;
        ret_buf_we    = 1'b0;
        data_we_1       = 1'b0;
        data_we_2       = 1'b0;
        tag_we_1        = 1'b0;
        tag_we_2        = 1'b0;
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
                addr_buf_we = 1'b1; // 请求地址缓存写使�?
                miss = 1'b0;
                ret_buf_we = 1'b0;
                if(refill) begin
                    data_from_mem = 1'b1;
                    w_valid = 1'b1;
                    w_dirty = 1'b0;
                    if(line_sel)begin
                        data_we_2=1;
                        tag_we_2 =1;
                    end
                    else begin
                        data_we_1=1;
                        tag_we_1 =1;
                    end
                    if (op_buf) begin // �?
                        w_dirty = 1'b1;
                    end 
                end
            end
            READ: begin
                data_from_mem = 1'b0;
                if (hit) begin // 命中
                    miss = 1'b0;
                    addr_buf_we = 1'b1; // 请求地址缓存写使�?
                end else begin // 未命�?
                    miss = 1'b1;
                    addr_buf_we = 1'b0;
                    mem_w = 1'b1;
                    mem_addr = dirty_mem_addr;
                    if(line_sel) begin
                        mem_w_data = r_line_2;
                    end
                    else begin
                        mem_w_data = r_line_1;
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
                    addr_buf_we = 1'b1; // 请求地址缓存写使�?
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
                end else begin // 未命�?
                    miss = 1'b1;
                    addr_buf_we = 1'b0; 
                    mem_w = 1'b1;
                    mem_addr = dirty_mem_addr;
                    if(line_sel) begin
                        mem_w_data = r_line_2;
                    end
                    else begin
                        mem_w_data = r_line_1;
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