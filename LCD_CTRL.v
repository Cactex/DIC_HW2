module LCD_CTRL(
	input 	   	  clk	   ,
	input 		  rst	   ,
	input 	[3:0] cmd      , 
	input 		  cmd_valid,
	input 	[7:0] IROM_Q   ,
	output 	reg	  IROM_rd  , 
	output  reg [5:0] IROM_A   ,
	output 	reg	  IRAM_ceb ,
	output 	reg	  IRAM_web ,
	output  reg [7:0] IRAM_D   ,
	output  reg [5:0] IRAM_A   ,
	input 	[7:0] IRAM_Q   ,
	output 	reg	  busy	   ,
	output 	reg	  done
);

parameter write = 0, shift_up = 1, shift_down = 2, shift_left = 3, shift_right = 4, max = 5, min = 6, average = 7, idle = 8;

reg [2:0] X_axis, Y_axis;
reg [3:0]state;
reg [3:0]next_state;
reg [7:0]pixel[0:63];
reg [5:0]rd_addr;
reg [5:0]wr_addr;
reg flag;
reg [7:0]m1, m2, m3, m4, m5, m7, m8, m9, m10, m11, m12, m13, m14, maxnum, minnum, avgnum;
reg [7:0]m6;
reg [11:0]averagesum;
integer i, j;

assign pix_addr = {Y_axis, X_axis};

