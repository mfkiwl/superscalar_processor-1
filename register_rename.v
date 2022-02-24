module rename(
    input wire clk,
    input wire resetn,
    input wire write_en,
    //renaming
    input wire rs_en0,
    input wire rs_en1,
    input wire rs_en2,
    input wire rs_en3,
    input wire rt_en0,
    input wire rt_en1,
    input wire rt_en2,
    input wire rt_en3,
    input wire rd_en0,
    input wire rd_en1,
    input wire rd_en2,
    input wire rd_en3,

    input wire [4:0] rs0,
    input wire [4:0] rs1,
    input wire [4:0] rs2,
    input wire [4:0] rs3,
    input wire [4:0] rt0,
    input wire [4:0] rt1,
    input wire [4:0] rt2,
    input wire [4:0] rt3,
    input wire [4:0] rd0,
    input wire [4:0] rd1,
    input wire [4:0] rd2,
    input wire [4:0] rd3,
    //ARF restore
    input wire restore_en,
    input wire [127:0] aRAT_value,

    output wire [4:0] psrc0_L,
    output wire [4:0] psrc0_R,
    output wire [4:0] psrc1_L,
    output wire [4:0] psrc1_R,
    output wire [4:0] psrc2_L,
    output wire [4:0] psrc2_R,
    output wire [4:0] psrc3_L,
    output wire [4:0] psrc3_R,
    output wire [4:0] pdest0,
    output wire [4:0] pdest1,
    output wire [4:0] pdest2,
    output wire [4:0] pdest3,
    
    output wire freelist_empty
);

    wire [4:0] src0_L;
    wire [4:0] src0_R;
    wire [4:0] dst0;
    wire [4:0] src1_L;
    wire [4:0] src1_R;
    wire [4:0] dst1;
    wire [4:0] src2_L;
    wire [4:0] src2_R;
    wire [4:0] dst2;
    wire [4:0] src3_L;
    wire [4:0] src3_R;
    wire [4:0] dst3;

    wire w_en0;
    wire w_en1;
    wire w_en2;
    wire w_en3;

    wire [4:0] wr_data0;
    wire [4:0] wr_data1;
    wire [4:0] wr_data2;
    wire [4:0] wr_data3;

    wire [4:0] rat_psrc0_L;
    wire [4:0] rat_psrc0_R;
    wire [4:0] rat_psrc1_L;
    wire [4:0] rat_psrc1_R;
    wire [4:0] rat_psrc2_L;
    wire [4:0] rat_psrc2_R;
    wire [4:0] rat_psrc3_L;
    wire [4:0] rat_psrc3_R;

    wire [4:0] fl0; //data from freelist
    wire [4:0] fl1;
    wire [4:0] fl2;
    wire [4:0] fl3;

    wire select_Psrc1_L;
    wire select_Psrc1_R;
    wire [1:0] select_Psrc2_L;
    wire [1:0] select_Psrc2_R;
    wire [1:0] select_Psrc3_L;
    wire [1:0] select_Psrc3_R;

    wire [4:0] ppreg0;
    wire [4:0] ppreg1;
    wire [4:0] ppreg2;
    wire [4:0] ppreg3;

    assign src0_L = rs_en0 ? rs0 : 5'd0;
    assign src0_R = rt_en0 & rd_en0 ? rt0 : 5'd0;
    assign dst0 = rd_en0 ? rd0 : rt0;
    assign src1_L = rs_en1 ? rs1 : 5'd0;
    assign src1_R = rt_en1 & rd_en1 ? rt1 : 5'd0;
    assign dst1 = rd_en1 ? rd1 : rt1;
    assign src2_L = rs_en2 ? rs2 : 5'd0;
    assign src2_R = rt_en2 & rd_en2 ? rt2 : 5'd0;
    assign dst2 = rd_en2 ? rd2 : rt2;
    assign src3_L = rs_en3 ? rs3 : 5'd0;
    assign src3_R = rt_en3 & rd_en3 ? rt3 : 5'd0;
    assign dst3 = rd_en3 ? rd3 : rt3;

    assign psrc0_L = rat_psrc0_L;
    assign psrc0_R = rat_psrc0_R;
    assign psrc1_L = select_Psrc1_L ? fl0 : rat_psrc1_L;
    assign psrc1_R = select_Psrc1_R ? fl0 : rat_psrc1_R;
    assign pdest0  = w_en0 ? (fl0) : (w_en1 ? (fl1) : (w_en2 ? (fl2) : (w_en3 ? (fl3) : 5'd0)));
    assign pdest1  = w_en1 ? (fl1) : (w_en2 ? (fl2) : (w_en3 ? (fl3) : 5'd0));
    assign pdest2  = w_en2 ? (fl2) : (w_en3 ? (fl3) : 5'd0);
    assign pdest3  = w_en3 ? (fl3) : 5'd0; 

    mux4x32 mux2_L(
        .s(select_Psrc2_L),
        .a0(rat_psrc2_L),
        .a1(fl0),
        .a2(fl1),
        .a3(5'd0),
        .out(psrc2_L)
    );

    mux4x32 mux2_R(
        .s(select_Psrc2_R),
        .a0(rat_psrc2_R),
        .a1(fl0),
        .a2(fl1),
        .a3(5'd0),
        .out(psrc2_R)
    );

    mux4x32 mux3_L(
        .s(select_Psrc3_L),
        .a0(rat_psrc3_L),
        .a1(fl0),
        .a2(fl1),
        .a3(fl2),
        .out(psrc3_L)
    );

    mux4x32 mux3_R(
        .s(select_Psrc3_R),
        .a0(rat_psrc3_R),
        .a1(fl0),
        .a2(fl1),
        .a3(fl2),
        .out(psrc3_R)
    );

    sRAT SRAT_imp(
        .clk(clk),
        .resetn(resetn),
        .write_en(write_en),
        .src0_L(src0_L),
        .src0_R(src0_R),
        .src1_L(src1_L),
        .src1_R(src1_R),
        .src2_L(src2_L),
        .src2_R(src2_R),
        .src3_L(src3_L),
        .src3_R(src3_R),
        .dst0(dst0),
        .dst1(dst1),
        .dst2(dst2),
        .dst3(dst3),
        .w_en0(w_en0),
        .w_en1(w_en1),
        .w_en2(w_en2),
        .w_en3(w_en3),
        .wr_data0(wr_data0),
        .wr_data1(wr_data1),
        .wr_data2(wr_data2),
        .wr_data3(wr_data3),
        .restore_en(restore_en),
        .aRAT_value(aRAT_value),
        .psrc0_L(rat_psrc0_L),
        .psrc0_R(rat_psrc0_R),
        .psrc1_L(rat_psrc1_L),
        .psrc1_R(rat_psrc1_R),
        .psrc2_L(rat_psrc2_L),
        .psrc2_R(rat_psrc2_R),
        .psrc3_L(rat_psrc3_L),
        .psrc3_R(rat_psrc3_R),
        .ppreg0(ppreg0),
        .ppreg1(ppreg1),
        .ppreg2(ppreg2),
        .ppreg3(ppreg3)
    );

    WAW_check waw_check_imp(
        .dst0(dst0),
        .dst1(dst1),
        .dst2(dst2),
        .dst3(dst3),
        .w_en0(w_en0),
        .w_en1(w_en1),
        .w_en2(w_en2),
        .w_en3(w_en3)
    );

    freeList freelist_imp(
        .clk(clk),
        .resetn(resetn),
        .data0(ppreg0),
        .data1(ppreg1),
        .data2(ppreg2),
        .data3(ppreg3),
        .wen(),
        .ren(),
        .out_en(),
        .dout0(fl0),
        .dout1(fl1),
        .dout2(fl2),
        .dout3(fl3),
        .empty(freelist_empty),
        .full()
    );

    RAW_check raw_check_imp(
        .src0_L(src0_L),
        .src0_R(src0_R),
        .src1_L(src1_L),
        .src1_R(src1_R),
        .src2_L(src2_L),
        .src2_R(src2_R),
        .src3_L(src3_L),
        .src3_R(src3_R),
        .dst0(dst0),
        .dst1(dst1),
        .dst2(dst2),
        .dst3(dst3),
        .select_Psrc1_L(select_Psrc1_L),
        .select_Psrc1_R(select_Psrc1_R),
        .select_Psrc2_L(select_Psrc2_L),
        .select_Psrc2_R(select_Psrc2_R),
        .select_Psrc3_L(select_Psrc3_L),
        .select_Psrc3_R(select_Psrc3_R)
    );



endmodule

//////////////////////////////////////////////////
module sRAT(
    input wire clk,
    input wire resetn,
    input wire write_en,

    input wire [4:0] src0_L,
    input wire [4:0] src0_R,
    input wire [4:0] src1_L,
    input wire [4:0] src1_R,
    input wire [4:0] src2_L,
    input wire [4:0] src2_R,
    input wire [4:0] src3_L,
    input wire [4:0] src3_R,
    input wire [4:0] dst0,
    input wire [4:0] dst1,
    input wire [4:0] dst2,
    input wire [4:0] dst3,

    input wire w_en0,
    input wire w_en1,
    input wire w_en2,
    input wire w_en3,
    
    input wire [4:0] wr_data0,
    input wire [4:0] wr_data1,
    input wire [4:0] wr_data2,
    input wire [4:0] wr_data3,

    input wire restore_en,
    input wire [127:0] aRAT_value,

    output wire [4:0] psrc0_L,
    output wire [4:0] psrc0_R,
    output wire [4:0] psrc1_L,
    output wire [4:0] psrc1_R,
    output wire [4:0] psrc2_L,
    output wire [4:0] psrc2_R,
    output wire [4:0] psrc3_L,
    output wire [4:0] psrc3_R,
    output wire [4:0] ppreg0,
    output wire [4:0] ppreg1,
    output wire [4:0] ppreg2,
    output wire [4:0] ppreg3
);

    reg [4:0] rat[0:31];

    assign psrc0_L = rat[src0_L];
    assign psrc0_R = rat[src0_R];
    assign psrc1_L = rat[src1_L];
    assign psrc1_R = rat[src1_R];
    assign psrc2_L = rat[src2_L];
    assign psrc2_R = rat[src2_R];
    assign psrc3_L = rat[src3_L];
    assign psrc3_R = rat[src3_R];
    assign ppreg0  = rat[dst0];
    assign ppreg1  = rat[dst1];
    assign ppreg2  = rat[dst2];
    assign ppreg3  = rat[dst3];

    always @(posedge clk) begin
        if(~resetn) begin : initialize
            integer i;
            for(i = 0;i < 32;i = i + 1) begin : loop
                rat[i] <= 5'd0;
            end
        end else if(restore_en) begin : restore
            rat[32'd0 ] <= aRAT_value[127:124];
            rat[32'd1 ] <= aRAT_value[123:120];
            rat[32'd2 ] <= aRAT_value[119:116];
            rat[32'd3 ] <= aRAT_value[115:112];
            rat[32'd4 ] <= aRAT_value[111:108];
            rat[32'd5 ] <= aRAT_value[107:104];
            rat[32'd6 ] <= aRAT_value[103:100];
            rat[32'd7 ] <= aRAT_value[99 : 96];
            rat[32'd8 ] <= aRAT_value[95 : 92];
            rat[32'd9 ] <= aRAT_value[91 : 88];
            rat[32'd10] <= aRAT_value[87 : 84];
            rat[32'd11] <= aRAT_value[83 : 80];
            rat[32'd12] <= aRAT_value[79 : 76];
            rat[32'd13] <= aRAT_value[75 : 72];
            rat[32'd14] <= aRAT_value[71 : 68];
            rat[32'd15] <= aRAT_value[67 : 64];
            rat[32'd16] <= aRAT_value[63 : 60];
            rat[32'd17] <= aRAT_value[59 : 56];
            rat[32'd18] <= aRAT_value[55 : 52];
            rat[32'd19] <= aRAT_value[51 : 48];
            rat[32'd20] <= aRAT_value[47 : 44];
            rat[32'd21] <= aRAT_value[43 : 40];
            rat[32'd22] <= aRAT_value[39 : 36];
            rat[32'd23] <= aRAT_value[35 : 32];
            rat[32'd24] <= aRAT_value[31 : 28];
            rat[32'd25] <= aRAT_value[27 : 24];
            rat[32'd26] <= aRAT_value[23 : 20];
            rat[32'd27] <= aRAT_value[19 : 16];
            rat[32'd28] <= aRAT_value[15 : 12];
            rat[32'd29] <= aRAT_value[11 :  8];
            rat[32'd30] <= aRAT_value[7  :  4];
            rat[32'd31] <= aRAT_value[3  :  0];
        end else if(write_en)begin
            if(w_en0) begin
                rat[dst0] <= wr_data0;
            end
            if(w_en1) begin
                rat[dst1] <= wr_data1;
            end
            if(w_en2) begin
                rat[dst2] <= wr_data2;
            end
            if(w_en3) begin
                rat[dst3] <= wr_data3;
            end
        end else begin
            rat[dst0] <= rat[dst0];
            rat[dst1] <= rat[dst1];
            rat[dst2] <= rat[dst2];
            rat[dst3] <= rat[dst3];
        end
    end

endmodule

//////////////////////////////////////////////////
module RAW_check(
    input wire [4:0] src0_L,
    input wire [4:0] src0_R,
    input wire [4:0] src1_L,
    input wire [4:0] src1_R,
    input wire [4:0] src2_L,
    input wire [4:0] src2_R,
    input wire [4:0] src3_L,
    input wire [4:0] src3_R,

    input wire [4:0] dst0,
    input wire [4:0] dst1,
    input wire [4:0] dst2,
    input wire [4:0] dst3,

    output wire select_Psrc1_L,
    output wire select_Psrc1_R,
    output wire [1:0] select_Psrc2_L,
    output wire [1:0] select_Psrc2_R,
    output wire [1:0] select_Psrc3_L,
    output wire [1:0] select_Psrc3_R
);

    assign select_Psrc1_L = (src1_L == dst0) ? 1'b1 : 1'b0;
    assign select_Psrc1_R = (src1_R == dst0) ? 1'b1 : 1'b0;

    assign select_Psrc2_L[0] = (src2_L == dst0) & (~(src2_L == dst1));
    assign select_Psrc2_L[1] = (src2_L == dst1);
    assign select_Psrc2_R[0] = (src2_R == dst0) & (~(src2_R == dst1));
    assign select_Psrc2_R[1] = (src2_R == dst1);

    assign select_Psrc3_L[0] = (src3_L == dst2) | (~(src3_L == dst1) & (src3_L == dst0));
    assign select_Psrc3_L[1] = (src3_L == dst2) | (src3_L == wst1);
    assign select_Psrc3_R[0] = (src3_R == dst2) | (~(src3_R == dst1) & (src3_R == dst0));
    assign select_Psrc3_R[1] = (src3_R == dst2) | (src3_R == dst1);

endmodule

//////////////////////////////////////////////////
module WAW_check(
    input wire [4:0] dst0,
    input wire [4:0] dst1,
    input wire [4:0] dst2,
    input wire [4:0] dst3,

    output wire w_en0,
    output wire w_en1,
    output wire w_en2,
    output wire w_en3
);

    assign w_en0 = (dst0 == dst1) | (dst0 == dst2) | (dst0 == dst3);
    assign w_en1 = (dst1 == dst2) | (dst1 == dst3);
    assign w_en2 = (dst2 == dst3);
    assign w_en3 = 1'b1;

endmodule

//////////////////////////////////////////////////
module freeList(
	input wire clk,
	input wire resetn,
	
	input wire [4:0] data0,
	input wire [4:0] data1,
	input wire [4:0] data2,
	input wire [4:0] data3,
	
	input wire [2:0] wen,
	input wire ren,
	
    output reg out_en,
	output reg [4:0] dout0,
	output reg [4:0] dout1,
	output reg [4:0] dout2,
	output reg [4:0] dout3,
	
	output wire empty,
	output wire full
);

	parameter WIDTH = 5;
	parameter DEPTH = 64;
	
	reg [WIDTH - 1 : 0] ram[0:DEPTH - 1];
	reg [5:0] wp;
	reg [5:0] rp;
	reg [6:0] count;
	
	assign empty = count == 0;
	assign full  = count == 7'd64;
	
//////////////////////////////////////////////////write
	always@(posedge clk) begin
		if(~resetn) begin : initialize
			integer i;
			for(i = 0;i < DEPTH;i = i + 1) begin : loop
				ram[i] <= 32'd0;
			end
		end else begin
			if((wen != 0) && {1'b0, count} + {5'b000, wen} <= 8'd64) begin
				case(wen)
					3'd0 : begin
					
					end
					3'd1 : begin
						ram[wp] <= data0;
					end
					3'd2 : begin
						ram[wp] 	<= data0;
						ram[wp + 1] <= data1;
					end
					3'd3 : begin
						ram[wp]		<= data0;
						ram[wp + 1] <= data1;
						ram[wp + 2] <= data2;
					end
					3'd4 : begin
						ram[wp]		<= data0;
						ram[wp + 1] <= data1;
						ram[wp + 2] <= data2;
						ram[wp + 3] <= data3;
					end
					default : begin
					
					end
				endcase
			end
		end
	end
	
	always@(posedge clk) begin
		if(~resetn) begin
			wp <= 0;
		end else begin
			if((wen != 0) && ({1'b0, count} + {5'b0000, wen} <= 8'd64)) begin
				wp <= wp + {3'b000, wen};
			end else begin
				wp <= wp;
			end
		end
	end
//////////////////////////////////////////////////read **when fifo is empty, it is not allowed to read and write at the same time**
	always@(posedge clk) begin
		if(~resetn) begin
			rp <= 0;
			dout0 <= 4'd0;
			dout1 <= 4'd0;
			dout2 <= 4'd0;
			dout3 <= 4'd0;
            out_en <= 1'b0;
		end else begin
			if(ren && ({1'b1, count} - 8'd4 >= 8'b1000000) && ~empty) begin
				dout0 <= ram[rp	   ];
				dout1 <= ram[rp + 1];
				dout2 <= ram[rp + 2];
				dout3 <= ram[rp + 3];
				rp <= rp + 6'd4;
                out_en <= 1'b1;
            end else begin
				out_en <= 1'b0;
			end
		end
	end
//////////////////////////////////////////////////count
	always@(posedge clk) begin
		if(~resetn) begin
			count <=7'd0;
		end else begin
			if((wen != 0) && ({1'b0, count} + {5'b0000, wen} <= 8'd64)) begin //write
				if(~ren) begin //write but not read
					count <= count + {4'b0000, wen};
				end else if(empty || ({1'b1, count} + {5'b0000, wen} - 8'd4 < 8'b10000000)) begin //write and read, but empty
					count <= count + {4'b0000, wen};
				end else begin
					count <= count + {4'b0000, wen} - 8'd4;
				end
			end else if(ren && ~empty && ({1'b1, count} - 8'd4 >= 8'b1000000)) begin //read
				count <= count - 7'd4;
			end else begin
				count <= count;
			end
		end
	end

endmodule

//////////////////////////////////////////////////
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