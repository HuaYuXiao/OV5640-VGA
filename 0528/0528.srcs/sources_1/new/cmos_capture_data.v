`timescale 1ns / 1ps


module cmos_capture_data(
    input rst_n,
    
    input cam_pclk,
    input cam_vsync,
    input cam_href,
    input [7:0] cam_data,
    
    output                cmos_wr_req     ,
    output cmos_frame_vsync,
    output cmos_frame_href,
    output cmos_frame_valid,
    output [15:0] cmos_frame_data
    );
   
parameter WAIT_FRAME = 4'd10;  // 帧等待计数器的值

reg cam_vsync_d0;              // 当前帧的vsync信号的延迟1个时钟周期的寄存器
reg cam_vsync_d1;              // 当前帧的vsync信号的延迟2个时钟周期的寄存器
reg cam_href_d0;               // 当前帧的href信号的延迟1个时钟周期的寄存器
reg cam_href_d1;               // 当前帧的href信号的延迟2个时钟周期的寄存器
reg [3:0] cmos_ps_cnt;         // CMOS像素计数器，用于计算像素时钟周期的个数
reg frame_val_flag;            // 帧有效标志，指示当前帧是否有效

reg [7:0] cam_data_d0;         // 当前帧的摄像头数据信号的延迟1个时钟周期的寄存器
reg [15:0] cmos_data_t;        // CMOS数据寄存器，用于存储组合的像素数据
reg byte_flag;                 // 字节标志，指示当前数据是否为低字节或高字节
reg byte_flag_d0;              // 字节标志的延迟1个时钟周期的寄存器

wire pos_vsync;                // 正向的vsync信号，用于指示vsync信号的上升沿
    
// Rising edge of the camera synchronization signal
assign pos_vsync = (~cam_vsync_d1) & cam_vsync_d0;
// Falling edge of the camera synchronization signal
assign cmos_wr_req = cam_vsync_d1 & (~cam_vsync_d0);
// Output frame valid signal
assign cmos_frame_vsync = frame_val_flag ? cam_vsync_d1 : 1'b0;
// Output line valid signal
assign cmos_frame_href = frame_val_flag ? cam_href_d1 : 1'b0;
// Output data valid signal
assign cmos_frame_valid = frame_val_flag ? byte_flag_d0 : 1'b0;
// Output data
assign cmos_frame_data = frame_val_flag ? cmos_data_t : 1'b0;

//采集输入场同步信号上升沿
always @(posedge cam_pclk or negedge rst_n) begin
    if(!rst_n) begin
        cam_vsync_d0 <= 1'b0;
        cam_vsync_d1 <= 1'b0;
        cam_href_d0 <= 1'b0;
        cam_href_d1 <= 1'b0;
    end
    else begin
        cam_vsync_d0 <= cam_vsync;
        cam_vsync_d1 <= cam_vsync_d0;
        cam_href_d0 <= cam_href;
        cam_href_d1 <= cam_href_d0;
    end
end    
    
//计算帧数    
always @(posedge cam_pclk or negedge rst_n) begin
    if(!rst_n)
        cmos_ps_cnt <= 4'd0;
    else if(pos_vsync && (cmos_ps_cnt < WAIT_FRAME))
        cmos_ps_cnt <= cmos_ps_cnt + 4'd1;
end    
    
//帧有效标志    
always @(posedge cam_pclk or negedge rst_n) begin
    if(!rst_n)
        frame_val_flag <= 1'b0;
    else if((cmos_ps_cnt == WAIT_FRAME) && pos_vsync)    
        frame_val_flag <= 1'b1;
end    
    
// 8位数据转RGB
always @(posedge cam_pclk or negedge rst_n) begin
    if(!rst_n) begin
        cmos_data_t <= 16'd0;       // 初始化CMOS数据
        cam_data_d0 <= 8'd0;        // 初始化摄像头数据
        byte_flag <= 1'b0;          // 字节标志复位
    end 
    else if(cam_href) begin         // 如果接收到有效行同步信号
        byte_flag <= ~byte_flag;    // 切换字节标志位
        cam_data_d0 <= cam_data;    // 保存摄像头数据
        if(byte_flag)               // 如果是第二个字节
            cmos_data_t <= {cam_data_d0,cam_data};    // 组合两个字节形成16位CMOS数据
    end
    else begin                     // 如果未接收到有效行同步信号
        byte_flag <= 1'b0;          // 字节标志复位
        cam_data_d0 <= 8'b0;        // 摄像头数据复位
    end
end

//输出数据有效信号
always @(posedge cam_pclk or negedge rst_n) begin
    if(!rst_n)
        byte_flag_d0 <= 1'b0;
    else
        byte_flag_d0 <= byte_flag;
end 

endmodule  
 