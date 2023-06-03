// Copyright 1986-2023 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.2.2 (win64) Build 3788238 Tue Feb 21 20:00:34 MST 2023
// Date        : Sun May 28 15:20:29 2023
// Host        : MagicBook running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ req_pend_fifo_sim_netlist.v
// Design      : req_pend_fifo
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "req_pend_fifo,fifo_generator_v13_2_7,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "fifo_generator_v13_2_7,Vivado 2022.2.2" *) 
(* NotValidForBitStream *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix
   (clk,
    srst,
    din,
    wr_en,
    rd_en,
    dout,
    full,
    empty);
  (* x_interface_info = "xilinx.com:signal:clock:1.0 core_clk CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME core_clk, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, INSERT_VIP 0" *) input clk;
  input srst;
  (* x_interface_info = "xilinx.com:interface:fifo_write:1.0 FIFO_WRITE WR_DATA" *) input [0:0]din;
  (* x_interface_info = "xilinx.com:interface:fifo_write:1.0 FIFO_WRITE WR_EN" *) input wr_en;
  (* x_interface_info = "xilinx.com:interface:fifo_read:1.0 FIFO_READ RD_EN" *) input rd_en;
  (* x_interface_info = "xilinx.com:interface:fifo_read:1.0 FIFO_READ RD_DATA" *) output [0:0]dout;
  (* x_interface_info = "xilinx.com:interface:fifo_write:1.0 FIFO_WRITE FULL" *) output full;
  (* x_interface_info = "xilinx.com:interface:fifo_read:1.0 FIFO_READ EMPTY" *) output empty;

  wire clk;
  wire [0:0]din;
  wire [0:0]dout;
  wire empty;
  wire full;
  wire rd_en;
  wire srst;
  wire wr_en;
  wire NLW_U0_almost_empty_UNCONNECTED;
  wire NLW_U0_almost_full_UNCONNECTED;
  wire NLW_U0_axi_ar_dbiterr_UNCONNECTED;
  wire NLW_U0_axi_ar_overflow_UNCONNECTED;
  wire NLW_U0_axi_ar_prog_empty_UNCONNECTED;
  wire NLW_U0_axi_ar_prog_full_UNCONNECTED;
  wire NLW_U0_axi_ar_sbiterr_UNCONNECTED;
  wire NLW_U0_axi_ar_underflow_UNCONNECTED;
  wire NLW_U0_axi_aw_dbiterr_UNCONNECTED;
  wire NLW_U0_axi_aw_overflow_UNCONNECTED;
  wire NLW_U0_axi_aw_prog_empty_UNCONNECTED;
  wire NLW_U0_axi_aw_prog_full_UNCONNECTED;
  wire NLW_U0_axi_aw_sbiterr_UNCONNECTED;
  wire NLW_U0_axi_aw_underflow_UNCONNECTED;
  wire NLW_U0_axi_b_dbiterr_UNCONNECTED;
  wire NLW_U0_axi_b_overflow_UNCONNECTED;
  wire NLW_U0_axi_b_prog_empty_UNCONNECTED;
  wire NLW_U0_axi_b_prog_full_UNCONNECTED;
  wire NLW_U0_axi_b_sbiterr_UNCONNECTED;
  wire NLW_U0_axi_b_underflow_UNCONNECTED;
  wire NLW_U0_axi_r_dbiterr_UNCONNECTED;
  wire NLW_U0_axi_r_overflow_UNCONNECTED;
  wire NLW_U0_axi_r_prog_empty_UNCONNECTED;
  wire NLW_U0_axi_r_prog_full_UNCONNECTED;
  wire NLW_U0_axi_r_sbiterr_UNCONNECTED;
  wire NLW_U0_axi_r_underflow_UNCONNECTED;
  wire NLW_U0_axi_w_dbiterr_UNCONNECTED;
  wire NLW_U0_axi_w_overflow_UNCONNECTED;
  wire NLW_U0_axi_w_prog_empty_UNCONNECTED;
  wire NLW_U0_axi_w_prog_full_UNCONNECTED;
  wire NLW_U0_axi_w_sbiterr_UNCONNECTED;
  wire NLW_U0_axi_w_underflow_UNCONNECTED;
  wire NLW_U0_axis_dbiterr_UNCONNECTED;
  wire NLW_U0_axis_overflow_UNCONNECTED;
  wire NLW_U0_axis_prog_empty_UNCONNECTED;
  wire NLW_U0_axis_prog_full_UNCONNECTED;
  wire NLW_U0_axis_sbiterr_UNCONNECTED;
  wire NLW_U0_axis_underflow_UNCONNECTED;
  wire NLW_U0_dbiterr_UNCONNECTED;
  wire NLW_U0_m_axi_arvalid_UNCONNECTED;
  wire NLW_U0_m_axi_awvalid_UNCONNECTED;
  wire NLW_U0_m_axi_bready_UNCONNECTED;
  wire NLW_U0_m_axi_rready_UNCONNECTED;
  wire NLW_U0_m_axi_wlast_UNCONNECTED;
  wire NLW_U0_m_axi_wvalid_UNCONNECTED;
  wire NLW_U0_m_axis_tlast_UNCONNECTED;
  wire NLW_U0_m_axis_tvalid_UNCONNECTED;
  wire NLW_U0_overflow_UNCONNECTED;
  wire NLW_U0_prog_empty_UNCONNECTED;
  wire NLW_U0_prog_full_UNCONNECTED;
  wire NLW_U0_rd_rst_busy_UNCONNECTED;
  wire NLW_U0_s_axi_arready_UNCONNECTED;
  wire NLW_U0_s_axi_awready_UNCONNECTED;
  wire NLW_U0_s_axi_bvalid_UNCONNECTED;
  wire NLW_U0_s_axi_rlast_UNCONNECTED;
  wire NLW_U0_s_axi_rvalid_UNCONNECTED;
  wire NLW_U0_s_axi_wready_UNCONNECTED;
  wire NLW_U0_s_axis_tready_UNCONNECTED;
  wire NLW_U0_sbiterr_UNCONNECTED;
  wire NLW_U0_underflow_UNCONNECTED;
  wire NLW_U0_valid_UNCONNECTED;
  wire NLW_U0_wr_ack_UNCONNECTED;
  wire NLW_U0_wr_rst_busy_UNCONNECTED;
  wire [4:0]NLW_U0_axi_ar_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_ar_rd_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_ar_wr_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_aw_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_aw_rd_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_aw_wr_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_b_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_b_rd_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_b_wr_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axi_r_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axi_r_rd_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axi_r_wr_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axi_w_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axi_w_rd_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axi_w_wr_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axis_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axis_rd_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axis_wr_data_count_UNCONNECTED;
  wire [3:0]NLW_U0_data_count_UNCONNECTED;
  wire [31:0]NLW_U0_m_axi_araddr_UNCONNECTED;
  wire [1:0]NLW_U0_m_axi_arburst_UNCONNECTED;
  wire [3:0]NLW_U0_m_axi_arcache_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_arid_UNCONNECTED;
  wire [7:0]NLW_U0_m_axi_arlen_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_arlock_UNCONNECTED;
  wire [2:0]NLW_U0_m_axi_arprot_UNCONNECTED;
  wire [3:0]NLW_U0_m_axi_arqos_UNCONNECTED;
  wire [3:0]NLW_U0_m_axi_arregion_UNCONNECTED;
  wire [2:0]NLW_U0_m_axi_arsize_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_aruser_UNCONNECTED;
  wire [31:0]NLW_U0_m_axi_awaddr_UNCONNECTED;
  wire [1:0]NLW_U0_m_axi_awburst_UNCONNECTED;
  wire [3:0]NLW_U0_m_axi_awcache_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_awid_UNCONNECTED;
  wire [7:0]NLW_U0_m_axi_awlen_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_awlock_UNCONNECTED;
  wire [2:0]NLW_U0_m_axi_awprot_UNCONNECTED;
  wire [3:0]NLW_U0_m_axi_awqos_UNCONNECTED;
  wire [3:0]NLW_U0_m_axi_awregion_UNCONNECTED;
  wire [2:0]NLW_U0_m_axi_awsize_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_awuser_UNCONNECTED;
  wire [63:0]NLW_U0_m_axi_wdata_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_wid_UNCONNECTED;
  wire [7:0]NLW_U0_m_axi_wstrb_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_wuser_UNCONNECTED;
  wire [7:0]NLW_U0_m_axis_tdata_UNCONNECTED;
  wire [0:0]NLW_U0_m_axis_tdest_UNCONNECTED;
  wire [0:0]NLW_U0_m_axis_tid_UNCONNECTED;
  wire [0:0]NLW_U0_m_axis_tkeep_UNCONNECTED;
  wire [0:0]NLW_U0_m_axis_tstrb_UNCONNECTED;
  wire [3:0]NLW_U0_m_axis_tuser_UNCONNECTED;
  wire [3:0]NLW_U0_rd_data_count_UNCONNECTED;
  wire [0:0]NLW_U0_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [0:0]NLW_U0_s_axi_buser_UNCONNECTED;
  wire [63:0]NLW_U0_s_axi_rdata_UNCONNECTED;
  wire [0:0]NLW_U0_s_axi_rid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_rresp_UNCONNECTED;
  wire [0:0]NLW_U0_s_axi_ruser_UNCONNECTED;
  wire [3:0]NLW_U0_wr_data_count_UNCONNECTED;

  (* C_ADD_NGC_CONSTRAINT = "0" *) 
  (* C_APPLICATION_TYPE_AXIS = "0" *) 
  (* C_APPLICATION_TYPE_RACH = "0" *) 
  (* C_APPLICATION_TYPE_RDCH = "0" *) 
  (* C_APPLICATION_TYPE_WACH = "0" *) 
  (* C_APPLICATION_TYPE_WDCH = "0" *) 
  (* C_APPLICATION_TYPE_WRCH = "0" *) 
  (* C_AXIS_TDATA_WIDTH = "8" *) 
  (* C_AXIS_TDEST_WIDTH = "1" *) 
  (* C_AXIS_TID_WIDTH = "1" *) 
  (* C_AXIS_TKEEP_WIDTH = "1" *) 
  (* C_AXIS_TSTRB_WIDTH = "1" *) 
  (* C_AXIS_TUSER_WIDTH = "4" *) 
  (* C_AXIS_TYPE = "0" *) 
  (* C_AXI_ADDR_WIDTH = "32" *) 
  (* C_AXI_ARUSER_WIDTH = "1" *) 
  (* C_AXI_AWUSER_WIDTH = "1" *) 
  (* C_AXI_BUSER_WIDTH = "1" *) 
  (* C_AXI_DATA_WIDTH = "64" *) 
  (* C_AXI_ID_WIDTH = "1" *) 
  (* C_AXI_LEN_WIDTH = "8" *) 
  (* C_AXI_LOCK_WIDTH = "1" *) 
  (* C_AXI_RUSER_WIDTH = "1" *) 
  (* C_AXI_TYPE = "1" *) 
  (* C_AXI_WUSER_WIDTH = "1" *) 
  (* C_COMMON_CLOCK = "1" *) 
  (* C_COUNT_TYPE = "0" *) 
  (* C_DATA_COUNT_WIDTH = "4" *) 
  (* C_DEFAULT_VALUE = "BlankString" *) 
  (* C_DIN_WIDTH = "1" *) 
  (* C_DIN_WIDTH_AXIS = "1" *) 
  (* C_DIN_WIDTH_RACH = "32" *) 
  (* C_DIN_WIDTH_RDCH = "64" *) 
  (* C_DIN_WIDTH_WACH = "1" *) 
  (* C_DIN_WIDTH_WDCH = "64" *) 
  (* C_DIN_WIDTH_WRCH = "2" *) 
  (* C_DOUT_RST_VAL = "0" *) 
  (* C_DOUT_WIDTH = "1" *) 
  (* C_ENABLE_RLOCS = "0" *) 
  (* C_ENABLE_RST_SYNC = "1" *) 
  (* C_EN_SAFETY_CKT = "0" *) 
  (* C_ERROR_INJECTION_TYPE = "0" *) 
  (* C_ERROR_INJECTION_TYPE_AXIS = "0" *) 
  (* C_ERROR_INJECTION_TYPE_RACH = "0" *) 
  (* C_ERROR_INJECTION_TYPE_RDCH = "0" *) 
  (* C_ERROR_INJECTION_TYPE_WACH = "0" *) 
  (* C_ERROR_INJECTION_TYPE_WDCH = "0" *) 
  (* C_ERROR_INJECTION_TYPE_WRCH = "0" *) 
  (* C_FAMILY = "artix7" *) 
  (* C_FULL_FLAGS_RST_VAL = "0" *) 
  (* C_HAS_ALMOST_EMPTY = "0" *) 
  (* C_HAS_ALMOST_FULL = "0" *) 
  (* C_HAS_AXIS_TDATA = "1" *) 
  (* C_HAS_AXIS_TDEST = "0" *) 
  (* C_HAS_AXIS_TID = "0" *) 
  (* C_HAS_AXIS_TKEEP = "0" *) 
  (* C_HAS_AXIS_TLAST = "0" *) 
  (* C_HAS_AXIS_TREADY = "1" *) 
  (* C_HAS_AXIS_TSTRB = "0" *) 
  (* C_HAS_AXIS_TUSER = "1" *) 
  (* C_HAS_AXI_ARUSER = "0" *) 
  (* C_HAS_AXI_AWUSER = "0" *) 
  (* C_HAS_AXI_BUSER = "0" *) 
  (* C_HAS_AXI_ID = "0" *) 
  (* C_HAS_AXI_RD_CHANNEL = "1" *) 
  (* C_HAS_AXI_RUSER = "0" *) 
  (* C_HAS_AXI_WR_CHANNEL = "1" *) 
  (* C_HAS_AXI_WUSER = "0" *) 
  (* C_HAS_BACKUP = "0" *) 
  (* C_HAS_DATA_COUNT = "0" *) 
  (* C_HAS_DATA_COUNTS_AXIS = "0" *) 
  (* C_HAS_DATA_COUNTS_RACH = "0" *) 
  (* C_HAS_DATA_COUNTS_RDCH = "0" *) 
  (* C_HAS_DATA_COUNTS_WACH = "0" *) 
  (* C_HAS_DATA_COUNTS_WDCH = "0" *) 
  (* C_HAS_DATA_COUNTS_WRCH = "0" *) 
  (* C_HAS_INT_CLK = "0" *) 
  (* C_HAS_MASTER_CE = "0" *) 
  (* C_HAS_MEMINIT_FILE = "0" *) 
  (* C_HAS_OVERFLOW = "0" *) 
  (* C_HAS_PROG_FLAGS_AXIS = "0" *) 
  (* C_HAS_PROG_FLAGS_RACH = "0" *) 
  (* C_HAS_PROG_FLAGS_RDCH = "0" *) 
  (* C_HAS_PROG_FLAGS_WACH = "0" *) 
  (* C_HAS_PROG_FLAGS_WDCH = "0" *) 
  (* C_HAS_PROG_FLAGS_WRCH = "0" *) 
  (* C_HAS_RD_DATA_COUNT = "0" *) 
  (* C_HAS_RD_RST = "0" *) 
  (* C_HAS_RST = "0" *) 
  (* C_HAS_SLAVE_CE = "0" *) 
  (* C_HAS_SRST = "1" *) 
  (* C_HAS_UNDERFLOW = "0" *) 
  (* C_HAS_VALID = "0" *) 
  (* C_HAS_WR_ACK = "0" *) 
  (* C_HAS_WR_DATA_COUNT = "0" *) 
  (* C_HAS_WR_RST = "0" *) 
  (* C_IMPLEMENTATION_TYPE = "0" *) 
  (* C_IMPLEMENTATION_TYPE_AXIS = "1" *) 
  (* C_IMPLEMENTATION_TYPE_RACH = "1" *) 
  (* C_IMPLEMENTATION_TYPE_RDCH = "1" *) 
  (* C_IMPLEMENTATION_TYPE_WACH = "1" *) 
  (* C_IMPLEMENTATION_TYPE_WDCH = "1" *) 
  (* C_IMPLEMENTATION_TYPE_WRCH = "1" *) 
  (* C_INIT_WR_PNTR_VAL = "0" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_MEMORY_TYPE = "2" *) 
  (* C_MIF_FILE_NAME = "BlankString" *) 
  (* C_MSGON_VAL = "1" *) 
  (* C_OPTIMIZATION_MODE = "0" *) 
  (* C_OVERFLOW_LOW = "0" *) 
  (* C_POWER_SAVING_MODE = "0" *) 
  (* C_PRELOAD_LATENCY = "1" *) 
  (* C_PRELOAD_REGS = "0" *) 
  (* C_PRIM_FIFO_TYPE = "512x36" *) 
  (* C_PRIM_FIFO_TYPE_AXIS = "1kx18" *) 
  (* C_PRIM_FIFO_TYPE_RACH = "512x36" *) 
  (* C_PRIM_FIFO_TYPE_RDCH = "1kx36" *) 
  (* C_PRIM_FIFO_TYPE_WACH = "512x36" *) 
  (* C_PRIM_FIFO_TYPE_WDCH = "1kx36" *) 
  (* C_PRIM_FIFO_TYPE_WRCH = "512x36" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL = "2" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_AXIS = "1022" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_RACH = "1022" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_RDCH = "1022" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_WACH = "1022" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_WDCH = "1022" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_WRCH = "1022" *) 
  (* C_PROG_EMPTY_THRESH_NEGATE_VAL = "3" *) 
  (* C_PROG_EMPTY_TYPE = "0" *) 
  (* C_PROG_EMPTY_TYPE_AXIS = "0" *) 
  (* C_PROG_EMPTY_TYPE_RACH = "0" *) 
  (* C_PROG_EMPTY_TYPE_RDCH = "0" *) 
  (* C_PROG_EMPTY_TYPE_WACH = "0" *) 
  (* C_PROG_EMPTY_TYPE_WDCH = "0" *) 
  (* C_PROG_EMPTY_TYPE_WRCH = "0" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL = "14" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_AXIS = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_RACH = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_RDCH = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_WACH = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_WDCH = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_WRCH = "1023" *) 
  (* C_PROG_FULL_THRESH_NEGATE_VAL = "13" *) 
  (* C_PROG_FULL_TYPE = "0" *) 
  (* C_PROG_FULL_TYPE_AXIS = "0" *) 
  (* C_PROG_FULL_TYPE_RACH = "0" *) 
  (* C_PROG_FULL_TYPE_RDCH = "0" *) 
  (* C_PROG_FULL_TYPE_WACH = "0" *) 
  (* C_PROG_FULL_TYPE_WDCH = "0" *) 
  (* C_PROG_FULL_TYPE_WRCH = "0" *) 
  (* C_RACH_TYPE = "0" *) 
  (* C_RDCH_TYPE = "0" *) 
  (* C_RD_DATA_COUNT_WIDTH = "4" *) 
  (* C_RD_DEPTH = "16" *) 
  (* C_RD_FREQ = "1" *) 
  (* C_RD_PNTR_WIDTH = "4" *) 
  (* C_REG_SLICE_MODE_AXIS = "0" *) 
  (* C_REG_SLICE_MODE_RACH = "0" *) 
  (* C_REG_SLICE_MODE_RDCH = "0" *) 
  (* C_REG_SLICE_MODE_WACH = "0" *) 
  (* C_REG_SLICE_MODE_WDCH = "0" *) 
  (* C_REG_SLICE_MODE_WRCH = "0" *) 
  (* C_SELECT_XPM = "0" *) 
  (* C_SYNCHRONIZER_STAGE = "2" *) 
  (* C_UNDERFLOW_LOW = "0" *) 
  (* C_USE_COMMON_OVERFLOW = "0" *) 
  (* C_USE_COMMON_UNDERFLOW = "0" *) 
  (* C_USE_DEFAULT_SETTINGS = "0" *) 
  (* C_USE_DOUT_RST = "1" *) 
  (* C_USE_ECC = "0" *) 
  (* C_USE_ECC_AXIS = "0" *) 
  (* C_USE_ECC_RACH = "0" *) 
  (* C_USE_ECC_RDCH = "0" *) 
  (* C_USE_ECC_WACH = "0" *) 
  (* C_USE_ECC_WDCH = "0" *) 
  (* C_USE_ECC_WRCH = "0" *) 
  (* C_USE_EMBEDDED_REG = "0" *) 
  (* C_USE_FIFO16_FLAGS = "0" *) 
  (* C_USE_FWFT_DATA_COUNT = "0" *) 
  (* C_USE_PIPELINE_REG = "0" *) 
  (* C_VALID_LOW = "0" *) 
  (* C_WACH_TYPE = "0" *) 
  (* C_WDCH_TYPE = "0" *) 
  (* C_WRCH_TYPE = "0" *) 
  (* C_WR_ACK_LOW = "0" *) 
  (* C_WR_DATA_COUNT_WIDTH = "4" *) 
  (* C_WR_DEPTH = "16" *) 
  (* C_WR_DEPTH_AXIS = "1024" *) 
  (* C_WR_DEPTH_RACH = "16" *) 
  (* C_WR_DEPTH_RDCH = "1024" *) 
  (* C_WR_DEPTH_WACH = "16" *) 
  (* C_WR_DEPTH_WDCH = "1024" *) 
  (* C_WR_DEPTH_WRCH = "16" *) 
  (* C_WR_FREQ = "1" *) 
  (* C_WR_PNTR_WIDTH = "4" *) 
  (* C_WR_PNTR_WIDTH_AXIS = "10" *) 
  (* C_WR_PNTR_WIDTH_RACH = "4" *) 
  (* C_WR_PNTR_WIDTH_RDCH = "10" *) 
  (* C_WR_PNTR_WIDTH_WACH = "4" *) 
  (* C_WR_PNTR_WIDTH_WDCH = "10" *) 
  (* C_WR_PNTR_WIDTH_WRCH = "4" *) 
  (* C_WR_RESPONSE_LATENCY = "1" *) 
  (* is_du_within_envelope = "true" *) 
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_fifo_generator_v13_2_7 U0
       (.almost_empty(NLW_U0_almost_empty_UNCONNECTED),
        .almost_full(NLW_U0_almost_full_UNCONNECTED),
        .axi_ar_data_count(NLW_U0_axi_ar_data_count_UNCONNECTED[4:0]),
        .axi_ar_dbiterr(NLW_U0_axi_ar_dbiterr_UNCONNECTED),
        .axi_ar_injectdbiterr(1'b0),
        .axi_ar_injectsbiterr(1'b0),
        .axi_ar_overflow(NLW_U0_axi_ar_overflow_UNCONNECTED),
        .axi_ar_prog_empty(NLW_U0_axi_ar_prog_empty_UNCONNECTED),
        .axi_ar_prog_empty_thresh({1'b0,1'b0,1'b0,1'b0}),
        .axi_ar_prog_full(NLW_U0_axi_ar_prog_full_UNCONNECTED),
        .axi_ar_prog_full_thresh({1'b0,1'b0,1'b0,1'b0}),
        .axi_ar_rd_data_count(NLW_U0_axi_ar_rd_data_count_UNCONNECTED[4:0]),
        .axi_ar_sbiterr(NLW_U0_axi_ar_sbiterr_UNCONNECTED),
        .axi_ar_underflow(NLW_U0_axi_ar_underflow_UNCONNECTED),
        .axi_ar_wr_data_count(NLW_U0_axi_ar_wr_data_count_UNCONNECTED[4:0]),
        .axi_aw_data_count(NLW_U0_axi_aw_data_count_UNCONNECTED[4:0]),
        .axi_aw_dbiterr(NLW_U0_axi_aw_dbiterr_UNCONNECTED),
        .axi_aw_injectdbiterr(1'b0),
        .axi_aw_injectsbiterr(1'b0),
        .axi_aw_overflow(NLW_U0_axi_aw_overflow_UNCONNECTED),
        .axi_aw_prog_empty(NLW_U0_axi_aw_prog_empty_UNCONNECTED),
        .axi_aw_prog_empty_thresh({1'b0,1'b0,1'b0,1'b0}),
        .axi_aw_prog_full(NLW_U0_axi_aw_prog_full_UNCONNECTED),
        .axi_aw_prog_full_thresh({1'b0,1'b0,1'b0,1'b0}),
        .axi_aw_rd_data_count(NLW_U0_axi_aw_rd_data_count_UNCONNECTED[4:0]),
        .axi_aw_sbiterr(NLW_U0_axi_aw_sbiterr_UNCONNECTED),
        .axi_aw_underflow(NLW_U0_axi_aw_underflow_UNCONNECTED),
        .axi_aw_wr_data_count(NLW_U0_axi_aw_wr_data_count_UNCONNECTED[4:0]),
        .axi_b_data_count(NLW_U0_axi_b_data_count_UNCONNECTED[4:0]),
        .axi_b_dbiterr(NLW_U0_axi_b_dbiterr_UNCONNECTED),
        .axi_b_injectdbiterr(1'b0),
        .axi_b_injectsbiterr(1'b0),
        .axi_b_overflow(NLW_U0_axi_b_overflow_UNCONNECTED),
        .axi_b_prog_empty(NLW_U0_axi_b_prog_empty_UNCONNECTED),
        .axi_b_prog_empty_thresh({1'b0,1'b0,1'b0,1'b0}),
        .axi_b_prog_full(NLW_U0_axi_b_prog_full_UNCONNECTED),
        .axi_b_prog_full_thresh({1'b0,1'b0,1'b0,1'b0}),
        .axi_b_rd_data_count(NLW_U0_axi_b_rd_data_count_UNCONNECTED[4:0]),
        .axi_b_sbiterr(NLW_U0_axi_b_sbiterr_UNCONNECTED),
        .axi_b_underflow(NLW_U0_axi_b_underflow_UNCONNECTED),
        .axi_b_wr_data_count(NLW_U0_axi_b_wr_data_count_UNCONNECTED[4:0]),
        .axi_r_data_count(NLW_U0_axi_r_data_count_UNCONNECTED[10:0]),
        .axi_r_dbiterr(NLW_U0_axi_r_dbiterr_UNCONNECTED),
        .axi_r_injectdbiterr(1'b0),
        .axi_r_injectsbiterr(1'b0),
        .axi_r_overflow(NLW_U0_axi_r_overflow_UNCONNECTED),
        .axi_r_prog_empty(NLW_U0_axi_r_prog_empty_UNCONNECTED),
        .axi_r_prog_empty_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .axi_r_prog_full(NLW_U0_axi_r_prog_full_UNCONNECTED),
        .axi_r_prog_full_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .axi_r_rd_data_count(NLW_U0_axi_r_rd_data_count_UNCONNECTED[10:0]),
        .axi_r_sbiterr(NLW_U0_axi_r_sbiterr_UNCONNECTED),
        .axi_r_underflow(NLW_U0_axi_r_underflow_UNCONNECTED),
        .axi_r_wr_data_count(NLW_U0_axi_r_wr_data_count_UNCONNECTED[10:0]),
        .axi_w_data_count(NLW_U0_axi_w_data_count_UNCONNECTED[10:0]),
        .axi_w_dbiterr(NLW_U0_axi_w_dbiterr_UNCONNECTED),
        .axi_w_injectdbiterr(1'b0),
        .axi_w_injectsbiterr(1'b0),
        .axi_w_overflow(NLW_U0_axi_w_overflow_UNCONNECTED),
        .axi_w_prog_empty(NLW_U0_axi_w_prog_empty_UNCONNECTED),
        .axi_w_prog_empty_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .axi_w_prog_full(NLW_U0_axi_w_prog_full_UNCONNECTED),
        .axi_w_prog_full_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .axi_w_rd_data_count(NLW_U0_axi_w_rd_data_count_UNCONNECTED[10:0]),
        .axi_w_sbiterr(NLW_U0_axi_w_sbiterr_UNCONNECTED),
        .axi_w_underflow(NLW_U0_axi_w_underflow_UNCONNECTED),
        .axi_w_wr_data_count(NLW_U0_axi_w_wr_data_count_UNCONNECTED[10:0]),
        .axis_data_count(NLW_U0_axis_data_count_UNCONNECTED[10:0]),
        .axis_dbiterr(NLW_U0_axis_dbiterr_UNCONNECTED),
        .axis_injectdbiterr(1'b0),
        .axis_injectsbiterr(1'b0),
        .axis_overflow(NLW_U0_axis_overflow_UNCONNECTED),
        .axis_prog_empty(NLW_U0_axis_prog_empty_UNCONNECTED),
        .axis_prog_empty_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .axis_prog_full(NLW_U0_axis_prog_full_UNCONNECTED),
        .axis_prog_full_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .axis_rd_data_count(NLW_U0_axis_rd_data_count_UNCONNECTED[10:0]),
        .axis_sbiterr(NLW_U0_axis_sbiterr_UNCONNECTED),
        .axis_underflow(NLW_U0_axis_underflow_UNCONNECTED),
        .axis_wr_data_count(NLW_U0_axis_wr_data_count_UNCONNECTED[10:0]),
        .backup(1'b0),
        .backup_marker(1'b0),
        .clk(clk),
        .data_count(NLW_U0_data_count_UNCONNECTED[3:0]),
        .dbiterr(NLW_U0_dbiterr_UNCONNECTED),
        .din(din),
        .dout(dout),
        .empty(empty),
        .full(full),
        .injectdbiterr(1'b0),
        .injectsbiterr(1'b0),
        .int_clk(1'b0),
        .m_aclk(1'b0),
        .m_aclk_en(1'b0),
        .m_axi_araddr(NLW_U0_m_axi_araddr_UNCONNECTED[31:0]),
        .m_axi_arburst(NLW_U0_m_axi_arburst_UNCONNECTED[1:0]),
        .m_axi_arcache(NLW_U0_m_axi_arcache_UNCONNECTED[3:0]),
        .m_axi_arid(NLW_U0_m_axi_arid_UNCONNECTED[0]),
        .m_axi_arlen(NLW_U0_m_axi_arlen_UNCONNECTED[7:0]),
        .m_axi_arlock(NLW_U0_m_axi_arlock_UNCONNECTED[0]),
        .m_axi_arprot(NLW_U0_m_axi_arprot_UNCONNECTED[2:0]),
        .m_axi_arqos(NLW_U0_m_axi_arqos_UNCONNECTED[3:0]),
        .m_axi_arready(1'b0),
        .m_axi_arregion(NLW_U0_m_axi_arregion_UNCONNECTED[3:0]),
        .m_axi_arsize(NLW_U0_m_axi_arsize_UNCONNECTED[2:0]),
        .m_axi_aruser(NLW_U0_m_axi_aruser_UNCONNECTED[0]),
        .m_axi_arvalid(NLW_U0_m_axi_arvalid_UNCONNECTED),
        .m_axi_awaddr(NLW_U0_m_axi_awaddr_UNCONNECTED[31:0]),
        .m_axi_awburst(NLW_U0_m_axi_awburst_UNCONNECTED[1:0]),
        .m_axi_awcache(NLW_U0_m_axi_awcache_UNCONNECTED[3:0]),
        .m_axi_awid(NLW_U0_m_axi_awid_UNCONNECTED[0]),
        .m_axi_awlen(NLW_U0_m_axi_awlen_UNCONNECTED[7:0]),
        .m_axi_awlock(NLW_U0_m_axi_awlock_UNCONNECTED[0]),
        .m_axi_awprot(NLW_U0_m_axi_awprot_UNCONNECTED[2:0]),
        .m_axi_awqos(NLW_U0_m_axi_awqos_UNCONNECTED[3:0]),
        .m_axi_awready(1'b0),
        .m_axi_awregion(NLW_U0_m_axi_awregion_UNCONNECTED[3:0]),
        .m_axi_awsize(NLW_U0_m_axi_awsize_UNCONNECTED[2:0]),
        .m_axi_awuser(NLW_U0_m_axi_awuser_UNCONNECTED[0]),
        .m_axi_awvalid(NLW_U0_m_axi_awvalid_UNCONNECTED),
        .m_axi_bid(1'b0),
        .m_axi_bready(NLW_U0_m_axi_bready_UNCONNECTED),
        .m_axi_bresp({1'b0,1'b0}),
        .m_axi_buser(1'b0),
        .m_axi_bvalid(1'b0),
        .m_axi_rdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .m_axi_rid(1'b0),
        .m_axi_rlast(1'b0),
        .m_axi_rready(NLW_U0_m_axi_rready_UNCONNECTED),
        .m_axi_rresp({1'b0,1'b0}),
        .m_axi_ruser(1'b0),
        .m_axi_rvalid(1'b0),
        .m_axi_wdata(NLW_U0_m_axi_wdata_UNCONNECTED[63:0]),
        .m_axi_wid(NLW_U0_m_axi_wid_UNCONNECTED[0]),
        .m_axi_wlast(NLW_U0_m_axi_wlast_UNCONNECTED),
        .m_axi_wready(1'b0),
        .m_axi_wstrb(NLW_U0_m_axi_wstrb_UNCONNECTED[7:0]),
        .m_axi_wuser(NLW_U0_m_axi_wuser_UNCONNECTED[0]),
        .m_axi_wvalid(NLW_U0_m_axi_wvalid_UNCONNECTED),
        .m_axis_tdata(NLW_U0_m_axis_tdata_UNCONNECTED[7:0]),
        .m_axis_tdest(NLW_U0_m_axis_tdest_UNCONNECTED[0]),
        .m_axis_tid(NLW_U0_m_axis_tid_UNCONNECTED[0]),
        .m_axis_tkeep(NLW_U0_m_axis_tkeep_UNCONNECTED[0]),
        .m_axis_tlast(NLW_U0_m_axis_tlast_UNCONNECTED),
        .m_axis_tready(1'b0),
        .m_axis_tstrb(NLW_U0_m_axis_tstrb_UNCONNECTED[0]),
        .m_axis_tuser(NLW_U0_m_axis_tuser_UNCONNECTED[3:0]),
        .m_axis_tvalid(NLW_U0_m_axis_tvalid_UNCONNECTED),
        .overflow(NLW_U0_overflow_UNCONNECTED),
        .prog_empty(NLW_U0_prog_empty_UNCONNECTED),
        .prog_empty_thresh({1'b0,1'b0,1'b0,1'b0}),
        .prog_empty_thresh_assert({1'b0,1'b0,1'b0,1'b0}),
        .prog_empty_thresh_negate({1'b0,1'b0,1'b0,1'b0}),
        .prog_full(NLW_U0_prog_full_UNCONNECTED),
        .prog_full_thresh({1'b0,1'b0,1'b0,1'b0}),
        .prog_full_thresh_assert({1'b0,1'b0,1'b0,1'b0}),
        .prog_full_thresh_negate({1'b0,1'b0,1'b0,1'b0}),
        .rd_clk(1'b0),
        .rd_data_count(NLW_U0_rd_data_count_UNCONNECTED[3:0]),
        .rd_en(rd_en),
        .rd_rst(1'b0),
        .rd_rst_busy(NLW_U0_rd_rst_busy_UNCONNECTED),
        .rst(1'b0),
        .s_aclk(1'b0),
        .s_aclk_en(1'b0),
        .s_aresetn(1'b0),
        .s_axi_araddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arburst({1'b0,1'b0}),
        .s_axi_arcache({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arid(1'b0),
        .s_axi_arlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arlock(1'b0),
        .s_axi_arprot({1'b0,1'b0,1'b0}),
        .s_axi_arqos({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arready(NLW_U0_s_axi_arready_UNCONNECTED),
        .s_axi_arregion({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arsize({1'b0,1'b0,1'b0}),
        .s_axi_aruser(1'b0),
        .s_axi_arvalid(1'b0),
        .s_axi_awaddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awburst({1'b0,1'b0}),
        .s_axi_awcache({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awid(1'b0),
        .s_axi_awlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awlock(1'b0),
        .s_axi_awprot({1'b0,1'b0,1'b0}),
        .s_axi_awqos({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awready(NLW_U0_s_axi_awready_UNCONNECTED),
        .s_axi_awregion({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awsize({1'b0,1'b0,1'b0}),
        .s_axi_awuser(1'b0),
        .s_axi_awvalid(1'b0),
        .s_axi_bid(NLW_U0_s_axi_bid_UNCONNECTED[0]),
        .s_axi_bready(1'b0),
        .s_axi_bresp(NLW_U0_s_axi_bresp_UNCONNECTED[1:0]),
        .s_axi_buser(NLW_U0_s_axi_buser_UNCONNECTED[0]),
        .s_axi_bvalid(NLW_U0_s_axi_bvalid_UNCONNECTED),
        .s_axi_rdata(NLW_U0_s_axi_rdata_UNCONNECTED[63:0]),
        .s_axi_rid(NLW_U0_s_axi_rid_UNCONNECTED[0]),
        .s_axi_rlast(NLW_U0_s_axi_rlast_UNCONNECTED),
        .s_axi_rready(1'b0),
        .s_axi_rresp(NLW_U0_s_axi_rresp_UNCONNECTED[1:0]),
        .s_axi_ruser(NLW_U0_s_axi_ruser_UNCONNECTED[0]),
        .s_axi_rvalid(NLW_U0_s_axi_rvalid_UNCONNECTED),
        .s_axi_wdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_wid(1'b0),
        .s_axi_wlast(1'b0),
        .s_axi_wready(NLW_U0_s_axi_wready_UNCONNECTED),
        .s_axi_wstrb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_wuser(1'b0),
        .s_axi_wvalid(1'b0),
        .s_axis_tdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axis_tdest(1'b0),
        .s_axis_tid(1'b0),
        .s_axis_tkeep(1'b0),
        .s_axis_tlast(1'b0),
        .s_axis_tready(NLW_U0_s_axis_tready_UNCONNECTED),
        .s_axis_tstrb(1'b0),
        .s_axis_tuser({1'b0,1'b0,1'b0,1'b0}),
        .s_axis_tvalid(1'b0),
        .sbiterr(NLW_U0_sbiterr_UNCONNECTED),
        .sleep(1'b0),
        .srst(srst),
        .underflow(NLW_U0_underflow_UNCONNECTED),
        .valid(NLW_U0_valid_UNCONNECTED),
        .wr_ack(NLW_U0_wr_ack_UNCONNECTED),
        .wr_clk(1'b0),
        .wr_data_count(NLW_U0_wr_data_count_UNCONNECTED[3:0]),
        .wr_en(wr_en),
        .wr_rst(1'b0),
        .wr_rst_busy(NLW_U0_wr_rst_busy_UNCONNECTED));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2022.2.2"
`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
Uus+5g3Fts6ofehbTlGvCWP47ZUO4Iguts10nwWKrrDCnmsKa0ECOFAy/6mqYixli8+MQiv36nW7
/i00MI/aOdL5Bnv7lIG8IKDhQU26Y0bwz+LQ8JdFuk+yoPzP3KSeDflyhZYqW+F1mMe76Z1rKxpm
NKBrJNbZx9pDDnUS99Q=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
MjhF8pcXDmDHbm3qaKwAoW7xraCAj9OKmQsxF9ez58Q1MBQmQ478ZxYQkHS7BgJ8jBjXuEVawhYE
RXXrl2Vh9LdUmrzHoIXf/7/0O8zwhvqGXZlBJvufZPjkW+kT2DV0zifiTSX/MtiLKEkjwrDOwdPw
eQ2VXS1M6bP+Fdv/EZtrQu+O6rr/z8rKbDnwlpS07oAAFNo9whhRhTyGODGiHXHvEt9aEmwggTe4
69Kzr3fkuDSbVmZuu9PSi/LMLdlx8wBbTY5dNNoD7dbmKs/lS8cyJHdH4o5HtFB3C+8TTd/+tS5n
wZBB2jesSLZ9tn0xfDf59P50VDr2XuQhTu0gtA==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
WgIQovaPdeSINbxJR137BKZONMNArLTTEi/M2ur2lEjx6z6OBuKH5q80CRzC4EYDDe6jUXzKWFDu
81B03qnuBmJaePVrwKDN5+8u99JrU5kQaFyFrQTWY2Z8nEt4zMvYeOHOve66lP+jPK2QItaVblAY
XbhtjP+k6pZCb/IRcRc=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
YD7Tl5QfW9Ui8DCiXtaE8D5ZIKMluUXQGhmoMiq6ZO2KSI9h6Ro9aoSFdKZWX6lCbhqBo9FUrcy0
uH7NQ9YbCY43K8tJE8tbFYzJxOmmHphtV7vSkjSl9HinJXduSqG5SfRjXhN7DUAlYw/QvHBhgUO3
YwZJso8yfud7CbV1HNEcwGwqXEwsGFdkE6bTiUhRnA9Sbof8jjC/qnZtL9qB3F7SHSONAp4yEUkt
t2zKOJsTQ1BbdYhkdSK4tU8C0hGDpCEl8foBaTj8wARxmwoB98XfsLW359Rc1/Cyo1FjSyA9yiYz
CJsstysstNZDK4UkQMreL/vFqi+PxPgf6cCd9w==

`pragma protect key_keyowner="Real Intent", key_keyname="RI-RSA-KEY-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
NDZIPYFfy5fHOyzo3Wvc+H6hGcMX/P2lLOQCrUCDKgWjBGN6qxCdHPt1E3UKOUWIisbvG/y2kR2e
lMxrLh2Am52VyNGgcKpQwnqw7eXa7+7xvN+Jo11Q1DRbu+NCAFEicO3kbrl48gTPAPhOW5LM7eA2
hZRbCh4SawXFUSOshB/ZJ9/ytC5fO0WCXXV6w0JjN5+rkDg401K4uq8xD4e84GVmnE5GUAfliRXm
W3urevu5NlqqRbGfuX0Yhf83nZnzIHe4PxFqnvtA7+BtSIGzgFiD8OqbV6+nRweKJRcdrx132aph
AoQtianVEl1M8EAP5CNzJAUfMvkkhMRU2x+WtA==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2021_07", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
ttaeY1lqndtl71pfmwuj1l1gkilLl3f5JV8o3KrBbi/MoHNXAw51rhKtwIQN5JMGkXNAq1kZyGmw
wfnBzWYlAxQE++8sDBT/lxMFxwK9TLDRjMA2veyUqZekotMyLr6d5jf7DgLHCM2cXo9TziodEX6R
o0vGAZjsBlNys+6jGfJbtdV8SCuAlc0I4z9p0boiUCidiK/avjWoktlxrQf1L9g1LZYdk1aRWr/r
hRVHSNpbPLPKSgbHsx6noNv3dgB2mfhn9jhmlmYxV7N5L+d1aoG4VKoY8gUkgypD0PthTdXpweFl
EObdkZWgp0s91R37yUiGaMhImifGXLT2TmvWcg==

`pragma protect key_keyowner="Metrics Technologies Inc.", key_keyname="DSim", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Xjh/r+uTIFLK1SUOPho9ZPs/oSNalRX+tpCee/BF80wWUXHxPNNIFfPbhrb5Ppm3iEtrNdI5DLRI
0tjaQNPbzdLVasl11GmsykNWzFFsvFxpFj7FYoGMg9QXQ+eT+V0zHbYMSapoSEKGOkdAC/UB8Cys
JxI58H0p8bLI3k0lZp9bTmnvhQqPdYGwLQCb2WsrplhqUtEumZjMcDjl4805ti1AZn5/ADeauued
Yo1NJOUajSC26cFNfwkugV4pVY67Lxk4tZPvHKNbu/qlVhdtJswY4bWKFxZutnAnXmo8S5nFwwEV
JNXYgpVDS07Cue7sbfuxNcNJFvsj6AwVEYNUNw==

`pragma protect key_keyowner="Atrenta", key_keyname="ATR-SG-RSA-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=384)
`pragma protect key_block
HsJKFyC7O8ipZYjpbPgzgOY1jcqskM/gO40stsMiM1axRuoFUxObJUt2hfCUSRNCPGcNO1F/k5sQ
YRkxxGWGkipZ+SNKhaOeg1KPWPOyKulujFtq1r64yeL9JT24FMoPBllBlpowEJW2rhYR8ZlWfZra
FfoGFR0l2YzhaeCfNwxUC4ipvZ64nViLxOqoX5r82UyusSDrPfqHu+sw2dmI0qIOe6Krpjgb0kvl
O+UFZqiv9YUgV0mrWsCOYt7y+jtTQJXRkUax3IbEk2EjOoMmQYwXf+x+Fay+Ed2L1weAiKUhgcqj
r7Y9moK51yRXg5LeoQCkNYG50Aw14aC0/I6frAQLjU6fip4iHHXe2RdL0v2xKvLh4X9buAKWic0X
mzA6XFlqEIlNKwo55UbQkTtkWgLwJxeydfCgAOeffrK6Ls2/4a2oneFZbKMNXe9GU4B8AZBZqhla
9MIcb3bCI75UlkW5iI5SB8R/eT/qvrL3yo+JpH6QS7RRXQVgEkwcPrz7

`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="CDS_RSA_KEY_VER_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
XhWAwLXQiQzRNHMj075cYascgsaaVmImnIfShSSdw3P5BkCWWmhosk5iLRi/nFtxUTXJuO2ST73Z
EuKgr6/PAqe2+AN48tbN2MKOLx+RKrgqzckIqKWA2gp974Fs/VXaPvr2TnlZ3QkOXqFYvx5UcOI0
PDcRse59FDAYbBIPtS2sw0//yQyHEoKf+D2tIvVNwHyXylR2Oko+g07H/jX5+xx/yuQg29ctBI/m
8vhIbJMnPIEs6AaWbll/KI4pfVEV2TE36xgAWxtyWcx/O9wCJzzri4VIQ/WuagIWoydOMKPISdih
IpmPuVDzuPwInDZfBse7K5fixLpWr1DmvJx7cg==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
sCbhosRvV5loCfp2CX5UW6G9dA98Fobzy39VERO4hPN82wRKr7i0hyc2W9kSdV3tifArfeuGK+hN
e9a6qR3mx5a2IrDDjAcEtVchIDpVVJLANzyh7qwTqBXDW/QRSPi3F5pA/YLWK9hePfmya4/jccvE
uKl38Z9x0Ag/YCb6H5BQKuS6O0s383I+FSzOTS0Sxpu+7L3Yr5kP8prRGIP1qD6zMgG6uKJj3HF9
omstvh1F3q5YMgScMd7v1MZWsZELgUQDktPhSt7HUUHogq2aZQYl7x3riganBKoQKZ13A9Iex2ky
qTF3cIrtAz6ZLK4ND+RBseQdbcm7l6h5GALeCg==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-PREC-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
P9Ji+GKT738MP7o8TaU+mDFK4pwND49sGVKlSEKVKYxfXQEpCgR3QoVlcWyNhPWFVCBRkAYfaXDX
w0WOnd+KAWMuSDiTgtIpjKHzomg6DvwzJONdE94jHt48fL/q3itgN6pxVY7sU6Bo7xJ0oFjBhGEx
7AY1YLKCoR95jGRnMi1K/OcvN2r3aLyVD4CZBm6xRydif1UrumV6WgSEP7wrQo64lc2+HShIad9x
RbARl/mCcH9mF8W1q5/Gp1LU3RiCnqrMA3tnN2mL3BLWKWJ3bHPQIGFb+eKzCFcksrNNuZW9I+F/
N+Q2f3PL3cVGpFzWMzIBCYLuA6RWNCw/62lOhw==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 55744)
`pragma protect data_block
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
`pragma protect end_protected
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
