// Copyright 1986-2023 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.2.2 (win64) Build 3788238 Tue Feb 21 20:00:34 MST 2023
// Date        : Sun May 28 15:21:15 2023
// Host        : MagicBook running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               d:/iCloudDrive/course/EE332/lab/final/code/0528/cam2hdmi.gen/sources_1/ip/mmcm/mmcm_stub.v
// Design      : mmcm
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module mmcm(clk_65m, xclk, clk_100m, locked, ui_clk)
/* synthesis syn_black_box black_box_pad_pin="clk_65m,xclk,clk_100m,locked,ui_clk" */;
  output clk_65m;
  output xclk;
  output clk_100m;
  output locked;
  input ui_clk;
endmodule
