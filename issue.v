module mux2x32(
    input wire s,
    input wire [31:0] a0,
    input wire [31:0] a1,
    output wire [31:0] out
);

    assign out = s ? a1 : a0;
    
endmodule

////////////////////////////////////////////////////////////////////////////////////////////////////
module mux4x32(
    input wire [1:0] s,
    input wire [31:0] a0,
    input wire [31:0] a1,
    input wire [31:0] a2,
    input wire [31:0] a3,
    output wire [31:0] out
);

    assign out = s == 2'b00 ? a0 : (s == 2'b01 ? a1 : (s == 2'b10 ? a2 : a3));
    
endmodule

////////////////////////////////////////////////////////////////////////////////////////////////////
module issue_queue(
	input wire clk,
	input wire resetn,
	input wire [31:0] din0,
	input wire [31:0] din1,
	input wire [31:0] din2,
	input wire [31:0] din3,
	input wire [2:0] write_num,
	input wire write_en,
	input wire [6:0] out_en, //corresponding bit will be enabled
	input wire [2:0] out_num0,
	input wire [2:0] out_num1,
	input wire out_en0,
	input wire out_en1,
	
	output wire [31:0] dout0,
	output wire [31:0] dout1,
	output reg  [2:0] count,
	output wire write_success //return the writing result
);

	reg [31:0] ISSUE_QUEUE [0:6];
	
	wire [31:0] IQ_update0;
	wire [31:0] IQ_update1;
	wire [31:0] IQ_update2;
	wire [31:0] IQ_update3;
	wire [31:0] IQ_update4;
	wire [31:0] IQ_update5;
	wire [31:0] IQ_update6;
	wire [1:0]  IQ_s0;
	wire [1:0]  IQ_s1;
	wire [1:0]  IQ_s2;
	wire [1:0]  IQ_s3;
	wire [1:0]  IQ_s4;
	wire [1:0]  IQ_s5;
	wire [1:0]  IQ_s6;
	
	wire out_two_2;
	wire out_two_3;
	wire out_two_4;
	wire out_two_5;
	wire out_two_6;
	
	wire [1:0] out_count;
	wire [2:0] w_ptr;
	
	assign out_count = {out_en0 & out_en1, out_en0 ^ out_en1};
	assign w_ptr = (count - {1'b0, out_count} < 0) ? (3'd0) : (count - {1'b0, out_count});
	assign write_success = (w_ptr + write_num > 4'd6) ? (1'b0) : (1'b1);
	
	assign dout0 = out_en0 ? ISSUE_QUEUE[out_num0] : 32'd0;
	assign dout1 = out_en1 ? ISSUE_QUEUE[out_num1] : 32'd0;
	
	assign out_two_2 = out_en[0] & out_en[1];
	assign out_two_3 = (out_en[0] & out_en[1]) | (out_en[0] & out_en[2]) | (out_en[1] & out_en[2]);
	assign out_two_4 = (out_en[0] & out_en[1]) | (out_en[0] & out_en[2]) | (out_en[0] & out_en[3]) | (out_en[1] & out_en[2]) | (out_en[1] & out_en[3]) | (out_en[2] & out_en[3]);
	assign out_two_5 = (out_en[0] & out_en[1]) | (out_en[0] & out_en[2]) | (out_en[0] & out_en[3]) | (out_en[0] & out_en[4]) | (out_en[1] & out_en[2]) | (out_en[1] & out_en[3]) |
					   (out_en[1] & out_en[4]) | (out_en[2] & out_en[3]) | (out_en[2] & out_en[4]) | (out_en[3] & out_en[4]);
					   
	assign IQ_s0 = out_en[0] ? (out_en[1] ? (2'b10) : (2'b01)) : (2'b00);
	assign IQ_s1 = out_en[0] ? ((out_en[1] | out_en[2]) ? (2'b10) : (2'b01)) : (out_en[1] ? (out_en[2] ? (2'b10) : (2'b01)) : (2'b00));
	assign IQ_s2 = (out_en[0] | out_en[1]) ? ((out_two_2 | out_en[2] | out_en[3]) ? (2'b10) : (2'b01)) : (out_en[2] ? (out_en[3] ? (2'b10) : (2'b01)) : (2'b00));
	assign IQ_s3 = (out_en[0] | out_en[1] | out_en[2]) ? ((out_two_3 | out_en[3] | out_en[4]) ? (2'b10) : (2'b01)) : (out_en[3] ? (out_en[4] ? (2'b10) : (2'b01)) : (2'b00));
	assign IQ_s4 = (out_en[0] | out_en[1] | out_en[2] | out_en[3]) ? ((out_two_4 | out_en[4] | out_en[5]) ? (2'b10) : (2'b01)) : (out_en[4] ? (out_en[5] ? (2'b10) : (2'b01)) : (2'b00));
	assign IQ_s5 = (out_en[0] | out_en[1] | out_en[2] | out_en[3] | out_en[4]) ? ((out_two_5 | out_en[5] | out_en[6]) ? (2'b10) : (2'b01)) : (2'b00);
	assign IQ_s6 = (out_en[0] | out_en[1] | out_en[2] | out_en[3] | out_en[4] | out_en[5] | out_en[6]) ? (1'b1) : (1'b0);
	
	mux4x32 mux0(
		.s(IQ_s0),
		.a0(ISSUE_QUEUE[3'd0]),
		.a1(ISSUE_QUEUE[3'd1]),
		.a2(ISSUE_QUEUE[3'd2]),
		.a3(32'd0),
		.out(IQ_update0)
	);
	
	mux4x32 mux1(
		.s(IQ_s1),
		.a0(ISSUE_QUEUE[3'd1]),
		.a1(ISSUE_QUEUE[3'd2]),
		.a2(ISSUE_QUEUE[3'd3]),
		.a3(32'd0),
		.out(IQ_update1)
	);
	
	mux4x32 mux2(
		.s(IQ_s2),
		.a0(ISSUE_QUEUE[3'd2]),
		.a1(ISSUE_QUEUE[3'd3]),
		.a2(ISSUE_QUEUE[3'd4]),
		.a3(32'd0),
		.out(IQ_update2)
	);
	
	mux4x32 mux3(
		.s(IQ_s3),
		.a0(ISSUE_QUEUE[3'd3]),
		.a1(ISSUE_QUEUE[3'd4]),
		.a2(ISSUE_QUEUE[3'd5]),
		.a3(32'd0),
		.out(IQ_update3)
	);
	
	mux4x32 mux4(
		.s(IQ_s4),
		.a0(ISSUE_QUEUE[3'd4]),
		.a1(ISSUE_QUEUE[3'd5]),
		.a2(ISSUE_QUEUE[3'd6]),
		.a3(32'd0),
		.out(IQ_update4)
	);
	
	mux4x32 mux5(
		.s(IQ_s5),
		.a0(ISSUE_QUEUE[3'd5]),
		.a1(ISSUE_QUEUE[3'd6]),
		.a2(32'd0),
		.a3(32'd0),
		.out(IQ_update5)
	);
	
	mux2x32 mux6(
		.s(IQ_s6),
		.a0(ISSUE_QUEUE[3'd6]),
		.a1(32'd0),
		.out(IQ_update6)
	);
	
	always@(posedge clk) begin
		if(~resetn) begin : initialize
			integer i;
			for(i = 0;i <= 6;i = i + 1) begin : loop
				ISSUE_QUEUE[i] <= 32'd0;
			end

			count <= 3'd0;
		end else begin
			if(write_en & write_success) begin
				case(w_ptr)
					3'd0 : begin
						case(write_num)
							3'd1 : begin
								ISSUE_QUEUE[3'd0] <= din0;
								ISSUE_QUEUE[3'd1] <= ISSUE_QUEUE[3'd1];
								ISSUE_QUEUE[3'd2] <= ISSUE_QUEUE[3'd2];
								ISSUE_QUEUE[3'd3] <= ISSUE_QUEUE[3'd3];
								ISSUE_QUEUE[3'd4] <= ISSUE_QUEUE[3'd4];
								ISSUE_QUEUE[3'd5] <= ISSUE_QUEUE[3'd5];
								ISSUE_QUEUE[3'd6] <= ISSUE_QUEUE[3'd6];
								count <= count + 3'd1;
							end
							3'd2 : begin
								ISSUE_QUEUE[3'd0] <= din0;
								ISSUE_QUEUE[3'd1] <= din1;
								ISSUE_QUEUE[3'd2] <= ISSUE_QUEUE[3'd2];
								ISSUE_QUEUE[3'd3] <= ISSUE_QUEUE[3'd3];
								ISSUE_QUEUE[3'd4] <= ISSUE_QUEUE[3'd4];
								ISSUE_QUEUE[3'd5] <= ISSUE_QUEUE[3'd5];
								ISSUE_QUEUE[3'd6] <= ISSUE_QUEUE[3'd6];
								count <= count + 3'd2;
							end
							3'd3 : begin
								ISSUE_QUEUE[3'd0] <= din0;
								ISSUE_QUEUE[3'd1] <= din1;
								ISSUE_QUEUE[3'd2] <= din2;
								ISSUE_QUEUE[3'd3] <= ISSUE_QUEUE[3'd3];
								ISSUE_QUEUE[3'd4] <= ISSUE_QUEUE[3'd4];
								ISSUE_QUEUE[3'd5] <= ISSUE_QUEUE[3'd5];
								ISSUE_QUEUE[3'd6] <= ISSUE_QUEUE[3'd6];
								count <= count + 3'd3;
							end
							3'd4 : begin
								ISSUE_QUEUE[3'd0] <= din0;
								ISSUE_QUEUE[3'd1] <= din1;
								ISSUE_QUEUE[3'd2] <= din2;
								ISSUE_QUEUE[3'd3] <= din3;
								ISSUE_QUEUE[3'd4] <= ISSUE_QUEUE[3'd4];
								ISSUE_QUEUE[3'd5] <= ISSUE_QUEUE[3'd5];
								ISSUE_QUEUE[3'd6] <= ISSUE_QUEUE[3'd6];
								count <= count + 3'd4;
							end
							default : begin
								ISSUE_QUEUE[3'd0] <= ISSUE_QUEUE[3'd0];
								ISSUE_QUEUE[3'd1] <= ISSUE_QUEUE[3'd1];
								ISSUE_QUEUE[3'd2] <= ISSUE_QUEUE[3'd2];
								ISSUE_QUEUE[3'd3] <= ISSUE_QUEUE[3'd3];
								ISSUE_QUEUE[3'd4] <= ISSUE_QUEUE[3'd4];
								ISSUE_QUEUE[3'd5] <= ISSUE_QUEUE[3'd5];
								ISSUE_QUEUE[3'd6] <= ISSUE_QUEUE[3'd6];
								count <= count;
							end
						endcase
					end
					3'd1 : begin
						case(write_num)
							3'd1 : begin
								ISSUE_QUEUE[3'd0] <= IQ_update0;
								ISSUE_QUEUE[3'd1] <= din0;
								ISSUE_QUEUE[3'd2] <= ISSUE_QUEUE[3'd2];
								ISSUE_QUEUE[3'd3] <= ISSUE_QUEUE[3'd3];
								ISSUE_QUEUE[3'd4] <= ISSUE_QUEUE[3'd4];
								ISSUE_QUEUE[3'd5] <= ISSUE_QUEUE[3'd5];
								ISSUE_QUEUE[3'd6] <= ISSUE_QUEUE[3'd6];
								count <= count + 3'd1;
							end
							3'd2 : begin
								ISSUE_QUEUE[3'd0] <= IQ_update0;
								ISSUE_QUEUE[3'd1] <= din0;
								ISSUE_QUEUE[3'd2] <= din1;
								ISSUE_QUEUE[3'd3] <= ISSUE_QUEUE[3'd3];
								ISSUE_QUEUE[3'd4] <= ISSUE_QUEUE[3'd4];
								ISSUE_QUEUE[3'd5] <= ISSUE_QUEUE[3'd5];
								ISSUE_QUEUE[3'd6] <= ISSUE_QUEUE[3'd6];
								count <= count + 3'd2;
							end
							3'd3 : begin
								ISSUE_QUEUE[3'd0] <= IQ_update0;
								ISSUE_QUEUE[3'd1] <= din0;
								ISSUE_QUEUE[3'd2] <= din1;
								ISSUE_QUEUE[3'd3] <= din2;
								ISSUE_QUEUE[3'd4] <= ISSUE_QUEUE[3'd4];
								ISSUE_QUEUE[3'd5] <= ISSUE_QUEUE[3'd5];
								ISSUE_QUEUE[3'd6] <= ISSUE_QUEUE[3'd6];
								count <= count + 3'd3;
							end
							3'd4 : begin
								ISSUE_QUEUE[3'd0] <= IQ_update0;
								ISSUE_QUEUE[3'd1] <= din0;
								ISSUE_QUEUE[3'd2] <= din1;
								ISSUE_QUEUE[3'd3] <= din2;
								ISSUE_QUEUE[3'd4] <= din3;
								ISSUE_QUEUE[3'd5] <= ISSUE_QUEUE[3'd5];
								ISSUE_QUEUE[3'd6] <= ISSUE_QUEUE[3'd6];
								count <= count + 3'd4;
							end
							default : begin
								ISSUE_QUEUE[3'd0] <= ISSUE_QUEUE[3'd0];
								ISSUE_QUEUE[3'd1] <= ISSUE_QUEUE[3'd1];
								ISSUE_QUEUE[3'd2] <= ISSUE_QUEUE[3'd2];
								ISSUE_QUEUE[3'd3] <= ISSUE_QUEUE[3'd3];
								ISSUE_QUEUE[3'd4] <= ISSUE_QUEUE[3'd4];
								ISSUE_QUEUE[3'd5] <= ISSUE_QUEUE[3'd5];
								ISSUE_QUEUE[3'd6] <= ISSUE_QUEUE[3'd6];
								count <= count;
							end
						endcase
					end
					3'd2 : begin
						case(write_num)
							3'd1 : begin
								ISSUE_QUEUE[3'd0] <= IQ_update0;
								ISSUE_QUEUE[3'd1] <= IQ_update1;
								ISSUE_QUEUE[3'd2] <= din0;
								ISSUE_QUEUE[3'd3] <= ISSUE_QUEUE[3'd3];
								ISSUE_QUEUE[3'd4] <= ISSUE_QUEUE[3'd4];
								ISSUE_QUEUE[3'd5] <= ISSUE_QUEUE[3'd5];
								ISSUE_QUEUE[3'd6] <= ISSUE_QUEUE[3'd6];
								count <= count + 3'd1;
							end
							3'd2 : begin
								ISSUE_QUEUE[3'd0] <= IQ_update0;
								ISSUE_QUEUE[3'd1] <= IQ_update1;
								ISSUE_QUEUE[3'd2] <= din0;
								ISSUE_QUEUE[3'd3] <= din1;
								ISSUE_QUEUE[3'd4] <= ISSUE_QUEUE[3'd4];
								ISSUE_QUEUE[3'd5] <= ISSUE_QUEUE[3'd5];
								ISSUE_QUEUE[3'd6] <= ISSUE_QUEUE[3'd6];
								count <= count + 3'd2;
							end
							3'd3 : begin
								ISSUE_QUEUE[3'd0] <= IQ_update0;
								ISSUE_QUEUE[3'd1] <= IQ_update1;
								ISSUE_QUEUE[3'd2] <= din0;
								ISSUE_QUEUE[3'd3] <= din1;
								ISSUE_QUEUE[3'd4] <= din2;
								ISSUE_QUEUE[3'd5] <= ISSUE_QUEUE[3'd5];
								ISSUE_QUEUE[3'd6] <= ISSUE_QUEUE[3'd6];
								count <= count + 3'd3;
							end
							3'd4 : begin
								ISSUE_QUEUE[3'd0] <= IQ_update0;
								ISSUE_QUEUE[3'd1] <= IQ_update1;
								ISSUE_QUEUE[3'd2] <= din0;
								ISSUE_QUEUE[3'd3] <= din1;
								ISSUE_QUEUE[3'd4] <= din2;
								ISSUE_QUEUE[3'd5] <= din3;
								ISSUE_QUEUE[3'd6] <= ISSUE_QUEUE[3'd6];
								count <= count + 3'd4;
							end
							default : begin
								ISSUE_QUEUE[3'd0] <= ISSUE_QUEUE[3'd0];
								ISSUE_QUEUE[3'd1] <= ISSUE_QUEUE[3'd1];
								ISSUE_QUEUE[3'd2] <= ISSUE_QUEUE[3'd2];
								ISSUE_QUEUE[3'd3] <= ISSUE_QUEUE[3'd3];
								ISSUE_QUEUE[3'd4] <= ISSUE_QUEUE[3'd4];
								ISSUE_QUEUE[3'd5] <= ISSUE_QUEUE[3'd5];
								ISSUE_QUEUE[3'd6] <= ISSUE_QUEUE[3'd6];
								count <= count;
							end
						endcase
					end
					3'd3 : begin
						case(write_num)
							3'd1 : begin
								ISSUE_QUEUE[3'd0] <= IQ_update0;
								ISSUE_QUEUE[3'd1] <= IQ_update1;
								ISSUE_QUEUE[3'd2] <= IQ_update2;
								ISSUE_QUEUE[3'd3] <= din0;
								ISSUE_QUEUE[3'd4] <= ISSUE_QUEUE[3'd4];
								ISSUE_QUEUE[3'd5] <= ISSUE_QUEUE[3'd5];
								ISSUE_QUEUE[3'd6] <= ISSUE_QUEUE[3'd6];
								count <= count + 3'd1;
							end
							3'd2 : begin
								ISSUE_QUEUE[3'd0] <= IQ_update0;
								ISSUE_QUEUE[3'd1] <= IQ_update1;
								ISSUE_QUEUE[3'd2] <= IQ_update2;
								ISSUE_QUEUE[3'd3] <= din0;
								ISSUE_QUEUE[3'd4] <= din1;
								ISSUE_QUEUE[3'd5] <= ISSUE_QUEUE[3'd5];
								ISSUE_QUEUE[3'd6] <= ISSUE_QUEUE[3'd6];
								count <= count + 3'd2;
							end
							3'd3 : begin
								ISSUE_QUEUE[3'd0] <= IQ_update0;
								ISSUE_QUEUE[3'd1] <= IQ_update1;
								ISSUE_QUEUE[3'd2] <= IQ_update2;
								ISSUE_QUEUE[3'd3] <= din0;
								ISSUE_QUEUE[3'd4] <= din1;
								ISSUE_QUEUE[3'd5] <= din2;
								ISSUE_QUEUE[3'd6] <= ISSUE_QUEUE[3'd6];
								count <= count + 3'd3;
							end
							3'd4 : begin
								ISSUE_QUEUE[3'd0] <= IQ_update0;
								ISSUE_QUEUE[3'd1] <= IQ_update1;
								ISSUE_QUEUE[3'd2] <= IQ_update2;
								ISSUE_QUEUE[3'd3] <= din0;
								ISSUE_QUEUE[3'd4] <= din1;
								ISSUE_QUEUE[3'd5] <= din2;
								ISSUE_QUEUE[3'd6] <= din3;
								count <= count + 3'd4;
							end
							default : begin
								ISSUE_QUEUE[3'd0] <= ISSUE_QUEUE[3'd0];
								ISSUE_QUEUE[3'd1] <= ISSUE_QUEUE[3'd1];
								ISSUE_QUEUE[3'd2] <= ISSUE_QUEUE[3'd2];
								ISSUE_QUEUE[3'd3] <= ISSUE_QUEUE[3'd3];
								ISSUE_QUEUE[3'd4] <= ISSUE_QUEUE[3'd4];
								ISSUE_QUEUE[3'd5] <= ISSUE_QUEUE[3'd5];
								ISSUE_QUEUE[3'd6] <= ISSUE_QUEUE[3'd6];
								count <= count;
							end
						endcase
					end
					3'd4 : begin
						case(write_num)
							3'd1 : begin
								ISSUE_QUEUE[3'd0] <= IQ_update0;
								ISSUE_QUEUE[3'd1] <= IQ_update1;
								ISSUE_QUEUE[3'd2] <= IQ_update2;
								ISSUE_QUEUE[3'd3] <= IQ_update3;
								ISSUE_QUEUE[3'd4] <= din0;
								ISSUE_QUEUE[3'd5] <= ISSUE_QUEUE[3'd5];
								ISSUE_QUEUE[3'd6] <= ISSUE_QUEUE[3'd6];
								count <= count + 3'd1;
							end
							3'd2 : begin
								ISSUE_QUEUE[3'd0] <= IQ_update0;
								ISSUE_QUEUE[3'd1] <= IQ_update1;
								ISSUE_QUEUE[3'd2] <= IQ_update2;
								ISSUE_QUEUE[3'd3] <= IQ_update3;
								ISSUE_QUEUE[3'd4] <= din0;
								ISSUE_QUEUE[3'd5] <= din1;
								ISSUE_QUEUE[3'd6] <= ISSUE_QUEUE[3'd6];
								count <= count + 3'd2;
							end
							3'd3 : begin
								ISSUE_QUEUE[3'd0] <= IQ_update0;
								ISSUE_QUEUE[3'd1] <= IQ_update1;
								ISSUE_QUEUE[3'd2] <= IQ_update2;
								ISSUE_QUEUE[3'd3] <= IQ_update3;
								ISSUE_QUEUE[3'd4] <= din0;
								ISSUE_QUEUE[3'd5] <= din1;
								ISSUE_QUEUE[3'd6] <= din2;
								count <= count + 3'd3;
							end
							default : begin
								ISSUE_QUEUE[3'd0] <= ISSUE_QUEUE[3'd0];
								ISSUE_QUEUE[3'd1] <= ISSUE_QUEUE[3'd1];
								ISSUE_QUEUE[3'd2] <= ISSUE_QUEUE[3'd2];
								ISSUE_QUEUE[3'd3] <= ISSUE_QUEUE[3'd3];
								ISSUE_QUEUE[3'd4] <= ISSUE_QUEUE[3'd4];
								ISSUE_QUEUE[3'd5] <= ISSUE_QUEUE[3'd5];
								ISSUE_QUEUE[3'd6] <= ISSUE_QUEUE[3'd6];
								count <= count;
							end
						endcase
					end
					3'd5 : begin
						case(write_num)
							3'd1 : begin
								ISSUE_QUEUE[3'd0] <= IQ_update0;
								ISSUE_QUEUE[3'd1] <= IQ_update1;
								ISSUE_QUEUE[3'd2] <= IQ_update2;
								ISSUE_QUEUE[3'd3] <= IQ_update3;
								ISSUE_QUEUE[3'd4] <= IQ_update4;
								ISSUE_QUEUE[3'd5] <= din0;
								ISSUE_QUEUE[3'd6] <= ISSUE_QUEUE[3'd6];
								count <= count + 3'd1;
							end
							3'd2 : begin
								ISSUE_QUEUE[3'd0] <= IQ_update0;
								ISSUE_QUEUE[3'd1] <= IQ_update1;
								ISSUE_QUEUE[3'd2] <= IQ_update2;
								ISSUE_QUEUE[3'd3] <= IQ_update3;
								ISSUE_QUEUE[3'd4] <= IQ_update4;
								ISSUE_QUEUE[3'd5] <= din0;
								ISSUE_QUEUE[3'd6] <= din1;
								count <= count + 3'd2;
							end
							default : begin
								ISSUE_QUEUE[3'd0] <= ISSUE_QUEUE[3'd0];
								ISSUE_QUEUE[3'd1] <= ISSUE_QUEUE[3'd1];
								ISSUE_QUEUE[3'd2] <= ISSUE_QUEUE[3'd2];
								ISSUE_QUEUE[3'd3] <= ISSUE_QUEUE[3'd3];
								ISSUE_QUEUE[3'd4] <= ISSUE_QUEUE[3'd4];
								ISSUE_QUEUE[3'd5] <= ISSUE_QUEUE[3'd5];
								ISSUE_QUEUE[3'd6] <= ISSUE_QUEUE[3'd6];
								count <= count;
							end
						endcase
					end
					3'd6 : begin
						case(write_num)
							3'd1 : begin
								ISSUE_QUEUE[3'd0] <= IQ_update0;
								ISSUE_QUEUE[3'd1] <= IQ_update1;
								ISSUE_QUEUE[3'd2] <= IQ_update2;
								ISSUE_QUEUE[3'd3] <= IQ_update3;
								ISSUE_QUEUE[3'd4] <= IQ_update4;
								ISSUE_QUEUE[3'd5] <= IQ_update5;
								ISSUE_QUEUE[3'd6] <= din0;
								count <= count + 3'd1;
							end
							default : begin
								ISSUE_QUEUE[3'd0] <= ISSUE_QUEUE[3'd0];
								ISSUE_QUEUE[3'd1] <= ISSUE_QUEUE[3'd1];
								ISSUE_QUEUE[3'd2] <= ISSUE_QUEUE[3'd2];
								ISSUE_QUEUE[3'd3] <= ISSUE_QUEUE[3'd3];
								ISSUE_QUEUE[3'd4] <= ISSUE_QUEUE[3'd4];
								ISSUE_QUEUE[3'd5] <= ISSUE_QUEUE[3'd5];
								ISSUE_QUEUE[3'd6] <= ISSUE_QUEUE[3'd6];
								count <= count;
							end
						endcase
					end
					default : begin
						ISSUE_QUEUE[3'd0] <= ISSUE_QUEUE[3'd0];
						ISSUE_QUEUE[3'd1] <= ISSUE_QUEUE[3'd1];
						ISSUE_QUEUE[3'd2] <= ISSUE_QUEUE[3'd2];
						ISSUE_QUEUE[3'd3] <= ISSUE_QUEUE[3'd3];
						ISSUE_QUEUE[3'd4] <= ISSUE_QUEUE[3'd4];
						ISSUE_QUEUE[3'd5] <= ISSUE_QUEUE[3'd5];
						ISSUE_QUEUE[3'd6] <= ISSUE_QUEUE[3'd6];
						count <= count;
					end
				endcase
			end else begin
				ISSUE_QUEUE[3'd0] <= IQ_update0;
				ISSUE_QUEUE[3'd1] <= IQ_update1;
				ISSUE_QUEUE[3'd2] <= IQ_update2;
				ISSUE_QUEUE[3'd3] <= IQ_update3;
				ISSUE_QUEUE[3'd4] <= IQ_update4;
				ISSUE_QUEUE[3'd5] <= IQ_update5;
				ISSUE_QUEUE[3'd6] <= IQ_update6;
			end
		end
	end

endmodule