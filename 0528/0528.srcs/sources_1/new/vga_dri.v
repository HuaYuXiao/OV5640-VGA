`timescale 1ns / 1ps


module vga_dri(
    input vga_clk,
    input sys_rst_n,
    
    output vga_hs,
    output vga_vs,
    output [15:0] vga_rgb,
    
    input [15:0] pixel_data,
    output data_req,
    output [9:0] pixel_xpos,
    output [9:0] pixel_ypos
    );
    
parameter H_SYNC = 10'd96;    // 场同步信号的宽度
parameter H_BACK = 10'd48;    // 场后宽度
parameter H_DISP = 10'd640;   // 场显示区域的宽度
parameter H_FRONT = 10'd16;   // 场前宽度
parameter H_TOTAL = 10'd800;  // 场总宽度

parameter V_SYNC = 10'd2;     // 帧同步信号的宽度
parameter V_BACK = 10'd33;    // 帧后宽度
parameter V_DISP = 10'd480;   // 帧显示区域的宽度
parameter V_FRONT = 10'd10;   // 帧前宽度
parameter V_TOTAL = 10'd525;  // 帧总宽度

reg [9:0] cnt_h;   // 场计数器，用于追踪VGA的场位置
reg [9:0] cnt_v;   // 帧计数器，用于追踪VGA的帧位置

wire vga_en;       // VGA使能信号，表示VGA是否启用
//wire data_req;

//行场同步信号
assign vga_hs = (cnt_h <= H_SYNC - 1'b1) ? 1'b0 : 1'b1;
assign vga_vs = (cnt_v <= V_SYNC - 1'b1) ? 1'b0 : 1'b1;   
    
assign vga_en = (((cnt_h >= H_SYNC + H_BACK) && (cnt_h < H_SYNC + H_BACK + H_DISP)) 
                && ((cnt_v >= V_SYNC + V_BACK) && (cnt_v < V_SYNC + V_BACK + V_DISP)))  
                ? 1'b1 : 1'b0;
//RGB565输出                
assign vga_rgb = vga_en ? pixel_data : 16'd0;                
                
assign data_req = (((cnt_h >= H_SYNC + H_BACK - 1'b1) && (cnt_h < H_SYNC + H_BACK + H_DISP - 1'b1))
                && ((cnt_v >= V_SYNC + V_BACK) && (cnt_v < V_SYNC + V_BACK + V_DISP)))
                ? 1'b1 : 1'b0;                
//像素点坐标                
assign pixel_xpos = data_req ? (cnt_h - (H_SYNC + H_BACK -1'b1)) : 10'd0;
assign pixel_ypos = data_req ? (cnt_v - (V_SYNC + V_BACK -1'b1)) : 10'd0;
                
//行计数器   
always @(posedge vga_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        cnt_h <= 10'd0;
    else begin
        if(cnt_h <H_TOTAL -1'b1)
            cnt_h <= cnt_h + 1'b1;
        else
            cnt_h <= 10'd0;             
    end           
end                

//场计数器   
always @(posedge vga_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        cnt_v <= 10'd0;
    else if(cnt_h == H_TOTAL - 1'b1) begin
        if(cnt_v < V_TOTAL - 1'b1)
            cnt_v <= cnt_v + 1'b1;
        else
            cnt_v <= 10'd0;  
    end           
end      
            
endmodule