wire [5:0] pos1 = {Y_axis - 3'd2, X_axis - 3'd2};
wire [5:0] pos2 = {Y_axis - 3'd2, X_axis - 3'd1};
wire [5:0] pos3 = {Y_axis - 3'd2, X_axis };
wire [5:0] pos4 = {Y_axis - 3'd2, X_axis + 3'd1};
wire [5:0] pos5 = {Y_axis - 3'd1, X_axis - 3'd2};
wire [5:0] pos6 = {Y_axis - 3'd1, X_axis - 3'd1};
wire [5:0] pos7 = {Y_axis - 3'd1, X_axis};
wire [5:0] pos8 = {Y_axis - 3'd1, X_axis + 3'd1};
wire [5:0] pos9 = {Y_axis, X_axis - 3'd2};
wire [5:0] pos10 = {Y_axis, X_axis - 3'd1};
wire [5:0] pos11 = {Y_axis, X_axis};
wire [5:0] pos12 = {Y_axis, X_axis + 3'd1};
wire [5:0] pos13 = {Y_axis + 3'd1, X_axis - 3'd2};
wire [5:0] pos14 = {Y_axis + 3'd1, X_axis - 3'd1};
wire [5:0] pos15 = {Y_axis + 3'd1, X_axis};
wire [5:0] pos16 = {Y_axis + 3'd1, X_axis + 3'd1};

always @(negedge rst) begin
	X_axis <= 3'd4;
    Y_axis <= 3'd4;
	busy <= 1;
	IROM_rd <= 1;
	IRAM_ceb <= 0;
	IRAM_web <= 1;
	rd_addr <= 0;
	wr_addr <= 0;
	flag = 0;
end

always @(posedge clk ) begin
	if(cmd_valid && !busy)begin
		busy <= 1;
		next_state <= cmd;
	end
	else if(busy)begin
		state <= next_state;
	end
end

always @(posedge clk) begin
	if(IROM_rd)begin
		flag <= 1;
		IROM_A <= rd_addr;
		rd_addr <= rd_addr + 1;
	end
	else
		rd_addr <= rd_addr;

	if(flag)begin
		pixel[IROM_A] <= IROM_Q;
		if(IROM_A == 63)begin
			IROM_rd <= 0;
			rd_addr <= 0;
			flag <= 0;
			busy <= 0;
		end
		else begin
		
		end
	end

	else begin
		
	end
end

always @(posedge clk) begin
	if(IRAM_ceb && !IRAM_web)begin
		IRAM_A <= wr_addr;
		wr_addr <= wr_addr + 1;
		IRAM_D <= pixel[wr_addr];
		if(IRAM_A == 63)begin
			IRAM_ceb <= 0;
			IRAM_web <= 1;
			done <= 1;
		end
		else begin
			
		end
			
	end
	else
		wr_addr <= wr_addr;
end

always @(*) begin
	case(state)
		write: begin
			IRAM_ceb = 1;
			IRAM_web = 0;
		end
		shift_up: begin
			if(Y_axis > 3'd2)
				Y_axis = Y_axis -1;
			else
				Y_axis = Y_axis;
			busy = 0;
			state = idle;
		end
		shift_down: begin
			if(Y_axis < 3'd6)
				Y_axis = Y_axis +1;
			else
				Y_axis = Y_axis;
			busy = 0;
			state = idle;
		end
		shift_left: begin
			if(X_axis > 3'd2)
				X_axis = X_axis -1;
			else
				X_axis = X_axis;
			busy = 0;
			state = idle;
		end
		shift_right: begin
			if(X_axis < 3'd6)
				X_axis = X_axis +1;
			else
				X_axis = X_axis;
			busy = 0;
			state = idle;
		end
		max: begin
			m1 = (pixel[pos1] > pixel[pos2]) ? pixel[pos1] :  pixel[pos2];
			m2 = (pixel[pos3] > pixel[pos4]) ? pixel[pos3] :  pixel[pos4];
			m3 = (pixel[pos5] > pixel[pos6]) ? pixel[pos5] :  pixel[pos6];
			m4 = (pixel[pos7] > pixel[pos8]) ? pixel[pos7] :  pixel[pos8];
			m5 = (pixel[pos9] > pixel[pos10]) ? pixel[pos9] :  pixel[pos10];
			m6 = (pixel[pos11] > pixel[pos12]) ? pixel[pos11] :  pixel[pos12];
			m7 = (pixel[pos13] > pixel[pos14]) ? pixel[pos13] :  pixel[pos14];
			m8 = (pixel[pos15] > pixel[pos16]) ? pixel[pos15] :  pixel[pos16];

			m9 = (m1 > m2) ? m1 : m2;
			m10 = (m3 > m4) ? m3 : m4;
			m11 = (m5 > m6) ? m5 : m6;
			m12 = (m7 > m8) ? m7 : m8;

			m13 = (m9 > m10) ? m9 : m10;
			m14 = (m11 > m12) ? m11 : m12;
			
			maxnum = (m13 > m14) ? m13 : m14;

			pixel[pos1] = maxnum;
			pixel[pos2] = maxnum;
			pixel[pos3] = maxnum;
			pixel[pos4] = maxnum;
			pixel[pos5] = maxnum;
			pixel[pos6] = maxnum;
			pixel[pos7] = maxnum;
			pixel[pos8] = maxnum;
			pixel[pos9] = maxnum;
			pixel[pos10] = maxnum;
			pixel[pos11] = maxnum;
			pixel[pos12] = maxnum;
			pixel[pos13] = maxnum;
			pixel[pos14] = maxnum;
			pixel[pos15] = maxnum;
			pixel[pos16] = maxnum;
			busy = 0;
		end
		min: begin	
			m1 = (pixel[pos1] < pixel[pos2]) ? pixel[pos1] :  pixel[pos2];
			m2 = (pixel[pos3] < pixel[pos4]) ? pixel[pos3] :  pixel[pos4];
			m3 = (pixel[pos5] < pixel[pos6]) ? pixel[pos5] :  pixel[pos6];
			m4 = (pixel[pos7] < pixel[pos8]) ? pixel[pos7] :  pixel[pos8];
			m5 = (pixel[pos9] < pixel[pos10]) ? pixel[pos9] :  pixel[pos10];
			m6 = (pixel[pos11] < pixel[pos12]) ? pixel[pos11] :  pixel[pos12];
			m7 = (pixel[pos13] < pixel[pos14]) ? pixel[pos13] :  pixel[pos14];
			m8 = (pixel[pos15] < pixel[pos16]) ? pixel[pos15] :  pixel[pos16];

			m9 = (m1 < m2) ? m1 : m2;
			m10 = (m3 < m4) ? m3 : m4;
			m11 = (m5 < m6) ? m5 : m6;
			m12 = (m7 < m8) ? m7 : m8;

			m13 = (m9 < m10) ? m9 : m10;
			m14 = (m11 < m12) ? m11 : m12;
			minnum = (m13 < m14) ? m13 : m14;
			pixel[pos1] = minnum;
			pixel[pos2] = minnum;
			pixel[pos3] = minnum;
			pixel[pos4] = minnum;
			pixel[pos5] = minnum;
			pixel[pos6] = minnum;
			pixel[pos7] = minnum;
			pixel[pos8] = minnum;
			pixel[pos9] = minnum;
			pixel[pos10] = minnum;
			pixel[pos11] = minnum;
			pixel[pos12] = minnum;
			pixel[pos13] = minnum;
			pixel[pos14] = minnum;
			pixel[pos15] = minnum;
			pixel[pos16] = minnum;

			busy = 0;
		end
		average: begin
			averagesum = 12'd0; 
			averagesum = pixel[pos1] + pixel[pos2] + pixel[pos3] + pixel[pos4]
						+ pixel[pos5] + pixel[pos6] + pixel[pos7] + pixel[pos8]
						+ pixel[pos9] + pixel[pos10] + pixel[pos11] + pixel[pos12]
						+ pixel[pos13] + pixel[pos14] + pixel[pos15] + pixel[pos16];
			 
			avgnum = averagesum >> 4;

			pixel[pos1] = avgnum;
			pixel[pos2] = avgnum;
			pixel[pos3] = avgnum;
			pixel[pos4] = avgnum;
			pixel[pos5] = avgnum;
			pixel[pos6] = avgnum;
			pixel[pos7] = avgnum;
			pixel[pos8] = avgnum;
			pixel[pos9] = avgnum;
			pixel[pos10] = avgnum;
			pixel[pos11] = avgnum;
			pixel[pos12] = avgnum;
			pixel[pos13] = avgnum;
			pixel[pos14] = avgnum;
			pixel[pos15] = avgnum;
			pixel[pos16] = avgnum;
			busy = 0;
		end
		idle: begin
			//do nothing
		end 
	endcase
end

endmodule

