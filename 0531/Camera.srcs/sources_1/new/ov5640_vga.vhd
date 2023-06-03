library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vga is
    port ( 
        clk25       : in  STD_LOGIC;                -- 25 MHzʱ������
        vga_red     : out STD_LOGIC_VECTOR(3 downto 0);     -- VGA��ʾ���ĺ�ɫ�������
        vga_green   : out STD_LOGIC_VECTOR(3 downto 0);     -- VGA��ʾ������ɫ�������
        vga_blue    : out STD_LOGIC_VECTOR(3 downto 0);     -- VGA��ʾ������ɫ�������
        vga_hsync   : out STD_LOGIC;               -- VGA��ʾ����ˮƽͬ���ź����
        vga_vsync   : out STD_LOGIC;               -- VGA��ʾ���Ĵ�ֱͬ���ź����
        frame_addr  : out STD_LOGIC_VECTOR(17 downto 0);    -- ֡��ַ���
        frame_pixel : in  STD_LOGIC_VECTOR(11 downto 0)      -- ֡������������
    );
end vga;

architecture Behavioral of vga is
   -- Timing constants
constant hRez       : natural := 640+160;       -- ˮƽ�ֱ��ʣ�����ǰ��ڿ�
constant hStartSync : natural := 640+16+160;   -- ˮƽͬ���ź���ʼλ��
constant hEndSync   : natural := 640+16+96+160; -- ˮƽͬ���źŽ���λ��
constant hMaxCount  : natural := 800+160;      -- ˮƽ���������ֵ

constant vRez       : natural := 480;          -- ��ֱ�ֱ���
constant vStartSync : natural := 480+10;       -- ��ֱͬ���ź���ʼλ��
constant vEndSync   : natural := 480+10+2;     -- ��ֱͬ���źŽ���λ��
constant vMaxCount  : natural := 480+10+2+33;  -- ��ֱ���������ֵ
   
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
        if hCounter = hMaxCount-1 then                  -- ���ˮƽ�������ﵽ���ֵ
            hCounter <= (others => '0');                -- ��ˮƽ����������Ϊ0
            if vCounter = vMaxCount-1 then              -- �����ֱ�������ﵽ���ֵ
               vCounter <= (others => '0');             -- ����ֱ����������Ϊ0
            else
               vCounter <= vCounter+1;                   -- ����ֱ��������1
            end if;
         else
            hCounter <= hCounter+1;                      -- ����ˮƽ��������1
         end if;

         -- ��blank�ź�Ϊ�͵�ƽ����frame_pixel�е����ݷ������Ӧ����ɫ�ź�
         if blank = '0' then
            vga_red   <= frame_pixel(11 downto 8);   -- ��ȡframe_pixel�еĺ�ɫ����
            vga_green <= frame_pixel( 7 downto 4);   -- ��ȡframe_pixel�е���ɫ����
            vga_blue  <= frame_pixel( 3 downto 0);   -- ��ȡframe_pixel�е���ɫ����
         else
            vga_red   <= (others => '0');            -- ��blank�ź�Ϊ�ߵ�ƽ������ɫ�ź���Ϊ0
            vga_green <= (others => '0');
            vga_blue  <= (others => '0');
         end if;
   
         if vCounter  >= vRez then
            address <= (others => '0');              -- ����ֱ���������ڵ��ڴ�ֱ�ֱ��ʣ��򽫵�ַ�ź���Ϊ0
            blank <= '1';                            -- ͬʱ��blank�ź���Ϊ�ߵ�ƽ
         else 
            if hCounter  < hRez then
               blank <= '0';                          -- ��ˮƽ������С��ˮƽ�ֱ��ʣ���blank�ź���Ϊ�͵�ƽ
               address <= address+1;                   -- ͬʱ��ַ�źŵ���
            else
               blank <= '1';                          -- ��ˮƽ���������ڵ���ˮƽ�ֱ��ʣ���blank�ź���Ϊ�ߵ�ƽ
            end if;
         end if;
   
         -- hSync����
         if hCounter > hStartSync and hCounter <= hEndSync then
            vga_hSync <= hsync_active;                 -- ��ˮƽ��������hStartSync��hEndSync֮�䣬��vga_hSync�ź���Ϊhsync_active
         else
            vga_hSync <= not hsync_active;             -- ��ˮƽ����������hStartSync��hEndSync֮�䣬��vga_hSync�ź���Ϊnot hsync_active
         end if;

         -- vSync����
         if vCounter >= vStartSync and vCounter < vEndSync then
            vga_vSync <= vsync_active;                 -- ����ֱ��������vStartSync��vEndSync֮�䣬��vga_vSync�ź���Ϊvsync_active
         else
            vga_vSync <= not vsync_active;             -- ����ֱ����������vStartSync��vEndSync֮�䣬��vga_vSync�ź���Ϊnot vsync_active
         end if;
      end if;
   end process;
end Behavioral;
