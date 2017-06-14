module grid_reg(input logic [11:0] Din [21:0],
					 input Clk,
					 input Reset, 
					 output logic [11:0] Dout [21:0]);
					 
always_ff @ (posedge Clk or posedge Reset)
begin
	if(Reset)
		Dout <= 0;
	else
		Dout <= Din;
end

endmodule
