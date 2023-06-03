`timescale 1ns / 1ps


module i2c_dri
    #(
      // Slave address
      parameter   SLAVE_ADDR =  7'b1010000   ,
      // Clock frequency of the i2c_dri module
      parameter   CLK_FREQ   = 26'd50_000_000,
      // SCL clock frequency of I2C
      parameter   I2C_FREQ   = 18'd250_000
     )(
          // Global clock
          input                clk        ,
          // Reset signal (active low)
          input                rst_n      ,

          // I2C interface
          // I2C execution trigger signal
          input                i2c_exec   ,
          // Bit control (16b/8b)
          input                bit_ctrl   ,
          // I2C read/write control signal
          input                i2c_rh_wl  ,
          // I2C device internal address
          input        [15:0]  i2c_addr   ,
          // Data to be written to I2C
          input        [ 7:0]  i2c_data_w ,
          // Data read from I2C
          output  reg  [ 7:0]  i2c_data_r ,
          // I2C operation completed
          output  reg          i2c_done   ,
          // SCL clock signal of I2C
          output  reg          scl        ,
          // SDA data signal of I2C
          inout                sda        ,

          // User interface
          // Clock for driving I2C operation
          output  reg          dri_clk
     );

// Local parameter definitions
localparam  st_idle     = 8'b0000_0001;          // Idle state
localparam  st_sladdr   = 8'b0000_0010;          // Send slave address
localparam  st_addr16   = 8'b0000_0100;          // Send 16-bit address
localparam  st_addr8    = 8'b0000_1000;          // Send 8-bit address
localparam  st_data_wr  = 8'b0001_0000;          // Write data (8-bit)
localparam  st_addr_rd  = 8'b0010_0000;          // Send slave address for read
localparam  st_data_rd  = 8'b0100_0000;          // Read data (8-bit)
localparam  st_stop     = 8'b1000_0000;          // Stop I2C operation

// reg define
reg sda_dir;                  // I2C�����߷������
reg sda_out;                  // SDA���״̬
reg st_done;                  // ״̬����ɱ�־
reg wr_flag;                  // д������־
reg [6:0] cnt;                // ������
reg [7:0] cur_state;          // ��ǰ״̬
reg [7:0] next_state;         // ��һ��״̬
reg [15:0] addr_t;            // ��ַ
reg [7:0] data_r;             // ��ȡ������
reg [7:0] data_wr_t;          // I2C��д�������
reg [9:0] clk_cnt;            // ʱ�Ӽ�����

//wire define
wire          sda_in      ;                      // SDA输入信号
wire   [8:0]  clk_divide  ;                      // 模块驱动时钟的分频系�?

// SDA����
assign sda = sda_dir ? sda_out : 1'bz;     // ����SDA����ѡ��������ݻ����״̬��1'bz��
assign sda_in = sda;                       // ��SDA�����ź����ӵ�sda_in
assign clk_divide = (CLK_FREQ/I2C_FREQ) >> 3;  // ʱ�ӷ�Ƶϵ�����㣬��������I2Cʱ��

// ����I2C���ߵ�SCLʱ���źŵ�ʱ�ӷ�Ƶģ��
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        dri_clk <= 1'b1;       // ��λʱ������ʱ���ź���Ϊ�ߵ�ƽ
        clk_cnt <= 10'd0;     // ��λʱ��ʱ�Ӽ���������
    end
    else if (clk_cnt == clk_divide - 1'd1) begin
        clk_cnt <= 10'd0;     // �ﵽ��Ƶ�����������ֵʱ��������������
        dri_clk <= ~dri_clk;  // �л�����ʱ���źŵĵ�ƽ��ʵ��SCLʱ�ӵ������Ա任
    end
    else
        clk_cnt <= clk_cnt + 1'b1;  // ��������£�ʱ�Ӽ���������
end

// Sequential logic for state transition (Next State Logic)
always @(posedge dri_clk or negedge rst_n) begin
    if(!rst_n)                 // If reset is active low
        cur_state <= st_idle;  // Set current state to idle
    else                       // Else, on positive edge of clock
        cur_state <= next_state;  // Update current state with next state
end

// ����߼��������ۺ�״̬ת���ж�
always @(*) begin
    // ��ʼ����һ��״̬Ϊst_idle
    // next_state = st_idle;
    case (cur_state)
        st_idle: begin                          // ����״̬
            if (i2c_exec) begin
                // �����i2c_exec�źţ�����st_sladdr״̬
                next_state = st_sladdr;
            end
            else
                next_state = st_idle;
        end
        st_sladdr: begin
            if (st_done) begin
                if (bit_ctrl)                     // �ж��Ƿ�Ϊ16λ��ַ
                    next_state = st_addr16;
                else
                    next_state = st_addr8;
            end
            else
                next_state = st_sladdr;
        end
        st_addr16: begin                         // 16λ��ַ
            if (st_done) begin
                next_state = st_addr8;
            end
            else begin
                next_state = st_addr16;
            end
        end
        st_addr8: begin                          // 8λ��ַ
            if (st_done) begin
                if (wr_flag == 1'b0)             // д�����ж�
                    next_state = st_data_wr;
                else
                    next_state = st_addr_rd;
            end
            else begin
                next_state = st_addr8;
            end
        end
        st_data_wr: begin                        // ����д��(8 bit)
            if (st_done)
                next_state = st_stop;
            else
                next_state = st_data_wr;
        end
        st_addr_rd: begin                        // ��ַ��ȡ��׼����ȡ����
            if (st_done) begin
                next_state = st_data_rd;
            end
            else begin
                next_state = st_addr_rd;
            end
        end
        st_data_rd: begin                        // ��ȡ����(8 bit)
            if (st_done)
                next_state = st_stop;
            else
                next_state = st_data_rd;
        end
        st_stop: begin                           // ����I2C����
            if (st_done)
                next_state = st_idle;
            else
                next_state = st_stop;
        end
        default: next_state = st_idle;
    endcase
end

// ʱ�������ش�����λ�ź��½��ش�����ʼ�տ�
always @(posedge dri_clk or negedge rst_n) begin
    // �����λ�ź�Ϊ�͵�ƽ���첽��λ��
    if(!rst_n) begin
        scl        <= 1'b1;         // I2Cʱ����Ĭ�ϸߵ�ƽ
        sda_out    <= 1'b1;         // I2C������Ĭ�ϸߵ�ƽ
        sda_dir    <= 1'b1;         // I2C�����߷���Ĭ�����
        i2c_done   <= 1'b0;         // I2C������ɱ�־λ��λΪ�͵�ƽ
        cnt        <= 1'b0;         // ��������λΪ��
        st_done    <= 1'b0;         // ״̬��������ɱ�־λ��λΪ�͵�ƽ
        data_r     <= 1'b0;         // ���ݶ�ȡ��־λ��λΪ�͵�ƽ
        i2c_data_r <= 1'b0;         // I2C���ݶ�ȡ��־λ��λΪ�͵�ƽ
        wr_flag    <= 1'b0;         // дʹ�ܱ�־λ��λΪ�͵�ƽ
        addr_t     <= 1'b0;         // I2C�豸��ַ�ݴ�����λΪ��
        data_wr_t  <= 1'b0;         // ����д���ݴ�����λΪ��
    end
    else begin
        st_done <= 1'b0 ;
        cnt     <= cnt +1'b1 ;
        case(cur_state)
             st_idle: begin                            // 空闲状�??
                scl     <= 1'b1;
                sda_out <= 1'b1;
                sda_dir <= 1'b1;
                i2c_done<= 1'b0;
                cnt     <= 7'b0;
                if(i2c_exec) begin
                    wr_flag   <= i2c_rh_wl ;
                    addr_t    <= i2c_addr  ;
                    data_wr_t <= i2c_data_w;
                end
            end
            st_sladdr: begin                           // 写地�?(器件地址和字地址)
                case(cnt)
                    7'd1 : sda_out <= 1'b0;            // �?始I2C
                    7'd3 : scl <= 1'b0;
                    7'd4 : sda_out <= SLAVE_ADDR[6];   // 传�?�器件地�?
                    7'd5 : scl <= 1'b1;
                    7'd7 : scl <= 1'b0;
                    7'd8 : sda_out <= SLAVE_ADDR[5];
                    7'd9 : scl <= 1'b1;
                    7'd11: scl <= 1'b0;
                    7'd12: sda_out <= SLAVE_ADDR[4];
                    7'd13: scl <= 1'b1;
                    7'd15: scl <= 1'b0;
                    7'd16: sda_out <= SLAVE_ADDR[3];
                    7'd17: scl <= 1'b1;
                    7'd19: scl <= 1'b0;
                    7'd20: sda_out <= SLAVE_ADDR[2];
                    7'd21: scl <= 1'b1;
                    7'd23: scl <= 1'b0;
                    7'd24: sda_out <= SLAVE_ADDR[1];
                    7'd25: scl <= 1'b1;
                    7'd27: scl <= 1'b0;
                    7'd28: sda_out <= SLAVE_ADDR[0];
                    7'd29: scl <= 1'b1;
                    7'd31: scl <= 1'b0;
                    7'd32: sda_out <= 1'b0;            // 0:�?
                    7'd33: scl <= 1'b1;
                    7'd35: scl <= 1'b0;
                    7'd36: begin
                        sda_dir <= 1'b0;               // 从机应答
                        sda_out <= 1'b1;
                    end
                    7'd37: scl     <= 1'b1;
                    7'd38: st_done <= 1'b1;
                    7'd39: begin
                        scl <= 1'b0;
                        cnt <= 1'b0;
                    end
                    default :  ;
                endcase
            end
            st_addr16: begin
                case(cnt)
                    7'd0 : begin
                        sda_dir <= 1'b1 ;
                        sda_out <= addr_t[15];         // 传�?�字地址
                    end
                    7'd1 : scl <= 1'b1;
                    7'd3 : scl <= 1'b0;
                    7'd4 : sda_out <= addr_t[14];
                    7'd5 : scl <= 1'b1;
                    7'd7 : scl <= 1'b0;
                    7'd8 : sda_out <= addr_t[13];
                    7'd9 : scl <= 1'b1;
                    7'd11: scl <= 1'b0;
                    7'd12: sda_out <= addr_t[12];
                    7'd13: scl <= 1'b1;
                    7'd15: scl <= 1'b0;
                    7'd16: sda_out <= addr_t[11];
                    7'd17: scl <= 1'b1;
                    7'd19: scl <= 1'b0;
                    7'd20: sda_out <= addr_t[10];
                    7'd21: scl <= 1'b1;
                    7'd23: scl <= 1'b0;
                    7'd24: sda_out <= addr_t[9];
                    7'd25: scl <= 1'b1;
                    7'd27: scl <= 1'b0;
                    7'd28: sda_out <= addr_t[8];
                    7'd29: scl <= 1'b1;
                    7'd31: scl <= 1'b0;
                    7'd32: begin
                        sda_dir <= 1'b0;               // 从机应答
                        sda_out <= 1'b1;
                    end
                    7'd33: scl     <= 1'b1;
                    7'd34: st_done <= 1'b1;
                    7'd35: begin
                        scl <= 1'b0;
                        cnt <= 1'b0;
                    end
                    default :  ;
                endcase
            end
            st_addr8: begin
                case(cnt)
                    7'd0: begin
                       sda_dir <= 1'b1 ;
                       sda_out <= addr_t[7];           // 字地�?
                    end
                    7'd1 : scl <= 1'b1;
                    7'd3 : scl <= 1'b0;
                    7'd4 : sda_out <= addr_t[6];
                    7'd5 : scl <= 1'b1;
                    7'd7 : scl <= 1'b0;
                    7'd8 : sda_out <= addr_t[5];
                    7'd9 : scl <= 1'b1;
                    7'd11: scl <= 1'b0;
                    7'd12: sda_out <= addr_t[4];
                    7'd13: scl <= 1'b1;
                    7'd15: scl <= 1'b0;
                    7'd16: sda_out <= addr_t[3];
                    7'd17: scl <= 1'b1;
                    7'd19: scl <= 1'b0;
                    7'd20: sda_out <= addr_t[2];
                    7'd21: scl <= 1'b1;
                    7'd23: scl <= 1'b0;
                    7'd24: sda_out <= addr_t[1];
                    7'd25: scl <= 1'b1;
                    7'd27: scl <= 1'b0;
                    7'd28: sda_out <= addr_t[0];
                    7'd29: scl <= 1'b1;
                    7'd31: scl <= 1'b0;
                    7'd32: begin
                        sda_dir <= 1'b0;               // 从机应答
                        sda_out <= 1'b1;
                    end
                    7'd33: scl     <= 1'b1;
                    7'd34: st_done <= 1'b1;
                    7'd35: begin
                        scl <= 1'b0;
                        cnt <= 1'b0;
                    end
                    default :  ;
                endcase
            end
            st_data_wr: begin                          // 写数�?(8 bit)
                case(cnt)
                    7'd0: begin
                        sda_out <= data_wr_t[7];       // I2C�?8位数�?
                        sda_dir <= 1'b1;
                    end
                    7'd1 : scl <= 1'b1;
                    7'd3 : scl <= 1'b0;
                    7'd4 : sda_out <= data_wr_t[6];
                    7'd5 : scl <= 1'b1;
                    7'd7 : scl <= 1'b0;
                    7'd8 : sda_out <= data_wr_t[5];
                    7'd9 : scl <= 1'b1;
                    7'd11: scl <= 1'b0;
                    7'd12: sda_out <= data_wr_t[4];
                    7'd13: scl <= 1'b1;
                    7'd15: scl <= 1'b0;
                    7'd16: sda_out <= data_wr_t[3];
                    7'd17: scl <= 1'b1;
                    7'd19: scl <= 1'b0;
                    7'd20: sda_out <= data_wr_t[2];
                    7'd21: scl <= 1'b1;
                    7'd23: scl <= 1'b0;
                    7'd24: sda_out <= data_wr_t[1];
                    7'd25: scl <= 1'b1;
                    7'd27: scl <= 1'b0;
                    7'd28: sda_out <= data_wr_t[0];
                    7'd29: scl <= 1'b1;
                    7'd31: scl <= 1'b0;
                    7'd32: begin
                        sda_dir <= 1'b0;               // 从机应答
                        sda_out <= 1'b1;
                    end
                    7'd33: scl <= 1'b1;
                    7'd34: st_done <= 1'b1;
                    7'd35: begin
                        scl  <= 1'b0;
                        cnt  <= 1'b0;
                    end
                    default  :  ;
                endcase
            end
            st_addr_rd: begin                          // 写地�?以进行读数据
                case(cnt)
                    7'd0 : begin
                        sda_dir <= 1'b1;
                        sda_out <= 1'b1;
                    end
                    7'd1 : scl <= 1'b1;
                    7'd2 : sda_out <= 1'b0;            // 重新�?�?
                    7'd3 : scl <= 1'b0;
                    7'd4 : sda_out <= SLAVE_ADDR[6];   // 传�?�器件地�?
                    7'd5 : scl <= 1'b1;
                    7'd7 : scl <= 1'b0;
                    7'd8 : sda_out <= SLAVE_ADDR[5];
                    7'd9 : scl <= 1'b1;
                    7'd11: scl <= 1'b0;
                    7'd12: sda_out <= SLAVE_ADDR[4];
                    7'd13: scl <= 1'b1;
                    7'd15: scl <= 1'b0;
                    7'd16: sda_out <= SLAVE_ADDR[3];
                    7'd17: scl <= 1'b1;
                    7'd19: scl <= 1'b0;
                    7'd20: sda_out <= SLAVE_ADDR[2];
                    7'd21: scl <= 1'b1;
                    7'd23: scl <= 1'b0;
                    7'd24: sda_out <= SLAVE_ADDR[1];
                    7'd25: scl <= 1'b1;
                    7'd27: scl <= 1'b0;
                    7'd28: sda_out <= SLAVE_ADDR[0];
                    7'd29: scl <= 1'b1;
                    7'd31: scl <= 1'b0;
                    7'd32: sda_out <= 1'b1;            // 1:�?
                    7'd33: scl <= 1'b1;
                    7'd35: scl <= 1'b0;
                    7'd36: begin
                        sda_dir <= 1'b0;               // 从机应答
                        sda_out <= 1'b1;
                    end
                    7'd37: scl     <= 1'b1;
                    7'd38: st_done <= 1'b1;
                    7'd39: begin
                        scl <= 1'b0;
                        cnt <= 1'b0;
                    end
                    default : ;
                endcase
            end
            st_data_rd: begin                          // 读取数据(8 bit)
                case(cnt)
                    7'd0: sda_dir <= 1'b0;
                    7'd1: begin
                        data_r[7] <= sda_in;
                        scl       <= 1'b1;
                    end
                    7'd3: scl  <= 1'b0;
                    7'd5: begin
                        data_r[6] <= sda_in ;
                        scl       <= 1'b1   ;
                    end
                    7'd7: scl  <= 1'b0;
                    7'd9: begin
                        data_r[5] <= sda_in;
                        scl       <= 1'b1  ;
                    end
                    7'd11: scl  <= 1'b0;
                    7'd13: begin
                        data_r[4] <= sda_in;
                        scl       <= 1'b1  ;
                    end
                    7'd15: scl  <= 1'b0;
                    7'd17: begin
                        data_r[3] <= sda_in;
                        scl       <= 1'b1  ;
                    end
                    7'd19: scl  <= 1'b0;
                    7'd21: begin
                        data_r[2] <= sda_in;
                        scl       <= 1'b1  ;
                    end
                    7'd23: scl  <= 1'b0;
                    7'd25: begin
                        data_r[1] <= sda_in;
                        scl       <= 1'b1  ;
                    end
                    7'd27: scl  <= 1'b0;
                    7'd29: begin
                        data_r[0] <= sda_in;
                        scl       <= 1'b1  ;
                    end
                    7'd31: scl  <= 1'b0;
                    7'd32: begin
                        sda_dir <= 1'b1;              // 非应�?
                        sda_out <= 1'b1;
                    end
                    7'd33: scl     <= 1'b1;
                    7'd34: st_done <= 1'b1;
                    7'd35: begin
                        scl <= 1'b0;
                        cnt <= 1'b0;
                        i2c_data_r <= data_r;
                    end
                    default  :  ;
                endcase
            end
            st_stop: begin                            // 结束I2C操作
                case(cnt)
                    7'd0: begin
                        sda_dir <= 1'b1;              // 结束I2C
                        sda_out <= 1'b0;
                    end
                    7'd1 : scl     <= 1'b1;
                    7'd3 : sda_out <= 1'b1;
                    7'd15: st_done <= 1'b1;
                    7'd16: begin
                        cnt      <= 1'b0;
                        i2c_done <= 1'b1;             // 向上层模块传递I2C结束信号
                    end
                    default  : ;
                endcase
            end
        endcase
    end
end

endmodule
