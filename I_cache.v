module I_cache(
    input clk,
    input resetn,

    input lookup_request,
    input [31:0] pc,
    output [127:0] fetch_pack,
    //AXI4 interface
    input [31:0] RDATA,
    input ARREADY,
    input RVALID,
    output [31:0] ARADDR,
    output ARVALID,
    output RREADY
);

    wire way0_hit;
    wire way1_hit;

    wire [20:0] tagv0;
    wire [20:0] tagv1;

    wire [7:0] index;
    wire [3:0] offset;
    wire [19:0] tag;

    wire [255:0] way0_data;
    wire [255:0] way1_data;
    
    wire [127:0] way0_fetch_pack;
    wire [127:0] way1_fetch_pack;
//////////
    assign way0_hit = tagv0[20] & (tagv0[19:0] == tag);
    assign way1_hit = tagv1[20] & (tagv1[19:0] == tag);

    assign index = pc[12:5];
    assign offset = pc[3:0];
    assign tag = pc[31:12]; //the length of tag should be modified

    assign way0_fetch_pack = pc[4:2] == 3'b000 ? way0_data[255:128] : (pc[4:2] == 3'b001 ? way0_data[223:96] : (pc[4:2] == 3'b010 ? way0_data[191:64] : (pc[4:2] == 3'b011 ? way0_data[159:32] : way0_data[127:0])));
    assign way1_fetch_pack = pc[4:2] == 3'b000 ? way1_data[255:128] : (pc[4:2] == 3'b001 ? way1_data[223:96] : (pc[4:2] == 3'b010 ? way1_data[191:64] : (pc[4:2] == 3'b011 ? way0_data[159:32] : way1_data[127:0])));
//////////
    parameter IDEL = 2'b00;
    parameter LOOKUP = 2'b01;
    parameter MISS = 2'b10;
    parameter REFILL = 2'b11;

    reg [1:0] state;

    always @(posedge clk) begin
        if(~resetn) begin
            state <= 2'b00;
        end else begin
            case(state)
                IDEL : begin
                    if(lookup_request) begin
                        state <= LOOKUP;
                    end
                end
                LOOKUP : begin
                    if((way0_hit | way1_hit) & ~lookup_request) begin
                        state <= IDEL;
                    end else if((way0_hit | way1_hit) & lookup_request) begin
                        state <= LOOKUP;
                    end else if(~way0_hit & ~way1_hit) begin
                        state <= MISS;
                    end
                end
                MISS : begin
                    if(ARREADY) begin
                        state <= REFILL;
                    end
                end
                REFILL : begin
                    if(RVALID) begin
                        state <= IDEL;
                    end
                end
                default : begin
                    
                end
            endcase
        end
    end
//////////implement two V-tables, two Tag-tables, two Data-tables
    TAGV_table TAGV0(
        .clka(clk),    // input wire clka
        .ena(1'b1),      // input wire ena
        .wea(),      // input wire [0 : 0] wea
        .addra(index),  // input wire [7 : 0] addra
        .dina(),    // input wire [20 : 0] dina
        .douta(tagv0)  // output wire [20 : 0] douta
    );

    TAGV_table TAGV1(
        .clka(clk),    // input wire clka
        .ena(1'b1),      // input wire ena
        .wea(),      // input wire [0 : 0] wea
        .addra(index),  // input wire [7 : 0] addra
        .dina(),    // input wire [20 : 0] dina
        .douta(tagv1)  // output wire [20 : 0] douta
    );

endmodule