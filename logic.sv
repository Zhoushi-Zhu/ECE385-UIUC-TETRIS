module blocklogic(
input logic Reset,
input logic frameClk,
input logic [2:0] next_shape,
input logic up, down, left, right, 
input logic pause, resume, enter,
output logic print_pause, print_title,
output logic [5:0] x1_out,x2_out,x3_out,x4_out,y1_out,y2_out,y3_out,y4_out,
output logic [11:0] output_coord [21:0],
output logic [2:0] output_color [21:0][11:0],
output logic [3:0] next_coord [2:0],
output logic [2:0] next_color [2:0][3:0],
output logic print_over,
output logic [7:0] score,
output logic [7:0] best_score,
output logic [2:0] active_shape,
output logic to_sw_sig,
input  logic from_sw_sig
);

logic [11:0] coord_static [21:0];
logic [2:0] color_static [21:0][11:0];
logic [11:0] coord_static_in [21:0];
logic [2:0] color_static_in [21:0][11:0];
logic [3:0] next_coord_static [2:0];
logic [2:0] next_color_static [2:0][3:0];
logic [3:0] next_coord_static_in [2:0];
logic [2:0] next_color_static_in [2:0][3:0];

logic [2:0] current_shape, current_shape_in;
logic [7:0] current_score_in, current_score;
logic [7:0] current_best_in, current_best;
logic [7:0] accu_in, accu;

	
enum logic [5:0]{START, RESET, NEW_BLOCK, INTER, MOVELEFT, MOVERIGHT, MOVEDOWN, AFTERLEFT, AFTERRIGHT, AFTERROTATE, BEFORENEW, NEWNEXT,
					  CLEAR1_1, CLEAR1_2, CLEAR1_3, CLEAR1_4, CLEAR1_5,
					  CLEAR2_1, CLEAR2_2, CLEAR2_3, CLEAR2_4, CLEAR2_5,
					  CLEAR3_1, CLEAR3_2, CLEAR3_3, CLEAR3_4, CLEAR3_5,
					  CLEAR4_1, CLEAR4_2, CLEAR4_3, CLEAR4_4, CLEAR4_5,
					  ROTATE_I, ROTATE_J, ROTATE_L, ROTATE_S, ROTATE_T, ROTATE_Z, ROTATE_CHOOSE, PAUSE, RESUME,
					  GAMEOVER} state, next_state;

logic [5:0] x1,x2,x3,x4,y1,y2,y3,y4;
logic [5:0] x1_in,x2_in,x3_in,x4_in,y1_in,y2_in,y3_in,y4_in;
logic [1:0] rotate_counter, rotate_counter_in;
logic [7:0] counter, counter_in;

always_ff @ (posedge frameClk or posedge Reset)
begin
	if(Reset)
	begin
		state <= START;
		x1 <= 0;
		x2 <= 0;
		x3 <= 0;
		x4 <= 0;
		y1 <= 0;
		y2 <= 0;
		y3 <= 0;
		y4 <= 0;
		counter <= 0;
		rotate_counter <= 0;
		current_score <= 0;
		current_shape <= 0;
		current_best <= 0;
		accu <= 1;
		coord_static <= '{12'd0, 12'd0, 12'd0, 12'd0, 12'd0, 12'd0, 12'd0, 12'd0, 12'd0, 12'd0, 
								12'd0, 12'd0, 12'd0, 12'd0, 12'd0, 12'd0, 12'd0, 12'd0, 12'd0, 12'd0, 
								12'd0, 12'd0 };
								
		next_coord_static <= '{4'd0, 4'd0, 4'd0};
		for(integer i = 0; i  < 22; i = i + 1)
				for(integer j = 0; j < 12; j = j + 1)
					begin
							color_static[i][j] = 3'b000;
					end
		for(integer i = 0; i  < 3; i = i + 1)
				for(integer j = 0; j < 4; j = j + 1)
					begin
							next_color_static[i][j] = 3'b000;
					end
		
	end
	else
	begin
		state <= next_state;
		x1 <= x1_in;
		x2 <= x2_in;
		x3 <= x3_in;
		x4 <= x4_in;
		y1 <= y1_in;
		y2 <= y2_in;
		y3 <= y3_in;
		y4 <= y4_in;
		counter <= counter_in;
		accu <= accu_in;
		current_score <= current_score_in;
		current_best <= current_best_in;
		rotate_counter <= rotate_counter_in;
		current_shape <= current_shape_in;
		coord_static <= coord_static_in;
		color_static <= color_static_in;
		next_color_static <= next_color_static_in;
		next_coord_static <= next_coord_static_in;
	end
end


