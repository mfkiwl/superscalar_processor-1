module select(
    input wire [20:0] IQ_ALU_dout0,
    input wire [20:0] IQ_ALU_dout1,
    input wire [20:0] IQ_ALU_dout2,
    input wire [20:0] IQ_ALU_dout3,
    input wire [20:0] IQ_ALU_dout4,
    input wire [20:0] IQ_ALU_dout5,
    input wire [20:0] IQ_ALU_dout6,

    input wire [20:0] IQ_LS_dout0,
    input wire [20:0] IQ_LS_dout1,
    input wire [20:0] IQ_LS_dout2,
    input wire [20:0] IQ_LS_dout3,
    input wire [20:0] IQ_LS_dout4,
    input wire [20:0] IQ_LS_dout5,
    input wire [20:0] IQ_LS_dout6,

    input wire [120:0] IQ_MD_dout0,
    input wire [120:0] IQ_MD_dout1,
    input wire [120:0] IQ_MD_dout2,
    input wire [120:0] IQ_MD_dout3,
    input wire [120:0] IQ_MD_dout4,
    input wire [120:0] IQ_MD_dout5,
    input wire [120:0] IQ_MD_dout6,

    output wire [2:0] IQ_ALU_select_num0,
    output wire IQ_ALU_select_en0,
    output wire [2:0] IQ_ALU_select_num1,
    output wire IQ_ALU_select_en1,
    output wire [6:0] IQ_ALU_select_en,
    output wire [2:0] IQ_LS_select_num,
    output wire IQ_LS_select_en,
    output wire [2:0] IQ_MD_select_num,
    output wire IQ_MD_select_en,

	output wire [1:0] IQ_ALU_wakeup0,
	output wire [1:0] IQ_ALU_wakeup1,
	output wire [1:0] IQ_ALU_wakeup2,
	output wire [1:0] IQ_ALU_wakeup3,
	output wire [1:0] IQ_ALU_wakeup4,
	output wire [1:0] IQ_ALU_wakeup5,
	output wire [1:0] IQ_ALU_wakeup6,

	output wire [1:0] IQ_LS_wakeup0,
	output wire [1:0] IQ_LS_wakeup1,
	output wire [1:0] IQ_LS_wakeup2,
	output wire [1:0] IQ_LS_wakeup3,
	output wire [1:0] IQ_LS_wakeup4,
	output wire [1:0] IQ_LS_wakeup5,
	output wire [1:0] IQ_LS_wakeup6,

	output wire [1:0] IQ_MD_wakeup0,
	output wire [1:0] IQ_MD_wakeup1,
	output wire [1:0] IQ_MD_wakeup2,
	output wire [1:0] IQ_MD_wakeup3,
	output wire [1:0] IQ_MD_wakeup4,
	output wire [1:0] IQ_MD_wakeup5,
	output wire [1:0] IQ_MD_wakeup6
);

	wire [6:0] rdy_MD;
	wire [6:0] rdy_LS;
	wire [6:0] rdy_ALU;

	wire [6:0] issued_MD;
	wire [6:0] issued_LS;
	wire [6:0] issued_ALU;

	wire [2:0] select_num_MD;
	wire [2:0] select_num_LS;
	wire [2:0] select_num_ALU0;
	wire [2:0] select_num_ALU1;

	wire select_en_MD;
	wire select_en_LS;
	wire select_en0_ALU;
	wire select_en1_ALU;
	wire [6:0] select_en_ALU;

	reg [4:0] wakeup_reg_ALU0;
	reg [4:0] wakeup_reg_ALU1;
	reg [4:0] wakeup_reg_MD;
	reg [4:0] wakeup_reg_LS;

	wire wakeup_ALU_en0;
	wire wakeup_ALU_en1;
	wire [6:0] wakeup_ALU_en;
	wire wakeup_MD_en;
	wire wakeup_LS_en;

	assign rdy_LS = {
		IQ_MD_dout6[114] & IQ_MD_dout6[75],
		IQ_MD_dout5[114] & IQ_MD_dout5[75],
		IQ_MD_dout4[114] & IQ_MD_dout4[75],
		IQ_MD_dout3[114] & IQ_MD_dout3[75],
		IQ_MD_dout2[114] & IQ_MD_dout2[75],
		IQ_MD_dout1[114] & IQ_MD_dout1[75],
		IQ_MD_dout0[114] & IQ_MD_dout0[75]
	};

	assign rdy_LS = {
		IQ_LS_dout6[14] & IQ_LS_dout6[7],
		IQ_LS_dout5[14] & IQ_LS_dout5[7],
		IQ_LS_dout4[14] & IQ_LS_dout4[7],
		IQ_LS_dout3[14] & IQ_LS_dout3[7],
		IQ_LS_dout2[14] & IQ_LS_dout2[7],
		IQ_LS_dout1[14] & IQ_LS_dout1[7],
		IQ_LS_dout0[14] & IQ_LS_dout0[7]
	};

	assign rdy_ALU = {
		IQ_ALU_dout6[14] & IQ_ALU_dout6[7],
		IQ_ALU_dout5[14] & IQ_ALU_dout5[7],
		IQ_ALU_dout4[14] & IQ_ALU_dout4[7],
		IQ_ALU_dout3[14] & IQ_ALU_dout3[7],
		IQ_ALU_dout2[14] & IQ_ALU_dout2[7],
		IQ_ALU_dout1[14] & IQ_ALU_dout1[7],
		IQ_ALU_dout0[14] & IQ_ALU_dout0[7]
	};

	assign issued_MD = {
		IQ_MD_dout6[120],
		IQ_MD_dout5[120],
		IQ_MD_dout4[120],
		IQ_MD_dout3[120],
		IQ_MD_dout2[120],
		IQ_MD_dout1[120],
		IQ_MD_dout0[120]
	};

	assign issued_LS = {
		IQ_LS_dout6[0],
		IQ_LS_dout5[0],
		IQ_LS_dout4[0],
		IQ_LS_dout3[0],
		IQ_LS_dout2[0],
		IQ_LS_dout1[0],
		IQ_LS_dout0[0]
	};

	assign issued_ALU = {
		IQ_ALU_dout6[0],
		IQ_ALU_dout5[0],
		IQ_ALU_dout4[0],
		IQ_ALU_dout3[0],
		IQ_ALU_dout2[0],
		IQ_ALU_dout1[0],
		IQ_ALU_dout0[0]
	};

	assign IQ_ALU_wakeup0 = {};

	One_M_Select Select_MD(
		.rdy(rdy_MD),
		.issued(issued_MD),
		.num(select_num_MD),
		.en(select_en_MD)
	);

	One_M_Select Select_LS(
		.rdy(rdy_LS),
		.issued(issued_LS),
		.num(select_num_LS),
		.en(select_en_LS)
	);

	Two_M_Select Select_ALU(
		.rdy(rdy_ALU),
		.issued(issued_ALU),
		.num0(select_num_ALU0),
		.num1(select_num_ALU1),
		.en(select_en_ALU),
		.en0(select_en0_ALU),
		.en1(select_en1_ALU)
	);

	always @(*) begin
		case(select_num_MD)
			3'd0 : begin
				wakeup_reg_MD <= IQ_MD_dout0[38:34];
			end
			3'd1 : begin
				wakeup_reg_MD <= IQ_MD_dout1[38:34];
			end
			3'd2 : begin
				wakeup_reg_MD <= IQ_MD_dout2[38:34];
			end
			3'd3 : begin
				wakeup_reg_MD <= IQ_MD_dout3[38:34];
			end
			3'd4 : begin
				wakeup_reg_MD <= IQ_MD_dout4[38:34];
			end
			3'd5 : begin
				wakeup_reg_MD <= IQ_MD_dout5[38:34];
			end
			3'd6 : begin
				wakeup_reg_MD <= IQ_MD_dout6[38:34];
			end
			default : begin
				wakeup_reg_MD <= 5'd0;
			end
		endcase
	end

	always @(*) begin
		case(select_num_LS)
			3'd0 : begin
				wakeup_reg_LS <= IQ_LS_dout0[6:2];
			end
			3'd1 : begin
				wakeup_reg_LS <= IQ_LS_dout1[6:2];
			end
			3'd2 : begin
				wakeup_reg_LS <= IQ_LS_dout2[6:2];
			end
			3'd3 : begin
				wakeup_reg_LS <= IQ_LS_dout3[6:2];
			end
			3'd4 : begin
				wakeup_reg_LS <= IQ_LS_dout4[6:2];
			end
			3'd5 : begin
				wakeup_reg_LS <= IQ_LS_dout5[6:2];
			end
			3'd6 : begin
				wakeup_reg_LS <= IQ_LS_dout6[6:2];
			end
			default : begin
				wakeup_reg_LS <= 5'd0;
			end
		endcase
	end

	always @(*) begin
		case(select_num_ALU0)
			3'd0 : begin
				wakeup_reg_ALU0 <= IQ_ALU_dout0[6:2];
			end
			3'd1 : begin
				wakeup_reg_ALU0 <= IQ_ALU_dout1[6:2];
			end
			3'd2 : begin
				wakeup_reg_ALU0 <= IQ_ALU_dout2[6:2];
			end
			3'd3 : begin
				wakeup_reg_ALU0 <= IQ_ALU_dout3[6:2];
			end
			3'd4 : begin
				wakeup_reg_ALU0 <= IQ_ALU_dout4[6:2];
			end
			3'd5 : begin
				wakeup_reg_ALU0 <= IQ_ALU_dout5[6:2];
			end
			3'd6 : begin
				wakeup_reg_ALU0 <= IQ_ALU_dout6[6:2];
			end
			default : begin
				wakeup_reg_ALU0 <= 5'd0;
			end
		endcase
		case(select_num_ALU1)
			3'd0 : begin
				wakeup_reg_ALU1 <= IQ_ALU_dout0[6:2];
			end
			3'd1 : begin
				wakeup_reg_ALU1 <= IQ_ALU_dout1[6:2];
			end
			3'd2 : begin
				wakeup_reg_ALU1 <= IQ_ALU_dout2[6:2];
			end
			3'd3 : begin
				wakeup_reg_ALU1 <= IQ_ALU_dout3[6:2];
			end
			3'd4 : begin
				wakeup_reg_ALU1 <= IQ_ALU_dout4[6:2];
			end
			3'd5 : begin
				wakeup_reg_ALU1 <= IQ_ALU_dout5[6:2];
			end
			3'd6 : begin
				wakeup_reg_ALU1 <= IQ_ALU_dout6[6:2];
			end
			default : begin
				wakeup_reg_ALU1 <= 5'd0;
			end
		endcase
	end

