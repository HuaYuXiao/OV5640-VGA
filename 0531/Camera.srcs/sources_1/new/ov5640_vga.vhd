library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vga is
    port ( 
        clk25       : in  STD_LOGIC;                -- 25 MHz时钟输入
        vga_red     : out STD_LOGIC_VECTOR(3 downto 0);     -- VGA显示屏的红色分量输出
        vga_green   : out STD_LOGIC_VECTOR(3 downto 0);     -- VGA显示屏的绿色分量输出
        vga_blue    : out STD_LOGIC_VECTOR(3 downto 0);     -- VGA显示屏的蓝色分量输出
        vga_hsync   : out STD_LOGIC;               -- VGA显示屏的水平同步信号输出
        vga_vsync   : out STD_LOGIC;               -- VGA显示屏的垂直同步信号输出
        frame_addr  : out STD_LOGIC_VECTOR(17 downto 0);    -- 帧地址输出
        frame_pixel : in  STD_LOGIC_VECTOR(11 downto 0)      -- 帧像素数据输入
    );
end vga;

architecture Behavioral of vga is
   -- Timing constants
constant hRez       : natural := 640+160;       -- 水平分辨率，包括前后黑框
constant hStartSync : natural := 640+16+160;   -- 水平同步信号起始位置
constant hEndSync   : natural := 640+16+96+160; -- 水平同步信号结束位置
constant hMaxCount  : natural := 800+160;      -- 水平计数器最大值

constant vRez       : natural := 480;          -- 垂直分辨率
constant vStartSync : natural := 480+10;       -- 垂直同步信号起始位置
constant vEndSync   : natural := 480+10+2;     -- 垂直同步信号结束位置
constant vMaxCount  : natural := 480+10+2+33;  -- 垂直计数器最大值
   
   constant hsync_active : std_logic := '0';
   constant vsync_active : std_logic := '0';

   signal hCounter : unsigned( 9 downto 0) := (others => '0');
   signal vCounter : unsigned( 9 downto 0) := (others => '0');
   signal address  : unsigned(18 downto 0) := (others => '0');
   signal blank    : std_logic := '1';

begin
   frame_addr <= std_logic_vector(address(18 downto 1));
   
   process(clk25)
   begin
      if rising_edge(clk25) then
         -- Count the lines and rows      
        if hCounter = hMaxCount-1 then                  -- 如果水平计数器达到最大值
            hCounter <= (others => '0');                -- 将水平计数器重置为0
            if vCounter = vMaxCount-1 then              -- 如果垂直计数器达到最大值
               vCounter <= (others => '0');             -- 将垂直计数器重置为0
            else
               vCounter <= vCounter+1;                   -- 否则垂直计数器加1
            end if;
         else
            hCounter <= hCounter+1;                      -- 否则水平计数器加1
         end if;

         -- 若blank信号为低电平，则将frame_pixel中的数据分配给对应的颜色信号
         if blank = '0' then
            vga_red   <= frame_pixel(11 downto 8);   -- 提取frame_pixel中的红色分量
            vga_green <= frame_pixel( 7 downto 4);   -- 提取frame_pixel中的绿色分量
            vga_blue  <= frame_pixel( 3 downto 0);   -- 提取frame_pixel中的蓝色分量
         else
            vga_red   <= (others => '0');            -- 若blank信号为高电平，则将颜色信号置为0
            vga_green <= (others => '0');
            vga_blue  <= (others => '0');
         end if;
   
         if vCounter  >= vRez then
            address <= (others => '0');              -- 若垂直计数器大于等于垂直分辨率，则将地址信号置为0
            blank <= '1';                            -- 同时将blank信号置为高电平
         else 
            if hCounter  < hRez then
               blank <= '0';                          -- 若水平计数器小于水平分辨率，则将blank信号置为低电平
               address <= address+1;                   -- 同时地址信号递增
            else
               blank <= '1';                          -- 若水平计数器大于等于水平分辨率，则将blank信号置为高电平
            end if;
         end if;
   
         -- hSync脉冲
         if hCounter > hStartSync and hCounter <= hEndSync then
            vga_hSync <= hsync_active;                 -- 若水平计数器在hStartSync和hEndSync之间，则将vga_hSync信号置为hsync_active
         else
            vga_hSync <= not hsync_active;             -- 若水平计数器不在hStartSync和hEndSync之间，则将vga_hSync信号置为not hsync_active
         end if;

         -- vSync脉冲
         if vCounter >= vStartSync and vCounter < vEndSync then
            vga_vSync <= vsync_active;                 -- 若垂直计数器在vStartSync和vEndSync之间，则将vga_vSync信号置为vsync_active
         else
            vga_vSync <= not vsync_active;             -- 若垂直计数器不在vStartSync和vEndSync之间，则将vga_vSync信号置为not vsync_active
         end if;
      end if;
   end process;
end Behavioral;
