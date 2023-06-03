`timescale 1ns / 1ps


module ddr2_top(
    /* User interface */
    input                               sys_clk_p,       // 系统时钟正极性输入
    input                               sys_clk_n,       // 系统时钟负极性输入
    output                              ui_clk,          // 用户接口时钟输出（100MHz）
    input                               sys_rst_n,       // 系统复位信号（低电平有效）

    /* read fifo channel */
    input                               video_clk,       // 视频时钟输入
    input                               rd_req,          // 读请求信号输入
    output reg                          rd_req_ack,      // 读请求应答信号输出
    input                               rd_en,           // 读使能信号输入
    output  [15:0]                      rd_data,         // 读数据输出

    /* write fifo channel */
    input                               cmos_pclk,       // CMOS数据时钟输入
    input                               wr_req,          // 写请求信号输入
    input                               wr_en,           // 写使能信号输入
    input   [15:0]                      wr_data,         // 写数据输入

    output                              init_calib_complete, // DDR初始化校准完成信号输出

    /* DDR3 phy interface */
	inout [31:0]                       ddr2_dq,         // DDR数据线，双向，32位
	inout [3:0]                        ddr2_dqs_n,      // DDR数据时钟信号差分负极性，双向，4位
	inout [3:0]                        ddr2_dqs_p,      // DDR数据时钟信号差分正极性，双向，4位
	output [14:0]                      ddr2_addr,       // DDR地址线，输出，15位
	output [2:0]                       ddr2_ba,         // DDR bank地址线，输出，3位
	output                             ddr2_ras_n,      // DDR行地址选通信号，输出
	output                             ddr2_cas_n,      // DDR列地址选通信号，输出
	output                             ddr2_we_n,       // DDR写使能信号，输出
	output                             ddr2_reset_n,    // DDR复位信号，输出
	output [0:0]                       ddr2_ck_p,       // DDR时钟信号正极性，输出
	output [0:0]                       ddr2_ck_n,       // DDR时钟信号负极性，输出
	output [0:0]                       ddr2_cke,        // DDR时钟使能信号，输出
	output [0:0]                       ddr2_cs_n,       // DDR芯片选通信号，输出
	output [3:0]                       ddr2_dm,         // DDR数据掩码信号，输出，4位
	output [0:0]                       ddr2_odt         // DDR输出驱动器使能信号，输出
    );
    
/* register */
reg write_region_flg;           // 写入区域标志位
reg read_region_flg;            // 读取区域标志位
reg frame_writing_to_ddr;       // 正在将帧写入DDR标志位
reg frame_reading_from_ddr;     // 正在从DDR读取帧标志位
reg wr_req_pend;                // 写请求挂起标志位
reg rd_req_pend;                // 读请求挂起标志位

/* wire define */
wire            rst_n               ;  // 复位信号

wire [15:0]     write_fifo_dout     ;  // 写入FIFO的输出数据
wire            write_fifo_empty    ;  // 写入FIFO是否为空
wire [31:0]     write_fifo_data     ;  // 写入FIFO的数据
wire            write_fifo_rd_en    ;  // 写入FIFO读使能信号
wire            wdata_ready         ;  // 数据准备好信号
wire            wr_finished         ;  // 写操作完成信号
wire [29:0]     wr_addr             ;  // 写入地址
wire [23:0]     wr_len_total        ;  // 写入总长度
wire            wr_ctrl_vld         ;  // 写控制信号有效
wire            write_fifo_wr_en    ;  // 写入FIFO写使能信号
wire            write_req_pend_fifo_empty;  // 写请求挂起FIFO是否为空

wire [31:0]     rdata               ;  // 读取的数据
wire            rdata_valid         ;  // 读取数据的有效性
wire [29:0]     rd_addr             ;  // 读取地址
wire [23:0]     rd_len_total        ;  // 读取总长度
wire            master_ready        ;  // 主模块是否就绪
wire            rd_ctrl_vld         ;  // 读控制信号有效
wire            rd_finished         ;  // 读操作完成信号
wire [15:0]     read_fifo_din       ;  // 读取FIFO的输入数据
wire            read_fifo_wr_en     ;  // 读取FIFO写使能信号
wire            read_fifo_full      ;  // 读取FIFO是否已满
wire            read_req_pend_fifo_empty;  // 读请求挂起FIFO是否为空

/* wire assign */
assign ui_clk = clk;                            // 输入时钟信号
assign rst_n = sys_rst_n & init_calib_complete;  // 复位信号

assign write_fifo_data = {16'd0, write_fifo_dout};   // 写入FIFO数据
assign write_fifo_rd_en = ~write_fifo_empty & wdata_ready;   // 写入FIFO读使能信号
assign wr_addr = write_region_flg? {27'h1,3'd000}: {27'h100000,3'd000};   // 写入地址
assign wr_len_total = 24'd786432;   // 写入数据总长度
assign wr_ctrl_vld = (~write_req_pend_fifo_empty & ~frame_writing_to_ddr) | (wr_req & ~frame_writing_to_ddr);   // 写入控制信号有效
assign write_fifo_wr_en = wr_en;   // 写入FIFO写使能信号

assign read_fifo_din = rdata[15:0];   // 读取FIFO数据输入
assign read_fifo_wr_en = ~(read_fifo_almost_full & read_fifo_full) & rdata_valid;   // 读取FIFO写使能信号
assign rd_addr = read_region_flg? {27'h1,3'd000}: {27'h100000,3'd000};   // 读取地址
assign rd_len_total = 24'd786432;   // 读取数据总长度
assign master_ready = ~(read_fifo_almost_full & read_fifo_full);   // 主模块准备就绪信号
assign rd_ctrl_vld = (~read_req_pend_fifo_empty & ~frame_reading_from_ddr) | (rd_req & ~frame_reading_from_ddr);   // 读取控制信号有效

always@(posedge clk)
begin
    if(~rst_n)
        write_region_flg <= 1'b0;
    else if(wr_ctrl_vld)
        write_region_flg <= ~write_region_flg;
end

always@(posedge clk)
begin
    if(~rst_n)
        read_region_flg <= 1'b0;
    else if(rd_ctrl_vld)
        read_region_flg <= ~read_region_flg;
end

always@(posedge clk)
begin
    if(~rst_n)
        rd_req_ack <= 1'b0;
    else if(rd_req)
        rd_req_ack <= 1'b1;
    else
        rd_req_ack <= 1'b0;
end

always@(posedge clk)
begin
    if(~rst_n)
        frame_writing_to_ddr <= 1'b0;
    else if(wr_finished)
        frame_writing_to_ddr <= 1'b0;
    else if(wr_ctrl_vld)
        frame_writing_to_ddr <= 1'b1;
end

always@(posedge clk)
begin
    if(~rst_n)
        frame_reading_from_ddr <= 1'b0;
    else if(rd_finished)
        frame_reading_from_ddr <= 1'b0;
    else if(rd_ctrl_vld)
        frame_reading_from_ddr <= 1'b1;
end

always@(posedge clk)
begin
    if(~rst_n)
        wr_req_pend <= 1'b0;
    else if(frame_writing_to_ddr & wr_req)
        wr_req_pend <= 1'b1;
    else
        wr_req_pend <= 1'b0;
end

always@(posedge clk)
begin
    if(~rst_n)
        rd_req_pend <= 1'b0;
    else if(frame_reading_from_ddr & rd_req)
        rd_req_pend <= 1'b1;
    else
        rd_req_pend <= 1'b0;
end

req_pend_fifo read_req_pend_fifo (
  .clk(clk),      // input wire clk
  .srst(~rst_n),    // input wire srst
  .din(1'b1),      // input wire [0 : 0] din
  .wr_en(rd_req_pend),  // input wire wr_en
  .rd_en(rd_ctrl_vld),  // input wire rd_en
  .dout(),    // output wire [0 : 0] dout
  .full(),    // output wire full
  .empty(read_req_pend_fifo_empty)  // output wire empty
);

req_pend_fifo write_req_pend_fifo (
  .clk(clk),      // input wire clk
  .srst(~rst_n),    // input wire srst
  .din(1'b1),      // input wire [0 : 0] din
  .wr_en(wr_req_pend),  // input wire wr_en
  .rd_en(wr_ctrl_vld),  // input wire rd_en
  .dout(),    // output wire [0 : 0] dout
  .full(),    // output wire full
  .empty(write_req_pend_fifo_empty)  // output wire empty
);

read_fifo read_channel (
  .rst(~rst_n),        // input wire rst
  .wr_clk(clk),  // input wire wr_clk
  .rd_clk(video_clk),  // input wire rd_clk
  .din(read_fifo_din),        // input wire [15 : 0] din
  .wr_en(read_fifo_wr_en),    // input wire wr_en
  .rd_en(rd_en),    // input wire rd_en
  .dout(rd_data),      // output wire [15 : 0] dout
  .full(read_fifo_full),      // output wire full
  .almost_full(read_fifo_almost_full),  // output wire almost_full
  .empty()    // output wire empty
);

write_fifo write_channel (
  .rst(~rst_n),        // input wire rst
  .wr_clk(cmos_pclk),  // input wire wr_clk
  .rd_clk(clk),  // input wire rd_clk
  .din(wr_data),        // input wire [15 : 0] din
  .wr_en(write_fifo_wr_en),    // input wire wr_en
  .rd_en(write_fifo_rd_en),    // input wire rd_en
  .dout(write_fifo_dout),      // output wire [15 : 0] dout
  .full(),      // output wire full
  .empty(write_fifo_empty)    // output wire empty
);

ddr2_axi u_ddr2_axi(
    /* User interface */
    .sys_clk_p(sys_clk_p),                      // 系统时钟正极性
    .sys_clk_n(sys_clk_n),                      // 系统时钟负极性
    .ui_clk(clk),                               // 用户接口时钟
    .sys_rst_n(sys_rst_n),                      // 系统复位信号（低电平有效）

    .wdata(write_fifo_data),                     // 写入数据
    .wdata_valid(write_fifo_rd_en),              // 写入数据有效
    .wdata_ready(wdata_ready),                    // 写入数据就绪
    .wr_addr(wr_addr),                            // 写入地址
    .wr_len_total(wr_len_total),                   // 写入长度（以32位字为单位）
    .wr_ctrl_vld(wr_ctrl_vld),                     // 写入控制信号有效
    .wr_finished(wr_finished),                     // 写入完成信号

    .rdata(rdata),                                // 读取数据
    .rdata_valid(rdata_valid),                     // 读取数据有效
    .rd_addr(rd_addr),                             // 读取地址
    .rd_len_total(rd_len_total),                    // 读取长度（以32位字为单位）
    .master_ready(master_ready),                    // 主机就绪信号
    .rd_ctrl_vld(rd_ctrl_vld),                      // 读取控制信号有效
    .rd_finished(rd_finished),                      // 读取完成信号
    .init_calib_complete(init_calib_complete),      // 初始化校准完成信号

    .ddr2_dq(ddr2_dq),                            // DDR数据线
    .ddr2_dqs_n(ddr2_dqs_n),                      // DDR数据时钟信号差分负极性
    .ddr2_dqs_p(ddr2_dqs_p),                      // DDR数据时钟信号差分正极性
    .ddr2_addr(ddr2_addr),                         // DDR地址线
    .ddr2_ba(ddr2_ba),                             // DDR bank地址线
    .ddr2_ras_n(ddr2_ras_n),                       // DDR行地址选通信号
    .ddr2_cas_n(ddr2_cas_n),                       // DDR列地址选通信号
    .ddr2_we_n(ddr2_we_n),                         // DDR写使能信号
    .ddr2_reset_n(ddr2_reset_n),                   // DDR复位信号
	// DDR2 clock positive signal
	.ddr2_ck_p(ddr2_ck_p),
	// DDR2 clock negative signal
	.ddr2_ck_n(ddr2_ck_n),
	// DDR2 clock enable signal
	.ddr2_cke(ddr2_cke),
	// DDR2 chip select signal (active low)
	.ddr2_cs_n(ddr2_cs_n),
	// DDR2 data mask signals
	.ddr2_dm(ddr2_dm),
	// DDR2 on-die termination signals
	.ddr2_odt(ddr2_odt)
);
 
endmodule
