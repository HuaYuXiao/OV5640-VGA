`timescale 1ns / 1ps


module ddr2_top(
    /* User interface */
    input                               sys_clk_p,       // ϵͳʱ������������
    input                               sys_clk_n,       // ϵͳʱ�Ӹ���������
    output                              ui_clk,          // �û��ӿ�ʱ�������100MHz��
    input                               sys_rst_n,       // ϵͳ��λ�źţ��͵�ƽ��Ч��

    /* read fifo channel */
    input                               video_clk,       // ��Ƶʱ������
    input                               rd_req,          // �������ź�����
    output reg                          rd_req_ack,      // ������Ӧ���ź����
    input                               rd_en,           // ��ʹ���ź�����
    output  [15:0]                      rd_data,         // ���������

    /* write fifo channel */
    input                               cmos_pclk,       // CMOS����ʱ������
    input                               wr_req,          // д�����ź�����
    input                               wr_en,           // дʹ���ź�����
    input   [15:0]                      wr_data,         // д��������

    output                              init_calib_complete, // DDR��ʼ��У׼����ź����

    /* DDR3 phy interface */
	inout [31:0]                       ddr2_dq,         // DDR�����ߣ�˫��32λ
	inout [3:0]                        ddr2_dqs_n,      // DDR����ʱ���źŲ�ָ����ԣ�˫��4λ
	inout [3:0]                        ddr2_dqs_p,      // DDR����ʱ���źŲ�������ԣ�˫��4λ
	output [14:0]                      ddr2_addr,       // DDR��ַ�ߣ������15λ
	output [2:0]                       ddr2_ba,         // DDR bank��ַ�ߣ������3λ
	output                             ddr2_ras_n,      // DDR�е�ַѡͨ�źţ����
	output                             ddr2_cas_n,      // DDR�е�ַѡͨ�źţ����
	output                             ddr2_we_n,       // DDRдʹ���źţ����
	output                             ddr2_reset_n,    // DDR��λ�źţ����
	output [0:0]                       ddr2_ck_p,       // DDRʱ���ź������ԣ����
	output [0:0]                       ddr2_ck_n,       // DDRʱ���źŸ����ԣ����
	output [0:0]                       ddr2_cke,        // DDRʱ��ʹ���źţ����
	output [0:0]                       ddr2_cs_n,       // DDRоƬѡͨ�źţ����
	output [3:0]                       ddr2_dm,         // DDR���������źţ������4λ
	output [0:0]                       ddr2_odt         // DDR���������ʹ���źţ����
    );
    
/* register */
reg write_region_flg;           // д�������־λ
reg read_region_flg;            // ��ȡ�����־λ
reg frame_writing_to_ddr;       // ���ڽ�֡д��DDR��־λ
reg frame_reading_from_ddr;     // ���ڴ�DDR��ȡ֡��־λ
reg wr_req_pend;                // д��������־λ
reg rd_req_pend;                // ����������־λ

/* wire define */
wire            rst_n               ;  // ��λ�ź�

wire [15:0]     write_fifo_dout     ;  // д��FIFO���������
wire            write_fifo_empty    ;  // д��FIFO�Ƿ�Ϊ��
wire [31:0]     write_fifo_data     ;  // д��FIFO������
wire            write_fifo_rd_en    ;  // д��FIFO��ʹ���ź�
wire            wdata_ready         ;  // ����׼�����ź�
wire            wr_finished         ;  // д��������ź�
wire [29:0]     wr_addr             ;  // д���ַ
wire [23:0]     wr_len_total        ;  // д���ܳ���
wire            wr_ctrl_vld         ;  // д�����ź���Ч
wire            write_fifo_wr_en    ;  // д��FIFOдʹ���ź�
wire            write_req_pend_fifo_empty;  // д�������FIFO�Ƿ�Ϊ��

wire [31:0]     rdata               ;  // ��ȡ������
wire            rdata_valid         ;  // ��ȡ���ݵ���Ч��
wire [29:0]     rd_addr             ;  // ��ȡ��ַ
wire [23:0]     rd_len_total        ;  // ��ȡ�ܳ���
wire            master_ready        ;  // ��ģ���Ƿ����
wire            rd_ctrl_vld         ;  // �������ź���Ч
wire            rd_finished         ;  // ����������ź�
wire [15:0]     read_fifo_din       ;  // ��ȡFIFO����������
wire            read_fifo_wr_en     ;  // ��ȡFIFOдʹ���ź�
wire            read_fifo_full      ;  // ��ȡFIFO�Ƿ�����
wire            read_req_pend_fifo_empty;  // ���������FIFO�Ƿ�Ϊ��

/* wire assign */
assign ui_clk = clk;                            // ����ʱ���ź�
assign rst_n = sys_rst_n & init_calib_complete;  // ��λ�ź�

assign write_fifo_data = {16'd0, write_fifo_dout};   // д��FIFO����
assign write_fifo_rd_en = ~write_fifo_empty & wdata_ready;   // д��FIFO��ʹ���ź�
assign wr_addr = write_region_flg? {27'h1,3'd000}: {27'h100000,3'd000};   // д���ַ
assign wr_len_total = 24'd786432;   // д�������ܳ���
assign wr_ctrl_vld = (~write_req_pend_fifo_empty & ~frame_writing_to_ddr) | (wr_req & ~frame_writing_to_ddr);   // д������ź���Ч
assign write_fifo_wr_en = wr_en;   // д��FIFOдʹ���ź�

assign read_fifo_din = rdata[15:0];   // ��ȡFIFO��������
assign read_fifo_wr_en = ~(read_fifo_almost_full & read_fifo_full) & rdata_valid;   // ��ȡFIFOдʹ���ź�
assign rd_addr = read_region_flg? {27'h1,3'd000}: {27'h100000,3'd000};   // ��ȡ��ַ
assign rd_len_total = 24'd786432;   // ��ȡ�����ܳ���
assign master_ready = ~(read_fifo_almost_full & read_fifo_full);   // ��ģ��׼�������ź�
assign rd_ctrl_vld = (~read_req_pend_fifo_empty & ~frame_reading_from_ddr) | (rd_req & ~frame_reading_from_ddr);   // ��ȡ�����ź���Ч

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
    .sys_clk_p(sys_clk_p),                      // ϵͳʱ��������
    .sys_clk_n(sys_clk_n),                      // ϵͳʱ�Ӹ�����
    .ui_clk(clk),                               // �û��ӿ�ʱ��
    .sys_rst_n(sys_rst_n),                      // ϵͳ��λ�źţ��͵�ƽ��Ч��

    .wdata(write_fifo_data),                     // д������
    .wdata_valid(write_fifo_rd_en),              // д��������Ч
    .wdata_ready(wdata_ready),                    // д�����ݾ���
    .wr_addr(wr_addr),                            // д���ַ
    .wr_len_total(wr_len_total),                   // д�볤�ȣ���32λ��Ϊ��λ��
    .wr_ctrl_vld(wr_ctrl_vld),                     // д������ź���Ч
    .wr_finished(wr_finished),                     // д������ź�

    .rdata(rdata),                                // ��ȡ����
    .rdata_valid(rdata_valid),                     // ��ȡ������Ч
    .rd_addr(rd_addr),                             // ��ȡ��ַ
    .rd_len_total(rd_len_total),                    // ��ȡ���ȣ���32λ��Ϊ��λ��
    .master_ready(master_ready),                    // ���������ź�
    .rd_ctrl_vld(rd_ctrl_vld),                      // ��ȡ�����ź���Ч
    .rd_finished(rd_finished),                      // ��ȡ����ź�
    .init_calib_complete(init_calib_complete),      // ��ʼ��У׼����ź�

    .ddr2_dq(ddr2_dq),                            // DDR������
    .ddr2_dqs_n(ddr2_dqs_n),                      // DDR����ʱ���źŲ�ָ�����
    .ddr2_dqs_p(ddr2_dqs_p),                      // DDR����ʱ���źŲ��������
    .ddr2_addr(ddr2_addr),                         // DDR��ַ��
    .ddr2_ba(ddr2_ba),                             // DDR bank��ַ��
    .ddr2_ras_n(ddr2_ras_n),                       // DDR�е�ַѡͨ�ź�
    .ddr2_cas_n(ddr2_cas_n),                       // DDR�е�ַѡͨ�ź�
    .ddr2_we_n(ddr2_we_n),                         // DDRдʹ���ź�
    .ddr2_reset_n(ddr2_reset_n),                   // DDR��λ�ź�
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
