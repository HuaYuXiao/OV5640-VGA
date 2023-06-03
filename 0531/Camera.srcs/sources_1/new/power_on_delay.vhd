library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity power_on_delay is
    port (
        clk_50M      : in  std_logic; -- 50MHzʱ������
        reset_n      : in  std_logic; -- ��λ�ź�����
        camera1_rstn : out std_logic; -- ����ͷ1��λ�ź����
        camera2_rstn : out std_logic; -- ����ͷ2��λ�ź����
        camera_pwnd  : out std_logic; -- ����ͷ��Դ�����ź����
        initial_en   : out std_logic  -- ��ʼʹ���ź����
    );
end entity power_on_delay;

architecture behavioral of power_on_delay is
    signal cnt1       : unsigned(18 downto 0);
    signal cnt2       : unsigned(15 downto 0);
    signal cnt3       : unsigned(19 downto 0);
    signal camera_rstn_reg : std_logic;
    signal camera_pwnd_reg : std_logic;

begin
    camera1_rstn <= camera_rstn_reg;
    camera2_rstn <= camera_rstn_reg;
    camera_pwnd  <= camera_pwnd_reg;

    -- 5ms
    process(clk_50M)
    begin
        if rising_edge(clk_50M) then
            if reset_n = '0' then
                cnt1 <= (others => '0');
                camera_pwnd_reg <= '1';
            elsif cnt1 < to_unsigned(2**18-1, cnt1'length) then
                cnt1 <= cnt1 + 1;
                camera_pwnd_reg <= '1';
            else
                camera_pwnd_reg <= '0';
            end if;
        end if;
    end process;

    -- 1.3ms
    process(clk_50M)
    begin
        if rising_edge(clk_50M) then
            if camera_pwnd_reg = '1' then
                cnt2 <= (others => '0');
                camera_rstn_reg <= '0';
            elsif cnt2 < to_unsigned(16#ffff#, cnt2'length) then
                cnt2 <= cnt2 + 1;
                camera_rstn_reg <= '0';
            else
                camera_rstn_reg <= '1';
            end if;
        end if;
    end process;

    -- 21ms
    process(clk_50M)
    begin
        if rising_edge(clk_50M) then
            if camera_rstn_reg = '0' then
                cnt3 <= (others => '0');
                initial_en <= '0';
            elsif cnt3 < to_unsigned(2**20-1, cnt3'length) then
                cnt3 <= cnt3 + 1;
                initial_en <= '0';
            else
                initial_en <= '1';
            end if;
        end if;
    end process;

end architecture behavioral;
