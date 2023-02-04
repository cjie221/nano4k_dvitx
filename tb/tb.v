//---------------------------------------------------------------------
// File name  : tb.v
// Module name: tb
// Created by : 
// ---------------------------------------------------------------------
// Release history
// ----------------------------------------------------------------------------------
// Ver:    |  Author    | Mod. Date    | Changes Made:
// ----------------------------------------------------------------------------------
// V1.0    | Caojie     | 07/17/19     | Initial version 
// ----------------------------------------------------------------------------------

`timescale 1ns / 1ps

module tb();

//========================================================
//parameters
parameter BMP_VIDEO_FORMAT		   = "WxH_xHz"; //video format
parameter BMP_SERIAL_CLK_PERIOD	   = 2.694; //unit: ns
parameter BMP_PIXEL_CLK_PERIOD	   = BMP_SERIAL_CLK_PERIOD*5; //unit: ns
parameter BMP_PIXEL_CLK_FREQ	   = 1000.0/BMP_PIXEL_CLK_PERIOD;//pixel clock frequency, unit: MHz
parameter BMP_WIDTH				   = 160;
parameter BMP_HEIGHT			   = 120;
parameter BMP_OPENED_NAME		   = "../../tb/pic/img160.bmp";
parameter BMP_REPEAT			   = 1'b1;  //0:bmp increase  , 1:bmp repeat 
parameter BMP_LINK				   = 1'b0;  //0:单像素；1:双像素
								   
parameter BMP_OUTPUTED_WIDTH	   = BMP_WIDTH;
parameter BMP_OUTPUTED_HEIGHT	   = BMP_HEIGHT;
parameter BMP_OUTPUTED_NAME		   = "../../tb/pic/out0_001.bmp";
parameter BMP_OUTPUTED_NUMBER	   = 16'd3;

//=======================================================
reg  serial_clk;  //x5
wire pixel_clock; //x1

reg  rst_n;

//------------
//dirver
wire	   vsync; 
wire	   hsync; 
wire	   data_valid; 
wire [7:0] data0_r; 
wire [7:0] data0_g;
wire [7:0] data0_b;

//--------------------------
wire 	   tmds_clk_p  ;
wire 	   tmds_clk_n  ;
wire [2:0] tmds_data_p ;//{r,g,b}
wire [2:0] tmds_data_n ;

//-------------------------
wire        rx0_pclk   ;
wire        rx0_vsync  ;
wire        rx0_hsync  ;
wire        rx0_de     ;
wire [7:0]  rx0_r      ; 
wire [7:0]  rx0_g      ; 
wire [7:0]  rx0_b      ; 

//-----------------
//monitor rgb input
wire		m_clk;
wire		m_vs_rgb;  
wire		m_hs_rgb;  
wire		m_de_rgb;  
wire [7:0]  m_data0_r;
wire [7:0]  m_data0_g;
wire [7:0]  m_data0_b;
wire [7:0]  m_data1_r;
wire [7:0]  m_data1_g;
wire [7:0]  m_data1_b;

//=====================================================
GSR GSR(.GSRI(1'b1));

//==============================================  
initial begin
  $fsdbDumpfile("tb.fsdb");
  $fsdbDumpvars;
end

//=====================================================
//clk
initial
  begin
	serial_clk	     = 1'b0;
  end

always  #(BMP_SERIAL_CLK_PERIOD/2.0) serial_clk = ~serial_clk;


//=====================================================
//rst_n
initial
  begin
	rst_n=1'b0;
	
	#2000;
	rst_n=1'b1;
end

//==================================================
//video driver
driver #
(
	.BMP_VIDEO_FORMAT	(BMP_VIDEO_FORMAT   ),
	.BMP_PIXEL_CLK_FREQ (BMP_PIXEL_CLK_FREQ ),
	.BMP_WIDTH		    (BMP_WIDTH	        ),
	.BMP_HEIGHT		    (BMP_HEIGHT	        ),
	.BMP_OPENED_NAME	(BMP_OPENED_NAME    )
)
driver_inst
(
	.link_i	       (BMP_LINK   ), //0,单像素；1，双像素
	.repeat_en     (BMP_REPEAT ),
	.video_gen_en  (rst_n 	   ),
	.pixel_clock   (pixel_clock),
	.vsync	       (vsync	   ),//负极性 
	.hsync	       (hsync	   ),//负极性 
	.data_valid    (data_valid ),
	.data0_r       (data0_r	   ), 
	.data0_g       (data0_g	   ),
	.data0_b       (data0_b	   ), 
	.data1_r       (     	   ), 
	.data1_g       (     	   ),
	.data1_b       (     	   )
);

//======================================================
//RGB to DVI
CLKDIV u_clkdiv
(.RESETN(rst_n)
,.HCLKIN(serial_clk) //clk  x5
,.CLKOUT(pixel_clock)//clk  x1
,.CALIB (1'b1)
);
defparam u_clkdiv.DIV_MODE="5";
defparam u_clkdiv.GSREN="false";

DVI_TX_Top DVI_TX_Top_inst
(
	.I_rst_n       (rst_n         ),   //asynchronous reset, low active
	.I_serial_clk  (serial_clk    ),
	.I_rgb_clk     (pixel_clock   ),   //pixel clock
	.I_rgb_vs      (vsync         ),  
	.I_rgb_hs      (hsync         ),        
	.I_rgb_de      (data_valid    ), 
	.I_rgb_r       (data0_r       ),  
	.I_rgb_g       (data0_g       ),  
	.I_rgb_b       (data0_b       ), 
	.O_tmds_clk_p  (tmds_clk_p    ),
	.O_tmds_clk_n  (tmds_clk_n    ),
	.O_tmds_data_p (tmds_data_p   ),  //{r,g,b}
	.O_tmds_data_n (tmds_data_n   )
);

//======================================================
//DVI to RGB  
DVI_RX_Top DVI_RX_Top_inst
(
	.I_rst_n         (rst_n         ),// active low 
	.I_tmds_clk_p    (tmds_clk_p    ),  
	.I_tmds_clk_n    (tmds_clk_n    ),  
	.I_tmds_data_p   (tmds_data_p   ),  //{r,g,b}
	.I_tmds_data_n   (tmds_data_n   ),
    .O_pll_phase     (              ), 
	.O_pll_phase_lock(              ),    
	.O_rgb_clk       (rx0_pclk      ),
	.O_rgb_vs        (rx0_vsync     ),
	.O_rgb_hs        (rx0_hsync     ),
	.O_rgb_de        (rx0_de        ),
	.O_rgb_r         (rx0_r         ),
	.O_rgb_g         (rx0_g         ),
	.O_rgb_b         (rx0_b         )
);

//======================================================
//monitor
assign m_clk     = rx0_pclk       ;
assign m_vs_rgb  = rx0_vsync      ;
assign m_hs_rgb  = rx0_hsync      ;
assign m_de_rgb  = rx0_de         ;
assign m_data0_r = rx0_r          ;
assign m_data0_g = rx0_g          ;
assign m_data0_b = rx0_b          ;
assign m_data1_r = 8'd0           ;
assign m_data1_g = 8'd0           ;
assign m_data1_b = 8'd0           ;

monitor#
(
  .BMP_OUTPUTED_WIDTH  (BMP_OUTPUTED_WIDTH ),
  .BMP_OUTPUTED_HEIGHT (BMP_OUTPUTED_HEIGHT),
  .BMP_OUTPUTED_NAME   (BMP_OUTPUTED_NAME  ),
  .BMP_OUTPUTED_NUMBER (BMP_OUTPUTED_NUMBER)
)
monitor_inst
(
  .link_i	    (BMP_LINK	), //0,单像素；1，双像素
  .video2bmp_en (rst_n		),
  .pixel_clock  (m_clk		), 
  .vsync		(m_vs_rgb	), //负极性	   
  .hsync		(m_hs_rgb	), //负极性	   
  .data_valid   (m_de_rgb	), 
  .data0_r	    (m_data0_r	),	
  .data0_g	    (m_data0_g	),
  .data0_b	    (m_data0_b	),
  .data1_r	    (m_data1_r	),	
  .data1_g	    (m_data1_g	),
  .data1_b	    (m_data1_b	)
);
		  
endmodule
