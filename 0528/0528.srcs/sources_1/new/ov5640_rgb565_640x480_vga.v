`timescale 1ns / 1ps


module ov5640_rgb565_640x480_vga(
    input                               sys_clk_p,       // ϵͳʱ������������
    input                               sys_clk_n,       // ϵͳʱ�Ӹ���������
    input                               sys_rst_n,       // ϵͳ��λ�źţ���������Ч��

    // ����ͷ
    input cam_pclk,           // ����ͷ����ʱ��
    input cam_vsync,          // ����ͷ��ֱͬ���ź�
    input cam_href,           // ����ͷ��ͬ���ź�
    input [7:0] cam_data,     // ����ͷ��������
    output cam_rst_n,         // ����ͷ��λ�źţ���������Ч��
    output cam_pwdn,          // ����ͷ��Դ�����ź�
    output cam_scl,           // ����ͷI2Cʱ����
    output                cam_xclk,    // ����ͷ����ʱ�����
    output cam_sda,            // ����ͷI2C������

// DDR3 phy interface
inout [31:0] ddr2_dq,           // DDR�����ߣ�˫��32λ
inout [3:0] ddr2_dqs_n,         // DDR����ʱ���źŲ�ָ����ԣ�˫��4λ
inout [3:0] ddr2_dqs_p,         // DDR����ʱ���źŲ�������ԣ�˫��4λ
output [14:0] ddr2_addr,        // DDR��ַ�ߣ������15λ
output [2:0] ddr2_ba,           // DDR bank��ַ�ߣ������3λ
output ddr2_ras_n,              // DDR�е�ַѡͨ�źţ����
output ddr2_cas_n,              // DDR�е�ַѡͨ�źţ����
output ddr2_we_n,               // DDRдʹ���źţ����
output ddr2_reset_n,            // DDR��λ�źţ����
output [0:0] ddr2_ck_p,         // DDRʱ���ź������ԣ����
output [0:0] ddr2_ck_n,         // DDRʱ���źŸ����ԣ����
output [0:0] ddr2_cke,          // DDRʱ��ʹ���źţ����
output [0:0] ddr2_cs_n,         // DDRоƬѡͨ�źţ����
output [3:0] ddr2_dm,           // DDR���������źţ������4λ
output [0:0] ddr2_odt,           // DDR���������ʹ���źţ����

    //VGA
    output vga_hs,
    output vga_vs,
    output [15:0] vga_rgb
    );
    
//parameter define
parameter  SLAVE_ADDR = 7'h3c         ;  //OV5640的器件地�??7'h3c
parameter  BIT_CTRL   = 1'b1          ;  //OV5640的字节地�??�??16�??  0:8�?? 1:16�??
parameter  CLK_FREQ   = 26'd65_000_000;  //i2c_dri模块的驱动时钟频率：65Mhz
parameter  I2C_FREQ   = 18'd250_000   ;  //I2C的SCL时钟频率,不超�??400KHz
parameter  CMOS_H_PIXEL = 24'd640    ;  //CMOS水平方向像素个数,用于设置SDRAM缓存大小
parameter  CMOS_V_PIXEL = 24'd480     ;  //CMOS垂直方向像素个数,用于设置SDRAM缓存大小
    
//wire define
wire                  clk_65m         ;  //65mhz时钟,提供给IIC驱动时钟和vga驱动时钟
wire clk_100m;  
wire                  locked          ;
wire                  rst_n           ;    
    
wire                  i2c_exec        ;  //I2C触发执行信号
wire   [23:0]         i2c_data        ;  //I2C要配置的地址与数�??(�??8位地�??,�??8位数�??)          
wire                  cam_init_done   ;  //摄像头初始化完成
wire                  i2c_done        ;  //I2C寄存器配置完成信�??
wire                  i2c_dri_clk     ;  //I2C操作时钟    
    
wire                  wr_en           ;  //sdram_ctrl模块写使�??
wire   [15:0]         wr_data         ;  //sdram_ctrl模块写数�??
wire                  rd_en           ;  //sdram_ctrl模块读使�??
wire   [15:0]         rd_data         ;  //sdram_ctrl模块读数�??
wire ddr2_init_done;
wire                  sys_init_done   ;  //系统初始化完�??(sdram初始�??+摄像头初始化)
    
assign rst_n = sys_rst_n & locked;   // ��λ�źţ�ͨ�����߼���������ϵͳ��λ�ź��������ź�����õ���λ�ź�
assign sys_init_done = ddr2_init_done & cam_init_done;   // ϵͳ��ʼ������źţ�ͨ�����߼���������DDR2��ʼ������źź�����ͷ��ʼ������ź�����õ�ϵͳ��ʼ������ź�
assign cam_rst_n = 1'b1;   // ����ͷ��λ�źţ�ʼ��Ϊ�ߵ�ƽ����ʾ����ͷ���ڸ�λ״̬
assign cam_pwdn = 1'b0;   // ����ͷ��Դ�����źţ�ʼ��Ϊ�͵�ƽ����ʾ����ͷ���ڹ���״̬
    
mmcm u_mmcm(    
    // Clock out ports    
    .clk_65m(clk_65m),     // output clk_65m    
    .xclk(cam_xclk),     // output xclk 24m    
    .clk_100m(clk_100m),     // output clk_100m    
    // Status and control signals    
    .locked(locked),       // output lockedendmodule
   // Clock in ports
    .ui_clk(ui_clk));      // input ui_clkk

// I2C����
i2c_ov5640_rgb565_cfg
#(
    .CMOS_H_PIXEL(CMOS_H_PIXEL),            // CMOSͼ���ˮƽ������
    .CMOS_V_PIXEL(CMOS_V_PIXEL)             // CMOSͼ��Ĵ�ֱ������
)
u_i2c_cfg(
    .clk(i2c_dri_clk),                       // I2C������ʱ���ź�
    .rst_n(rst_n),                           // �����źţ�����Ч��
    .i2c_done(i2c_done),                     // I2C��������ź�
    .i2c_exec(i2c_exec),                     // ִ��I2C�����ʹ���ź�
    .i2c_data(i2c_data),                     // I2C�����ź�
    .init_done(cam_init_done)                // ����ͷ��ʼ������ź�
);
  
// I2C����ģ��
i2c_dri
#(
.SLAVE_ADDR         (SLAVE_ADDR),       // ���豸��ַ
.CLK_FREQ           (CLK_FREQ  ),       // ϵͳʱ��Ƶ��
.I2C_FREQ           (I2C_FREQ  )        // I2Cͨ��Ƶ��
)
u_i2c_dri(
.clk                (clk_65m   ),       // ����ʱ��
.rst_n              (sys_rst_n & locked & init_calib_complete),   // ��λ�ź�

.i2c_exec           (i2c_exec  ),       // I2Cִ���ź�
.bit_ctrl           (BIT_CTRL  ),       // I2Cλ�����ź�
.i2c_rh_wl          (1'b0),             // I2C��/дѡ��0��ʾ��ָ��IC�豸��������
.i2c_addr           (i2c_data[23:8]),   // I2C�豸��ַ
.i2c_data_w         (i2c_data[7:0]),    // I2Cд����
.i2c_data_r         (),                 // I2C������
.i2c_done           (i2c_done  ),       // I2C��������ź�
.scl                (cam_scl   ),       // I2Cʱ����
.sda                (cam_sda   ),       // I2C������

.dri_clk            (i2c_dri_clk)       // I2C����ʱ��
);
        
// I2C master controller
i2c_config i2c_config(
	.rst                        (rst),                // ��λ�ź�����
	.clk                        (clk_100m),           // ʱ���ź�����
	.clk_div_cnt                (16'd500),            // ʱ�ӷ�Ƶ������ֵ
	.i2c_addr_2byte             (1'b0),               // I2C��ַ�Ƿ�Ϊ2�ֽ�
	.error                      (                      ),  // �����ź����
	.done                       (                      ),  // ����ź����
	.i2c_scl                    (vga_scl),            // I2Cʱ�����ź�����/���
	.i2c_sda                    (vga_sda)             // I2C�������ź�����/���
);

// CMOSͼ�����ݲɼ�
cmos_capture_data u_cmos_capture_data(
    .rst_n(rst_n & sys_init_done),  // ��λ�źţ���ϵͳ��ʼ������ź����룬���ڿ���ģ��ĸ�λ
    
    .cam_pclk(cam_pclk),            // CMOS����ͷ����ʱ���ź�
    .cam_vsync(cam_vsync),          // CMOS����ͷ��ֱͬ���ź�
    .cam_href(cam_href),            // CMOS����ͷ��ͬ���ź�
    .cam_data(cam_data),            // CMOS����ͷ�����ź�
    
    .cmos_frame_vsync(),            // �����CMOSͼ��֡��ֱͬ���ź�
    .cmos_frame_href(),             // �����CMOSͼ��֡��ͬ���ź�
    .cmos_frame_valid(wr_en),       // �����CMOSͼ��֡��Ч�ź�
    .cmos_frame_data(wr_data)       // �����CMOSͼ��֡����
);

// DDR2������ģ��
ddr2_top u_ddr2_top(
    /* User interface */
    .sys_clk_p(sys_clk_p),       // ϵͳʱ������������
    .sys_clk_n(sys_clk_n),       // ϵͳʱ�Ӹ���������
    .ui_clk(ui_clk),             // �û��ӿ�ʱ�ӣ�100MHz��
    .sys_rst_n(sys_rst_n),       // ϵͳ��λ�źţ��͵�ƽ��Ч��

    /* read fifo channel */
    .video_clk(clk_65m),         // ��Ƶʱ�ӣ�65MHz��
    .rd_req(read_req),           // �������ź�
    .rd_req_ack(read_req_ack),   // ������Ӧ���ź�
    .rd_en(read_en),             // ��ʹ���ź�
    .rd_data(read_data_ori),     // ��ȡ������
    .rd_min_addr(24'd0),         // ��ȡ���ݵ���С��ַ
    .rd_max_addr(CMOS_H_PIXEL*CMOS_V_PIXEL),  // ��ȡ���ݵ�����ַ
    .rd_len(10'd512),            // ��ȡ���ݵĳ���
    .rd_load(~rst_n),            // ��ȡ���ݼ����ź�

    /* write fifo channel */
    .cmos_pclk(cam_pclk),        // ����ͷ����ʱ������
    .wr_req(cmos_wr_req),        // д�����ź�
    .wr_en(wr_en),               // дʹ���ź�
    .wr_data(wr_data),           // д�������
    .wr_min_addr(24'd0),         // д�����ݵ���С��ַ
    .wr_max_addr(CMOS_H_PIXEL*CMOS_V_PIXEL),  // д�����ݵ�����ַ
    .wr_len(10'd512),            // д�����ݵĳ���
    .init_calib_complete(init_calib_complete),  // ��ʼ��У׼����ź�
    .wr_load(~rst_n),            // д�����ݼ����ź�

    /* DDR2 phy interface */
    .ddr2_dq(ddr2_dq),           // DDR������
    .ddr2_dqs_n(ddr2_dqs_n),     // DDR����ʱ���źŲ�ָ�����
    .ddr2_dqs_p(ddr2_dqs_p),     // DDR����ʱ���źŲ��������
    .ddr2_addr(ddr2_addr),       // DDR��ַ��
    .ddr2_ba(ddr2_ba),           // DDR bank��ַ��
    .ddr2_ras_n(ddr2_ras_n),     // DDR�е�ַѡͨ�ź�
    .ddr2_cas_n(ddr2_cas_n),     // DDR�е�ַѡͨ�ź�
    .ddr2_we_n(ddr2_we_n),       // DDRдʹ���ź�
    .ddr2_reset_n(ddr2_reset_n), // DDR��λ�ź�
    .ddr2_ck_p(ddr2_ck_p),       // DDRʱ���ź�������
    .ddr2_ck_n(ddr2_ck_n),       // DDRʱ���źŸ�����
    .ddr2_cke(ddr2_cke),         // DDRʱ��ʹ���ź�
    .ddr2_cs_n(ddr2_cs_n),       // DDRоƬѡͨ�ź�
    .ddr2_dm(ddr2_dm),           // DDR���������ź�
    .ddr2_odt(ddr2_odt)          // DDR���������ʹ���ź�
);
      
// VGA Display Driver Module Instantiation
vga_dri u_vga_dri (
    .vga_clk(clk_25m),          // VGAʱ������
    .sys_rst_n(rst_n),          // ϵͳ��λ�ź�

    .vga_hs(vga_hs),            // VGA��ͬ���ź����
    .vga_vs(vga_vs),            // VGA��ͬ���ź����
    .vga_rgb(vga_rgb),          // VGA RGB��ɫ���

    .pixel_data(rd_data),       // ������������
    .data_req(rd_en),           // ���������ź�����
    .pixel_xpos(),              // ����X����
    .pixel_ypos()               // ����Y����
);

endmodule        
          