endmodule

////////////////////////////////////////////////////////////////////////////////////////////////////
module One_M_Select(
	input wire [6:0] rdy,
	input wire [6:0] issued,
	output reg [2:0] num,
	output reg en
);

	always@(*) begin
		if(rdy[0] == 1'b1 && issued[0] != 1'b1) begin
			num <= 3'd0;
			en  <= 1'b1;
		end else if(rdy[1] == 1'b1 && issued[1] != 1'b1) begin
			num <= 3'd1;
			en  <= 1'b1;
		end else if(rdy[2] == 1'b1 && issued[2] != 1'b1) begin
			num <= 3'd2;
			en  <= 1'b1;
		end else if(rdy[3] == 1'b1 && issued[3] != 1'b1) begin
			num <= 3'd3;
			en  <= 1'b1;
		end else if(rdy[4] == 1'b1 && issued[4] != 1'b1) begin
			num <= 3'd4;
			en  <= 1'b1;
		end else if(rdy[5] == 1'b1 && issued[5] != 1'b1) begin
			num <= 3'd5;
			en  <= 1'b1;
		end else if(rdy[6] == 1'b1 && issued[6] != 1'b1) begin
			num <= 3'd6;
			en  <= 1'b1;
		end else begin
			num <= 3'd7;
			en  <= 1'b0;
		end
	end
	
