set_property SRC_FILE_INFO {cfile:d:/iCloudDrive/course/EE332/lab/final/code/0528/cam2hdmi.gen/sources_1/ip/mmcm/mmcm.xdc rfile:../../../cam2hdmi.gen/sources_1/ip/mmcm/mmcm.xdc id:1 order:EARLY scoped_inst:inst} [current_design]
current_instance inst
set_property src_info {type:SCOPED_XDC file:1 line:57 export:INPUT save:INPUT read:READ} [current_design]
set_input_jitter [get_clocks -of_objects [get_ports ui_clk]] 0.100
