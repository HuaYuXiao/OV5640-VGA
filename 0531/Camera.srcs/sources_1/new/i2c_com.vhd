library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i2c_com is
    port (
        clock_i2c   : in  std_logic;     -- Input clock for I2C module
        camera_rstn : in  std_logic;     -- Camera reset signal
        ack         : out std_logic;     -- I2C acknowledge signal
        i2c_data    : in  std_logic_vector(31 downto 0);  -- Input data for I2C module
        start       : in  std_logic;     -- Start signal for I2C communication
        tr_end      : out std_logic;     -- I2C transaction end signal
        i2c_sclk    : out std_logic;     -- I2C serial clock signal
        i2c_sdat    : inout std_logic    -- I2C serial data signal
    );
end entity i2c_com;

architecture behavioral of i2c_com is
    signal cyc_count     : unsigned(5 downto 0);
    signal reg_sdat      : std_logic;
    signal sclk          : std_logic;
    signal ack1, ack2, ack3 : std_logic;
    signal tr_end_signal : std_logic;

    signal i2c_sclk_wire : std_logic;
    signal i2c_sdat_wire : std_logic;
    signal ack_wire      : std_logic;

begin
    ack <= ack1 or ack2 or ack3;
    i2c_sclk <= (sclk or (cyc_count >= "000100" and cyc_count <= "100111")) and (not clock_i2c);
    i2c_sdat_wire <= reg_sdat when reg_sdat = '1' else '0';

process (clock_i2c, camera_rstn)
    begin
        if camera_rstn = '0' then                       -- 如果相机复位信号为低电平
            cyc_count <= "111111";                      -- 将循环计数器设置为最大值
        else
            if start = '0' then                         -- 如果开始信号为低电平
                cyc_count <= (others => '0');            -- 将循环计数器清零
            elsif cyc_count < "111111" then              -- 如果循环计数器小于最大值
                cyc_count <= cyc_count + 1;              -- 循环计数器加一
            end if;
        end if;
    end process;

    process (clock_i2c, camera_rstn)
    begin
        if camera_rstn = '0' then
            tr_end_signal <= '0';
            ack1 <= '1';
            ack2 <= '1';
            ack3 <= '1';
            sclk <= '1';
            reg_sdat <= '1';
        else
            case cyc_count is
                when "000000" =>
                    ack1 <= '1';
                    ack2 <= '1';
                    ack3 <= '1';
                    tr_end_signal <= '0';
                    sclk <= '1';
                    reg_sdat <= '1';
                when "000001" =>
                    reg_sdat <= '0';
                when "000010" =>
                    sclk <= '0';
                when "000011" =>
                    reg_sdat <= i2c_data(31);
                when "000100" =>
                    reg_sdat <= i2c_data(30);
                when "000101" =>
                    reg_sdat <= i2c_data(29);
                when "000110" =>
                    reg_sdat <= i2c_data(28);
                when "000111" =>
                    reg_sdat <= i2c_data(27);
                when "001000" =>
                    reg_sdat <= i2c_data(26);
                when "001001" =>
                    reg_sdat <= i2c_data(25);
                when "001010" =>
                    reg_sdat <= i2c_data(24);
                when "001011" =>
                    reg_sdat <= '1';
                when "001100" =>
                    reg_sdat <= i2c_data(23);
                    ack1 <= i2c_sdat_wire;
                when "001101" =>
                    reg_sdat <= i2c_data(22);
                when "001110" =>
                    reg_sdat <= i2c_data(21);
                when "001111" =>
                    reg_sdat <= i2c_data(20);
                when "010000" =>
                    reg_sdat <= i2c_data(19);
                when "010001" =>
                    reg_sdat <= i2c_data(18);
                when "010010" =>
                    reg_sdat <= i2c_data(17);
                when "010011" =>
                    reg_sdat <= i2c_data(16);
                when "010100" =>
                    reg_sdat <= '1';
                when "010101" =>
                    reg_sdat <= i2c_data(15);
                    ack1 <= i2c_sdat_wire;
                when "010110" =>
                    reg_sdat <= i2c_data(14);
                when "010111" =>
                    reg_sdat <= i2c_data(13);
                when "011000" =>
                    reg_sdat <= i2c_data(12);
                when "011001" =>
                    reg_sdat <= i2c_data(11);
                when "011010" =>
                    reg_sdat <= i2c_data(10);
                when "011011" =>
                    reg_sdat <= i2c_data(9);
                when "011100" =>
                    reg_sdat <= i2c_data(8);
                when "011101" =>
                    reg_sdat <= '1';
                when "011110" =>
                    reg_sdat <= i2c_data(7);
                    ack2 <= i2c_sdat_wire;
                when "011111" =>
                    reg_sdat <= i2c_data(6);
                when "100000" =>
                    reg_sdat <= i2c_data(5);
                when "100001" =>
                    reg_sdat <= i2c_data(4);
                when "100010" =>
                    reg_sdat <= i2c_data(3);
                when "100011" =>
                    reg_sdat <= i2c_data(2);
                when "100100" =>
                    reg_sdat <= i2c_data(1);
                when "100101" =>
                    reg_sdat <= i2c_data(0);
                when "100110" =>
                    reg_sdat <= '1';
                when "100111" =>
                    ack3 <= i2c_sdat_wire;
                    sclk <= '0';
                    reg_sdat <= '0';
                when "101000" =>
                    sclk <= '1';
                when "101001" =>
                    reg_sdat <= '1';
                    tr_end_signal <= '1';
            end case;
        end if;
    end process;

    tr_end <= tr_end_signal;
    i2c_sclk <= i2c_sclk_wire;
    i2c_sdat <= i2c_sdat_wire;

end architecture behavioral;
