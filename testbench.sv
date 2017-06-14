module testbench();

   timeunit 10ms;// Half clock cycle at 50 MHz
   // This is the amount of time represented by #1
   timeprecision 1ms;
   
   // These signals are internal because the control will be
   // instantiated as a submodule in testbench.
	
 logic Reset;
 logic clk;
 logic [2:0] next_shape;
 logic up, down, left, right, enter;
 logic pause, resume;
 logic print_pause;
 logic [5:0] x1_out,x2_out,x3_out,x4_out,y1_out,y2_out,y3_out,y4_out;
 logic [11:0] output_coord [21:0];
 logic [2:0] output_color [21:0][11:0];
 logic [3:0] next_coord [2:0];
 logic [2:0] next_color [2:0][3:0];
 logic print_over, print_title;
 logic [7:0] score, best_score;
 logic [2:0] active_shape;
 logic to_sw_sig;
 logic from_sw_sig;
	 
 blocklogic thelogic(.*, .frameClk(clk));
	 
	 // Toggle the clock
   // #1 means wait for a delay of 1 timeunit
   always begin : CLOCK_GENERATION
      #1 clk = ~clk;
   end

   
	initial begin: CLOCK_INITIALIZATION
      clk = 0;
		//Continue = 1;
   end
	
	initial begin: TEST_VECTORS
		#2 Reset = 1;
			left = 0;
			right = 0;
			down = 0;

			up = 0;
			
		#2 Reset = 0;
		#10 left = 1;
		#2 left = 0;
		#10 right = 1;
		#2 right = 0;
		#10 up = 1;
		#2 up = 0;
		#10 down = 1;
		#10 down = 0;
		#10 up = 1;
		#2 up = 0;
		#10 up = 1;
		#2 up = 0;
		#10 right = 1;
		#2 right = 0;
		#10 right = 1;
		#2 right = 0;
		#10 right = 1;
		#2 right = 0;
		#10 right = 1;
		#2 right = 0;
		#10 right = 1;
		#2 right = 0;
		#10 right = 1;
		#2 right = 0;
		#10 right = 1;
		#2 right = 0;
		#10 pause = 1;
		#2 pause = 0;
		#10 resume = 1;
		#2 resume = 0;
		#10 right = 1;
		#2 right = 0;
		#10 right = 1;
		#2 right = 0;
		
		#10 down = 1;
		#2 down = 0;
		#10 down = 1;
		#2 down = 0;
		#10 down = 1;
		#2 down = 0;
		#10 down = 1;
		#2 down = 0;
		#10 down = 1;
		#2 down = 0;
		#10 down = 1;
		#2 down = 0;
		#10 down = 1;
		#2 down = 0;
		#10 down = 1;
		#2 down = 0;
		#10 down = 1;
		#2 down = 0;
		#10 down = 1;
		#2 down = 0;
		#10 down = 1;
		#2 down = 0;
		
		
		
		
		
		
		
		//#4 S = 16'b0000000000000000;
		
		end

endmodule
		