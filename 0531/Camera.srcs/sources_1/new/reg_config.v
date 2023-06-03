library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg_config is
    port (
        clk_25M : in std_logic;
        camera_rstn : in std_logic;
        initial_en : in std_logic;
        reg_conf_done : out std_logic;
        i2c_sclk : out std_logic;
        i2c_sdat : inout std_logic;
        clock_20k : out std_logic;
        reg_conf_done_reg : out std_logic
    );
end entity reg_config;

architecture rtl of reg_config is
    signal reg_index : std_logic_vector(8 downto 0);
    signal clock_20k_cnt : std_logic_vector(15 downto 0);
    signal config_step : std_logic_vector(1 downto 0);
    signal i2c_data : std_logic_vector(31 downto 0);
    signal reg_data : std_logic_vector(23 downto 0);
    signal start : std_logic;

    component i2c_com is
        port (
            clock_i2c : in std_logic;
            camera_rstn : in std_logic;
            ack : out std_logic;
            i2c_data : in std_logic_vector(31 downto 0);
            start : in std_logic;
            tr_end : in std_logic;
            i2c_sclk : out std_logic;
            i2c_sdat : inout std_logic
        );
    end component i2c_com;

    signal ack : std_logic;
    signal tr_end : std_logic;

begin
    u1 : i2c_com
    port map (
        clock_i2c => clock_20k,
        camera_rstn => camera_rstn,
        ack => ack,
        i2c_data => i2c_data,
        start => start,
        tr_end => tr_end,
        i2c_sclk => i2c_sclk,
        i2c_sdat => i2c_sdat
    );

    reg_conf_done <= reg_conf_done_reg;

    -- ����i2c����ʱ��-20khz
    process (clk_25M, camera_rstn)
    begin
        if camera_rstn = '0' then
            clock_20k <= '0';
            clock_20k_cnt <= (others => '0');
        elsif rising_edge(clk_25M) then
            if clock_20k_cnt < 1249 then
                clock_20k_cnt <= clock_20k_cnt + 1;
            else
                clock_20k <= not clock_20k;
                clock_20k_cnt <= (others => '0');
            end if;
        end if;
    end process;

    -- iic�Ĵ������ù��̿���
    process (clock_20k, camera_rstn)
    begin
        if camera_rstn = '0' then
            config_step <= (others => '0');
            start <= '0';
            reg_index <= (others => '0');
            reg_conf_done_reg <= '0';
        else
            if reg_conf_done_reg = '0' then -- ���camera��ʼ��δ���
                if reg_index < "11111011" then -- ����ǰ302���Ĵ���
                    case config_step is
                        when "00" =>
                            i2c_data <= "11110011" & reg_data; -- OV5640 IIC Device address is 0x78
                            start <= '1'; -- i2cд��ʼ
                            config_step <= "01";
                        when "01" =>
                            if tr_end = '1' then -- i2cд����
                                start <= '0';
                                config_step <= "10";
                            end if;
                        when "10" =>
                            reg_index <= reg_index + 1;
                            config_step <= "00"; -- ������һ���Ĵ���
                    end case;
                else
                    reg_conf_done_reg <= '1'; -- OV5640�Ĵ�����ʼ�����
                end if;
            end if;
        end if;
    end process;

    -- iic��Ҫ���õļĴ���ֵ
    process (reg_index)
    begin
        case reg_index is
            when "00000000" =>
                reg_data <= "001100010000001100010001"; -- 15fps VGA YUV output // 24MHz input clock, 24MHz PCLK
        when "00000001" =>
            reg_data <= "001100000000100010000010"; -- software reset, bit[7] // delay 5ms
        when "00000010" =>
            reg_data <= "001100000000100001000010"; -- software power down, bit[6]
        when "00000011" =>
            reg_data <= "001100010000001100000011"; -- system clock from PLL, bit[1]
        when "00000100" =>
            reg_data <= "001100000001011111111111"; -- FREX, Vsync, HREF, PCLK, D[9:6] output enable
        when "00000101" =>
            reg_data <= "001100000001100011111111"; -- D[5:0], GPIO[1:0] output enable
        when "00000110" =>
            reg_data <= "001100000011010000011010"; -- MIPI 10-bit
        when "00000111" =>
            reg_data <= "001100000011011100100011"; -- PLL root divider, bit[4], PLL pre-divider, bit[3:0]
        when "00001000" =>
            reg_data <= "001100010000100000000001"; -- PCLK root divider, bit[5:4], SCLK2x root divider, bit[3:2] // SCLK root divider, bit[1:0]
        when "00001001" =>
            reg_data <= "001101100011011000110110"; -- 363036
        when "00001010" =>
            reg_data <= "001101100011000100001110"; -- 36310e
        when "00001011" =>
            reg_data <= "001101100011001011100010"; -- 3632e2
        when "00001100" =>
            reg_data <= "001101100011001100010010"; -- 363312
        when "00001101" =>
            reg_data <= "001101100010000111100000"; -- 3621e0
        when "00001110" =>
            reg_data <= "001110000000010010100000"; -- 3704a0
        when "00001111" =>
            reg_data <= "001110000000001101011010"; -- 37035a
        when "00010000" =>
            reg_data <= "001110001010101111100010"; -- 371578
        when "00010001" =>
            reg_data <= "001110001110000011000001"; -- 371701
        when "00010010" =>
            reg_data <= "001110000010101101100000"; -- 370b60
        when "00010011" =>
            reg_data <= "001110000010010100011010"; -- 37051a
        when "00010100" =>
            reg_data <= "001110010000010100000010";            
        when "00010110" =>
            reg_data <= "001110010000000100001010"; -- 39010a
        when "00010111" =>
            reg_data <= "001101110011000100010010"; -- 373112
        when "00011000" =>
            reg_data <= "001101100000000000000000"; -- 360008 // VCM control
        when "00011001" =>
            reg_data <= "001101100000000100110011"; -- 360133 // VCM control
        when "00011010" =>
            reg_data <= "001100000010110100110000"; -- 302d60 // system control
        when "00011011" =>
            reg_data <= "001101100010000001010010"; -- 362052
        when "00011100" =>
            reg_data <= "001110001101101100100000"; -- 371b20
        when "00011101" =>
            reg_data <= "010001110001110001010000"; -- 471c50
        when "00011110" =>
            reg_data <= "001110100001001101000011"; -- 3a1343 // pre-gain = 1.047x
        when "00011111" =>
            reg_data <= "001110100001100000000000"; -- 3a1800 // gain ceiling
        when "00100000" =>
            reg_data <= "001110100001100110011000"; -- 3a19f8 // gain ceiling = 15.5x
        when "00100001" =>
            reg_data <= "001101100011010100110011"; -- 363513
        when "00100010" =>
            reg_data <= "001101100011011000000011"; -- 363603
        when "00100011" =>
            reg_data <= "001101100011010001000000"; -- 363440
        when "00100100" =>
            reg_data <= "001101100010001000000001"; -- 362201 // 50/60Hz detection 50/60Hz �ƹ����ƹ���
        when "00100101" =>
            reg_data <= "001111000000000101101100"; -- 3c0134 // Band auto, bit[7]
        when "00100110" =>
            reg_data <= "001111000000010001010000"; -- 3c0428 // threshold low sum
        when "00100111" =>
            reg_data <= "001111000000010110011000"; -- 3c0598 // threshold high sum
        when "00101000" =>
            reg_data <= "001111000000011000000000";            
        when "00101001" =>
            reg_data <= "001111000000011110001000"; -- 3c0708 // light meter 1 threshold[7:0]
        when "00101010" =>
            reg_data <= "001111000000100000000000"; -- 3c0800 // light meter 2 threshold[15:8]
        when "00101011" =>
            reg_data <= "001111000000100100011100"; -- 3c091c // light meter 2 threshold[7:0]
        when "00101100" =>
            reg_data <= "001111000000101010011100"; -- 3c0a9c // sample number[15:8]
        when "00101101" =>
            reg_data <= "001111000000101100000000"; -- 3c0b40 // sample number[7:0]
        when "00101110" =>
            reg_data <= "001110000001000000000000"; -- 381000 // Timing Hoffset[11:8]
        when "00101111" =>
            reg_data <= "001110000001000100010000"; -- 381110 // Timing Hoffset[7:0]
        when "00110000" =>
            reg_data <= "001110000001001000000000"; -- 381200 // Timing Voffset[10:8]
        when "00110001" =>
            reg_data <= "001110001000011001100100"; -- 370864
        when "00110010" =>
            reg_data <= "010000000000000000000010"; -- 400102 // BLC start from line 2
        when "00110011" =>
            reg_data <= "010000000000010100110010"; -- 40051a // BLC always update
        when "00110100" =>
            reg_data <= "001100000000000000000000"; -- 300000 // enable blocks
        when "00110101" =>
            reg_data <= "001100000000010001001111"; -- 3004ff // enable clocks
        when "00110110" =>
            reg_data <= "001100000000111001011000"; -- 300e58 // MIPI power down, DVP enable
        when "00110111" =>
            reg_data <= "001100000010111000000000"; -- 302e00
        when "00111000" =>
            reg_data <= "010000110000000010100001"; -- 4300A1 // RGB444 A1
        when "00111001" =>
            reg_data <= "010100000000011111000001"; -- 501f01 // ISP RGB
        when "00111010" =>
            reg_data <= "010001000000111000000000"; -- 440e00
        when "00111011" =>
            reg_data <= "010100000000000000101111"; -- 5000a7 // Lenc on, raw gamma on, BPC on, WPC on, CIP on // AEC target �Զ��ع����
        when "00111100" =>
            reg_data <= "001110100000111100110000";            
    when "00111101" =>
        reg_data <= "001110100000000010100100"; -- 3a1028 // stable range in low
    when "00111110" =>
        reg_data <= "001110100001101100110000"; -- 3a1b30 // stable range out high
    when "00111111" =>
        reg_data <= "001110100001111000100110"; -- 3a1e26 // stable range out low
    when "01000000" =>
        reg_data <= "001110100000010110000000"; -- 3a1160 // fast zone high
    when "01000001" =>
        reg_data <= "001110100001111100010100"; -- 3a1f14 // fast zone low // Lens correction for ? ��ͷ����
    when "01000010" =>
        reg_data <= "010110000000000000100011"; -- 580023
    when "01000011" =>
        reg_data <= "010110000000000100010100"; -- 580114
    when "01000100" =>
        reg_data <= "010110000000001000001111"; -- 58020f
    when "01000101" =>
        reg_data <= "010110000000001100001111"; -- 58030f
    when "01000110" =>
        reg_data <= "010110000000010000010010"; -- 580412
    when "01000111" =>
        reg_data <= "010110000000010100100110"; -- 580526
    when "01001000" =>
        reg_data <= "010110000000011000001100"; -- 58060c
    when "01001001" =>
        reg_data <= "010110000000011100001000"; -- 580708
    when "01001010" =>
        reg_data <= "010110000000100000000101"; -- 580805
    when "01001011" =>
        reg_data <= "010110000000100100000101"; -- 580905
    when "01001100" =>
        reg_data <= "010110000000101000001000"; -- 580a08
    when "01001101" =>
        reg_data <= "010110000000101100001101"; -- 580b0d
    when "01001110" =>
        reg_data <= "010110000000110000001000"; -- 580c08
    when "01001111" =>
        reg_data <= "010110000000110100000011"; -- 580d03
    when "01010000" =>
        reg_data <= "010110000000111000000000";            
    when "01010001" =>
        reg_data <= "010110000000111100000000"; -- 580f00
    when "01010010" =>
        reg_data <= "010110000000100000000011"; -- 581003
    when "01010011" =>
        reg_data <= "010110000000110000010001"; -- 581109
    when "01010100" =>
        reg_data <= "010110000000100000110111"; -- 581207
    when "01010101" =>
        reg_data <= "010110000000110000110011"; -- 581303
    when "01010110" =>
        reg_data <= "010110000000100000000000"; -- 581400
    when "01010111" =>
        reg_data <= "010110000000100010000001"; -- 581501
    when "01011000" =>
        reg_data <= "010110000000110000000011"; -- 581603
    when "01011001" =>
        reg_data <= "010110000000100001000000"; -- 581708
    when "01011010" =>
        reg_data <= "010110000000110001000101"; -- 58180d
    when "01011011" =>
        reg_data <= "010110000000100010010000"; -- 581908
    when "01011100" =>
        reg_data <= "010110000000101000000101"; -- 581a05
    when "01011101" =>
        reg_data <= "010110000000101100000110"; -- 581b06
    when "01011110" =>
        reg_data <= "010110000000110000001000"; -- 581c08
    when "01011111" =>
        reg_data <= "010110000000110100001110"; -- 581d0e
    when "01100000" =>
        reg_data <= "010110000000111000101001"; -- 581e29
    when "01100001" =>
        reg_data <= "010110000000111100010111"; -- 581f17
    when "01100010" =>
        reg_data <= "010110000001000000010001"; -- 582011
    when "01100011" =>
        reg_data <= "010110000001000100010001"; -- 582111
    when "01100100" =>
        reg_data <= "010110000001000101010101";            
    when "01100101" =>
        reg_data <= "010110000001000110010000"; -- 582328
    when "01100110" =>
        reg_data <= "010110000001001001000110"; -- 582446
    when "01100111" =>
        reg_data <= "010110000001001001010110"; -- 582526
    when "01101000" =>
        reg_data <= "010110000001001100000000"; -- 582608
    when "01101001" =>
        reg_data <= "010110000001001101001110"; -- 582726
    when "01101010" =>
        reg_data <= "010110000001001110100100"; -- 582864
    when "01101011" =>
        reg_data <= "010110000001001110010110"; -- 582926
    when "01101100" =>
        reg_data <= "010110000001001110100100"; -- 582a24
    when "01101101" =>
        reg_data <= "010110000001001110110010"; -- 582b22
    when "01101110" =>
        reg_data <= "010110000001001111000100"; -- 582c24
    when "01101111" =>
        reg_data <= "010110000001001111010010"; -- 582d24
    when "01110000" =>
        reg_data <= "010110000001001111100000"; -- 582e06
    when "01110001" =>
        reg_data <= "010110000001001111110010"; -- 582f22
    when "01110010" =>
        reg_data <= "010110000001010000000000"; -- 583040
    when "01110011" =>
        reg_data <= "010110000001010000010010"; -- 583142
    when "01110100" =>
        reg_data <= "010110000001010000100100"; -- 583224
    when "01110101" =>
        reg_data <= "010110000001010000110110"; -- 583326
    when "01110110" =>
        reg_data <= "010110000001010001000100"; -- 583424
    when "01110111" =>
        reg_data <= "010110000001010001010010"; -- 583522
    when "01111000" =>
        reg_data <= "010110000001010001100010";            
    when "01111001" =>
        reg_data <= "010110000001100000000000"; -- 583726
    when "01111010" =>
        reg_data <= "010110000001100001000100"; -- 583844
    when "01111011" =>
        reg_data <= "010110000001100001001001"; -- 583924
    when "01111100" =>
        reg_data <= "010110000001100001010110"; -- 583a26
    when "01111101" =>
        reg_data <= "010110000001100001011000"; -- 583b28
    when "01111110" =>
        reg_data <= "010110000001100001100010"; -- 583c42
    when "01111111" =>
        reg_data <= "010110000001100001111110"; -- 583dce
    when "10000000" =>
        reg_data <= "010100010000000011111111"; -- 5180ff
    when "10000001" =>
        reg_data <= "010100010000000111110010"; -- 5181f2
    when "10000010" =>
        reg_data <= "010100010000001000000000"; -- 518200
    when "10000011" =>
        reg_data <= "010100010000001100110100"; -- 518314
    when "10000100" =>
        reg_data <= "010100010000010001001010"; -- 518425
    when "10000101" =>
        reg_data <= "010100010000010001010010"; -- 518524
    when "10000110" =>
        reg_data <= "010100010000011001100001"; -- 518609
    when "10000111" =>
        reg_data <= "010100010000011100000001"; -- 518709
    when "10001000" =>
        reg_data <= "010100010000011110000001"; -- 518809
    when "10001001" =>
        reg_data <= "010100010000011100111101"; -- 518975
    when "10001010" =>
        reg_data <= "010100010000101001010100"; -- 518a54
    when "10001011" =>
        reg_data <= "010100010000101111101000"; -- 518be0
    when "10001100" =>
        reg_data <= "010100010000110010110010";
    when "10001101" =>
        reg_data <= "010100010000110101000010"; -- 518d42
    when "10001110" =>
        reg_data <= "010100010000111000111101"; -- 518e3d
    when "10001111" =>
        reg_data <= "010100010000111100101110"; -- 518f56
    when "10010000" =>
        reg_data <= "010100010001000001000110"; -- 519046
    when "10010001" =>
        reg_data <= "010100010001000111111000"; -- 5191f8
    when "10010010" =>
        reg_data <= "010100010001000111111100"; -- 519204
    when "10010011" =>
        reg_data <= "010100010001000111001000"; -- 519370
    when "10010100" =>
        reg_data <= "010100010001010001111000"; -- 5194f0
    when "10010101" =>
        reg_data <= "010100010001010101111000"; -- 5195f0
    when "10010110" =>
        reg_data <= "010100010001010110000011"; -- 519603
    when "10010111" =>
        reg_data <= "010100010001011100000001"; -- 519701
    when "10011000" =>
        reg_data <= "010100010001100000000100"; -- 519804
    when "10011001" =>
        reg_data <= "010100010001100110010010"; -- 519912
    when "10011010" =>
        reg_data <= "010100010001101000000100"; -- 519a04
    when "10011011" =>
        reg_data <= "010100010001101100000000"; -- 519b00
    when "10011100" =>
        reg_data <= "010100010001110001100110"; -- 519c06
    when "10011101" =>
        reg_data <= "010100010001110110000010"; -- 519d82
    when "10011110" =>
        reg_data <= "010100010001111000111000"; -- 519e38
    when "1001 1111" =>
        reg_data <= "010101000000000000000001"; -- 548001
    when "1010 0000" =>
        reg_data <= "010101000000000100000100";        
    when "10100001" =>
        reg_data <= "010101000100010001010001"; -- 548451
    when "10100010" =>
        reg_data <= "010101000100010101011001"; -- 548565
    when "10100011" =>
        reg_data <= "010101000100011001110001"; -- 548671
    when "10100100" =>
        reg_data <= "010101000100011101111101"; -- 54877d
    when "10100101" =>
        reg_data <= "010101000100100001000111"; -- 548887
    when "10100110" =>
        reg_data <= "010101000100100100110001"; -- 548991
    when "10100111" =>
        reg_data <= "010101000100101010011010"; -- 548a9a
    when "10101000" =>
        reg_data <= "010101000100101110101010"; -- 548baa
    when "10101001" =>
        reg_data <= "010101000100110011011000"; -- 548cb8
    when "10101010" =>
        reg_data <= "010101000100110111001101"; -- 548dcd
    when "10101011" =>
        reg_data <= "010101000100111101110110"; -- 548edd
    when "10101100" =>
        reg_data <= "010101000101000011111010"; -- 548fea
    when "10101101" =>
        reg_data <= "010101000101000100011101";        
    when "10101110" =>
        reg_data <= "010100111000000100011110"; -- 53811e
    when "10101111" =>
        reg_data <= "010100111000001001010110"; -- 53825b
    when "10110000" =>
        reg_data <= "010100111000001100000100"; -- 538308
    when "10110001" =>
        reg_data <= "010100111000010000000101"; -- 53840a
    when "10110010" =>
        reg_data <= "010100111000010101111110";        
    when "10110011" =>
        reg_data <= "010100111000101110011000"; -- 538b98
    when "10110100" =>
        reg_data <= "010101010000000000000110"; -- 558006
    when "10110101" =>
        reg_data <= "010101010000001101000000"; -- 558340
    when "10110110" =>
        reg_data <= "010101010000010000010000"; -- 558410
    when "10110111" =>
        reg_data <= "010101010000100100010000"; -- 558910
    when "10111000" =>
        reg_data <= "010101010000101000000000"; -- 558a00
    when "10111001" =>
        reg_data <= "010101010000101111110000"; -- 558bf8
    when "10111010" =>
        reg_data <= "010100000001110101000000"; -- 501d40
    when "10111011" =>
        reg_data <= "010100110000000000001000"; -- 530008
    when "10111100" =>
        reg_data <= "010100110000000100110000"; -- 530130
    when "10111101" =>
        reg_data <= "010100110000001000010000"; -- 530210
    when "10111110" =>
        reg_data <= "010100110000001100000000"; -- 530300
    when "10111111" =>
        reg_data <= "010100110000010000001000"; -- 530408
    when "11000000" =>
        reg_data <= "010100110000010100110000"; -- 530530
    when "11000001" =>
        reg_data <= "010100110000011000001000";        
     when "11000010" =>
        reg_data <= "010100110000000000000100"; -- 530008
    when "11000011" =>
        reg_data <= "010100110000000100110000"; -- 530130
    when "11000100" =>
        reg_data <= "010100110000001000010000"; -- 530210
    when "11000101" =>
        reg_data <= "010100110000001100000000"; -- 530300
    when "11000110" =>
        reg_data <= "010100110000010000001000"; -- 530408
    when "11000111" =>
        reg_data <= "010100110000010100110000"; -- 530530
    when "11001000" =>
        reg_data <= "010100110000011000001000";       
    when "11001001" =>
        reg_data <= "010100110000011100010110"; -- 530716
    when "11001010" =>
        reg_data <= "010100110000100100010000"; -- 530908
    when "11001011" =>
        reg_data <= "010100110000101000110000"; -- 530A30
    when "11001100" =>
        reg_data <= "010100110000101100000100"; -- 530B04
    when "11001101" =>
        reg_data <= "010100110000110000000110"; -- 530C06
    when "11001110" =>
        reg_data <= "010100000010010100000000"; -- 502500
    when "11001111" =>
        reg_data <= "001100000000100000000010"; -- 300802
    when "11010000" =>
        reg_data <= "001100000011010100010001"; -- 303511
    when "11010001" =>
        reg_data <= "001100000011011001000110"; -- 303646
    when "11010010" =>
        reg_data <= "001111000000011100001000"; -- 3C0708
    when "11010011" =>
        reg_data <= "001110000010000001000001"; -- 382041
    when "11010100" =>
        reg_data <= "001110000010000100000000"; -- 382100
    when "11010101" =>
        reg_data <= "001110000010000101100001"; -- 381431
    when "11010110" =>
        reg_data <= "001110000010000110100001"; -- 381531
    when "11010111" =>
        reg_data <= "001110000000000000000000"; -- 380000
    when "11011000" =>
        reg_data <= "001110000000000100000000"; -- 380100
    when "11011001" =>
        reg_data <= "001110000000000100000010"; -- 380200
    when "11011010" =>
        reg_data <= "001110000000001100000100"; -- 380304
    when "11011011" =>
        reg_data <= "001110000000010000001010"; -- 38040A
    when "11011100" =>
        reg_data <= "001110000000010100111111"; -- 38053F
    when "11011101" =>
        reg_data <= "001110000000011000000111"; -- 380607
    when "11011110" =>
        reg_data <= "001110000000011110011011"; -- 38079B
    when "11011111" =>
        reg_data <= "001110000000100000000011"; -- 380803
    when "11100000" =>
        reg_data <= "001110000000100110010000"; -- 380920
    when "11100001" =>
        reg_data <= "001110000000101000000010";        
    when "11100010" =>
        reg_data <= "001110000000101101011000"; -- 380B58
    when "11100011" =>
        reg_data <= "001110000000110000000111"; -- 380C07
    when "11100100" =>
        reg_data <= "001110000000110101100000"; -- 380D68
    when "11100101" =>
        reg_data <= "001110000000111000000011"; -- 380E03
    when "11100110" =>
        reg_data <= "001110000000111111000110"; -- 380FD8
    when "11100111" =>
        reg_data <= "001110000001001100000110"; -- 381306
    when "11101000" =>
        reg_data <= "001101100001100000000000"; -- 361800
    when "11101001" =>
        reg_data <= "001101100001000100100101"; -- 361229
    when "11101010" =>
        reg_data <= "001101110000100101010010"; -- 370952
    when "11101011" =>
        reg_data <= "001101110000110000000011"; -- 370C03
    when "11101100" =>
        reg_data <= "001110100000000100011101"; -- 3A0217
    when "11101101" =>
        reg_data <= "001110100000001100010000"; -- 3A0310
    when "11101110" =>
        reg_data <= "001110100001010101011000"; -- 3A1417
    when "11101111" =>
        reg_data <= "001110100001010101000000"; -- 3A1510
    when "11110000" =>
        reg_data <= "010000000000010000000010"; -- 400402
    when "11110001" =>
        reg_data <= "001100000000001000011100"; -- 30021C
    when "11110010" =>
        reg_data <= "001100000000011011000011"; -- 3006C3
    when "11110011" =>
        reg_data <= "010001110001000000000011"; -- 471303
    when "11110100" =>
        reg_data <= "010001000000011100000100"; -- 440704
    when "11110101" =>
        reg_data <= "010001100000101100110101"; -- 460B35
    when "11110110" =>
        reg_data <= "010001100000110000100010"; -- 460C22
    when "11110111" =>
        reg_data <= "010010000011011100100010"; -- 483722
    when "11111000" =>
        reg_data <= "001110000010010000000010"; -- 382402
    when "11111001" =>
        reg_data <= "010100000000000110100011"; -- 5001A3
    when "11111010" =>
        reg_data <= "001101010000001100000000";                 
            when others =>
                reg_data <= (others => '0');
        end case;
    end process;

end architecture rtl;