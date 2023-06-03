-- Copyright 1986-2023 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2022.2.2 (win64) Build 3788238 Tue Feb 21 20:00:34 MST 2023
-- Date        : Sun May 28 15:21:15 2023
-- Host        : MagicBook running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               d:/iCloudDrive/course/EE332/lab/final/code/0528/cam2hdmi.gen/sources_1/ip/mmcm/mmcm_stub.vhdl
-- Design      : mmcm
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a100tcsg324-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mmcm is
  Port ( 
    clk_65m : out STD_LOGIC;
    xclk : out STD_LOGIC;
    clk_100m : out STD_LOGIC;
    locked : out STD_LOGIC;
    ui_clk : in STD_LOGIC
  );

end mmcm;

architecture stub of mmcm is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk_65m,xclk,clk_100m,locked,ui_clk";
begin
end;