endmodule

////////////////////////////////////////////////////////////////////////////////////////////////////
module Two_M_Select(
	input wire [6:0] rdy,
	input wire [6:0] issued,
	output reg [2:0] num0,
	output reg [2:0] num1,
	output reg en0,
	output reg en1,
    output reg [6:0] en
);

	always@(*) begin
		if(rdy[0] == 1'b1 && issued[0] != 1'b1) begin
			num0 <= 3'd0;
			en0  <= 1'b1;
			if(rdy[1] == 1'b1 && issued[1] != 1'b1) begin
				num1 <= 3'd1;
				en1  <= 1'b1;
                en   <= 7'b0000011;
			end else if(rdy[2] == 1'b1 && issued[2] != 1'b1) begin
				num1 <= 3'd2;
				en1  <= 1'b1;
                en   <= 7'b0000101;
			end else if(rdy[3] == 1'b1 && issued[3] != 1'b1) begin
				num1 <= 3'd3;
				en1  <= 1'b1;
                en   <= 7'b0001001;
			end else if(rdy[4] == 1'b1 && issued[4] != 1'b1) begin
				num1 <= 3'd4;
				en1  <= 1'b1;
                en   <= 7'b0010001;
			end else if(rdy[5] == 1'b1 && issued[5] != 1'b1) begin
				num1 <= 3'd5;
				en1  <= 1'b1;
                en   <= 7'b0100001;
			end else if(rdy[6] == 1'b1 && issued[6] != 1'b1) begin
				num1 <= 3'd6;
				en1  <= 1'b1;
                en   <= 7'b1000001;
			end else begin
				num1 <= 3'd7;
				en1  <= 1'b0;
                en   <= 7'b0000001;
			end
		end else if(rdy[1] == 1'b1 && issued[1] != 1'b1) begin
			num0 <= 3'd1;
			en0  <= 1'b1;
			if(rdy[2] == 1'b1 && issued[2] != 1'b1) begin
				num1 <= 3'd2;
				en1  <= 1'b1;
                en   <= 7'b0000110;
			end else if(rdy[3] == 1'b1 && issued[3] != 1'b1) begin
				num1 <= 3'd3;
				en1  <= 1'b1;
                en   <= 7'b0001010;
			end else if(rdy[4] == 1'b1 && issued[4] != 1'b1) begin
				num1 <= 3'd4;
				en1  <= 1'b1;
                en   <= 7'b0010010;
			end else if(rdy[5] == 1'b1 && issued[5] != 1'b1) begin
				num1 <= 3'd5;
				en1  <= 1'b1;
                en   <= 7'b0100010;
			end else if(rdy[6] == 1'b1 && issued[6] != 1'b1) begin
				num1 <= 3'd6;
				en1  <= 1'b1;
                en   <= 7'b1000010;
			end else begin
				num1 <= 3'd7;
				en1  <= 1'b0;
                en   <= 7'b0000010;
			end
		end else if(rdy[2] == 1'b1 && issued[2] != 1'b1) begin
			num0 <= 3'd2;
			en0  <= 1'b1;
			if(rdy[3] == 1'b1 && issued[3] != 1'b1) begin
				num1 <= 3'd3;
				en1  <= 1'b1;
                en   <= 7'b0001100;
			end else if(rdy[4] == 1'b1 && issued[4] != 1'b1) begin
				num1 <= 3'd4;
				en1  <= 1'b1;
                en   <= 7'b0010100;
			end else if(rdy[5] == 1'b1 && issued[5] != 1'b1) begin
				num1 <= 3'd5;
				en1  <= 1'b1;
                en   <= 7'b0100100;
			end else if(rdy[6] == 1'b1 && issued[6] != 1'b1) begin
				num1 <= 3'd6;
				en1  <= 1'b1;
                en   <= 7'b1000100;
			end else begin
				num1 <= 3'd7;
				en1  <= 1'b0;
                en   <= 7'b0000100;
			end
		end else if(rdy[3] == 1'b1 && issued[3] != 1'b1) begin
			num0 <= 3'd3;
			en0  <= 1'b1;
			if(rdy[4] == 1'b1 && issued[4] != 1'b1) begin
				num1 <= 3'd4;
				en1  <= 1'b1;
                en   <= 7'b0011000;
			end else if(rdy[5] == 1'b1 && issued[5] != 1'b1) begin
				num1 <= 3'd5;
				en1  <= 1'b1;
                en   <= 7'b0101000;
			end else if(rdy[6] == 1'b1 && issued[6] != 1'b1) begin
				num1 <= 3'd6;
				en1  <= 1'b1;
                en   <= 7'b1001000;
			end else begin
				num1 <= 3'd7;
				en1  <= 1'b0;
                en   <= 7'b0001000;
			end
		end else if(rdy[4] == 1'b1 && issued[4] != 1'b1) begin
			num0 <= 3'd4;
			en0  <= 1'b1;
			if(rdy[5] == 1'b1 && issued[5] != 1'b1) begin
				num1 <= 3'd5;
				en1  <= 1'b1;
                en   <= 7'b0110000;
			end else if(rdy[6] == 1'b1 && issued[6] != 1'b1) begin
				num1 <= 3'd6;
				en1  <= 1'b1;
                en   <= 7'b1010000;
			end else begin
				num1 <= 3'd7;
				en1  <= 1'b0;
                en   <= 7'b0010000;
			end
		end else if(rdy[5] == 1'b1 && issued[5] != 1'b1) begin
			num0 <= 3'd5;
			en0  <= 1'b1;
			if(rdy[6] == 1'b1 && issued[6] != 1'b1) begin
				num1 <= 3'd6;
				en1  <= 1'b1;
                en   <= 7'b1100000;
			end else begin
				num1 <= 3'd7;
				en1  <= 1'b0;
                en   <= 7'b0100000;
			end
		end else if(rdy[6] == 1'b1 && issued[6] != 1'b1) begin
			num0 <= 3'd6;
			en0  <= 1'b1;
			num1 <= 3'd7;
			en1  <= 1'b0;
            en   <= 7'b1000000;
		end else begin
			num0 <= 3'd7;
			en0  <= 1'b0;
			num1 <= 3'd7;
			en1  <= 1'b0;
            en   <= 7'b0000000;
		end
	end

endmodule