always_comb//state output control
begin
	//next_state = state;
	x1_in = x1;
	x2_in = x2;
	x3_in = x3;
	x4_in = x4;
	y1_in = y1;
	y2_in = y2;
	y3_in = y3;
	y4_in = y4;
	counter_in = counter;
	current_score_in = current_score;
	rotate_counter_in = rotate_counter;
	current_shape_in = current_shape;
	current_best_in = current_best;
	coord_static_in = coord_static;
	color_static_in = color_static;
	next_color_static_in = next_color_static;
	next_coord_static_in = next_coord_static;
	accu_in = accu;
	print_over = 0;
	print_pause = 0;
	to_sw_sig = 0;
	print_title = 0;
	
	case(state)
		START:begin
			print_title = 1'b1;
			to_sw_sig = 1'b1;
		end
		
		RESET:begin
			for(integer i = 0; i  < 22; i = i + 1)
				for(integer j = 0; j < 12; j = j + 1)
					begin
						if(i == 21 || j == 0|| j == 11)
							coord_static_in[i][j] = 1'b1;
						else
							coord_static_in[i][j] = 1'b0;
							
							color_static_in[i][j] = 3'b000;
					end
					
		current_score_in = 0;
		current_shape_in = 0;
		accu_in = 1;
		rotate_counter_in = 0;
		
		end
		
		NEW_BLOCK:begin
			case (next_shape)
				3'b001:begin//I
					x1_in = 6'd4;
					x2_in = 6'd5;
					x3_in = 6'd6;
					x4_in = 6'd7;
					y1_in = 6'd1;
					y2_in = 6'd1;
					y3_in = 6'd1;
					y4_in = 6'd1;
					current_shape_in = 3'b001;
				end
				
				3'b010:begin//J
					x1_in = 6'd4;
					x2_in = 6'd5;
					x3_in = 6'd6;
					x4_in = 6'd6;
					y1_in = 6'd1;
					y2_in = 6'd1;
					y3_in = 6'd1;
					y4_in = 6'd2;
					current_shape_in = 3'b010;
				end
				
				3'b011:begin//L
					x1_in = 6'd4;
					x2_in = 6'd5;
					x3_in = 6'd6;
					x4_in = 6'd4;
					y1_in = 6'd1;
					y2_in = 6'd1;
					y3_in = 6'd1;
					y4_in = 6'd2;
					current_shape_in = 3'b011;
				end
				
				3'b100:begin//O
					x1_in = 6'd5;
					x2_in = 6'd5;
					x3_in = 6'd6;
					x4_in = 6'd6;
					y1_in = 6'd1;
					y2_in = 6'd2;
					y3_in = 6'd1;
					y4_in = 6'd2;
					current_shape_in = 3'b100;
				end
				
				3'b101:begin//S
					x1_in = 6'd4;
					x2_in = 6'd5;
					x3_in = 6'd5;
					x4_in = 6'd6;
					y1_in = 6'd2;
					y2_in = 6'd2;
					y3_in = 6'd1;
					y4_in = 6'd1;
					current_shape_in = 3'b101;
				end
				
				3'b110:begin//T
					x1_in = 6'd4;
					x2_in = 6'd5;
					x3_in = 6'd6;
					x4_in = 6'd5;
					y1_in = 6'd1;
					y2_in = 6'd1;
					y3_in = 6'd1;
					y4_in = 6'd2;
					current_shape_in = 3'b110;
				end
				
				3'b111:begin//Z
					x1_in = 6'd4;
					x2_in = 6'd5;
					x3_in = 6'd5;
					x4_in = 6'd6;
					y1_in = 6'd1;
					y2_in = 6'd1;
					y3_in = 6'd2;
					y4_in = 6'd2;
					current_shape_in = 3'b111;
				end
				
				default: begin//I
					x1_in = 6'd4;
					x2_in = 6'd5;
					x3_in = 6'd6;
					x4_in = 6'd7;
					y1_in = 6'd1;
					y2_in = 6'd1;
					y3_in = 6'd1;
					y4_in = 6'd1;
					current_shape_in = 3'b001;
				end
			endcase
			
			rotate_counter_in = 0;
			//to_sw_sig = 1'b1;
		end
		
		NEWNEXT:begin
			case(next_shape)
				3'b001:begin//I
					next_coord_static_in[0][0] = 1'b0;next_coord_static_in[0][1] = 1'b0;next_coord_static_in[0][2] = 1'b0;next_coord_static_in[0][3] = 1'b0;
					next_coord_static_in[1][0] = 1'b1;next_coord_static_in[1][1] = 1'b1;next_coord_static_in[1][2] = 1'b1;next_coord_static_in[1][3] = 1'b1;
					next_coord_static_in[2][0] = 1'b0;next_coord_static_in[2][1] = 1'b0;next_coord_static_in[2][2] = 1'b0;next_coord_static_in[2][3] = 1'b0;
					next_color_static_in[0][0] = 3'd0;		 next_color_static_in[0][1] = 3'd0;		  next_color_static_in[0][2] = 3'd0;		next_color_static_in[0][3] = 3'd0;
					next_color_static_in[1][0] = next_shape;next_color_static_in[1][1] = next_shape;next_color_static_in[1][2] = next_shape;next_color_static_in[1][3] = next_shape;
					next_color_static_in[2][0] = 3'd0;		 next_color_static_in[2][1] = 3'd0;		  next_color_static_in[2][2] = 3'd0;		next_color_static_in[2][3] = 3'd0;
				end
				
				3'b010:begin//J
					next_coord_static_in[0][0] = 1'b0;next_coord_static_in[0][1] = 1'b0;next_coord_static_in[0][2] = 1'b0;next_coord_static_in[0][3] = 1'b0;
					next_coord_static_in[1][0] = 1'b1;next_coord_static_in[1][1] = 1'b1;next_coord_static_in[1][2] = 1'b1;next_coord_static_in[1][3] = 1'b0;
					next_coord_static_in[2][0] = 1'b0;next_coord_static_in[2][1] = 1'b0;next_coord_static_in[2][2] = 1'b1;next_coord_static_in[2][3] = 1'b0;
					next_color_static_in[0][0] = 3'd0;		 next_color_static_in[0][1] = 3'd0;		  next_color_static_in[0][2] = 3'd0;		next_color_static_in[0][3] = 3'd0;
					next_color_static_in[1][0] = next_shape;next_color_static_in[1][1] = next_shape;next_color_static_in[1][2] = next_shape;next_color_static_in[1][3] = 3'd0;
					next_color_static_in[2][0] = 3'd0;		 next_color_static_in[2][1] = 3'd0;		  next_color_static_in[2][2] = next_shape;next_color_static_in[2][3] = 3'd0;
				end
				
				3'b011:begin//L
					next_coord_static_in[0][0] = 1'b0;next_coord_static_in[0][1] = 1'b0;next_coord_static_in[0][2] = 1'b1;next_coord_static_in[0][3] = 1'b0;
					next_coord_static_in[1][0] = 1'b1;next_coord_static_in[1][1] = 1'b1;next_coord_static_in[1][2] = 1'b1;next_coord_static_in[1][3] = 1'b0;
					next_coord_static_in[2][0] = 1'b0;next_coord_static_in[2][1] = 1'b0;next_coord_static_in[2][2] = 1'b0;next_coord_static_in[2][3] = 1'b0;
					next_color_static_in[0][0] = 3'd0;		 next_color_static_in[0][1] = 3'd0;		  next_color_static_in[0][2] = next_shape;next_color_static_in[0][3] = 3'd0;
					next_color_static_in[1][0] = next_shape;next_color_static_in[1][1] = next_shape;next_color_static_in[1][2] = next_shape;next_color_static_in[1][3] = 3'd0;
					next_color_static_in[2][0] = 3'd0;		 next_color_static_in[2][1] = 3'd0;		  next_color_static_in[2][2] = 3'd0;		next_color_static_in[2][3] = 3'd0;
				end
				
				3'b100:begin//O
					next_coord_static_in[0][0] = 1'b0;next_coord_static_in[0][1] = 1'b0;next_coord_static_in[0][2] = 1'b0;next_coord_static_in[0][3] = 1'b0;
					next_coord_static_in[1][0] = 1'b0;next_coord_static_in[1][1] = 1'b1;next_coord_static_in[1][2] = 1'b1;next_coord_static_in[1][3] = 1'b0;
					next_coord_static_in[2][0] = 1'b0;next_coord_static_in[2][1] = 1'b1;next_coord_static_in[2][2] = 1'b1;next_coord_static_in[2][3] = 1'b0;
					next_color_static_in[0][0] = 3'd0;		 next_color_static_in[0][1] = 3'd0;		  next_color_static_in[0][2] = 3'd0;		next_color_static_in[0][3] = 3'd0;
					next_color_static_in[1][0] = 3'd0;		 next_color_static_in[1][1] = next_shape;next_color_static_in[1][2] = next_shape;next_color_static_in[1][3] = 3'd0;
					next_color_static_in[2][0] = 3'd0;		 next_color_static_in[2][1] = next_shape;next_color_static_in[2][2] = next_shape;next_color_static_in[2][3] = 3'd0;
				end
				
				3'b101:begin//S
					next_coord_static_in[0][0] = 1'b0;next_coord_static_in[0][1] = 1'b0;next_coord_static_in[0][2] = 1'b0;next_coord_static_in[0][3] = 1'b0;
					next_coord_static_in[1][0] = 1'b0;next_coord_static_in[1][1] = 1'b0;next_coord_static_in[1][2] = 1'b1;next_coord_static_in[1][3] = 1'b1;
					next_coord_static_in[2][0] = 1'b0;next_coord_static_in[2][1] = 1'b1;next_coord_static_in[2][2] = 1'b1;next_coord_static_in[2][3] = 1'b0;
					next_color_static_in[0][0] = 3'd0;		 next_color_static_in[0][1] = 3'd0;		  next_color_static_in[0][2] = 3'd0;		next_color_static_in[0][3] = 3'd0;
					next_color_static_in[1][0] = 3'd0;		 next_color_static_in[1][1] = 3'd0;		  next_color_static_in[1][2] = next_shape;next_color_static_in[1][3] = next_shape;
					next_color_static_in[2][0] = 3'd0;		 next_color_static_in[2][1] = next_shape;next_color_static_in[2][2] = next_shape;next_color_static_in[2][3] = 3'd0;
				end
				
				3'b110:begin//T
					next_coord_static_in[0][0] = 1'b0;next_coord_static_in[0][1] = 1'b0;next_coord_static_in[0][2] = 1'b0;next_coord_static_in[0][3] = 1'b0;
					next_coord_static_in[1][0] = 1'b1;next_coord_static_in[1][1] = 1'b1;next_coord_static_in[1][2] = 1'b1;next_coord_static_in[1][3] = 1'b0;
					next_coord_static_in[2][0] = 1'b0;next_coord_static_in[2][1] = 1'b1;next_coord_static_in[2][2] = 1'b0;next_coord_static_in[2][3] = 1'b0;
					next_color_static_in[0][0] = 3'd0;		 next_color_static_in[0][1] = 3'd0;		  next_color_static_in[0][2] = 3'd0;		next_color_static_in[0][3] = 3'd0;
					next_color_static_in[1][0] = next_shape;next_color_static_in[1][1] = next_shape;next_color_static_in[1][2] = next_shape;next_color_static_in[1][3] = 3'd0;
					next_color_static_in[2][0] = 3'd0;		 next_color_static_in[2][1] = next_shape;		  next_color_static_in[2][2] = 3'd0;next_color_static_in[2][3] = 3'd0;
				end
				
				3'b111:begin//Z
					next_coord_static_in[0][0] = 1'b0;next_coord_static_in[0][1] = 1'b0;next_coord_static_in[0][2] = 1'b0;next_coord_static_in[0][3] = 1'b0;
					next_coord_static_in[1][0] = 1'b1;next_coord_static_in[1][1] = 1'b1;next_coord_static_in[1][2] = 1'b0;next_coord_static_in[1][3] = 1'b0;
					next_coord_static_in[2][0] = 1'b0;next_coord_static_in[2][1] = 1'b1;next_coord_static_in[2][2] = 1'b1;next_coord_static_in[2][3] = 1'b0;
					next_color_static_in[0][0] = 3'd0;		 next_color_static_in[0][1] = 3'd0;		  next_color_static_in[0][2] = 3'd0;		next_color_static_in[0][3] = 3'd0;
					next_color_static_in[1][0] = next_shape;next_color_static_in[1][1] = next_shape;next_color_static_in[1][2] = 3'd0;		next_color_static_in[1][3] = 3'd0;
					next_color_static_in[2][0] = 3'd0;		 next_color_static_in[2][1] = next_shape;next_color_static_in[2][2] = next_shape;next_color_static_in[2][3] = 3'd0;
				end
				
				default: begin//I
					next_coord_static_in[0][0] = 1'b0;next_coord_static_in[0][1] = 1'b0;next_coord_static_in[0][2] = 1'b0;next_coord_static_in[0][3] = 1'b0;
					next_coord_static_in[1][0] = 1'b1;next_coord_static_in[1][1] = 1'b1;next_coord_static_in[1][2] = 1'b1;next_coord_static_in[1][3] = 1'b1;
					next_coord_static_in[2][0] = 1'b0;next_coord_static_in[2][1] = 1'b0;next_coord_static_in[2][2] = 1'b0;next_coord_static_in[2][3] = 1'b0;
					next_color_static_in[0][0] = 3'd0;		 next_color_static_in[0][1] = 3'd0;		  next_color_static_in[0][2] = 3'd0;		next_color_static_in[0][3] = 3'd0;
					next_color_static_in[1][0] = next_shape;next_color_static_in[1][1] = next_shape;next_color_static_in[1][2] = next_shape;next_color_static_in[1][3] = next_shape;
					next_color_static_in[2][0] = 3'd0;		 next_color_static_in[2][1] = 3'd0;		  next_color_static_in[2][2] = 3'd0;		next_color_static_in[2][3] = 3'd0;
				end
			endcase
		end
		
		INTER:begin
		
			x1_in = x1;
			x2_in = x2;
			x3_in = x3;
			x4_in = x4;
			y1_in = y1;
			y2_in = y2;
			y3_in = y3;
			y4_in = y4;
			
			accu_in = 1;
			
			if(down)
				counter_in = counter + 8'd30;
			else
				counter_in = counter + 8'd1;
		end
		
		MOVELEFT:begin
		
			if(coord_static[y1][x1-1] == 1 || coord_static[y2][x2-1] == 1 || coord_static[y3][x3- 1] == 1 || coord_static[y4][x4-1] == 1 )
			begin
			x1_in = x1;
			x2_in = x2;
			x3_in = x3;
			x4_in = x4;
			y1_in = y1;
			y2_in = y2;
			y3_in = y3;
			y4_in = y4;
			end
			else
			begin
			x1_in = x1 - 6'd1;
			x2_in = x2 - 6'd1;
			x3_in = x3 - 6'd1;
			x4_in = x4 - 6'd1;
			y1_in = y1;
			y2_in = y2;
			y3_in = y3;
			y4_in = y4;
			end
		
		end
		
		
		MOVERIGHT:begin
		
			if(coord_static[y1][x1+1] == 1 || coord_static[y2][x2+1] == 1 || coord_static[y3][x3+1] == 1 || coord_static[y4][x4+1] == 1 )
			begin
			x1_in = x1;
			x2_in = x2;
			x3_in = x3;
			x4_in = x4;
			y1_in = y1;
			y2_in = y2;
			y3_in = y3;
			y4_in = y4;
			end
			else
			begin
			x1_in = x1 + 6'd1;
			x2_in = x2 + 6'd1;
			x3_in = x3 + 6'd1;
			x4_in = x4 + 6'd1;
			y1_in = y1;
			y2_in = y2;
			y3_in = y3;
			y4_in = y4;
			end
		
		end
		
		MOVEDOWN:begin
			if(coord_static[y1+1][x1] == 1 || coord_static[y2+1][x2] == 1 || coord_static[y3+1][x3] == 1 || coord_static[y4+1][x4] == 1 )
			begin
				coord_static_in[y1][x1] = 1;
				coord_static_in[y2][x2] = 1;
				coord_static_in[y3][x3] = 1;
				coord_static_in[y4][x4] = 1;
				
				color_static_in[y1][x1] = current_shape;
				color_static_in[y2][x2] = current_shape;
				color_static_in[y3][x3] = current_shape;
				color_static_in[y4][x4] = current_shape;
			
				counter_in = 0;
				current_shape_in = 0;
			end
			else
			begin
				x1_in = x1;
				x2_in = x2;
				x3_in = x3;
				x4_in = x4;
				y1_in = y1+6'd1;
				y2_in = y2+6'd1;
				y3_in = y3+6'd1;
				y4_in = y4+6'd1;
				counter_in = 0;
			end
			
		end
		
		CLEAR1_1:begin
		if(coord_static[y1] == 12'b111111111111)
		begin
			coord_static_in[y1] = 12'b100000000001;
			
			if(y1 > 19)  begin coord_static_in[20] = coord_static[19]; color_static_in[20] = color_static[19]; end
			if(y1 > 18)  begin coord_static_in[19] = coord_static[18]; color_static_in[19] = color_static[18]; end
			if(y1 > 17)  begin coord_static_in[18] = coord_static[17]; color_static_in[18] = color_static[17]; end
			if(y1 > 16)  begin coord_static_in[17] = coord_static[16]; color_static_in[17] = color_static[16]; end
		end
		end
		
		CLEAR1_2:begin
			if(y1 > 15)  begin coord_static_in[16] = coord_static[15]; color_static_in[16] = color_static[15]; end
			if(y1 > 14)  begin coord_static_in[15] = coord_static[14]; color_static_in[15] = color_static[14]; end
			if(y1 > 13)  begin coord_static_in[14] = coord_static[13]; color_static_in[14] = color_static[13]; end
			if(y1 > 12)  begin coord_static_in[13] = coord_static[12]; color_static_in[13] = color_static[12]; end
		end
		
		CLEAR1_3:begin
			if(y1 > 11)  begin coord_static_in[12] = coord_static[11]; color_static_in[12] = color_static[11]; end
			if(y1 > 10)  begin coord_static_in[11] = coord_static[10]; color_static_in[11] = color_static[10]; end
			if(y1 > 9)  begin coord_static_in[10] = coord_static[9]; color_static_in[10] = color_static[9]; end
			if(y1 > 8)  begin coord_static_in[9] = coord_static[8]; color_static_in[9] = color_static[8]; end
		end
		
		CLEAR1_4:begin
			if(y1 > 7)  begin coord_static_in[8] = coord_static[7]; color_static_in[8] = color_static[7]; end
			if(y1 > 6)  begin coord_static_in[7] = coord_static[6]; color_static_in[7] = color_static[6]; end
			if(y1 > 5)  begin coord_static_in[6] = coord_static[5]; color_static_in[6] = color_static[5]; end
			if(y1 > 4)  begin coord_static_in[5] = coord_static[4]; color_static_in[5] = color_static[4]; end
		end
		
		CLEAR1_5:begin
			if(y1 > 3)  begin coord_static_in[4] = coord_static[3]; color_static_in[4] = color_static[3]; end
			if(y1 > 2)  begin coord_static_in[3] = coord_static[2]; color_static_in[3] = color_static[2]; end
			if(y1 > 1)  begin coord_static_in[2] = coord_static[1]; color_static_in[2] = color_static[1]; end
			if(y1 > 0)  begin coord_static_in[1] = coord_static[0]; color_static_in[1] = color_static[0]; end
		
			coord_static_in[0] = 12'b100000000001;color_static_in[0] = '{3'b000,3'b000,3'b000,3'b000,3'b000,3'b000,3'b000,3'b000,3'b000,3'b000,3'b000,3'b000};
			current_score_in = current_score + accu;
			accu_in = accu + 1;
		end
		
		CLEAR2_1:begin
		if(coord_static[y2] == 12'b111111111111)
		begin
			coord_static_in[y2] = 12'b100000000001;
			
			if(y2 > 19)  begin coord_static_in[20] = coord_static[19]; color_static_in[20] = color_static[19]; end
			if(y2 > 18)  begin coord_static_in[19] = coord_static[18]; color_static_in[19] = color_static[18]; end
			if(y2 > 17)  begin coord_static_in[18] = coord_static[17]; color_static_in[18] = color_static[17]; end
			if(y2 > 16)  begin coord_static_in[17] = coord_static[16]; color_static_in[17] = color_static[16]; end
		end
		end
		
		CLEAR2_2:begin
			if(y2 > 15)  begin coord_static_in[16] = coord_static[15]; color_static_in[16] = color_static[15]; end
			if(y2 > 14)  begin coord_static_in[15] = coord_static[14]; color_static_in[15] = color_static[14]; end
			if(y2 > 13)  begin coord_static_in[14] = coord_static[13]; color_static_in[14] = color_static[13]; end
			if(y2 > 12)  begin coord_static_in[13] = coord_static[12]; color_static_in[13] = color_static[12]; end
		end
		
		CLEAR2_3:begin
			if(y2 > 11)  begin coord_static_in[12] = coord_static[11]; color_static_in[12] = color_static[11]; end
			if(y2 > 10)  begin coord_static_in[11] = coord_static[10]; color_static_in[11] = color_static[10]; end
			if(y2 > 9)  begin coord_static_in[10] = coord_static[9]; color_static_in[10] = color_static[9]; end
			if(y2 > 8)  begin coord_static_in[9] = coord_static[8]; color_static_in[9] = color_static[8]; end
		end
		
		CLEAR2_4:begin
			if(y2 > 7)  begin coord_static_in[8] = coord_static[7]; color_static_in[8] = color_static[7]; end
			if(y2 > 6)  begin coord_static_in[7] = coord_static[6]; color_static_in[7] = color_static[6]; end
			if(y2 > 5)  begin coord_static_in[6] = coord_static[5]; color_static_in[6] = color_static[5]; end
			if(y2 > 4)  begin coord_static_in[5] = coord_static[4]; color_static_in[5] = color_static[4]; end
		end
		
		CLEAR2_5:begin
			if(y2 > 3)  begin coord_static_in[4] = coord_static[3]; color_static_in[4] = color_static[3]; end
			if(y2 > 2)  begin coord_static_in[3] = coord_static[2]; color_static_in[3] = color_static[2]; end
			if(y2 > 1)  begin coord_static_in[2] = coord_static[1]; color_static_in[2] = color_static[1]; end
			if(y2 > 0)  begin coord_static_in[1] = coord_static[0]; color_static_in[1] = color_static[0]; end
		
			coord_static_in[0] = 12'b100000000001;color_static_in[0] = '{3'b000,3'b000,3'b000,3'b000,3'b000,3'b000,3'b000,3'b000,3'b000,3'b000,3'b000,3'b000};
			current_score_in = current_score + accu;
			accu_in = accu + 1;
		end
		
		CLEAR3_1:begin
		if(coord_static[y3] == 12'b111111111111)
		begin
			coord_static_in[y3] = 12'b100000000001;
			
			if(y3 > 19)  begin coord_static_in[20] = coord_static[19]; color_static_in[20] = color_static[19]; end
			if(y3 > 18)  begin coord_static_in[19] = coord_static[18]; color_static_in[19] = color_static[18]; end
			if(y3 > 17)  begin coord_static_in[18] = coord_static[17]; color_static_in[18] = color_static[17]; end
			if(y3 > 16)  begin coord_static_in[17] = coord_static[16]; color_static_in[17] = color_static[16]; end
		end
		end
		
		CLEAR3_2:begin
			if(y3 > 15)  begin coord_static_in[16] = coord_static[15]; color_static_in[16] = color_static[15]; end
			if(y3 > 14)  begin coord_static_in[15] = coord_static[14]; color_static_in[15] = color_static[14]; end
			if(y3 > 13)  begin coord_static_in[14] = coord_static[13]; color_static_in[14] = color_static[13]; end
			if(y3 > 12)  begin coord_static_in[13] = coord_static[12]; color_static_in[13] = color_static[12]; end
		end
		
		CLEAR3_3:begin
			if(y3 > 11)  begin coord_static_in[12] = coord_static[11]; color_static_in[12] = color_static[11]; end
			if(y3 > 10)  begin coord_static_in[11] = coord_static[10]; color_static_in[11] = color_static[10]; end
			if(y3 > 9)  begin coord_static_in[10] = coord_static[9]; color_static_in[10] = color_static[9]; end
			if(y3 > 8)  begin coord_static_in[9] = coord_static[8]; color_static_in[9] = color_static[8]; end
		end
		
		CLEAR3_4:begin
			if(y3 > 7)  begin coord_static_in[8] = coord_static[7]; color_static_in[8] = color_static[7]; end
			if(y3 > 6)  begin coord_static_in[7] = coord_static[6]; color_static_in[7] = color_static[6]; end
			if(y3 > 5)  begin coord_static_in[6] = coord_static[5]; color_static_in[6] = color_static[5]; end
			if(y3 > 4)  begin coord_static_in[5] = coord_static[4]; color_static_in[5] = color_static[4]; end
		end
		
		CLEAR3_5:begin
			if(y3 > 3)  begin coord_static_in[4] = coord_static[3]; color_static_in[4] = color_static[3]; end
			if(y3 > 2)  begin coord_static_in[3] = coord_static[2]; color_static_in[3] = color_static[2]; end
			if(y3 > 1)  begin coord_static_in[2] = coord_static[1]; color_static_in[2] = color_static[1]; end
			if(y3 > 0)  begin coord_static_in[1] = coord_static[0]; color_static_in[1] = color_static[0]; end
		
			coord_static_in[0] = 12'b100000000001;color_static_in[0] = '{3'b000,3'b000,3'b000,3'b000,3'b000,3'b000,3'b000,3'b000,3'b000,3'b000,3'b000,3'b000};
			current_score_in = current_score + accu;
			accu_in = accu + 1;
		end
		
		CLEAR4_1:begin
		if(coord_static[y4] == 12'b111111111111)
		begin
			coord_static_in[y4] = 12'b100000000001;
			
			if(y4 > 19)  begin coord_static_in[20] = coord_static[19]; color_static_in[20] = color_static[19]; end
			if(y4 > 18)  begin coord_static_in[19] = coord_static[18]; color_static_in[19] = color_static[18]; end
			if(y4 > 17)  begin coord_static_in[18] = coord_static[17]; color_static_in[18] = color_static[17]; end
			if(y4 > 16)  begin coord_static_in[17] = coord_static[16]; color_static_in[17] = color_static[16]; end
		end
		end
		
		CLEAR4_2:begin
			if(y4 > 15)  begin coord_static_in[16] = coord_static[15]; color_static_in[16] = color_static[15]; end
			if(y4 > 14)  begin coord_static_in[15] = coord_static[14]; color_static_in[15] = color_static[14]; end
			if(y4 > 13)  begin coord_static_in[14] = coord_static[13]; color_static_in[14] = color_static[13]; end
			if(y4 > 12)  begin coord_static_in[13] = coord_static[12]; color_static_in[13] = color_static[12]; end
		end
		
		CLEAR4_3:begin
			if(y4 > 11)  begin coord_static_in[12] = coord_static[11]; color_static_in[12] = color_static[11]; end
			if(y4 > 10)  begin coord_static_in[11] = coord_static[10]; color_static_in[11] = color_static[10]; end
			if(y4 > 9)  begin coord_static_in[10] = coord_static[9]; color_static_in[10] = color_static[9]; end
			if(y4 > 8)  begin coord_static_in[9] = coord_static[8]; color_static_in[9] = color_static[8]; end
		end
		
		CLEAR4_4:begin
			if(y4 > 7)  begin coord_static_in[8] = coord_static[7]; color_static_in[8] = color_static[7]; end
			if(y4 > 6)  begin coord_static_in[7] = coord_static[6]; color_static_in[7] = color_static[6]; end
			if(y4 > 5)  begin coord_static_in[6] = coord_static[5]; color_static_in[6] = color_static[5]; end
			if(y4 > 4)  begin coord_static_in[5] = coord_static[4]; color_static_in[5] = color_static[4]; end
		end
		
		CLEAR4_5:begin
			if(y4 > 3)  begin coord_static_in[4] = coord_static[3]; color_static_in[4] = color_static[3]; end
			if(y4 > 2)  begin coord_static_in[3] = coord_static[2]; color_static_in[3] = color_static[2]; end
			if(y4 > 1)  begin coord_static_in[2] = coord_static[1]; color_static_in[2] = color_static[1]; end
			if(y4 > 0)  begin coord_static_in[1] = coord_static[0]; color_static_in[1] = color_static[0]; end
		
			coord_static_in[0] = 12'b100000000001;color_static_in[0] = '{3'b000,3'b000,3'b000,3'b000,3'b000,3'b000,3'b000,3'b000,3'b000,3'b000,3'b000,3'b000};
			current_score_in = current_score + accu;
			accu_in = accu + 1;
		end
		
		
		
		
		
			ROTATE_I: begin //I
				case (rotate_counter)
					2'b00, 2'b10: begin
						if(coord_static[y1-6'd1][x1+6'd1] == 0 && coord_static[y2][x2] == 0 && coord_static[y3+6'd1][x3-6'd1] == 0 && coord_static[y4+6'd2][x4-6'd2] == 0)
						begin
							x1_in = x1+6'd1; y1_in = y1-6'd1;
							x2_in = x2; y2_in = y2;
							x3_in = x3-6'd1; y3_in = y3+6'd1;
							x4_in = x4-6'd2; y4_in = y4+6'd2;
							rotate_counter_in = rotate_counter + 1;
						end
					end
					
					2'b01, 2'b11: begin
						if(coord_static[y1+6'd1][x1-6'd1] == 0 && coord_static[y2][x2] == 0 && coord_static[y3-6'd1][x3+6'd1] == 0 && coord_static[y4-6'd2][x4+6'd2] == 0)
						begin
							x1_in = x1-6'd1; y1_in = y1+6'd1;
							x2_in = x2; y2_in = y2;
							x3_in = x3+6'd1; y3_in = y3-6'd1;
							x4_in = x4+6'd2; y4_in = y4-6'd2;
							rotate_counter_in = rotate_counter + 1;
						end
					end
				endcase
			end
				
			ROTATE_J: begin//J
				case (rotate_counter)
					2'b00: begin
						if(coord_static[y1-6'd1][x1+6'd1] == 0 && coord_static[y2][x2] == 0 && coord_static[y3+6'd1][x3-6'd1] == 0 && coord_static[y4][x4-6'd2] == 0)
						begin
							x1_in = x1+6'd1; y1_in = y1-6'd1;
							x2_in = x2; y2_in = y2;
							x3_in = x3-6'd1; y3_in = y3+6'd1;
							x4_in = x4-6'd2; y4_in = y4;
							rotate_counter_in = rotate_counter + 1;
						end
					end
					
					2'b01: begin
						if(coord_static[y1+6'd1][x1+6'd1] == 0 && coord_static[y2][x2] == 0 && coord_static[y3-6'd1][x3-6'd1] == 0 && coord_static[y4-6'd2][x4] == 0)
						begin
							x1_in = x1+6'd1; y1_in = y1+6'd1;
							x2_in = x2; y2_in = y2;
							x3_in = x3-6'd1; y3_in = y3-6'd1;
							x4_in = x4; y4_in = y4-6'd2;
							rotate_counter_in = rotate_counter + 1;
						end
					end
					
					2'b10: begin
						if(coord_static[y1+6'd1][x1-6'd1] == 0 && coord_static[y2][x2] == 0 && coord_static[y3-6'd1][x3+6'd1] == 0 && coord_static[y4][x4+6'd2] == 0)
						begin
							x1_in = x1-6'd1; y1_in = y1+6'd1;
							x2_in = x2; y2_in = y2;
							x3_in = x3+6'd1; y3_in = y3-6'd1;
							x4_in = x4+6'd2; y4_in = y4;
							rotate_counter_in = rotate_counter + 1;
						end
					end
		
					2'b11: begin
						if(coord_static[y1-6'd1][x1-6'd1] == 0 && coord_static[y2][x2] == 0 && coord_static[y3+6'd1][x3+6'd1] == 0 && coord_static[y4+6'd2][x4] == 0)
						begin
							x1_in = x1-6'd1; y1_in = y1-6'd1;
							x2_in = x2; y2_in = y2;
							x3_in = x3+6'd1; y3_in = y3+6'd1;
							x4_in = x4; y4_in = y4+6'd2;
							rotate_counter_in = rotate_counter + 1;
						end
					end
					
				endcase
			end
			
			
			ROTATE_L: begin//L
				case (rotate_counter)
					2'b00: begin
						if(coord_static[y1-6'd1][x1+6'd1] == 0 && coord_static[y2][x2] == 0 && coord_static[y3+6'd1][x3-6'd1] == 0 && coord_static[y4-6'd2][x4] == 0)
						begin
							x1_in = x1+6'd1; y1_in = y1-6'd1;
							x2_in = x2; y2_in = y2;
							x3_in = x3-6'd1; y3_in = y3+6'd1;
							x4_in = x4; y4_in = y4-6'd2;
							rotate_counter_in = rotate_counter + 1;
						end
					end
					
					2'b01: begin
						if(coord_static[y1+6'd1][x1+6'd1] == 0 && coord_static[y2][x2] == 0 && coord_static[y3-6'd1][x3-6'd1] == 0 && coord_static[y4][x4+6'd2] == 0)
						begin
							x1_in = x1+6'd1; y1_in = y1+6'd1;
							x2_in = x2; y2_in = y2;
							x3_in = x3-6'd1; y3_in = y3-6'd1;
							x4_in = x4+6'd2; y4_in = y4;
							rotate_counter_in = rotate_counter + 1;
						end
					end
					
					2'b10: begin
						if(coord_static[y1+6'd1][x1-6'd1] == 0 && coord_static[y2][x2] == 0 && coord_static[y3-6'd1][x3+6'd1] == 0 && coord_static[y4-6'd2][x4] == 0)
						begin
							x1_in = x1-6'd1; y1_in = y1+6'd1;
							x2_in = x2; y2_in = y2;
							x3_in = x3+6'd1; y3_in = y3-6'd1;
							x4_in = x4; y4_in = y4+6'd2;
							rotate_counter_in = rotate_counter + 1;
						end
					end
		
					2'b11: begin
						if(coord_static[x1-6'd1][y1-6'd1] == 0 && coord_static[x2][y2] == 0 && coord_static[x3+6'd1][y3+6'd1] == 0 && coord_static[x4-6'd2][y4] == 0)
						begin
							x1_in = x1-6'd1; y1_in = y1-6'd1;
							x2_in = x2; y2_in = y2;
							x3_in = x3+6'd1; y3_in = y3+6'd1;
							x4_in = x4-6'd2; y4_in = y4;
							rotate_counter_in = rotate_counter + 1;
						end
					end
					
				endcase
			end
			
			ROTATE_S: begin//S
				case (rotate_counter)
					2'b00, 2'b10: begin
						if(coord_static[y1-6'd1][x1+6'd1] == 0 && coord_static[y2][x2] == 0 && coord_static[y3+6'd1][x3+6'd1] == 0 && coord_static[y4+6'd2][x4] == 0)
						begin
							x1_in = x1+6'd1; y1_in = y1-6'd1;
							x2_in = x2; y2_in = y2;
							x3_in = x3+6'd1; y3_in = y3+6'd1;
							x4_in = x4; y4_in = y4+6'd2;
							rotate_counter_in = rotate_counter + 1;
						end
					end
					
					2'b01, 2'b11: begin
						if(coord_static[y1+6'd1][x1-6'd1] == 0 && coord_static[y2][x2] == 0 && coord_static[y3-6'd1][x3-6'd1] == 0 && coord_static[y4-6'd2][x4] == 0)
						begin
							x1_in = x1-6'd1; y1_in = y1+6'd1;
							x2_in = x2; y2_in = y2;
							x3_in = x3-6'd1; y3_in = y3-6'd1;
							x4_in = x4; y4_in = y4-6'd2;
							rotate_counter_in = rotate_counter + 1;
						end
					end
					
				endcase
			end
			
			ROTATE_T: begin//T
				case (rotate_counter)
					2'b00: begin
						if(coord_static[y1-6'd1][x1+6'd1] == 0 && coord_static[y2][x2] == 0 && coord_static[y3+6'd1][x3-6'd1] == 0 && coord_static[y4-6'd1][x4-6'd1] == 0)
						begin
							x1_in = x1+6'd1; y1_in = y1-6'd1;
							x2_in = x2; y2_in = y2;
							x3_in = x3-6'd1; y3_in = y3+6'd1;
							x4_in = x4-6'd1; y4_in = y4-6'd1;
							rotate_counter_in = rotate_counter + 1;
						end
					end
					
					2'b01: begin
						if(coord_static[y1+6'd1][x1+6'd1] == 0 && coord_static[y2][x2] == 0 && coord_static[y3-6'd1][x3-6'd1] == 0 && coord_static[y4-6'd1][x4+6'd1] == 0)
						begin
							x1_in = x1+6'd1; y1_in = y1+6'd1;
							x2_in = x2; y2_in = y2;
							x3_in = x3-6'd1; y3_in = y3-6'd1;
							x4_in = x4+6'd1; y4_in = y4-6'd1;
							rotate_counter_in = rotate_counter + 1;
						end
					end
					
					2'b10: begin
						if(coord_static[y1+1][x1-1] == 0 && coord_static[y2][x2] == 0 && coord_static[y3-1][x3+1] == 0 && coord_static[y4+1][x4+1] == 0)
						begin
							x1_in = x1-1; y1_in = y1+1;
							x2_in = x2; y2_in = y2;
							x3_in = x3+1; y3_in = y3-1;
							x4_in = x4+1; y4_in = y4+1;
							rotate_counter_in = rotate_counter + 1;
						end
					end
		
					2'b11: begin
						if(coord_static[y1-1][x1-1] == 0 && coord_static[y2][x2] == 0 && coord_static[y3+1][x3+1] == 0 && coord_static[y4+1][x4-1] == 0)
						begin
							x1_in = x1-1; y1_in = y1-1;
							x2_in = x2; y2_in = y2;
							x3_in = x3+1; y3_in = y3+1;
							x4_in = x4-1; y4_in = y4+1;
							rotate_counter_in = rotate_counter + 1;
						end
					end
					
				endcase
			end
			
			ROTATE_Z: begin//Z
				case (rotate_counter)
					2'b00, 2'b10: begin
						if(coord_static[y1-1][x1+1] == 0 && coord_static[y2][x2] == 0 && coord_static[y3-1][x3-1] == 0 && coord_static[y4][x4-2] == 0)
						begin
							x1_in = x1+1; y1_in = y1-1;
							x2_in = x2; y2_in = y2;
							x3_in = x3-1; y3_in = y3-1;
							x4_in = x4-2; y4_in = y4;
							rotate_counter_in = rotate_counter + 1;
						end
					end
					
					2'b01, 2'b11: begin
						if(coord_static[y1+1][x1-1] == 0 && coord_static[y2][x2] == 0 && coord_static[y3+1][x3+1] == 0 && coord_static[y4][x4+2] == 0)
						begin
							x1_in = x1-1; y1_in = y1+1;
							x2_in = x2; y2_in = y2;
							x3_in = x3+1; y3_in = y3+1;
							x4_in = x4+2; y4_in = y4;
							rotate_counter_in = rotate_counter + 1;
						end
					end
				endcase
			end
				
			
		PAUSE:begin
			print_pause = 1;
		end
		
		BEFORENEW:begin
			to_sw_sig = 1;
		end
		
		GAMEOVER:begin
			print_over = 1;
			if(current_best < current_score)
				current_best_in = current_score;
		end
		
		default:begin
		end

	endcase
	
end

always_comb//state transition logic
begin
	next_state = state;
	case (state)
		RESET: begin
			next_state = NEW_BLOCK;
		end
		
		START:begin
			if(enter == 1'b1)
				next_state = RESET;
		end
		
		NEWNEXT:begin
			next_state = INTER;
		end
		
		ROTATE_CHOOSE: begin	
			case(current_shape)
			3'b001: next_state = ROTATE_I;
			3'b010: next_state = ROTATE_J;
			3'b011: next_state = ROTATE_L;
			3'b100: next_state = INTER;
			3'b101: next_state = ROTATE_S;
			3'b110: next_state = ROTATE_T;
			3'b111: next_state = ROTATE_Z;
			endcase
		end
		
		NEW_BLOCK: begin
			next_state = BEFORENEW;
		end
		
		ROTATE_I:begin
			next_state = AFTERROTATE;
		end
		
		ROTATE_J:begin
			next_state = AFTERROTATE;
		end
		
		ROTATE_L:begin
			next_state = AFTERROTATE;
		end
		
		ROTATE_S:begin
			next_state = AFTERROTATE;
		end
		
		ROTATE_T:begin
			next_state = AFTERROTATE;
		end
		
		ROTATE_Z:begin
			next_state = AFTERROTATE;
		end
		
		AFTERROTATE:begin
			if(up == 0)
				next_state = INTER;
		end
		
		AFTERLEFT:begin
			if(left == 0)
				next_state = INTER;
		end
		
		AFTERRIGHT:begin
			if(right == 0)
				next_state = INTER;
		end
		
		BEFORENEW:begin
			if(from_sw_sig == 1)
				next_state = NEWNEXT;
		end
		
		INTER: begin
		
			if(coord_static[0] != 12'b100000000001 || coord_static[1] != 12'b100000000001)
				next_state = GAMEOVER;
			else if(pause)
				next_state = PAUSE;
			else if(current_shape == 0)
				next_state = CLEAR1_1;
			else if(counter > 60)
				next_state = MOVEDOWN;
			else if(left)
				next_state = MOVELEFT;
			else if(right)
				next_state = MOVERIGHT;
			else if(up)
				next_state = ROTATE_CHOOSE;
			else
				next_state = INTER;
		end
		
		PAUSE:begin
			if(resume)
				next_state = INTER;
		end
		
		MOVELEFT: begin
			next_state = AFTERLEFT;
		end
		
		MOVERIGHT: begin
			next_state = AFTERRIGHT;
		end
		
		MOVEDOWN: begin

			
				next_state = INTER;
		end
		
		CLEAR1_1: begin
			if(coord_static[y1] == 12'b111111111111)
				next_state = CLEAR1_2;
			else
				next_state = CLEAR2_1;
		end

		CLEAR1_2: begin
			next_state = CLEAR1_3;
		end

		CLEAR1_3: begin
			next_state = CLEAR1_4;
		end

		CLEAR1_4: begin
			next_state = CLEAR1_5;
		end
		
		CLEAR1_5: begin
			next_state = CLEAR1_1;
		end
		
		CLEAR2_1: begin
			if(coord_static[y2] == 12'b111111111111)
				next_state = CLEAR2_2;
			else
				next_state = CLEAR3_1;
		end

		CLEAR2_2: begin
			next_state = CLEAR2_3;
		end

		CLEAR2_3: begin
			next_state = CLEAR2_4;
		end

		CLEAR2_4: begin
			next_state = CLEAR2_5;
		end
		
		CLEAR2_5: begin
			next_state = CLEAR2_1;
		end
		
		CLEAR3_1: begin
				if(coord_static[y3] == 12'b111111111111)
				next_state = CLEAR3_2;
			else
				next_state = CLEAR4_1;
		end

		CLEAR3_2: begin
			next_state = CLEAR3_3;
		end

		CLEAR3_3: begin
			next_state = CLEAR3_4;
		end

		CLEAR3_4: begin
			next_state = CLEAR3_5;
		end
		
		CLEAR3_5: begin
			next_state = CLEAR3_1;
		end
		
		CLEAR4_1: begin
				if(coord_static[y1] == 12'b111111111111)
				next_state = CLEAR4_2;
			else
				next_state = NEW_BLOCK;
		end

		CLEAR4_2: begin
			next_state = CLEAR4_3;
		end

		CLEAR4_3: begin
			next_state = CLEAR4_4;
		end

		CLEAR4_4: begin
			next_state = CLEAR4_5;
		end
		
		CLEAR4_5: begin
			next_state = CLEAR4_1;
		end

		GAMEOVER:begin
		if(enter == 1'b1)
				next_state = RESET;
		end
		
		default:begin
		end
	endcase
end

assign output_coord = coord_static;
assign output_color = color_static;
assign next_color = next_color_static;
assign next_coord = next_coord_static;
assign score = current_score;
assign best_score = current_best;
assign x1_out = x1;
assign x2_out = x2;
assign x3_out = x3;
assign x4_out = x4;
assign y1_out = y1;
assign y2_out = y2;
assign y3_out = y3;
assign y4_out = y4;
assign active_shape = current_shape;

endmodule





	
			
		
		
		
		
			
			
			
				
		
				

