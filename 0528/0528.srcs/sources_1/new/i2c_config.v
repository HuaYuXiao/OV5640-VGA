`timescale 1ns / 1ps


module i2c_config(
	input              rst,                    // 复位信号
	input              clk,                    // 时钟信号
	input[15:0]        clk_div_cnt,            // 时钟分频计数器
	input              i2c_addr_2byte,         // I2C地址是否为2字节
	output reg[9:0]    lut_index,              // 查找表索引
	input[7:0]         lut_dev_addr,           // 查找表中的设备地址
	input[15:0]        lut_reg_addr,           // 查找表中的寄存器地址
	input[7:0]         lut_reg_data,           // 查找表中的寄存器数据
	output reg         error,                  // 错误标志
	output             done,                   // 完成标志
	inout              i2c_scl,                // I2C时钟线
	inout              i2c_sda                 // I2C数据线
);

// I2C pad signals
wire scl_pad_i;         // 输入信号，I2C时钟线输入
wire scl_pad_o;         // 输出信号，I2C时钟线输出
wire scl_padoen_o;      // 输出信号，I2C时钟线输出使能

wire sda_pad_i;         // 输入信号，I2C数据线输入
wire sda_pad_o;         // 输出信号，I2C数据线输出
wire sda_padoen_o;      // 输出信号，I2C数据线输出使能

assign sda_pad_i = i2c_sda;                       // 将I2C数据线接入输入信号
assign i2c_sda = ~sda_padoen_o ? sda_pad_o : 1'bz; // 根据输出使能信号控制I2C数据线输出

assign scl_pad_i = i2c_scl;                       // 将I2C时钟线接入输入信号
assign i2c_scl = ~scl_padoen_o ? scl_pad_o : 1'bz; // 根据输出使能信号控制I2C时钟线输出

reg i2c_read_req;              // I2C读请求寄存器
wire i2c_read_req_ack;         // I2C读请求确认信号
reg i2c_write_req;             // I2C写请求寄存器
wire i2c_write_req_ack;        // I2C写请求确认信号
wire [7:0] i2c_slave_dev_addr; // I2C从设备地址信号
wire [15:0] i2c_slave_reg_addr; // I2C从设备寄存器地址信号
wire [7:0] i2c_write_data;      // I2C写数据信号
wire [7:0] i2c_read_data;       // I2C读数据信号

wire err;                     // 错误信号
reg [2:0] state;               // 状态寄存器，用于I2C通信状态的控制

// 状态定义
localparam S_IDLE           = 0;  // 空闲状态
localparam S_WR_I2C_CHECK   = 1;  // 写入I2C前的检查状态
localparam S_WR_I2C         = 2;  // 写入I2C状态
localparam S_WR_I2C_DONE    = 3;  // 写入I2C完成状态

assign done = (state == S_WR_I2C_DONE);          // 状态机是否完成写入I2C操作的标志
assign i2c_slave_dev_addr = lut_dev_addr;        // I2C从设备地址，由查找表lut_dev_addr给定
assign i2c_slave_reg_addr = lut_reg_addr;        // I2C寄存器地址，由查找表lut_reg_addr给定
assign i2c_write_data = lut_reg_data;            // 待写入I2C寄存器的数据，由查找表lut_reg_data给定

always @(posedge clk or posedge rst)
begin
    if (rst)
    begin
        // 复位状态，初始化各个变量
        state <= S_IDLE;         // 状态变量设置为S_IDLE
        error <= 1'b0;           // 错误标志位清零
        lut_index <= 8'd0;       // 查找表索引设置为0
    end
    else
        case (state)
            S_IDLE:
            begin
                // 空闲状态，准备进行下一步操作
                state <= S_WR_I2C_CHECK;  // 进入S_WR_I2C_CHECK状态
                error <= 1'b0;           // 错误标志位清零
                lut_index <= 8'd0;       // 查找表索引设置为0
            end
            
S_WR_I2C_CHECK:
begin
    if(i2c_slave_dev_addr != 8'hff)
    begin
        i2c_write_req <= 1'b1;       // 设置I2C写请求信号为有效
        state <= S_WR_I2C;           // 进入I2C写状态
    end
    else
    begin
        state <= S_WR_I2C_DONE;      // 如果设备地址为全1，进入I2C写完成状态
    end
end

S_WR_I2C:
begin
    if(i2c_write_req_ack)
    begin
        error <= err ? 1'b1 : error;  // 如果有错误，设置错误标志位为1
        lut_index <= lut_index + 8'd1;  // 增加LUT索引值
        i2c_write_req <= 1'b0;       // 清除I2C写请求信号
        state <= S_WR_I2C_CHECK;     // 返回I2C写检查状态
    end
end

S_WR_I2C_DONE:
begin
    state <= S_WR_I2C_DONE;         // 保持在I2C写完成状态
end

default:
    state <= S_IDLE;                // 默认情况下，进入空闲状态

		endcase
end

i2c_master_top u_i2c_master_top(
	.rst(rst),
	.clk(clk),
	.clk_div_cnt(clk_div_cnt),
	
	// I2C signals
	// i2c clock line
	.scl_pad_i(scl_pad_i),       // SCL-line input
	.scl_pad_o(scl_pad_o),       // SCL-line output (always 1'b0)
	.scl_padoen_o(scl_padoen_o),    // SCL-line output enable (active low)

	// i2c data line
	.sda_pad_i(sda_pad_i),       // SDA-line input
	.sda_pad_o(sda_pad_o),       // SDA-line output (always 1'b0)
	.sda_padoen_o(sda_padoen_o),    // SDA-line output enable (active low)
	
// I2C read request signal
.i2c_read_req(i2c_read_req),
// I2C 2-byte address signal
.i2c_addr_2byte(i2c_addr_2byte),
// I2C read request acknowledge signal
.i2c_read_req_ack(i2c_read_req_ack),
// I2C write request signal
.i2c_write_req(i2c_write_req),
// I2C write request acknowledge signal
.i2c_write_req_ack(i2c_write_req_ack),
// I2C slave device address
.i2c_slave_dev_addr(i2c_slave_dev_addr),
// I2C slave register address
.i2c_slave_reg_addr(i2c_slave_reg_addr),
// Data to be written to I2C
.i2c_write_data(i2c_write_data),
// Data read from I2C
.i2c_read_data(i2c_read_data),
// Error signal
.error(err)
);
endmodule