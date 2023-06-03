library ieee;
use ieee.std_logic_1164.ALL;
use ieee.NUMERIC_STD.ALL;

entity ov5640 is
    port (
        pclk  : in   std_logic;
        vsync : in   std_logic;
        href  : in   std_logic;
        d     : in   std_logic_vector ( 7 downto 0);
        addr  : out  std_logic_vector (17 downto 0);
        dout  : out  std_logic_vector (11 downto 0);
        we    : out  std_logic
    );
end ov5640;

architecture behavioral of ov5640 is
   signal d_latch      : std_logic_vector(15 downto 0) := (others => '0');
   signal address      : std_logic_vector(18 downto 0) := (others => '0');
   signal address_next : std_logic_vector(18 downto 0) := (others => '0');
   signal wr_hold      : std_logic_vector( 1 downto 0)  := (others => '0');
   
begin
   addr <= address(18 downto 1);
   process(pclk)
   begin
      if rising_edge(pclk) then
         -- This is a bit tricky href starts a pixel transfer that takes 3 cycles
         --        Input   | state after clock tick   
         --         href   | wr_hold    d_latch           d                 we address  address_next
         -- cycle -1  x    |    xx      xxxxxxxx xxxxxxxx  xxxxxxxxxxxxxxxx  x   xxxx     xxxx
         -- cycle 0   1    |    x1      xxxxxxxx 0000RRRR  xxxxxxxxxxxxxxxx  x   xxxx     addr
         -- cycle 1   0    |    10      0000RRRR GGGGBBBB  xxxxxxxx GGGGBBBB  x   addr     addr
         -- cycle 2   x    |    0x      GGGBBBBBxxxxxxxx  RRRRRGGGGGGBBBBB  1   addr     addr+1

        if vsync = '1' then -- 如果垂直同步信号为高电平
            address <= (others => '0'); -- 地址清零
            address_next <= (others => '0'); -- 下一个地址清零
            wr_hold <= (others => '0'); -- 写入保持信号清零
        else -- 如果垂直同步信号为低电平
            dout <= d_latch(11 downto 8) & d_latch(7 downto 4) & d_latch(3 downto 0); -- 输出数据为数据锁存器中的数据
            address <= address_next; -- 当前地址等于下一个地址
            we <= wr_hold(1); -- 写入使能信号等于写入保持信号的高位
            wr_hold <= wr_hold(0) & (href and not wr_hold(0)); -- 更新写入保持信号，根据行同步信号和写入保持信号的前一状态
            d_latch <= d_latch(7 downto 0) & d; -- 数据锁存器更新，将前一个时钟周期的数据左移8位，并将当前数据放入低8位
        
            if wr_hold(1) = '1' then -- 如果写入保持信号的高位为高电平
               address_next <= std_logic_vector(unsigned(address_next)+1); -- 下一个地址加一
            end if;
        end if;
      end if;
   end process;
end behavioral;
