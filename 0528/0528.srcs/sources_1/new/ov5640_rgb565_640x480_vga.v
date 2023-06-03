`timescale 1ns / 1ps


module ov5640_rgb565_640x480_vga(
    input                               sys_clk_p,       // 系统时钟正极性输入
    input                               sys_clk_n,       // 系统时钟负极性输入
    input                               sys_rst_n,       // 系统复位信号（负极性有效）

    // 摄像头
    input cam_pclk,           // 摄像头像素时钟
    input cam_vsync,          // 摄像头垂直同步信号
    input cam_href,           // 摄像头行同步信号
    input [7:0] cam_data,     // 摄像头数据总线
    output cam_rst_n,         // 摄像头复位信号（负极性有效）
    output cam_pwdn,          // 摄像头电源控制信号
    output cam_scl,           // 摄像头I2C时钟线
    output                cam_xclk,    // 摄像头像素时钟输出
    output cam_sda,            // 摄像头I2C数据线

// DDR3 phy interface
inout [31:0] ddr2_dq,           // DDR数据线，双向，32位
inout [3:0] ddr2_dqs_n,         // DDR数据时钟信号差分负极性，双向，4位
inout [3:0] ddr2_dqs_p,         // DDR数据时钟信号差分正极性，双向，4位
output [14:0] ddr2_addr,        // DDR地址线，输出，15位
output [2:0] ddr2_ba,           // DDR bank地址线，输出，3位
output ddr2_ras_n,              // DDR行地址选通信号，输出
output ddr2_cas_n,              // DDR列地址选通信号，输出
output ddr2_we_n,               // DDR写使能信号，输出
output ddr2_reset_n,            // DDR复位信号，输出
output [0:0] ddr2_ck_p,         // DDR时钟信号正极性，输出
output [0:0] ddr2_ck_n,         // DDR时钟信号负极性，输出
output [0:0] ddr2_cke,          // DDR时钟使能信号，输出
output [0:0] ddr2_cs_n,         // DDR芯片选通信号，输出
output [3:0] ddr2_dm,           // DDR数据掩码信号，输出，4位
output [0:0] ddr2_odt,           // DDR输出驱动器使能信号，输出

    //VGA
    output vga_hs,
    output vga_vs,
    output [15:0] vga_rgb
    );
    
//parameter define
parameter  SLAVE_ADDR = 7'h3c         ;  //OV5640鐨勫櫒浠跺湴锟??7'h3c
parameter  BIT_CTRL   = 1'b1          ;  //OV5640鐨勫瓧鑺傚湴锟??锟??16锟??  0:8锟?? 1:16锟??
parameter  CLK_FREQ   = 26'd65_000_000;  //i2c_dri妯″潡鐨勯┍鍔ㄦ椂閽熼鐜囷細65Mhz
parameter  I2C_FREQ   = 18'd250_000   ;  //I2C鐨凷CL鏃堕挓棰戠巼,涓嶈秴锟??400KHz
parameter  CMOS_H_PIXEL = 24'd640    ;  //CMOS姘村钩鏂瑰悜鍍忕礌涓暟,鐢ㄤ簬璁剧疆SDRAM缂撳瓨澶у皬
parameter  CMOS_V_PIXEL = 24'd480     ;  //CMOS鍨傜洿鏂瑰悜鍍忕礌涓暟,鐢ㄤ簬璁剧疆SDRAM缂撳瓨澶у皬
    
//wire define
wire                  clk_65m         ;  //65mhz鏃堕挓,鎻愪緵缁橧IC椹卞姩鏃堕挓鍜寁ga椹卞姩鏃堕挓
wire clk_100m;  
wire                  locked          ;
wire                  rst_n           ;    
    
wire                  i2c_exec        ;  //I2C瑙﹀彂鎵ц淇″彿
wire   [23:0]         i2c_data        ;  //I2C瑕侀厤缃殑鍦板潃涓庢暟锟??(锟??8浣嶅湴锟??,锟??8浣嶆暟锟??)          
wire                  cam_init_done   ;  //鎽勫儚澶村垵濮嬪寲瀹屾垚
wire                  i2c_done        ;  //I2C瀵勫瓨鍣ㄩ厤缃畬鎴愪俊锟??
wire                  i2c_dri_clk     ;  //I2C鎿嶄綔鏃堕挓    
    
wire                  wr_en           ;  //sdram_ctrl妯″潡鍐欎娇锟??
wire   [15:0]         wr_data         ;  //sdram_ctrl妯″潡鍐欐暟锟??
wire                  rd_en           ;  //sdram_ctrl妯″潡璇讳娇锟??
wire   [15:0]         rd_data         ;  //sdram_ctrl妯″潡璇绘暟锟??
wire ddr2_init_done;
wire                  sys_init_done   ;  //绯荤粺鍒濆鍖栧畬锟??(sdram鍒濆锟??+鎽勫儚澶村垵濮嬪寲)
    
assign rst_n = sys_rst_n & locked;   // 复位信号，通过与逻辑操作符将系统复位信号与锁定信号相与得到复位信号
assign sys_init_done = ddr2_init_done & cam_init_done;   // 系统初始化完成信号，通过与逻辑操作符将DDR2初始化完成信号和摄像头初始化完成信号相与得到系统初始化完成信号
assign cam_rst_n = 1'b1;   // 摄像头复位信号，始终为高电平，表示摄像头处于复位状态
assign cam_pwdn = 1'b0;   // 摄像头电源控制信号，始终为低电平，表示摄像头处于工作状态
    
mmcm u_mmcm(    
    // Clock out ports    
    .clk_65m(clk_65m),     // output clk_65m    
    .xclk(cam_xclk),     // output xclk 24m    
    .clk_100m(clk_100m),     // output clk_100m    
    // Status and control signals    
    .locked(locked),       // output lockedendmodule
   // Clock in ports
    .ui_clk(ui_clk));      // input ui_clkk

// I2C配置
i2c_ov5640_rgb565_cfg
#(
    .CMOS_H_PIXEL(CMOS_H_PIXEL),            // CMOS图像的水平像素数
    .CMOS_V_PIXEL(CMOS_V_PIXEL)             // CMOS图像的垂直像素数
)
u_i2c_cfg(
    .clk(i2c_dri_clk),                       // I2C驱动器时钟信号
    .rst_n(rst_n),                           // 重置信号（低有效）
    .i2c_done(i2c_done),                     // I2C传输完成信号
    .i2c_exec(i2c_exec),                     // 执行I2C传输的使能信号
    .i2c_data(i2c_data),                     // I2C数据信号
    .init_done(cam_init_done)                // 摄像头初始化完成信号
);
  
// I2C驱动模块
i2c_dri
#(
.SLAVE_ADDR         (SLAVE_ADDR),       // 从设备地址
.CLK_FREQ           (CLK_FREQ  ),       // 系统时钟频率
.I2C_FREQ           (I2C_FREQ  )        // I2C通信频率
)
u_i2c_dri(
.clk                (clk_65m   ),       // 输入时钟
.rst_n              (sys_rst_n & locked & init_calib_complete),   // 复位信号

.i2c_exec           (i2c_exec  ),       // I2C执行信号
.bit_ctrl           (BIT_CTRL  ),       // I2C位控制信号
.i2c_rh_wl          (1'b0),             // I2C读/写选择，0表示向指定IC设备发出操作
.i2c_addr           (i2c_data[23:8]),   // I2C设备地址
.i2c_data_w         (i2c_data[7:0]),    // I2C写数据
.i2c_data_r         (),                 // I2C读数据
.i2c_done           (i2c_done  ),       // I2C操作完成信号
.scl                (cam_scl   ),       // I2C时钟线
.sda                (cam_sda   ),       // I2C数据线

.dri_clk            (i2c_dri_clk)       // I2C驱动时钟
);
        
// I2C master controller
i2c_config i2c_config(
	.rst                        (rst),                // 复位信号输入
	.clk                        (clk_100m),           // 时钟信号输入
	.clk_div_cnt                (16'd500),            // 时钟分频计数器值
	.i2c_addr_2byte             (1'b0),               // I2C地址是否为2字节
	.error                      (                      ),  // 错误信号输出
	.done                       (                      ),  // 完成信号输出
	.i2c_scl                    (vga_scl),            // I2C时钟线信号输入/输出
	.i2c_sda                    (vga_sda)             // I2C数据线信号输入/输出
);

// CMOS图像数据采集
cmos_capture_data u_cmos_capture_data(
    .rst_n(rst_n & sys_init_done),  // 复位信号，与系统初始化完成信号相与，用于控制模块的复位
    
    .cam_pclk(cam_pclk),            // CMOS摄像头像素时钟信号
    .cam_vsync(cam_vsync),          // CMOS摄像头垂直同步信号
    .cam_href(cam_href),            // CMOS摄像头行同步信号
    .cam_data(cam_data),            // CMOS摄像头数据信号
    
    .cmos_frame_vsync(),            // 输出，CMOS图像帧垂直同步信号
    .cmos_frame_href(),             // 输出，CMOS图像帧行同步信号
    .cmos_frame_valid(wr_en),       // 输出，CMOS图像帧有效信号
    .cmos_frame_data(wr_data)       // 输出，CMOS图像帧数据
);

// DDR2控制器模块
ddr2_top u_ddr2_top(
    /* User interface */
    .sys_clk_p(sys_clk_p),       // 系统时钟正极性输入
    .sys_clk_n(sys_clk_n),       // 系统时钟负极性输入
    .ui_clk(ui_clk),             // 用户接口时钟（100MHz）
    .sys_rst_n(sys_rst_n),       // 系统复位信号（低电平有效）

    /* read fifo channel */
    .video_clk(clk_65m),         // 视频时钟（65MHz）
    .rd_req(read_req),           // 读请求信号
    .rd_req_ack(read_req_ack),   // 读请求应答信号
    .rd_en(read_en),             // 读使能信号
    .rd_data(read_data_ori),     // 读取的数据
    .rd_min_addr(24'd0),         // 读取数据的最小地址
    .rd_max_addr(CMOS_H_PIXEL*CMOS_V_PIXEL),  // 读取数据的最大地址
    .rd_len(10'd512),            // 读取数据的长度
    .rd_load(~rst_n),            // 读取数据加载信号

    /* write fifo channel */
    .cmos_pclk(cam_pclk),        // 摄像头像素时钟输入
    .wr_req(cmos_wr_req),        // 写请求信号
    .wr_en(wr_en),               // 写使能信号
    .wr_data(wr_data),           // 写入的数据
    .wr_min_addr(24'd0),         // 写入数据的最小地址
    .wr_max_addr(CMOS_H_PIXEL*CMOS_V_PIXEL),  // 写入数据的最大地址
    .wr_len(10'd512),            // 写入数据的长度
    .init_calib_complete(init_calib_complete),  // 初始化校准完成信号
    .wr_load(~rst_n),            // 写入数据加载信号

    /* DDR2 phy interface */
    .ddr2_dq(ddr2_dq),           // DDR数据线
    .ddr2_dqs_n(ddr2_dqs_n),     // DDR数据时钟信号差分负极性
    .ddr2_dqs_p(ddr2_dqs_p),     // DDR数据时钟信号差分正极性
    .ddr2_addr(ddr2_addr),       // DDR地址线
    .ddr2_ba(ddr2_ba),           // DDR bank地址线
    .ddr2_ras_n(ddr2_ras_n),     // DDR行地址选通信号
    .ddr2_cas_n(ddr2_cas_n),     // DDR列地址选通信号
    .ddr2_we_n(ddr2_we_n),       // DDR写使能信号
    .ddr2_reset_n(ddr2_reset_n), // DDR复位信号
    .ddr2_ck_p(ddr2_ck_p),       // DDR时钟信号正极性
    .ddr2_ck_n(ddr2_ck_n),       // DDR时钟信号负极性
    .ddr2_cke(ddr2_cke),         // DDR时钟使能信号
    .ddr2_cs_n(ddr2_cs_n),       // DDR芯片选通信号
    .ddr2_dm(ddr2_dm),           // DDR数据掩码信号
    .ddr2_odt(ddr2_odt)          // DDR输出驱动器使能信号
);
      
// VGA Display Driver Module Instantiation
vga_dri u_vga_dri (
    .vga_clk(clk_25m),          // VGA时钟输入
    .sys_rst_n(rst_n),          // 系统复位信号

    .vga_hs(vga_hs),            // VGA行同步信号输出
    .vga_vs(vga_vs),            // VGA场同步信号输出
    .vga_rgb(vga_rgb),          // VGA RGB颜色输出

    .pixel_data(rd_data),       // 像素数据输入
    .data_req(rd_en),           // 数据请求信号输入
    .pixel_xpos(),              // 像素X坐标
    .pixel_ypos()               // 像素Y坐标
);

endmodule        
          