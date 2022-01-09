module four_ports_fifo(
	input wire clk,
	input wire resetn,
	
	input wire [31:0] data0,
	input wire [31:0] data1,
	input wire [31:0] data2,
	input wire [31:0] data3,
	
	input wire [2:0] wen,
	input wire [2:0] ren,
	
	output reg [32:0] dout0,
	output reg [32:0] dout1,
	output reg [32:0] dout2,
	output reg [32:0] dout3,
	
	output wire empty,
	output wire full
);

	parameter WIDTH = 32;
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
			dout0 <= 32'd0;
			dout1 <= 32'd0;
			dout2 <= 32'd0;
			dout3 <= 32'd0;
		end else begin
			if((ren != 0) && ({1'b1, count} - {5'b000, ren} >= 8'b1000000) && ~empty) begin
				case(ren)
					3'd0 : begin
						dout0 <= 32'd0;
						dout1 <= 32'd0;
						dout2 <= 32'd0;
						dout3 <= 32'd0;
					end
					3'd1 : begin
						dout0 <= {1'b1, ram[rp]};
						dout1 <= 32'd0;
						dout2 <= 32'd0;
						dout3 <= 32'd0;
						rp <= rp + 6'd1;
					end
					3'd2 : begin
						dout0 <= {1'b1, ram[rp	  ]};
						dout1 <= {1'b1, ram[rp + 1]};
						dout2 <= 32'd0;
						dout3 <= 32'd0;
						rp <= rp + 6'd2;
					end
					3'd3 : begin
						dout0 <= {1'b1, ram[rp	  ]};
						dout1 <= {1'b1, ram[rp + 1]};
						dout2 <= {1'b1, ram[rp + 2]};
						dout3 <= 32'd0;
						rp <= rp + 6'd3;
					end
					3'd4 : begin
						dout0 <= {1'b1, ram[rp	  ]};
						dout1 <= {1'b1, ram[rp + 1]};
						dout2 <= {1'b1, ram[rp + 2]};
						dout3 <= {1'b1, ram[rp + 3]};
						rp <= rp + 6'd4;
					end
					default : begin
						dout0 <= 32'd0;
						dout1 <= 32'd0;
						dout2 <= 32'd0;
						dout3 <= 32'd0;
					end
				endcase
			end else if((ren != 0) && ~empty) begin
				case(count)
					7'd0 : begin
						dout0 <= 32'd0;
						dout1 <= 32'd0;
						dout2 <= 32'd0;
						dout3 <= 32'd0;
					end
					7'd1 : begin
						dout0 <= {1'b1, ram[rp]};
						dout1 <= 32'd0;
						dout2 <= 32'd0;
						dout3 <= 32'd0;
						rp <= rp + 6'd1;
					end
					7'd2 : begin
						dout0 <= {1'b1, ram[rp	  ]};
						dout1 <= {1'b1, ram[rp + 1]};
						dout2 <= 32'd0;
						dout3 <= 32'd0;
						rp <= rp + 6'd2;
					end
					7'd3 : begin
						dout0 <= {1'b1, ram[rp	  ]};
						dout1 <= {1'b1, ram[rp + 1]};
						dout2 <= {1'b1, ram[rp + 2]};
						dout3 <= 32'd0;
						rp <= rp + 6'd3;
					end
					default : begin
						dout0 <= 32'd0;
						dout1 <= 32'd0;
						dout2 <= 32'd0;
						dout3 <= 32'd0;
					end
				endcase
			end else begin
				dout0 <= 32'd0;
				dout1 <= 32'd0;
				dout2 <= 32'd0;
				dout3 <= 32'd0;
			end
		end
	end
//////////////////////////////////////////////////count
	always@(posedge clk) begin
		if(~resetn) begin
			count <=7'd0;
		end else begin
			if((wen != 0) && ({1'b0, count} + {5'b0000, wen} <= 8'd64)) begin //write
				if(ren == 0) begin //write but not read
					count <= count + {4'b0000, wen};
				end else if(empty) begin //write and read, but empty
					count <= count + {4'b0000, wen};
				end else if({1'b1, count} + {5'b0000, wen} - {5'b0000, ren} < 8'b10000000) begin //write and read and not empty but read more than existed
					count <= {4'b0000, wen};
				end else begin
					count <= count + {4'b0000, wen} - {4'b0000, ren};
				end
			end else if((ren != 0) && ~empty && ({1'b1, count} - {5'b000, ren} >= 8'b1000000)) begin //read
				count <= count - {4'b0000, ren};
			end else if((ren != 0) && ~empty) begin //read but read more than existed
				count <= 0;
			end else begin
				count <= count;
			end
		end
	end

endmodule