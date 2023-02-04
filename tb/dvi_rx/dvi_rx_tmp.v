//Copyright (C)2014-2022 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//GOWIN Version: GowinSynthesis V1.9.8.10
//Part Number: GW1NSR-LV4CQN48PC7/I6
//Device: GW1NSR-4C
//Created Time: Sun Jan 29 19:05:21 2023

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

	DVI_RX_Top your_instance_name(
		.I_rst_n(I_rst_n_i), //input I_rst_n
		.I_tmds_clk_p(I_tmds_clk_p_i), //input I_tmds_clk_p
		.I_tmds_clk_n(I_tmds_clk_n_i), //input I_tmds_clk_n
		.I_tmds_data_p(I_tmds_data_p_i), //input [2:0] I_tmds_data_p
		.I_tmds_data_n(I_tmds_data_n_i), //input [2:0] I_tmds_data_n
		.O_pll_phase(O_pll_phase_o), //output [3:0] O_pll_phase
		.O_pll_phase_lock(O_pll_phase_lock_o), //output O_pll_phase_lock
		.O_rgb_clk(O_rgb_clk_o), //output O_rgb_clk
		.O_rgb_vs(O_rgb_vs_o), //output O_rgb_vs
		.O_rgb_hs(O_rgb_hs_o), //output O_rgb_hs
		.O_rgb_de(O_rgb_de_o), //output O_rgb_de
		.O_rgb_r(O_rgb_r_o), //output [7:0] O_rgb_r
		.O_rgb_g(O_rgb_g_o), //output [7:0] O_rgb_g
		.O_rgb_b(O_rgb_b_o) //output [7:0] O_rgb_b
	);

//--------Copy end-------------------
