vlib work
vlib activehdl

vlib activehdl/xpm
vlib activehdl/xil_defaultlib

vmap xpm activehdl/xpm
vmap xil_defaultlib activehdl/xil_defaultlib

vlog -work xpm  -sv2k12 \
"D:/software/Vivado/2022.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"D:/software/Vivado/2022.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93  \
"D:/software/Vivado/2022.2/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib  -v2k5 \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/clocking/mig_7series_v4_2_clk_ibuf.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/clocking/mig_7series_v4_2_infrastructure.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/clocking/mig_7series_v4_2_iodelay_ctrl.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/clocking/mig_7series_v4_2_tempmon.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/controller/mig_7series_v4_2_arb_mux.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/controller/mig_7series_v4_2_arb_row_col.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/controller/mig_7series_v4_2_arb_select.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/controller/mig_7series_v4_2_bank_cntrl.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/controller/mig_7series_v4_2_bank_common.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/controller/mig_7series_v4_2_bank_compare.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/controller/mig_7series_v4_2_bank_mach.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/controller/mig_7series_v4_2_bank_queue.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/controller/mig_7series_v4_2_bank_state.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/controller/mig_7series_v4_2_col_mach.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/controller/mig_7series_v4_2_mc.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/controller/mig_7series_v4_2_rank_cntrl.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/controller/mig_7series_v4_2_rank_common.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/controller/mig_7series_v4_2_rank_mach.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/controller/mig_7series_v4_2_round_robin_arb.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/ecc/mig_7series_v4_2_ecc_buf.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/ecc/mig_7series_v4_2_ecc_dec_fix.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/ecc/mig_7series_v4_2_ecc_gen.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/ecc/mig_7series_v4_2_ecc_merge_enc.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/ecc/mig_7series_v4_2_fi_xor.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/ip_top/mig_7series_v4_2_memc_ui_top_std.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/ip_top/mig_7series_v4_2_mem_intfc.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/phy/mig_7series_v4_2_ddr_byte_group_io.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/phy/mig_7series_v4_2_ddr_byte_lane.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/phy/mig_7series_v4_2_ddr_calib_top.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/phy/mig_7series_v4_2_ddr_if_post_fifo.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/phy/mig_7series_v4_2_ddr_mc_phy.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/phy/mig_7series_v4_2_ddr_mc_phy_wrapper.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/phy/mig_7series_v4_2_ddr_of_pre_fifo.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_4lanes.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_ck_addr_cmd_delay.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_dqs_found_cal.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_dqs_found_cal_hr.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_init.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_ocd_cntlr.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_ocd_data.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_ocd_edge.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_ocd_lim.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_ocd_mux.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_ocd_po_cntlr.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_ocd_samp.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_oclkdelay_cal.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_prbs_rdlvl.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_rdlvl.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_tempmon.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_top.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_wrcal.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_wrlvl.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_wrlvl_off_delay.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/phy/mig_7series_v4_2_ddr_prbs_gen.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/phy/mig_7series_v4_2_poc_cc.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/phy/mig_7series_v4_2_poc_edge_store.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/phy/mig_7series_v4_2_poc_meta.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/phy/mig_7series_v4_2_poc_pd.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/phy/mig_7series_v4_2_poc_tap_base.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/phy/mig_7series_v4_2_poc_top.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/ui/mig_7series_v4_2_ui_cmd.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/ui/mig_7series_v4_2_ui_rd_data.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/ui/mig_7series_v4_2_ui_top.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/ui/mig_7series_v4_2_ui_wr_data.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/mig_mig_sim.v" \
"../../../../0528.gen/sources_1/ip/mig/mig/user_design/rtl/mig.v" \

vlog -work xil_defaultlib \
"glbl.v"

