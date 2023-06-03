`timescale 1ns / 1ps


module i2c_config(
	input              rst,                    // ��λ�ź�
	input              clk,                    // ʱ���ź�
	input[15:0]        clk_div_cnt,            // ʱ�ӷ�Ƶ������
	input              i2c_addr_2byte,         // I2C��ַ�Ƿ�Ϊ2�ֽ�
	output reg[9:0]    lut_index,              // ���ұ�����
	input[7:0]         lut_dev_addr,           // ���ұ��е��豸��ַ
	input[15:0]        lut_reg_addr,           // ���ұ��еļĴ�����ַ
	input[7:0]         lut_reg_data,           // ���ұ��еļĴ�������
	output reg         error,                  // �����־
	output             done,                   // ��ɱ�־
	inout              i2c_scl,                // I2Cʱ����
	inout              i2c_sda                 // I2C������
);

// I2C pad signals
wire scl_pad_i;         // �����źţ�I2Cʱ��������
wire scl_pad_o;         // ����źţ�I2Cʱ�������
wire scl_padoen_o;      // ����źţ�I2Cʱ�������ʹ��

wire sda_pad_i;         // �����źţ�I2C����������
wire sda_pad_o;         // ����źţ�I2C���������
wire sda_padoen_o;      // ����źţ�I2C���������ʹ��

assign sda_pad_i = i2c_sda;                       // ��I2C�����߽��������ź�
assign i2c_sda = ~sda_padoen_o ? sda_pad_o : 1'bz; // �������ʹ���źſ���I2C���������

assign scl_pad_i = i2c_scl;                       // ��I2Cʱ���߽��������ź�
assign i2c_scl = ~scl_padoen_o ? scl_pad_o : 1'bz; // �������ʹ���źſ���I2Cʱ�������

reg i2c_read_req;              // I2C������Ĵ���
wire i2c_read_req_ack;         // I2C������ȷ���ź�
reg i2c_write_req;             // I2Cд����Ĵ���
wire i2c_write_req_ack;        // I2Cд����ȷ���ź�
wire [7:0] i2c_slave_dev_addr; // I2C���豸��ַ�ź�
wire [15:0] i2c_slave_reg_addr; // I2C���豸�Ĵ�����ַ�ź�
wire [7:0] i2c_write_data;      // I2Cд�����ź�
wire [7:0] i2c_read_data;       // I2C�������ź�

wire err;                     // �����ź�
reg [2:0] state;               // ״̬�Ĵ���������I2Cͨ��״̬�Ŀ���

// ״̬����
localparam S_IDLE           = 0;  // ����״̬
localparam S_WR_I2C_CHECK   = 1;  // д��I2Cǰ�ļ��״̬
localparam S_WR_I2C         = 2;  // д��I2C״̬
localparam S_WR_I2C_DONE    = 3;  // д��I2C���״̬

assign done = (state == S_WR_I2C_DONE);          // ״̬���Ƿ����д��I2C�����ı�־
assign i2c_slave_dev_addr = lut_dev_addr;        // I2C���豸��ַ���ɲ��ұ�lut_dev_addr����
assign i2c_slave_reg_addr = lut_reg_addr;        // I2C�Ĵ�����ַ���ɲ��ұ�lut_reg_addr����
assign i2c_write_data = lut_reg_data;            // ��д��I2C�Ĵ��������ݣ��ɲ��ұ�lut_reg_data����

always @(posedge clk or posedge rst)
begin
    if (rst)
    begin
        // ��λ״̬����ʼ����������
        state <= S_IDLE;         // ״̬��������ΪS_IDLE
        error <= 1'b0;           // �����־λ����
        lut_index <= 8'd0;       // ���ұ���������Ϊ0
    end
    else
        case (state)
            S_IDLE:
            begin
                // ����״̬��׼��������һ������
                state <= S_WR_I2C_CHECK;  // ����S_WR_I2C_CHECK״̬
                error <= 1'b0;           // �����־λ����
                lut_index <= 8'd0;       // ���ұ���������Ϊ0
            end
            
S_WR_I2C_CHECK:
begin
    if(i2c_slave_dev_addr != 8'hff)
    begin
        i2c_write_req <= 1'b1;       // ����I2Cд�����ź�Ϊ��Ч
        state <= S_WR_I2C;           // ����I2Cд״̬
    end
    else
    begin
        state <= S_WR_I2C_DONE;      // ����豸��ַΪȫ1������I2Cд���״̬
    end
end

S_WR_I2C:
begin
    if(i2c_write_req_ack)
    begin
        error <= err ? 1'b1 : error;  // ����д������ô����־λΪ1
        lut_index <= lut_index + 8'd1;  // ����LUT����ֵ
        i2c_write_req <= 1'b0;       // ���I2Cд�����ź�
        state <= S_WR_I2C_CHECK;     // ����I2Cд���״̬
    end
end

S_WR_I2C_DONE:
begin
    state <= S_WR_I2C_DONE;         // ������I2Cд���״̬
end

default:
    state <= S_IDLE;                // Ĭ������£��������״̬

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