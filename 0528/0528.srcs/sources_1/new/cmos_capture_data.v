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
   
parameter WAIT_FRAME = 4'd10;  // ֡�ȴ���������ֵ

reg cam_vsync_d0;              // ��ǰ֡��vsync�źŵ��ӳ�1��ʱ�����ڵļĴ���
reg cam_vsync_d1;              // ��ǰ֡��vsync�źŵ��ӳ�2��ʱ�����ڵļĴ���
reg cam_href_d0;               // ��ǰ֡��href�źŵ��ӳ�1��ʱ�����ڵļĴ���
reg cam_href_d1;               // ��ǰ֡��href�źŵ��ӳ�2��ʱ�����ڵļĴ���
reg [3:0] cmos_ps_cnt;         // CMOS���ؼ����������ڼ�������ʱ�����ڵĸ���
reg frame_val_flag;            // ֡��Ч��־��ָʾ��ǰ֡�Ƿ���Ч

reg [7:0] cam_data_d0;         // ��ǰ֡������ͷ�����źŵ��ӳ�1��ʱ�����ڵļĴ���
reg [15:0] cmos_data_t;        // CMOS���ݼĴ��������ڴ洢��ϵ���������
reg byte_flag;                 // �ֽڱ�־��ָʾ��ǰ�����Ƿ�Ϊ���ֽڻ���ֽ�
reg byte_flag_d0;              // �ֽڱ�־���ӳ�1��ʱ�����ڵļĴ���

wire pos_vsync;                // �����vsync�źţ�����ָʾvsync�źŵ�������
    
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

//�ɼ����볡ͬ���ź�������
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
    
//����֡��    
always @(posedge cam_pclk or negedge rst_n) begin
    if(!rst_n)
        cmos_ps_cnt <= 4'd0;
    else if(pos_vsync && (cmos_ps_cnt < WAIT_FRAME))
        cmos_ps_cnt <= cmos_ps_cnt + 4'd1;
end    
    
//֡��Ч��־    
always @(posedge cam_pclk or negedge rst_n) begin
    if(!rst_n)
        frame_val_flag <= 1'b0;
    else if((cmos_ps_cnt == WAIT_FRAME) && pos_vsync)    
        frame_val_flag <= 1'b1;
end    
    
// 8λ����תRGB
always @(posedge cam_pclk or negedge rst_n) begin
    if(!rst_n) begin
        cmos_data_t <= 16'd0;       // ��ʼ��CMOS����
        cam_data_d0 <= 8'd0;        // ��ʼ������ͷ����
        byte_flag <= 1'b0;          // �ֽڱ�־��λ
    end 
    else if(cam_href) begin         // ������յ���Ч��ͬ���ź�
        byte_flag <= ~byte_flag;    // �л��ֽڱ�־λ
        cam_data_d0 <= cam_data;    // ��������ͷ����
        if(byte_flag)               // ����ǵڶ����ֽ�
            cmos_data_t <= {cam_data_d0,cam_data};    // ��������ֽ��γ�16λCMOS����
    end
    else begin                     // ���δ���յ���Ч��ͬ���ź�
        byte_flag <= 1'b0;          // �ֽڱ�־��λ
        cam_data_d0 <= 8'b0;        // ����ͷ���ݸ�λ
    end
end

//���������Ч�ź�
always @(posedge cam_pclk or negedge rst_n) begin
    if(!rst_n)
        byte_flag_d0 <= 1'b0;
    else
        byte_flag_d0 <= byte_flag;
end 

endmodule  
 