module mux4x32(
    input [1:0] s,
    input [31:0] a0,
    input [31:0] a1,
    input [31:0] a2,
    input [31:0] a3,
    output [31:0] out
);

    assign out = s == 2'b00 ? a0 : (s == 2'b01 ? a1 : (s == 2'b10 ? a2 : (s == 2'b11 ? a3 : 32'd0)));
    
endmodule

////////////////////////////////////////////////////////////////////////////////////////////////////
module issue_queue(
	input wire clk,
	input wire resetn,
	input wire [31:0] inst0,
	input wire [31:0] inst1,
	input wire [1:0] wen,
	input wire [7:0] out_en, //corresponding bit will be enabled
	
	output wire [31:0] inst0,
	output wire [31:0] inst1
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
	
	assign out_two_2 = out_en[0] & out_en[1];
	assign out_two_3 = (out_en[0] & out_en[1]) | (out_en[0] & out_en[2]) | (out_en[1] & out_en[2]);
	assign out_two_4 = (out_en[0] & out_en[1]) | (out_en[0] & out_en[2]) | (out_en[0] & out_en[3]) | (out_en[1] & out_en[2]) | (out_en[1] & out_en[3]) | (out_en[2] & out_en[3]);
	assign out_two_5 = (out_en[0] & out_en[1]) | (out_en[0] & out_en[2]) | (out_en[0] & out_en[3]) | (out_en[0] & out_en[4]) | (out_en[1] & out_en[2]) | (out_en[1] & out_en[3]) |
					   (out_en[1] & out_en[4]) | (out_en[2] & out_en[3]) | (out_en[2] & out_en[4]) | (out_en[3] & out_en[4]);
	assign out_two_6 = (out_en[0] & out_en[1]) | (out_en[0] & out_en[2]) | (out_en[0] & out_en[3]) | (out_en[0] & out_en[4]) | (out_en[0] & out_en[5]) | (out_en[1] & out_en[2]) |
					   (out_en[1] & out_en[3]) | (out_en[1] & out_en[4]) | (out_en[1] & out_en[5]) | (out_en[2] & out_en[3]) | (out_en[2] & out_en[4]) | (out_en[2] & out_en[5]) |
					   (out_en[3] & out_en[4]) | (out_en[3] & out_en[5]) | (out_en[4] & out_en[5]);
					   
	assign IQ_s0 = out_en[0] ? (out_en[1] ? (2'b10) : (2'b01)) : (2'b00);
	assign IQ_s1 = out_en[0] ? (out_en[1] ? (2'b10) : (2'b01)) : (out_en[1] ? (out_en[2] ? (2'b10) : (2'b01)) : (2'b00));
	assign IQ_s2 = (out_en[0] | out_en[1]) ? (out_two_2 ? (2'b10) : ()) : (out_en[2] ? (out_en[3] ? (2'b10) : (2'b01)) : (2'b00));
	assign IQ_s3 = 
	assign IQ_s4 = 
	assign IQ_s5 = 
	assign IQ_s6 = 
	
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
		.a2(inst0),
		.a3(32'd0),
		.out(IQ_update5)
	);
	
	mux4x32 mux6(
		.s(IQ_s6),
		.a0(ISSUE_QUEUE[3'd6]),
		.a1(inst0),
		.a2(inst1),
		.a3(32'd0),
		.out(IQ_update6)
	);
	
	always@(posedge clk) begin
		if(~resetn) begin : initialize
			integer i;
			for(i = 0;i <= 6;i = i + 1) begin : loop
				ISSUE_QUEUE[i] <= 32'd0;
			end
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
	

endmodule