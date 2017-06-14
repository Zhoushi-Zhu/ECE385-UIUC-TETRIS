//-------------------------------------------------------------------------
//    Ball.sv                                                            --
//    Viral Mehta                                                        --
//    Spring 2005                                                        --
//                                                                       --
//    Modified by Stephen Kempf 03-01-2006                               --
//                              03-12-2007                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  03-03-2017                               --
//    Spring 2017 Distribution                                           --
//                                                                       --
//    For use with ECE 298 Lab 7                                         --
//    UIUC ECE Department                                                --
//-------------------------------------------------------------------------
//frame for main gaming part
//need another frame for scoring and peripherals

module  ball ( input  [15:0]  keycode,
					input         Reset, 
                             frame_clk,          // The clock indicating a new frame (~60Hz)
         output logic [2:0]  frame_coord[9:0][19:0] // Ball coordinates and size
				 );
				 
logic shape_count;
logic [5:0] counter, counter_in;
logic [2:0]  frame_static[9:0][19:0];
logic [2:0]  frame_active[9:0][19:0];
logic [2:0]  frame_active[9:0][19:0]; 


				  
always_ff @ (posedge frame_clk)
begin
if(Reset)
	begin
		for(int i = 0; i < 10; i++)
		begin
			for(int j = 0; j < 20; j++)
				begin
					frame_static[i][j] = 1'b0;
					frame_active[i][j] = 1'b0;
					frame_active_in[i][j] = 1'b0;
				end
		end 
	
	end
else
	begin
		for(int i = 0; i < 10; i++)
		begin
			for(int j = 0; j < 20; j++)
				assign frame_active[i][j] = frame_active_in[i][j];
		end 
	
	end
	
counter = coutner_in;
end

	
	
//logic active_x, active_y, 



always_comb
begin
	case (keycode[7:0])
		8'h16://S DOWN
		begin
			counter_in = counter + 6;
			begin
			for(int i = 1; i < 10; i++)
				begin
					for(int j = 0; j < 20; j++)
						assign frame_active_in[i][j] = frame_active[i][j];
				end 
			end
		end
			
		8'h04://A LEFT
		begin
		if(frame_active[0] == 20'b0)
		begin
			for(int i = 0; i < 9; i++)
				begin
					for(int j = 0; j < 20; j++)
						assign frame_active_in[i][j] = frame_active[i+1][j];
				end 
			end
		end
			
		8'h07://D RIGHT
		begin
		if(frame_active[9] == 20'b0)
		begin
			for(int i = 1; i < 10; i++)
				begin
					for(int j = 0; j < 20; j++)
						assign frame_active_in[i][j] = frame_active[i-1][j];
				end 
			end
		end
			
		default:
		begin
			counter_in = counter + 1;
			begin
			for(int i = 1; i < 10; i++)
				begin
					for(int j = 0; j < 20; j++)
						assign frame_active_in[i][j] = frame_active[i][j];
				end 
			end
		end
			
	endcase
	

	
	
	if(counter == 60)//move downward every second
		begin
			for(int i = 0; i < 10; i++)
				begin
					for(int j = 0; j < 20; j++)
						assign frame_active[i][j] = frame_active_in[i][j];
				end 
		end     
end


             


    
endmodule

