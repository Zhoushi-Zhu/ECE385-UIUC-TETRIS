module keycode_reader(input logic [15:0]keycode,
							output logic 		up,
							output logic 		down,
							output logic 		left,
							output logic 		right,
							output logic 		pause,
							output logic 		resume,
							output logic      enter
							);

always_comb
begin

up = 0;
left = 0;
right = 0;
down = 0;
pause = 0;
resume = 0;
enter = 0;


			unique case(keycode[7:0])
				8'h1A://W UP
				begin
					up = 1;
				end
			
				8'h16://S DOWN
				begin
					down = 1;
				end
			
				8'h04://A LEFT
				begin
					left = 1;
				end
			
				8'h07://D RIGHT
				begin
					right = 1;
				end
				
				8'h13://P PAUSE
				begin
					pause = 1;
				end
			
				8'h15://R RESUME
				begin
					resume = 1;
				end
				
				8'h28://enter enter
				begin
					enter = 1;
				end
				
				
				default:
				begin
					
				end
			endcase
			
end

endmodule
			