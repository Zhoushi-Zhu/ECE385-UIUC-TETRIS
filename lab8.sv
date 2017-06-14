//-------------------------------------------------------------------------
//      lab7_usb.sv                                                      --
//      Christine Chen                                                   --
//      Fall 2014                                                        --
//                                                                       --
//      Fall 2014 Distribution                                           --
//                                                                       --
//      For use with ECE 385 Lab 7                                       --
//      UIUC ECE Department                                              --
//-------------------------------------------------------------------------


module lab8( input               CLOCK_50,
             input        [3:0]  KEY,          //bit 0 is set up as Reset
             output logic [6:0]  HEX0, HEX1,
             // VGA Interface 
             output logic [7:0]  VGA_R,        //VGA Red
                                 VGA_G,        //VGA Green
                                 VGA_B,        //VGA Blue
             output logic        VGA_CLK,      //VGA Clock
                                 VGA_SYNC_N,   //VGA Sync signal
                                 VGA_BLANK_N,  //VGA Blank signal
                                 VGA_VS,       //VGA virtical sync signal
                                 VGA_HS,       //VGA horizontal sync signal
             // CY7C67200 Interface
             inout  wire  [15:0] OTG_DATA,     //CY7C67200 Data bus 16 Bits
             output logic [1:0]  OTG_ADDR,     //CY7C67200 Address 2 Bits
             output logic        OTG_CS_N,     //CY7C67200 Chip Select
                                 OTG_RD_N,     //CY7C67200 Write
                                 OTG_WR_N,     //CY7C67200 Read
                                 OTG_RST_N,    //CY7C67200 Reset
             input               OTG_INT,      //CY7C67200 Interrupt
             // SDRAM Interface for Nios II Software
             output logic [12:0] DRAM_ADDR,    //SDRAM Address 13 Bits
             inout  wire  [31:0] DRAM_DQ,      //SDRAM Data 32 Bits
             output logic [1:0]  DRAM_BA,      //SDRAM Bank Address 2 Bits
             output logic [3:0]  DRAM_DQM,     //SDRAM Data Mast 4 Bits
             output logic        DRAM_RAS_N,   //SDRAM Row Address Strobe
                                 DRAM_CAS_N,   //SDRAM Column Address Strobe
                                 DRAM_CKE,     //SDRAM Clock Enable
                                 DRAM_WE_N,    //SDRAM Write Enable
                                 DRAM_CS_N,    //SDRAM Chip Select
                                 DRAM_CLK      //SDRAM Clock
                    );
    
    logic Reset_h, Clk;
    logic [15:0] keycode;
    
    assign Clk = CLOCK_50;
    assign {Reset_h} = ~(KEY[0]);  // The push buttons are active low
    
    logic [1:0] hpi_addr;
    logic [15:0] hpi_data_in, hpi_data_out;
    logic hpi_r, hpi_w,hpi_cs;
    
    // Interface between NIOS II and EZ-OTG chip
    hpi_io_intf hpi_io_inst(
                            .Clk(Clk),
                            .Reset(Reset_h),
                            // signals connected to NIOS II
                            .from_sw_address(hpi_addr),
                            .from_sw_data_in(hpi_data_in),
                            .from_sw_data_out(hpi_data_out),
                            .from_sw_r(hpi_r),
                            .from_sw_w(hpi_w),
                            .from_sw_cs(hpi_cs),
                            // signals connected to EZ-OTG chip
                            .OTG_DATA(OTG_DATA),    
                            .OTG_ADDR(OTG_ADDR),    
                            .OTG_RD_N(OTG_RD_N),    
                            .OTG_WR_N(OTG_WR_N),    
                            .OTG_CS_N(OTG_CS_N),    
                            .OTG_RST_N(OTG_RST_N)
    );
     
     //The connections for nios_system might be named different depending on how you set up Qsys
     nios_system nios_system(
                             .clk_clk(Clk),         
                             .reset_reset_n(KEY[0]),   
                             .sdram_wire_addr(DRAM_ADDR), 
                             .sdram_wire_ba(DRAM_BA),   
                             .sdram_wire_cas_n(DRAM_CAS_N),
                             .sdram_wire_cke(DRAM_CKE),  
                             .sdram_wire_cs_n(DRAM_CS_N), 
                             .sdram_wire_dq(DRAM_DQ),   
                             .sdram_wire_dqm(DRAM_DQM),  
                             .sdram_wire_ras_n(DRAM_RAS_N),
                             .sdram_wire_we_n(DRAM_WE_N), 
                             .sdram_out_clk(DRAM_CLK),
                             .keycode_export(keycode),  
                             .otg_hpi_address_export(hpi_addr),
                             .otg_hpi_data_in_port(hpi_data_in),
                             .otg_hpi_data_out_port(hpi_data_out),
                             .otg_hpi_cs_export(hpi_cs),
                             .otg_hpi_r_export(hpi_r),
                             .otg_hpi_w_export(hpi_w),
									  .random_needed_external_connection_export(to_sw_sig),
									  .random_number_external_connection_export(next_shape),
									  .random_ready_external_connection_export(from_sw_sig)
    );
    
    //Fill in the connections for the rest of the modules 
	 logic [9:0] DrawX, DrawY;
	 logic [5:0] x1_out,x2_out,x3_out,x4_out,y1_out,y2_out,y3_out,y4_out;
	 logic [11:0] output_coord [21:0];
	 logic [2:0] output_color [21:0][11:0];
	 logic [3:0] next_coord [2:0];
	 logic [2:0] next_color [2:0][3:0];
	 logic up, down, left, right, pause, print_pause, resume, enter, print_title;
	 logic [2:0]active_shape;
	 logic Reset_Ball;
	assign Reset_Ball = ~KEY[3];
	 logic print_over;
	 logic [7:0] score, best_score;
	 logic [3:0] num2, num3, num4, best2, best3, best4;
	 logic [2:0] next_shape;
	 logic to_sw_sig;
	 logic from_sw_sig;
	 //assign next_shape = 3'b001;
	 
	 binary_to_bcd btd(.binary(score), .h(num2), .t(num3), .o(num4));
	 binary_to_bcd btd2(.binary(best_score), .h(best2), .t(best3), .o(best4));
	 
	 
	 blocklogic thelogic(.*, .frameClk(VGA_VS), .Reset(Reset_Ball));
	 
	 
    VGA_controller vga_controller_instance(.Clk(Clk), 
														 .Reset(Reset_h), 
														 .VGA_VS(VGA_VS), 
														 .VGA_HS(VGA_HS), 
														 .VGA_CLK(VGA_CLK), 
														 .VGA_BLANK_N(VGA_BLANK_N), 
														 .VGA_SYNC_N(VGA_SYNC_N), 
														 .DrawX(DrawX), 
														 .DrawY(DrawY));
   
   /*	ball ball_instance(.keycode(keycode),
							  .frame_clk(VGA_VS), 
							  .Reset(Reset_h|Reset_Ball), 
							  .BallX(BallX), 
							  .BallY(BallY), 
							  .BallS(BallS));*/
    
    color_mapper color_instance(.Clk(VGA_CLK), .x1(x1_out), .x2(x2_out), .x3(x3_out), .x4(x4_out), .y1(y1_out), .y2(y2_out), .y3(y3_out), .y4(y4_out), .num1(4'd0), .best1(4'd0),
										  .*,
										  .VGA_R(VGA_R),
										  .VGA_G(VGA_G),
										  .VGA_B(VGA_B));
    
    HexDriver hex_inst_0 (score[3:0], HEX0);
    HexDriver hex_inst_1 (score[7:4], HEX1);
	 
	 keycode_reader the_reader(.*);
    
    /**************************************************************************************
        ATTENTION! Please answer the following quesiton in your lab report! Points will be allocated for the answers!
        Hidden Question #1/2:
        What are the advantages and/or disadvantages of using a USB interface over PS/2 interface to
             connect to the keyboard? List any two.  Give an answer in your Post-Lab.
    **************************************************************************************/
endmodule
