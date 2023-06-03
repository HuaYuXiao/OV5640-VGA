`timescale 1ns / 1ps


module ddr2_axi(
    /* User interface */
    input                               sys_clk_p,
    input                               sys_clk_n,  
    output                              ui_clk, //
    input                               sys_rst_n,//active low

    input [31:0]                        wdata,                                          //ila 32
    input                               wdata_valid,                                    //ila 1
    output                              wdata_ready,                                    //ila 1
    input [29:0]                        wr_addr,                                        //ila 30
    input [23:0]                        wr_len_total,//in 32bit words                   //ila 24
    input                               wr_ctrl_vld,                                    //ila 1
    output                              wr_finished,                                    //ila 1

    output [31:0]                       rdata,                                          //ila 32
    output                              rdata_valid,                                    //ila 1
    input [29:0]                        rd_addr,                                        //ila 30
    input [23:0]                        rd_len_total,//in 32bit words                   //ila 24
    input                               master_ready,                   
    input                               rd_ctrl_vld,                                    //ila 1
    output                              rd_finished,                                    //ila 1  

    output                              init_calib_complete, 

    /* DDR3 phy interface */
	inout [31:0]                       ddr2_dq,
	inout [3:0]                        ddr2_dqs_n,
	inout [3:0]                        ddr2_dqs_p,
	output [14:0]                      ddr2_addr,
	output [2:0]                       ddr2_ba,
	output                             ddr2_ras_n,
	output                             ddr2_cas_n,
	output                             ddr2_we_n,
	output                             ddr2_reset_n,
	output [0:0]                       ddr2_ck_p,
	output [0:0]                       ddr2_ck_n,
	output [0:0]                       ddr2_cke,
	output [0:0]                       ddr2_cs_n,
	output [3:0]                       ddr2_dm,
	output [0:0]                       ddr2_odt

);

localparam 
IDLE = 4'd0,                       // 空闲状态
WRITE_CTRL = 4'd1,                 // 写控制状态
WRITE_DATA = 4'd2,                 // 写数据状态
WRITE_CHECK = 4'd3,                // 写校验状态
WRITE_FINISH = 4'd4,               // 写完成状态
READ = 4'd5,                       // 读状态
READ_CTRL = 4'd6,                  // 读控制状态
READ_DATA = 4'd7,                  // 读数据状态
//READ_CHECK = 4'd8,                // 读校验状态
READ_FINISH = 4'd9,                // 读完成状态
RW_ERR = 4'd10,                    // 读写错误状态
WRITE_INIT = 4'd11,                // 写初始化状态
READ_INIT = 4'd12                  // 读初始化状态
;

wire [3 : 0] m_axi_awid = 4'd0;                      // AXI写ID
reg [29 : 0] m_axi_awaddr;                           // AXI写地址
reg [7 : 0] m_axi_awlen;                             // AXI写长度
wire [2 : 0] m_axi_awsize = 3'h2;                    // AXI写传输大小
wire [1 : 0] m_axi_awburst = 2'b01;                  // AXI写突发类型
wire m_axi_awlock = 1'b0;                            // AXI写锁定信号
wire [3 : 0] m_axi_awcache = 4'b0011;                // AXI写缓存控制
wire [2 : 0] m_axi_awprot = 3'd0;                    // AXI写保护类型
wire [3 : 0] m_axi_awqos = 4'd0;                     // AXI写质量服务等级
reg m_axi_awvalid;                                   // AXI写有效信号
wire m_axi_awready;                                  // AXI写就绪信号

wire [31 : 0] m_axi_wdata = wdata;                   // AXI写数据
wire [3 : 0] m_axi_wstrb = m_axi_wvalid ? 4'hf:4'd0;   // AXI写数据有效位
wire m_axi_wlast;                                    // AXI写最后一个数据信号
wire m_axi_wvalid = wdata_valid;                     // AXI写有效信号
wire m_axi_wready;                                   // AXI写就绪信号

wire [3 : 0] m_axi_bid;                              // AXI写ID
wire [1 : 0] m_axi_bresp;                            // AXI写响应
wire m_axi_bvalid;                                   // AXI写有效信号
wire m_axi_bready = 1'b1;                            // AXI写就绪信号

wire [3 : 0] m_axi_arid = 4'd0;                      // AXI读ID
reg [29 : 0] m_axi_araddr;                           // AXI读地址
reg [7 : 0] m_axi_arlen;                             // AXI读长度
wire [2 : 0] m_axi_arsize = 3'h2;                    // AXI读传输大小
wire [1 : 0] m_axi_arburst = 2'b01;                  // AXI读突发类型
wire m_axi_arlock = 1'b0;                            // AXI读锁定信号
wire [3 : 0] m_axi_arcache = 4'b0011;                // AXI读缓存控制
wire [2 : 0] m_axi_arprot = 3'd0;                    // AXI读保护类型
wire [3 : 0] m_axi_arqos = 4'd0;                     // AXI读质量服务等级
reg m_axi_arvalid;                                   // AXI读有效信号
wire m_axi_arready;                                  // AXI读就绪信号

wire [3 : 0] m_axi_rid;                              // AXI读ID
wire [31 : 0] m_axi_rdata;                           // AXI读数据
wire [1 : 0] m_axi_rresp;                            // AXI读响应
wire m_axi_rlast;                                    // AXI读最后一个数据信号
wire m_axi_rvalid;                                   // AXI读有效信号
wire m_axi_rready = master_ready;                    // AXI读就绪信号

wire ui_clk;                                         // UI时钟
wire ui_clk_sync_rst;                                // UI时钟同步复位信号
//wire init_calib_complete;                          // 初始化校准完成信号
wire clk = ui_clk;                                   // 时钟信号
wire rst_n = init_calib_complete & sys_rst_n;        // 复位信号

assign wdata_ready = m_axi_wready & (wr_state == WRITE_DATA) && (already_wdata_num < wr_len_total_r);   // 写数据就绪信号
assign rdata_valid = m_axi_rvalid & master_ready;     // 读数据有效信号

IBUFDS sys_clk_ibufgds
(
	.O  (sys_clk_w),
	.I  (sys_clk_p),
	.IB (sys_clk_n)
);
   BUFG bufg_clk (
   .O(sys_clk), // 1-bit output: Clock output
   .I(sys_clk_w)  // 1-bit input: Clock input
);

reg [29:0] wr_addr_r;
always@(posedge clk)
begin
    if(~rst_n)
        wr_addr_r <= 30'd0;
    else if(wr_ctrl_vld)
        wr_addr_r <= wr_addr;
end

reg [29:0] rd_addr_r;
always@(posedge clk)
begin
    if(~rst_n)
        rd_addr_r <= 30'd0;
    else if(rd_ctrl_vld)
        rd_addr_r <= rd_addr;
end

reg [23:0] wr_len_total_r;
always@(posedge clk)
begin
    if(!rst_n)
        wr_len_total_r <= 24'd0;
    else if(wr_ctrl_vld)
        wr_len_total_r <= wr_len_total;
end

reg [23:0] rd_len_total_r;
always@(posedge clk)
begin
    if(!rst_n)
        rd_len_total_r <= 24'd0;
    else if(rd_ctrl_vld)
        rd_len_total_r <= rd_len_total;
end

reg [3:0] m_axi_bresp_r;
always@(posedge clk)
begin
    if(m_axi_bvalid)
        m_axi_bresp_r <= m_axi_bresp;
end

reg [3:0]   wr_state;                                                    //ila 4
reg [3:0]   rd_state;                                                    //ila 4 
reg [23:0]  remain_wdata_num;                                        //ila 24
reg [23:0]  remain_rdata_num;                                        //ila 24
reg         write_init_done;                                                
wire        read_burst_end;                                                //ila 1
reg read_init_done;
always@(posedge clk)
begin
    if(!rst_n)
        wr_state <= IDLE;
    else
        case (wr_state)
            IDLE:
            begin
                if (wr_ctrl_vld) wr_state <= WRITE_INIT;
                else wr_state <= IDLE;
            end
            WRITE_INIT:
            begin
                if(write_init_done)
                    wr_state <= WRITE_CTRL;
                else
                    wr_state <= WRITE_INIT;
            end
            WRITE_CTRL:
            begin
                if(wr_burst_ctrl_done) wr_state <= WRITE_DATA;
                else wr_state <= WRITE_CTRL;
            end
            WRITE_DATA:
            begin
                if(m_axi_bvalid) wr_state <= WRITE_CHECK;
                else wr_state <= WRITE_DATA;
            end
            WRITE_CHECK:
            begin
                if(m_axi_bresp_r[1]) wr_state <= RW_ERR;
                else if(remain_wdata_num == 24'd0) wr_state <= WRITE_FINISH;
                else wr_state <= WRITE_CTRL;
            end
            WRITE_FINISH:
            begin
                wr_state <= IDLE;
            end
            RW_ERR:
            begin
                wr_state <= RW_ERR;
            end
        endcase 
end

always@(posedge clk)
begin
    if(!rst_n)
        rd_state <= IDLE;
    else
        case (rd_state)
            IDLE:
            begin
                if(rd_ctrl_vld) rd_state <= READ_INIT;
                else rd_state <= IDLE;
            end
            READ_INIT:
            begin
                if(read_init_done)
                    rd_state <= READ_CTRL;
                else
                    rd_state <=READ_INIT;
            end
            READ_CTRL:
            begin
                if(rd_burst_ctrl_done) rd_state <= READ_DATA;
                else rd_state <= READ_CTRL;
            end
            READ_DATA:
            begin
                if(m_axi_rresp[1] & m_axi_rvalid) rd_state <= RW_ERR;
                else if(m_axi_rlast & m_axi_rvalid & (remain_rdata_num == 24'd1)) rd_state <= READ_FINISH;
                else if(read_burst_end) rd_state <= READ_CTRL;
                else rd_state <= READ_DATA;
            end
            READ_FINISH:
            begin
                rd_state <= IDLE;
            end
            RW_ERR:
            begin
                rd_state <= RW_ERR;
            end
        endcase 
end

/*********************** WRITE LOGIC START ************************/
always@(posedge clk)
begin
    if(!rst_n)
        write_init_done <= 1'b0;
    else
        write_init_done <= wr_ctrl_vld;
end

reg [3:0] wr_state_r;

always@(posedge clk)
begin
    if(~rst_n)
        wr_state_r <= 4'd0;
    else
        wr_state_r <= wr_state;
end

wire wr_burst_ctrl_start = (wr_state == WRITE_CTRL) && (wr_state_r != WRITE_CTRL);
reg [3:0] rd_state_r;

always@(posedge clk)
begin
    if(~rst_n)
        rd_state_r <= 4'd0;
    else
        rd_state_r <= rd_state;
end

always@(posedge clk)
begin
    if(!rst_n)
        m_axi_awvalid <= 1'b0;
    else if(wr_burst_ctrl_start)
        m_axi_awvalid <= 1'b1;
    else if(m_axi_awready & m_axi_awvalid)
        m_axi_awvalid <= 1'b0;
end

wire wr_burst_ctrl_done = m_axi_awready & m_axi_awvalid; //align to all wr ctrl sigs

always@(posedge clk)
begin
    if(!rst_n)
        m_axi_awaddr <= 30'd0;
    else if(wr_burst_ctrl_start && (wr_state_r == WRITE_INIT)) //first write burst
        m_axi_awaddr <= wr_addr_r;
    else if(wr_burst_ctrl_start && (wr_state_r == WRITE_CHECK))    //other write burst
        m_axi_awaddr <= m_axi_awaddr + 30'd2048;
end

reg [23:0] already_wdata_num;

always@(posedge clk)
begin
    if(!rst_n)
        already_wdata_num <= 23'd0;
    else if(write_init_done)
        already_wdata_num <= 23'd0;
    else if(wdata_valid & wdata_ready && (already_wdata_num < wr_len_total_r))
        already_wdata_num <= already_wdata_num + 1'b1;
end

always@(*)
begin
    remain_wdata_num = wr_len_total_r - already_wdata_num;
end

always@(posedge clk)
begin
    if(!rst_n)
        m_axi_awlen <= 8'd0;
    else if(wr_burst_ctrl_start)
        if(remain_wdata_num < 256)
            m_axi_awlen <= remain_wdata_num - 1'b1;
        else if(remain_wdata_num >= 256)
            m_axi_awlen <= 8'd255;
end

reg [7:0] single_wr_cnt;

always@(posedge clk)
begin
    if(!rst_n)
        single_wr_cnt <= 8'd0;
    else if((single_wr_cnt == (m_axi_awlen + 1)) && (wr_state == WRITE_DATA))
        single_wr_cnt <= 8'd0;
    else if(wdata_valid & wdata_ready && (wr_state == WRITE_DATA))
        single_wr_cnt <= single_wr_cnt + 1'b1;
end

assign m_axi_wlast = wdata_valid & m_axi_wready & (single_wr_cnt == m_axi_awlen) & (wr_state == WRITE_DATA);
assign wr_finished = (wr_state == WRITE_FINISH);

/*********************** READ LOGIC START *************************/
always@(posedge clk)
begin
    if(!rst_n)
        read_init_done <= 1'b0;
    else
        read_init_done <= rd_ctrl_vld;
end

wire rd_burst_ctrl_start = (rd_state == READ_CTRL) && (rd_state_r != READ_CTRL);

always@(posedge clk)
begin
    if(!rst_n)
        m_axi_arvalid <= 1'b0;
    else if(rd_burst_ctrl_start)
        m_axi_arvalid <= 1'b1;
    else if(m_axi_arready & m_axi_arvalid)
        m_axi_arvalid <= 1'b0;
end

wire rd_burst_ctrl_done = m_axi_arready & m_axi_arvalid; //align to all rd ctrl sigs

always@(posedge clk)
begin
    if(!rst_n)
        m_axi_araddr <= 30'd0;
    else if(rd_burst_ctrl_start && (rd_state_r == READ_INIT)) //first read burst
        m_axi_araddr <= rd_addr_r;
    else if(rd_burst_ctrl_start)    //other read burst
        m_axi_araddr <= m_axi_araddr + 30'd2048;
end

reg [23:0] already_rdata_num;

always@(posedge clk)
begin
    if(!rst_n)
        already_rdata_num <= 23'd0;
    else if(read_init_done)
        already_rdata_num <= 23'd0;
    else if(m_axi_rready & m_axi_rvalid && (already_rdata_num < rd_len_total_r))
        already_rdata_num <= already_rdata_num + 1'b1;
end

always@(*)
begin
    remain_rdata_num = rd_len_total_r - already_rdata_num;
end

assign rd_finished = (rd_state == READ_FINISH);
assign read_burst_end = m_axi_rlast && (rd_state == READ_DATA);

always@(posedge clk)
begin
    if(!rst_n)
        m_axi_arlen <= 8'd0;
    else if(rd_burst_ctrl_start)
        if(remain_rdata_num < 256)
            m_axi_arlen <= remain_rdata_num - 1'b1;
        else if(remain_rdata_num >= 256)
            m_axi_arlen <= 8'd255;
end

mig u_ddr2 (
	// Memory interface ports
	.ddr2_addr                      (ddr2_addr), 
	.ddr2_ba                        (ddr2_ba), 
	.ddr2_cas_n                     (ddr2_cas_n), 
	.ddr2_ck_n                      (ddr2_ck_n), 
	.ddr2_ck_p                      (ddr2_ck_p),
	.ddr2_cke                       (ddr2_cke),  
	.ddr2_ras_n                     (ddr2_ras_n), 
	.ddr2_reset_n                   (ddr2_reset_n), 
	.ddr2_we_n                      (ddr2_we_n),  
	.ddr2_dq                        (ddr2_dq),  
	.ddr2_dqs_n                     (ddr2_dqs_n),  
	.ddr2_dqs_p                     (ddr2_dqs_p),  
	.init_calib_complete            (init_calib_complete),  
	 
	.ddr2_cs_n                      (ddr2_cs_n),  
	.ddr2_dm                        (ddr2_dm),  
	.ddr2_odt                       (ddr2_odt),  
	// Application interface ports
	.ui_clk                         (ui_clk), 
	.ui_clk_sync_rst                (ui_clk_sync_rst),  // output			ui_clk_sync_rst
	.mmcm_locked                    (),  // output			mmcm_locked
	.aresetn                        (1'b1),  // input			aresetn
	.app_sr_req                     (1'b0),  // input			app_sr_req
	.app_ref_req                    (1'b0),  // input			app_ref_req
	.app_zq_req                     (1'b0),  // input			app_zq_req
	.app_sr_active                  (),  // output			app_sr_active
	.app_ref_ack                    (),  // output			app_ref_ack
	.app_zq_ack                     (),  // output			app_zq_ack
	// Slave Interface Write Address Ports
	.s_axi_awid                     (m_axi_awid),  // input [0:0]			s_axi_awid
	.s_axi_awaddr                   (m_axi_awaddr),  // input [29:0]			s_axi_awaddr        //ila 30 9.25.19.58
	.s_axi_awlen                    (m_axi_awlen),  // input [7:0]			s_axi_awlen             //ila 8  9.25.19.58
	.s_axi_awsize                   (m_axi_awsize),  // input [2:0]			s_axi_awsize
	.s_axi_awburst                  (m_axi_awburst),  // input [1:0]			s_axi_awburst
	.s_axi_awlock                   (m_axi_awlock),  // input [0:0]			s_axi_awlock
	.s_axi_awcache                  (m_axi_awcache),  // input [3:0]			s_axi_awcache
	.s_axi_awprot                   (m_axi_awprot),  // input [2:0]			s_axi_awprot
	.s_axi_awqos                    (m_axi_awqos),  // input [3:0]			s_axi_awqos
	.s_axi_awvalid                  (m_axi_awvalid),  // input			s_axi_awvalid
	.s_axi_awready                  (m_axi_awready),  // output			s_axi_awready
	// Slave Interface Write Data Ports
	.s_axi_wdata                    (m_axi_wdata),  // input [31:0]			s_axi_wdata             
	.s_axi_wstrb                    (m_axi_wstrb),  // input [3:0]			s_axi_wstrb
	.s_axi_wlast                    (m_axi_wlast),  // input			s_axi_wlast                 //ila 1
	.s_axi_wvalid                   (m_axi_wvalid),  // input			s_axi_wvalid                //ila 1
	.s_axi_wready                   (m_axi_wready),  // output			s_axi_wready                //ila 1
	// Slave Interface Write Response Ports
	.s_axi_bid                      (m_axi_bid),  // output [0:0]			s_axi_bid
	.s_axi_bresp                    (m_axi_bresp),  // output [1:0]			s_axi_bresp             //ila 2
	.s_axi_bvalid                   (m_axi_bvalid),  // output			s_axi_bvalid                //ila 1
	.s_axi_bready                   (m_axi_bready),  // input			s_axi_bready
	// Slave Interface Read Address Ports
	.s_axi_arid                     (m_axi_arid),  // input [0:0]			s_axi_arid
	.s_axi_araddr                   (m_axi_araddr),  // input [29:0]			s_axi_araddr        //ila 30 9.25.19.58
	.s_axi_arlen                    (m_axi_arlen),  // input [7:0]			s_axi_arlen             //ila 8  9.25.19.58
	.s_axi_arsize                   (m_axi_arsize),  // input [2:0]			s_axi_arsize
	.s_axi_arburst                  (m_axi_arburst),  // input [1:0]			s_axi_arburst
	.s_axi_arlock                   (m_axi_arlock),  // input [0:0]			s_axi_arlock
	.s_axi_arcache                  (m_axi_arcache),  // input [3:0]			s_axi_arcache
	.s_axi_arprot                   (m_axi_arprot),  // input [2:0]			s_axi_arprot
	.s_axi_arqos                    (m_axi_arqos),  // input [3:0]			s_axi_arqos
	.s_axi_arvalid                  (m_axi_arvalid),  // input			s_axi_arvalid
	.s_axi_arready                  (m_axi_arready),  // output			s_axi_arready
	// Slave Interface Read Data Ports
	.s_axi_rid                      (m_axi_rid),  // output [0:0]			s_axi_rid
	.s_axi_rdata                    (m_axi_rdata),  // output [31:0]			s_axi_rdata
	.s_axi_rresp                    (m_axi_rresp),  // output [1:0]			s_axi_rresp             //ila 2
	.s_axi_rlast                    (m_axi_rlast),  // output			s_axi_rlast                 //ila 1
	.s_axi_rvalid                   (m_axi_rvalid),  // output			s_axi_rvalid                //ila 1
	.s_axi_rready                   (m_axi_rready),  // input			s_axi_rready
	// System Clock Ports
	.sys_clk_i                      (sys_clk),
	.sys_rst                        (sys_rst_n) // input sys_rst
);

endmodule
