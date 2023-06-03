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
reg sda_dir;                  // I2C数据线方向控制
reg sda_out;                  // SDA输出状态
reg st_done;                  // 状态机完成标志
reg wr_flag;                  // 写操作标志
reg [6:0] cnt;                // 计数器
reg [7:0] cur_state;          // 当前状态
reg [7:0] next_state;         // 下一个状态
reg [15:0] addr_t;            // 地址
reg [7:0] data_r;             // 读取的数据
reg [7:0] data_wr_t;          // I2C待写入的数据
reg [9:0] clk_cnt;            // 时钟计数器

//wire define
wire          sda_in      ;                      // SDA杈撳叆淇″彿
wire   [8:0]  clk_divide  ;                      // 妯″潡椹卞姩鏃堕挓鐨勫垎棰戠郴鏁?

// SDA控制
assign sda = sda_dir ? sda_out : 1'bz;     // 根据SDA方向选择输出数据或高阻状态（1'bz）
assign sda_in = sda;                       // 将SDA输入信号连接到sda_in
assign clk_divide = (CLK_FREQ/I2C_FREQ) >> 3;  // 时钟分频系数计算，用于生成I2C时序

// 生成I2C总线的SCL时钟信号的时钟分频模块
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        dri_clk <= 1'b1;       // 复位时将驱动时钟信号置为高电平
        clk_cnt <= 10'd0;     // 复位时将时钟计数器清零
    end
    else if (clk_cnt == clk_divide - 1'd1) begin
        clk_cnt <= 10'd0;     // 达到分频计数器的最大值时，将计数器清零
        dri_clk <= ~dri_clk;  // 切换驱动时钟信号的电平，实现SCL时钟的周期性变换
    end
    else
        clk_cnt <= clk_cnt + 1'b1;  // 正常情况下，时钟计数器递增
end

// Sequential logic for state transition (Next State Logic)
always @(posedge dri_clk or negedge rst_n) begin
    if(!rst_n)                 // If reset is active low
        cur_state <= st_idle;  // Set current state to idle
    else                       // Else, on positive edge of clock
        cur_state <= next_state;  // Update current state with next state
end

// 组合逻辑，用于综合状态转换判断
always @(*) begin
    // 初始化下一个状态为st_idle
    // next_state = st_idle;
    case (cur_state)
        st_idle: begin                          // 空闲状态
            if (i2c_exec) begin
                // 如果有i2c_exec信号，进入st_sladdr状态
                next_state = st_sladdr;
            end
            else
                next_state = st_idle;
        end
        st_sladdr: begin
            if (st_done) begin
                if (bit_ctrl)                     // 判断是否为16位地址
                    next_state = st_addr16;
                else
                    next_state = st_addr8;
            end
            else
                next_state = st_sladdr;
        end
        st_addr16: begin                         // 16位地址
            if (st_done) begin
                next_state = st_addr8;
            end
            else begin
                next_state = st_addr16;
            end
        end
        st_addr8: begin                          // 8位地址
            if (st_done) begin
                if (wr_flag == 1'b0)             // 写操作判断
                    next_state = st_data_wr;
                else
                    next_state = st_addr_rd;
            end
            else begin
                next_state = st_addr8;
            end
        end
        st_data_wr: begin                        // 数据写入(8 bit)
            if (st_done)
                next_state = st_stop;
            else
                next_state = st_data_wr;
        end
        st_addr_rd: begin                        // 地址读取，准备读取数据
            if (st_done) begin
                next_state = st_data_rd;
            end
            else begin
                next_state = st_addr_rd;
            end
        end
        st_data_rd: begin                        // 读取数据(8 bit)
            if (st_done)
                next_state = st_stop;
            else
                next_state = st_data_rd;
        end
        st_stop: begin                           // 结束I2C操作
            if (st_done)
                next_state = st_idle;
            else
                next_state = st_stop;
        end
        default: next_state = st_idle;
    endcase
end

// 时钟上升沿触发或复位信号下降沿触发的始终块
always @(posedge dri_clk or negedge rst_n) begin
    // 如果复位信号为低电平（异步复位）
    if(!rst_n) begin
        scl        <= 1'b1;         // I2C时钟线默认高电平
        sda_out    <= 1'b1;         // I2C数据线默认高电平
        sda_dir    <= 1'b1;         // I2C数据线方向默认输出
        i2c_done   <= 1'b0;         // I2C操作完成标志位复位为低电平
        cnt        <= 1'b0;         // 计数器复位为零
        st_done    <= 1'b0;         // 状态机操作完成标志位复位为低电平
        data_r     <= 1'b0;         // 数据读取标志位复位为低电平
        i2c_data_r <= 1'b0;         // I2C数据读取标志位复位为低电平
        wr_flag    <= 1'b0;         // 写使能标志位复位为低电平
        addr_t     <= 1'b0;         // I2C设备地址暂存器复位为零
        data_wr_t  <= 1'b0;         // 数据写入暂存器复位为零
    end
    else begin
        st_done <= 1'b0 ;
        cnt     <= cnt +1'b1 ;
        case(cur_state)
             st_idle: begin                            // 绌洪棽鐘舵??
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
            st_sladdr: begin                           // 鍐欏湴鍧?(鍣ㄤ欢鍦板潃鍜屽瓧鍦板潃)
                case(cnt)
                    7'd1 : sda_out <= 1'b0;            // 寮?濮婭2C
                    7'd3 : scl <= 1'b0;
                    7'd4 : sda_out <= SLAVE_ADDR[6];   // 浼犻?佸櫒浠跺湴鍧?
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
                    7'd32: sda_out <= 1'b0;            // 0:鍐?
                    7'd33: scl <= 1'b1;
                    7'd35: scl <= 1'b0;
                    7'd36: begin
                        sda_dir <= 1'b0;               // 浠庢満搴旂瓟
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
                        sda_out <= addr_t[15];         // 浼犻?佸瓧鍦板潃
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
                        sda_dir <= 1'b0;               // 浠庢満搴旂瓟
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
                       sda_out <= addr_t[7];           // 瀛楀湴鍧?
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
                        sda_dir <= 1'b0;               // 浠庢満搴旂瓟
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
            st_data_wr: begin                          // 鍐欐暟鎹?(8 bit)
                case(cnt)
                    7'd0: begin
                        sda_out <= data_wr_t[7];       // I2C鍐?8浣嶆暟鎹?
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
                        sda_dir <= 1'b0;               // 浠庢満搴旂瓟
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
            st_addr_rd: begin                          // 鍐欏湴鍧?浠ヨ繘琛岃鏁版嵁
                case(cnt)
                    7'd0 : begin
                        sda_dir <= 1'b1;
                        sda_out <= 1'b1;
                    end
                    7'd1 : scl <= 1'b1;
                    7'd2 : sda_out <= 1'b0;            // 閲嶆柊寮?濮?
                    7'd3 : scl <= 1'b0;
                    7'd4 : sda_out <= SLAVE_ADDR[6];   // 浼犻?佸櫒浠跺湴鍧?
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
                    7'd32: sda_out <= 1'b1;            // 1:璇?
                    7'd33: scl <= 1'b1;
                    7'd35: scl <= 1'b0;
                    7'd36: begin
                        sda_dir <= 1'b0;               // 浠庢満搴旂瓟
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
            st_data_rd: begin                          // 璇诲彇鏁版嵁(8 bit)
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
                        sda_dir <= 1'b1;              // 闈炲簲绛?
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
            st_stop: begin                            // 缁撴潫I2C鎿嶄綔
                case(cnt)
                    7'd0: begin
                        sda_dir <= 1'b1;              // 缁撴潫I2C
                        sda_out <= 1'b0;
                    end
                    7'd1 : scl     <= 1'b1;
                    7'd3 : sda_out <= 1'b1;
                    7'd15: st_done <= 1'b1;
                    7'd16: begin
                        cnt      <= 1'b0;
                        i2c_done <= 1'b1;             // 鍚戜笂灞傛ā鍧椾紶閫扞2C缁撴潫淇″彿
                    end
                    default  : ;
                endcase
            end
        endcase
    end
end

endmodule
