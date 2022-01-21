module mux2x32(
    input s,
    input [31:0] a0,
    input [31:0] a1,
    output [31:0] out
);

    assign out = (s == 1'b0) ? a0 : a1;
    
endmodule

////////////////////////////////////////////////////////////////////////////////////////////////////
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
	input wire [2:0] out_num0,
	input wire [2:0] out_num1,
	input wire out_en0,
	input wire out_en1,
	
	output wire [31:0] inst0,
	output wire [31:0] inst1
);

	reg [31:0] ISSUE_QUEUE [0:7];
	
	wire [1:0] out_count;
	wire [31:0] IQ_update0;
	wire [31:0] IQ_update1;
	wire [31:0] IQ_update2;
	wire [31:0] IQ_update3;
	wire [31:0] IQ_update4;
	wire [31:0] IQ_update5;
	wire [31:0] IQ_update6;
	wire [31:0] IQ_update7;
	wire [1:0]  IQ_s0;
	wire [1:0]  IQ_s1;
	wire [1:0]  IQ_s2;
	wire [1:0]  IQ_s3;
	wire [1:0]  IQ_s4;
	wire [1:0]  IQ_s5;
	wire [1:0]  IQ_s6;
	wire [1:0]  IQ_s7;

	assign out_count = {out_en0 & out_en1, out_en0 ^ out_en1};
	assign IQ_s0 = ;
	assign IQ_s1 = ;
	assign IQ_s2 = ;
	assign IQ_s3 = ;
	assign IQ_s4 = ;
	assign IQ_s5 = ;
	assign IQ_s6 = ;
	assign IQ_s7 = ;
	
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
		.a2(ISSUE_QUEUE[3'd7]),
		.a3(32'd0),
		.out(IQ_update5)
	);
	
	mux4x32 mux6(
		.s(IQ_s6),
		.a0(ISSUE_QUEUE[3'd6]),
		.a1(ISSUE_QUEUE[3'd7]),
		.a2(inst0),
		.a3(32'd0),
		.out(IQ_update6)
	);
	
	mux2x32 mux7(
		.s(IQ_s7),
		.a0(ISSUE_QUEUE[3'd7]),
		.a1(inst1),
		.out(IQ_update7)
	);
	
	always@(posedge clk) begin
		if(~resetn) begin : initialize
			integer i;
			for(i = 0;i <= 7;i = i + 1) begin : loop
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
			ISSUE_QUEUE[3'd7] <= IQ_update7;
		end
	end
	

endmodule