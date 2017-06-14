//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  03-03-2017                               --
//                                                                       --
//    Spring 2017 Distribution                                           --
//                                                                       --
//    For use with ECE 385 Lab 7                                         --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------


module  color_mapper ( input        Clk,
							  input        [5:0] x1,x2,x3,x4,y1,y2,y3,y4,
							  input   		[9:0] DrawX, DrawY,       // Coordinates of current drawing pixel       // Ball coordinates
                       input        [11:0] output_coord [21:0],
							  input 			[2:0] output_color [21:0][11:0],
							  input 			[2:0] active_shape,
							  input 			[2:0] next_shape,
                       output logic [7:0] VGA_R, VGA_G, VGA_B, // VGA RGB output
							  input logic [3:0] next_coord [2:0],
							  input logic [2:0] next_color [2:0][3:0],
							  input logic        print_pause,
							  input logic        print_over, print_title,
							  input logic [3:0] num1, num2, num3, num4,
							  input logic [3:0] best1, best2, best3, best4
                     );
    
    
    //logic ball_on;
    logic [7:0] Red, Green, Blue;
	 logic in_range, in_state, in_next, in_title, in_score, in_num, in_enter, in_frame, in_best, in_word;
	 logic [18:0] address;
	 logic [18:0] next_address;
	 logic [5:0] Xadd, Yadd, Xnext, Ynext;
	 assign Xadd = (DrawX - Xstart) % 20;
	 assign Yadd = (DrawY - Ystart) % 20;
	 assign address = Xadd + 20 * Yadd;
	 assign Xnext = (DrawX - nextXstart) % 20;
	 assign Ynext = (DrawY - nextYstart) % 20;
	 assign next_address = Xnext + 20 * Ynext;
	 logic [23:0] color_from_mem;
	 logic [23:0] next_color_from_mem;
	 
	 frameROM next_rom(.Clk, .read_address(next_address), .data_Out(next_color_from_mem));
	 frameROM tetris_block(.Clk, .read_address(address), .data_Out(color_from_mem));
	 font_rom_tetris tetrisfonts(.addr(tetris_addr), .data(tetris_row));
	 font_rom_enter enterfonts(.addr(enter_addr), .data(enter_row));
	 font_rom_state statefonts(.addr(state_addr), .data(state_row));
	 font_rom_score scorefonts(.addr(score_addr), .data(score_row));
	 font_rom_num numfonts1(.addr(num_addr), .data(num_row));
	 font_rom_num bestfonts1(.addr(best_addr), .data(best_row));
	 font_rom_score bestfonts2(.addr(word_addr), .data(word_row));
    
	 logic [5:0] tetris_addr;
	 logic [7:0] tetris_row;
	 assign tetris_addr = titleCount * 10 + Ytitle/4;
	 
	 
	 logic [7:0] enter_addr;
	 logic [7:0] enter_row;
	 assign enter_addr = enterCount * 10 + Yenter/3;
	 
	 logic [5:0] state_addr;
	 logic [15:0] state_row;
	 assign state_addr = stateCount * 16 + Ystate/4;
	 
	 logic [5:0] score_addr;
	 logic [7:0] score_row;
	 assign score_addr = scoreCount * 10 + Yscore/2;
	 
	 logic [5:0] word_addr;
	 logic [7:0] word_row;
	 assign word_addr = wordCount * 10 + Yword/2;
	 
	 logic [6:0] num_addr;
	 logic [7:0] num_row;
	 assign numCount = (DrawX - numXstart)/16;
	 always_comb begin
			unique case (numCount)
					2'b00:begin
						num_addr = num1 * 10 + Ynum/2;
					end
					2'b01:begin
						num_addr = num2 * 10 + Ynum/2;
					end
					2'b10:begin
						num_addr = num3 * 10 + Ynum/2;
					end
					2'b11:begin
						num_addr = num4 * 10 + Ynum/2;
					end
			endcase
		
	end
	
	
	 logic [6:0] best_addr;
	 logic [7:0] best_row;
	 assign bestCount = (DrawX - bestXstart)/16;
	 always_comb begin
			unique case (bestCount)
					2'b00:begin
						best_addr = best1 * 10 + Ybest/2;
					end
					2'b01:begin
						best_addr = best2 * 10 + Ybest/2;
					end
					2'b10:begin
						best_addr = best3 * 10 + Ybest/2;
					end
					2'b11:begin
						best_addr = best4 * 10 + Ybest/2;
					end
			endcase
		
	end
	 
	  /* The ball's (pixelated) circle is generated using the standard circle formula.  Note that while 
    the single line is quite powerful descriptively, it causes the synthesis tool to use up three
    of the 12 available multipliers on the chip! Since the multiplicants are required to be signed,
    we have to first cast them from logic to int (signed by default) before they are multiplied. */
      
    /*int DistX, DistY, Size;
    assign DistX = DrawX - BallX;
    assign DistY = DrawY - BallY;
    assign Size = BallS;*/
	 
	 int Xstart, Ystart, Xend, Yend;
	 int Xreal, Yreal, Xtitle, Ytitle, Xscore, Yscore, Xstate, Ystate, Xenter, Yenter, Xnum, Ynum, nextXreal, nextYreal, bestX, bestY;
	 
	
	 logic [2:0] titleCount;
	 logic [4:0] enterCount;
	 logic [1:0] stateCount;
	 logic [3:0] scoreCount;
	 logic [1:0] numCount;
	 logic [1:0] bestCount;
	 logic [2:0] wordCount;
	 int stateXstart, stateYstart, stateXend, stateYend;
	 int nextXstart, nextYstart, nextXend, nextYend;
	 int titleXstart, titleYstart, titleXend, titleYend;
	 int scoreXstart, scoreYstart, scoreXend, scoreYend;
	 int numXstart, numYstart, numXend, numYend;
	 int enterXstart, enterYstart, enterXend, enterYend;
	 int frameXstart, frameYstart, frameXend, frameYend;
	 int bestXstart, bestYstart, bestXend, bestYend;
	 int wordXstart, wordYstart, wordXend, wordYend;
	 
	 assign Xstart = 300;
	 assign Xend = 500;
	 assign Ystart = 30;
	 assign Yend = 430;
	 
	 assign titleXstart = 224;
	 assign titleXend = 416;
	 assign titleYstart = 100;
	 assign titleYend = 140;
	 
	 assign enterXstart = 80;
	 assign enterXend = 560;
	 assign enterYstart = 300;
	 assign enterYend = 330;
	 
	 assign scoreXstart = 170;
	 assign scoreXend = 250;
	 assign scoreYstart = 30;
	 assign scoreYend = 50;
	 
	 assign numXstart = 178;
	 assign numXend = 242;
	 assign numYstart = 70;
	 assign numYend = 90;

	 assign wordXstart = 178;
	 assign wordXend = 242;
	 assign wordYstart = 130;
	 assign wordYend = 150;
	 
	 assign bestXstart = 178;
	 assign bestXend = 242;
	 assign bestYstart = 170;
	 assign bestYend = 190;
	 
	 
	 assign nextXstart = 170;
	 assign nextXend = 250;
	 assign nextYstart = 230;
	 assign nextYend = 290;
	 
	 assign stateXstart = 178;
	 assign stateXend = 242;
	 assign stateYstart = 366;
	 assign stateYend = 430;
	 
	 assign frameXstart = 100;
	 assign frameXend = 540;
	 assign frameYstart = 10;
	 assign frameYend = 450;
	 
	 assign Xreal = (DrawX - Xstart)/20 + 1;
	 assign Yreal = ((DrawY - Ystart)/20) + 1;
	 assign nextXreal = (DrawX - nextXstart)/20;
	 assign nextYreal = ((DrawY - nextYstart)/20);
	 assign Xtitle = (DrawX - titleXstart)%32;
    assign Ytitle = (DrawY - titleYstart)%40;
	 assign Xscore = (DrawX - scoreXstart)%16;
    assign Yscore = (DrawY - scoreYstart)%20;
	 assign Xstate = (DrawX - stateXstart)%64;
    assign Ystate = (DrawY - stateYstart)%64;
	 assign Xnum = (DrawX - numXstart)%16;
    assign Ynum = (DrawY - numYstart)%20;
	 assign Xenter = (DrawX - enterXstart)%24;
    assign Yenter = (DrawY - enterYstart)%30;
	 assign Xbest = (DrawX - bestXstart)%16;
    assign Ybest = (DrawY - bestYstart)%20;
	 assign Xword = (DrawX - wordXstart)%16;
    assign Yword = (DrawY - bestYstart)%20;
	 
	 assign titleCount = (DrawX - titleXstart)/32;
	 assign enterCount = (DrawX - enterXstart)/24;
	 assign scoreCount = (DrawX - scoreXstart)/16;
	 assign wordCount = (DrawX - wordXstart)/16;
	 //assign stateCount = (DrawX - stateXstart)/32;
	 
	 
	 
    assign VGA_R = Red;
    assign VGA_G = Green;
    assign VGA_B = Blue;
	 
	 always_comb
    begin : stateCounter
		if(print_over == 1'b1)
			stateCount = 2'b00;
		else if(print_pause == 1'b1)
			stateCount = 2'b01;
		else
			stateCount = 2'b10;
		end
		
    
    // Compute whether the pixel corresponds to ball or background
    /*always_comb
    begin : Ball_on_proc
        if ( ( DistX*DistX + DistY*DistY) <= (Size * Size) ) 
            ball_on = 1'b1;
        else 
            ball_on = 1'b0;
    end*/
	 always_comb
    begin : in_range_proc
		if(DrawX > Xstart && DrawX <= Xend && DrawY > Ystart && DrawY <= Yend)
			in_range = 1'b1;
		else
			in_range = 1'b0;
	 end
	 
	 always_comb
    begin : in_word_proc
		if(DrawX > wordXstart && DrawX <= wordXend && DrawY > wordYstart && DrawY <= wordYend)
			in_word = 1'b1;
		else
			in_word = 1'b0;
	 end
	 
	 always_comb
    begin : in_best_proc
		if(DrawX > bestXstart && DrawX <= bestXend && DrawY > bestYstart && DrawY <= bestYend)
			in_best = 1'b1;
		else
			in_best = 1'b0;
	 end
	 
	 always_comb
    begin : in_frame_proc
		if(DrawX > frameXstart && DrawX <= frameXend && DrawY > frameYstart && DrawY <= frameYend)
			in_frame = 1'b1;
		else
			in_frame = 1'b0;
	 end
	 
	 always_comb
    begin : in_enter_proc
		if(DrawX > enterXstart && DrawX <= enterXend && DrawY > enterYstart && DrawY <= enterYend)
			in_enter = 1'b1;
		else
			in_enter = 1'b0;
	 end
	 
	 always_comb
    begin : next_proc
		if(DrawX > nextXstart && DrawX <= nextXend && DrawY > nextYstart && DrawY <= nextYend)
			in_next = 1'b1;
		else
			in_next = 1'b0;
	 end
	 
	 always_comb
    begin : state_proc
		if(DrawX > stateXstart && DrawX <= stateXend && DrawY > stateYstart && DrawY <= stateYend)
			in_state = 1'b1;
		else
			in_state = 1'b0;
	 end
	 
	 always_comb
    begin : title_proc
		if(DrawX > titleXstart && DrawX <= titleXend && DrawY > titleYstart && DrawY <= titleYend)
			in_title = 1'b1;
		else
			in_title = 1'b0;
	 end
	 
	 always_comb
    begin : score_proc
		if(DrawX > scoreXstart && DrawX <= scoreXend	&& DrawY > scoreYstart && DrawY <= scoreYend)
			in_score = 1'b1;
		else
			in_score = 1'b0;
	 end
	 
	 always_comb
    begin : num_proc
		if(DrawX > numXstart && DrawX <= numXend && DrawY > numYstart && DrawY <= numYend)
			in_num = 1'b1;
		else
			in_num = 1'b0;
	 end
	 
	 always_comb
    begin : RGB_Display
	 Red = 8'h00; ;//background
	 Green = 8'h00;
	 Blue = 8'h00;
		   if(print_title == 1'b1) begin
				if(in_title == 1'b1) begin
					if(tetris_row[7 - Xtitle/4] == 1'b1) begin
						Red = 8'hff;
						Green = 8'hff;
						Blue = 8'hff;
					end
				end
				else if(in_enter == 1'b1) begin
					if(enter_row[7 - Xenter/3] == 1'b1) begin
						Red = 8'hff;
						Green = 8'hff;
						Blue = 8'h00;
					end
				end
			end
			else if ((in_range == 1'b1)) 
			begin
            // White ball
			if(((Xreal == x1 && Yreal == y1) || (Xreal == x2 && Yreal == y2) || (Xreal == x3 && Yreal == y3) || (Xreal == x4 && Yreal == y4)) && print_over == 0)
				unique case (active_shape)
					
					3'b001:begin
						Red = color_from_mem[23:16];
						Green = color_from_mem[15:8];
						Blue = color_from_mem[7:0];
					end
					
					3'b010:begin
						Red = color_from_mem[23:16];
						Green = color_from_mem[7:0];
						Blue = color_from_mem[15:8];
					end
					
					3'b011:begin
						Red = color_from_mem[15:8];
						Green = color_from_mem[23:16];
						Blue = color_from_mem[7:0];
					end
					
					3'b100:begin
						Red = color_from_mem[15:8];
						Green = color_from_mem[7:0];
						Blue = color_from_mem[23:16];
					end
					
					3'b101:begin
						Red = color_from_mem[7:0];
						Green = color_from_mem[15:8];
						Blue = color_from_mem[23:16];
					end
					
					3'b110:begin
						Red = color_from_mem[7:0];
						Green = color_from_mem[23:16];
						Blue = color_from_mem[15:8];
					end
					
					3'b111:begin
						Red = color_from_mem[7:0];
						Green = color_from_mem[15:8];
						Blue = color_from_mem[7:0];
					end
				
					default:begin
					end
					
				endcase
					
			else
				unique case (output_color[Yreal][Xreal])
					
					3'b001:begin
						Red = color_from_mem[23:16];
						Green = color_from_mem[15:8];
						Blue = color_from_mem[7:0];
					end
					
					3'b010:begin
						Red = color_from_mem[23:16];
						Green = color_from_mem[7:0];
						Blue = color_from_mem[15:8];
					end
					
					3'b011:begin
						Red = color_from_mem[15:8];
						Green = color_from_mem[23:16];
						Blue = color_from_mem[7:0];
					end
					
					3'b100:begin
						Red = color_from_mem[15:8];
						Green = color_from_mem[7:0];
						Blue = color_from_mem[23:16];
					end
					
					3'b101:begin
						Red = color_from_mem[7:0];
						Green = color_from_mem[15:8];
						Blue = color_from_mem[23:16];
					end
					
					3'b110:begin
						Red = color_from_mem[7:0];
						Green = color_from_mem[23:16];
						Blue = color_from_mem[15:8];
					end
					
					3'b111:begin
						Red = color_from_mem[7:0];
						Green = color_from_mem[15:8];
						Blue = color_from_mem[7:0];
					end
					
					default:begin
						Red = 8'h00;
						Green = 8'h00;
						Blue = 8'h00;
					end
					
				endcase
			
			
			end
			
			else if(in_state == 1'b1)begin
				if(state_row[15 - Xstate/4] == 1'b1)begin
					if(print_over)
						begin//play
							Red = 8'hff;
							Green = 8'h00;
							Blue = 8'h00;
						end
					else if(print_pause)
						begin//pause
							Red = 8'hff;
							Green = 8'hff;
							Blue = 8'h00;
						end
					else
						begin//over
							Red = 8'h00;
							Green = 8'hff;
							Blue = 8'h00;
						end
				end
			end
			
			else if(in_score == 1'b1) begin
				if(score_row[7 - Xscore/2] == 1'b1) begin
					Red = 8'hff;
					Green = 8'h00;
					Blue = 8'hff;
				end					
			end
			
			/*else if(in_word == 1'b1) begin
				if(word_row[7 - Xword/2] == 1'b1) begin
					Red = 8'hff;
					Green = 8'h00;
					Blue = 8'hff;
				end					
			end*/
			
			else if(in_num == 1'b1)begin
						if(num_row[7 - Xnum/2] == 1'b1)begin
							Red = 8'h00;
							Green = 8'hff;
							Blue = 8'h00;
						end
			end
	
			/*else if(in_best == 1'b1)begin
						if(num_row[7 - Xbest/2] == 1'b1)begin
							Red = 8'hff;
							Green = 8'hff;
							Blue = 8'h00;
						end
			end*/	
			
			else if(in_next == 1'b1) begin
				unique case (next_color[nextYreal][nextXreal])
					
					3'b001:begin
						Red = next_color_from_mem[23:16];
						Green = next_color_from_mem[15:8];
						Blue = next_color_from_mem[7:0];
					end
					
					3'b010:begin
						Red = next_color_from_mem[23:16];
						Green = next_color_from_mem[7:0];
						Blue = next_color_from_mem[15:8];
					end
					
					3'b011:begin
						Red = next_color_from_mem[15:8];
						Green = next_color_from_mem[23:16];
						Blue = next_color_from_mem[7:0];
					end
					
					3'b100:begin
						Red = next_color_from_mem[15:8];
						Green = next_color_from_mem[7:0];
						Blue = next_color_from_mem[23:16];
					end
					
					3'b101:begin
						Red = next_color_from_mem[7:0];
						Green = next_color_from_mem[15:8];
						Blue = next_color_from_mem[23:16];
					end
					
					3'b110:begin
						Red = next_color_from_mem[7:0];
						Green = next_color_from_mem[23:16];
						Blue = next_color_from_mem[15:8];
					end
					
					3'b111:begin
						Red = next_color_from_mem[7:0];
						Green = next_color_from_mem[15:8];
						Blue = next_color_from_mem[7:0];
					end
					
					default:begin
					end
					
				endcase
			end
			else if(in_frame == 1'b1)begin
				Red = 8'hff;
				Green = 8'hff;
				Blue = 8'hff;
			end
			
    end 
	
		
    
    // Assign color based on ball_on signal
    /*always_comb
    begin : RGB_Display
        if ((ball_on == 1'b1)) 
        begin
            // White ball
            Red = 8'hff;
            Green = 8'hff;
            Blue = 8'hff;
        end
        else 
        begin
            // Background with nice color gradient
            Red = 8'h3f; 
            Green = 8'h00;
            Blue = 8'h7f - {1'b0, DrawX[9:3]};
        end
    end */
    
endmodule
