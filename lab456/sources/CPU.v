`include "./include/config.v"

module CPU (
    input                   [ 0 : 0]            clk,
    input                   [ 0 : 0]            rst,

    input                   [ 0 : 0]            global_en,

/* ------------------------------ Memory (inst) ----------------------------- */
    output                  [31 : 0]            imem_raddr,
    input                   [31 : 0]            imem_rdata,

/* ------------------------------ Memory (data) ----------------------------- */
    input                   [31 : 0]            dmem_rdata, 
    output                  [ 0 : 0]            dmem_we,    
    output                  [31 : 0]            dmem_addr,  
    output                  [31 : 0]            dmem_wdata, 

/* ---------------------------------- Debug --------------------------------- */
    output                  [ 0 : 0]            commit,
    output                  [31 : 0]            commit_pc,
    output                  [31 : 0]            commit_inst,
    output                  [ 0 : 0]            commit_halt,
    output                  [ 0 : 0]            commit_reg_we,
    output                  [ 4 : 0]            commit_reg_wa,
    output                  [31 : 0]            commit_reg_wd,
    output                  [ 0 : 0]            commit_dmem_we,
    output                  [31 : 0]            commit_dmem_wa,
    output                  [31 : 0]            commit_dmem_wd,

    input                   [ 4 : 0]            debug_reg_ra,
    output                  [31 : 0]            debug_reg_rd
);

wire [0:0] commit_if;
assign commit_if = 1'H1;

wire [0:0] rf_rd0_fe;
wire [0:0] rf_rd1_fe;
wire [31:0] rf_rd0_fd;
wire [31:0] rf_rd1_fd;
wire [31:0] rf_wd_mem;

wire [0:0] stall_pc;
wire [0:0] stall_if_id;
wire [0:0] flush_if_id;
wire [0:0] flush_id_ex;

wire [31:0] cur_pc;
wire [31:0] cur_npc;
wire [1: 0] cur_npc_sel;
wire [4 :0] cur_rf_ra0;
wire [4 :0] cur_rf_ra1;
wire [31:0] cur_alu_src0;
wire [31:0] cur_alu_src1;

wire [0:0]commit_id;

wire [31:0]inst_id;
wire [31:0]pc_id;
wire [31:0]pcadd4_id;

wire [31:0]imm_id;
wire [4:0] rf_wa_id;
wire [31:0]rf_rd0_id;
wire [31:0]rf_rd1_id;
wire [4:0] alu_op_id;
wire [0:0] rf_we_id;
wire [0:0] alu_src0_sel_id;
wire [0:0] alu_src1_sel_id;
wire [3:0] dmem_access_id;
wire [1:0] rf_wd_sel_id;
wire [3:0] br_type_id;
wire [0:0] dmem_we_id;

wire  [0:0]  commit_ex;

wire [31:0] inst_ex;
wire [31:0] pcadd4_ex;
wire [31:0] pc_ex;

wire [ 4:0] rf_ra0_ex;
wire [ 4:0] rf_ra1_ex;
wire [31:0] rf_rd0_ex;
wire [31:0] rf_rd0_ex_real;
wire [31:0] rf_rd1_ex;
wire [31:0] rf_rd1_ex_real;
wire [31:0] imm_ex;
wire [4:0]  rf_wa_ex;
wire [4:0]  alu_op_ex;
wire [0:0]  rf_we_ex;
wire [0:0]  alu_src0_sel_ex;
wire [0:0]  alu_src1_sel_ex;
wire [3:0]  dmem_access_ex;
wire [0:0]  dmem_we_ex;
wire [1:0]  rf_wd_sel_ex;
wire [3:0]  br_type_ex;

wire [31:0] alu_res_ex;

wire [ 0: 0] commit_mem;

wire [31: 0] inst_mem;
wire [31: 0] pcadd4_mem;
wire [31: 0] pc_mem;

wire [31:0 ] rf_rd1_mem; 
wire [ 3: 0] dmem_access_mem;
wire [ 4: 0] rf_wa_mem;
wire [ 0: 0] rf_we_mem;
wire [ 1: 0] rf_wd_sel_mem;
wire [ 0: 0] dmem_we_mem;
wire [31:0 ] dmem_rd_out_mem;

wire [31: 0] alu_res_mem;

wire [0:0]  commit_wb;

wire [31:0] inst_wb;
wire [31:0] pcadd4_wb;
wire [31:0] pc_wb;

wire [1:0] rf_wd_sel_wb;
wire [4:0]  rf_wa_wb;
wire [0:0]  rf_we_wb;
wire [0:0]  dmem_we_wb;
wire [31:0] rf_wd_wb;

wire [31:0] alu_res_wb;

wire [31:0] dmem_rd_out_wb;
wire [31:0] dmem_wd_wb;

between_regfile IFID(
    .rst(rst),
    .clk(clk),
    .en(global_en),
    .flush(flush_if_id),
    .stall(stall_if_id),

    .commit_in(commit_if),

    .inst_in(imem_rdata),
    .pc_in(cur_pc),
    .pcadd4_in(cur_pc+4),

    .rf_ra0_in(4'B0),
    .rf_ra1_in(4'B0),
    .rf_rd0_in(32'B0),
    .rf_rd1_in(32'B0),
    .imm_in(32'B0),
    .rf_wa_in(5'B0),
    .rf_we_in(1'B0),
    .dmem_access_in(4'B0),
    .dmem_we_in(1'B0),
    .rf_wd_sel_in(2'B0),
    .alu_op_in(5'B0),
    .br_type_in(4'B0),
    .alu_src0_sel_in(1'B0),  
    .alu_src1_sel_in(1'B0),

    .alu_res_in(32'B0),

    .dmem_rd_out_in(32'B0),
    .dmem_wd_in(32'B0),

    .commit_out(commit_id),

    .inst_out(inst_id),
    .pc_out(pc_id),
    .pcadd4_out(pcadd4_id),

    .rf_ra0_out(),
    .rf_ra1_out(),
    .dmem_access_out(),
    .dmem_we_out(),
    .rf_wd_sel_out(),
    .alu_op_out(),
    .br_type_out(),
    .alu_src0_sel_out(),  
    .alu_src1_sel_out(),
    .rf_rd0_out(),
    .rf_rd1_out(),
    .imm_out(),
    .rf_wa_out(),
    .rf_we_out(),

    .alu_res_out(),

    .dmem_rd_out_out(),
    .dmem_wd_out()
);
MUX muxreal1(
    .src0(rf_rd0_ex),
    .src1(rf_rd0_fd),
    .sel (rf_rd0_fe),
    .res (rf_rd0_ex_real)
);
MUX muxreal2(
    .src0(rf_rd1_ex),
    .src1(rf_rd1_fd),
    .sel (rf_rd1_fe),
    .res (rf_rd1_ex_real)
);
between_regfile IDEX(
    .rst(rst),
    .clk(clk),
    .en(global_en),
    .flush(flush_id_ex),
    .stall(1'B0),

    .commit_in(commit_id),

    .inst_in(inst_id),
    .pc_in(pc_id),
    .pcadd4_in(pcadd4_id),

    .rf_ra0_in(cur_rf_ra0),
    .rf_ra1_in(cur_rf_ra1),
    .rf_rd0_in(rf_rd0_id),
    .rf_rd1_in(rf_rd1_id),
    .imm_in(imm_id),
    .rf_wa_in(rf_wa_id),
    .rf_we_in(rf_we_id),
    .dmem_access_in(dmem_access_id),
    .dmem_we_in(dmem_we_id),
    .rf_wd_sel_in(rf_wd_sel_id),
    .alu_op_in(alu_op_id),
    .br_type_in(br_type_id),
    .alu_src0_sel_in(alu_src0_sel_id),  
    .alu_src1_sel_in(alu_src1_sel_id),

    .alu_res_in(32'B0),

    .dmem_rd_out_in(32'B0),
    .dmem_wd_in(32'B0),

    .commit_out(commit_ex),

    .inst_out(inst_ex),
    .pc_out(pc_ex),
    .pcadd4_out(pcadd4_ex),

    .rf_ra0_out(rf_ra0_ex),
    .rf_ra1_out(rf_ra1_ex),
    .dmem_access_out(dmem_access_ex),
    .dmem_we_out(dmem_we_ex),
    .rf_wd_sel_out(rf_wd_sel_ex),
    .alu_op_out(alu_op_ex),
    .br_type_out(br_type_ex),
    .alu_src0_sel_out(alu_src0_sel_ex),  
    .alu_src1_sel_out(alu_src1_sel_ex),
    .rf_rd0_out(rf_rd0_ex),
    .rf_rd1_out(rf_rd1_ex),
    .imm_out(imm_ex),
    .rf_wa_out(rf_wa_ex),
    .rf_we_out(rf_we_ex),

    .alu_res_out(),

    .dmem_rd_out_out(),
    .dmem_wd_out()
);

//Forwarding
Forwarding fw(
    .rf_we_mem(rf_we_mem),
    .rf_we_wb(rf_we_wb),
    .rf_wa_mem(rf_wa_mem),
    .rf_wa_wb(rf_wa_wb),
    .rf_wd_mem(rf_wd_mem),
    .rf_wd_wb(rf_wd_wb),

    .rf_ra0_ex(rf_ra0_ex),
    .rf_ra1_ex(rf_ra1_ex),

    .rf_rd0_fe(rf_rd0_fe),
    .rf_rd1_fe(rf_rd1_fe),
    .rf_rd0_fd(rf_rd0_fd),
    .rf_rd1_fd(rf_rd1_fd)
);

segCtrl segctrl(
    .rf_we_ex(rf_we_ex),
    .rf_wa_ex(rf_wa_ex),
    .rf_ra0_id(cur_rf_ra0),
    .rf_ra1_id(cur_rf_ra1),
    .rf_wd_sel_ex(rf_wd_sel_ex),
    .npc_sel_ex(cur_npc_sel),

    .stall_pc(stall_pc),
    .stall_if_id(stall_if_id),
    .flush_if_id(flush_if_id),
    .flush_id_ex(flush_id_ex)
);

between_regfile EXMEM(
    .rst(rst),
    .clk(clk),
    .en(global_en),
    .flush(1'B0),
    .stall(1'B0),

    .commit_in(commit_ex),

    .inst_in(inst_ex),
    .pc_in(pc_ex),
    .pcadd4_in(pcadd4_ex),

    .rf_ra0_in(32'B0),
    .rf_ra1_in(32'B0),
    .rf_rd0_in(32'B0),
    .rf_rd1_in(rf_rd1_ex_real),
    .imm_in(32'B0),
    .rf_wa_in(rf_wa_ex),
    .rf_we_in(rf_we_ex),
    .dmem_access_in(dmem_access_ex),
    .dmem_we_in(dmem_we_ex),
    .rf_wd_sel_in(rf_wd_sel_ex),
    .alu_op_in(5'B0),
    .br_type_in(4'B0),
    .alu_src0_sel_in(1'B0),  
    .alu_src1_sel_in(1'B0),

    .alu_res_in(alu_res_ex),

    .dmem_rd_out_in(32'B0),
    .dmem_wd_in(),

    .commit_out(commit_mem),

    .inst_out(inst_mem),
    .pc_out(pc_mem),
    .pcadd4_out(pcadd4_mem),

    .rf_ra0_out(),
    .rf_ra1_out(),
    .dmem_access_out(dmem_access_mem),
    .dmem_we_out(dmem_we_mem),
    .rf_wd_sel_out(rf_wd_sel_mem),
    .alu_op_out(),
    .br_type_out(),
    .alu_src0_sel_out(),  
    .alu_src1_sel_out(),
    .rf_rd0_out(),
    .rf_rd1_out(rf_rd1_mem),
    .imm_out(),
    .rf_wa_out(rf_wa_mem),
    .rf_we_out(rf_we_mem),

    .alu_res_out(alu_res_mem),

    .dmem_rd_out_out(),
    .dmem_wd_out()
);

between_regfile MEMWB(
    .rst(rst),
    .clk(clk),
    .en(global_en),
    .flush(1'B0),
    .stall(1'B0),

    .commit_in(commit_mem),

    .inst_in(inst_mem),
    .pc_in(pc_mem),
    .pcadd4_in(pcadd4_mem),

    .rf_ra0_in(32'B0),
    .rf_ra1_in(32'B0),
    .rf_rd0_in(32'B0),
    .rf_rd1_in(32'B0),
    .imm_in(32'B0),
    .rf_wa_in(rf_wa_mem),
    .rf_we_in(rf_we_mem),
    .dmem_access_in(32'B0),
    .dmem_we_in(dmem_we_mem),
    .rf_wd_sel_in(rf_wd_sel_mem),
    .alu_op_in(5'B0),
    .br_type_in(4'B0),
    .alu_src0_sel_in(1'B0),  
    .alu_src1_sel_in(1'B0),

    .alu_res_in(alu_res_mem),

    .dmem_rd_out_in(dmem_rd_out_mem),
    .dmem_wd_in(dmem_wdata),

    .commit_out(commit_wb),

    .inst_out(inst_wb),
    .pc_out(pc_wb),
    .pcadd4_out(pcadd4_wb),

    .rf_ra0_out(),
    .rf_ra1_out(),
    .dmem_access_out(),
    .dmem_we_out(dmem_we_wb),
    .rf_wd_sel_out(rf_wd_sel_wb),
    .alu_op_out(),
    .br_type_out(),
    .alu_src0_sel_out(),  
    .alu_src1_sel_out(),
    .rf_rd0_out(),
    .rf_rd1_out(),
    .imm_out(),
    .rf_wa_out(rf_wa_wb),
    .rf_we_out(rf_we_wb),

    .alu_res_out(alu_res_wb),

    .dmem_rd_out_out(dmem_rd_out_wb),
    .dmem_wd_out(dmem_wd_wb)
);
assign dmem_we = dmem_we_mem;
NPC npc(
    .pc_add4(cur_pc+4),
    .pc_addoffset(alu_res_ex),
    .pc_0(alu_res_ex&(~1)),
    .npc_sel(cur_npc_sel),
    .npc(cur_npc)
);

PC my_pc (
    .clk    (clk        ),
    .rst    (rst        ),
    .en     (global_en  ),
    .npc    (cur_npc    ),
    .flush  (1'B0       ),
    .stall  (stall_pc   ),
    .pc     (cur_pc     )
);
assign imem_raddr = cur_pc;
BRANCH branch(
    .br_type(br_type_ex),
    .br_src0(rf_rd0_ex_real),
    .br_src1(rf_rd1_ex_real),
    .npc_sel(cur_npc_sel)
);
DECODE decode(
    .inst   (inst_id),
    .alu_op (alu_op_id),
    .imm    (imm_id),
    .rf_ra0 (cur_rf_ra0),
    .rf_ra1 (cur_rf_ra1),
    .rf_wa  (rf_wa_id),
    .rf_we  (rf_we_id),
    .alu_src0_sel(alu_src0_sel_id),
    .alu_src1_sel(alu_src1_sel_id),
    .dmem_access(dmem_access_id),
    .rf_wd_sel(rf_wd_sel_id),
    .br_type(br_type_id),
    .dmem_we(dmem_we_id)
);
REG_FILE regfile(
    .clk    (clk),
    .rf_ra0 (cur_rf_ra0),
    .rf_ra1 (cur_rf_ra1),
    .rf_wa  (rf_wa_wb),
    .rf_we  (rf_we_wb),
    .rf_wd  (rf_wd_wb),
    .debug_reg_ra(debug_reg_ra),
    .rf_rd0 (rf_rd0_id),
    .rf_rd1 (rf_rd1_id),
    .debug_reg_rd(debug_reg_rd)
);
assign dmem_addr = alu_res_mem;
SLU slu(
    .addr(alu_res_mem),
    .dmem_access(dmem_access_mem),
    .rd_in(dmem_rdata),
    .wd_in(rf_rd1_mem),
    .rd_out(dmem_rd_out_mem),
    .wd_out(dmem_wdata)
);
MUX mux1(
    .src0(pc_ex),
    .src1(rf_rd0_ex_real),
    .sel (alu_src0_sel_ex),
    .res (cur_alu_src0)
);
MUX mux2(
    .src0(imm_ex),
    .src1(rf_rd1_ex_real),
    .sel (alu_src1_sel_ex),
    .res (cur_alu_src1)
);

ALU alu(
    .alu_src0(cur_alu_src0),
    .alu_src1(cur_alu_src1),
    .alu_op  (alu_op_ex),
    .alu_res (alu_res_ex)
);

assign rf_wd_mem = alu_res_mem;
MUX4 mux4(
    .src0(pcadd4_wb),
    .src1(alu_res_wb),
    .src2(dmem_rd_out_wb),
    .src3(0),
    .sel(rf_wd_sel_wb),
    .res(rf_wd_wb)
);

/* -------------------------------------------------------------------------- */
/*                                    Commit                                  */
/* -------------------------------------------------------------------------- */
    reg  [ 0 : 0]   commit_reg          ;
    reg  [31 : 0]   commit_pc_reg       ;
    reg  [31 : 0]   commit_inst_reg     ;
    reg  [ 0 : 0]   commit_halt_reg     ;
    reg  [ 0 : 0]   commit_reg_we_reg   ;
    reg  [ 4 : 0]   commit_reg_wa_reg   ;
    reg  [31 : 0]   commit_reg_wd_reg   ;
    reg  [ 0 : 0]   commit_dmem_we_reg  ;
    reg  [31 : 0]   commit_dmem_wa_reg  ;
    reg  [31 : 0]   commit_dmem_wd_reg  ;

    always @(posedge clk) begin
        if (rst) begin
            commit_reg          <= 1'H0;
            commit_pc_reg       <= 32'H0;
            commit_inst_reg     <= 32'H0;
            commit_halt_reg     <= 1'H0;
            commit_reg_we_reg   <= 1'H0;
            commit_reg_wa_reg   <= 5'H0;
            commit_reg_wd_reg   <= 32'H0;
            commit_dmem_we_reg  <= 1'H0;
            commit_dmem_wa_reg  <= 32'H0;
            commit_dmem_wd_reg  <= 32'H0;
        end
        else if (global_en) begin 
            commit_reg          <= commit_wb;
            commit_pc_reg       <= pc_wb;
            commit_inst_reg     <= inst_wb;
            commit_halt_reg     <= inst_wb == `HALT_INST;
            commit_reg_we_reg   <= rf_we_wb;
            commit_reg_wa_reg   <= rf_wa_wb;
            commit_reg_wd_reg   <= rf_wd_wb;
            commit_dmem_we_reg  <= dmem_we_wb;
            commit_dmem_wa_reg  <= alu_res_wb;
            commit_dmem_wd_reg  <= dmem_wd_wb;                          
        end
    end

    assign commit               = commit_reg;
    assign commit_pc            = commit_pc_reg;
    assign commit_inst          = commit_inst_reg;
    assign commit_halt          = commit_halt_reg;
    assign commit_reg_we        = commit_reg_we_reg;
    assign commit_reg_wa        = commit_reg_wa_reg;
    assign commit_reg_wd        = commit_reg_wd_reg;
    assign commit_dmem_we       = commit_dmem_we_reg;
    assign commit_dmem_wa       = commit_dmem_wa_reg;
    assign commit_dmem_wd       = commit_dmem_wd_reg;
endmodule