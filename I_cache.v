module cache_fetch(
    input wire [4:0] offset,
    input wire [255:0] cache_data,
    input wire [127:0] memory_data,
    input wire hit,
    output reg [32:0] inst0,
    output reg [32:0] inst1,
    output reg [32:0] inst2,
    output reg [32:0] inst3
);

    always @(*) begin
        if(hit) begin
            case(offset)
                5'b00000 : begin
                    inst0 <= {1'b1, cache_data[255:224]};
                    inst1 <= {1'b1, cache_data[223:192]};
                    inst2 <= {1'b1, cache_data[191:160]};
                    inst3 <= {1'b1, cache_data[159:128]};
                end
                5'b00100 : begin
                    inst0 <= {1'b1, cache_data[223:192]};
                    inst1 <= {1'b1, cache_data[191:160]};
                    inst2 <= {1'b1, cache_data[159:128]};
                    inst3 <= {1'b1, cache_data[127:96]};
                end
                5'b01000 : begin
                    inst0 <= {1'b1, cache_data[191:160]};
                    inst1 <= {1'b1, cache_data[159:128]};
                    inst2 <= {1'b1, cache_data[127:96]};
                    inst3 <= {1'b1, cache_data[95:64]};
                end
                5'b01100 : begin
                    inst0 <= {1'b1, cache_data[159:128]};
                    inst1 <= {1'b1, cache_data[127:96]};
                    inst2 <= {1'b1, cache_data[95:64]};
                    inst3 <= {1'b1, cache_data[63:32]};
                end
                5'b10000 : begin
                    inst0 <= {1'b1, cache_data[127:96]};
                    inst1 <= {1'b1, cache_data[95:64]};
                    inst2 <= {1'b1, cache_data[63:32]};
                    inst3 <= {1'b1, cache_data[31:0]};
                end
                5'b10100 : begin
                    inst0 <= {1'b1, cache_data[95:64]};
                    inst1 <= {1'b1, cache_data[63:32]};
                    inst2 <= {1'b1, cache_data[31:0]};
                    inst3 <= 33'd0;
                end
                5'b11000 : begin
                    inst0 <= {1'b1, cache_data[63:32]};
                    inst1 <= {1'b1, cache_data[31:0]};
                    inst2 <= 33'd0;
                    inst3 <= 33'd0;
                end
                5'b11000 : begin
                    inst0 <= {1'b1, cache_data[31:0]};
                    inst1 <= 33'd0;
                    inst2 <= 33'd0;
                    inst3 <= 33'd0;
                end
                default : begin
                    inst0 <= 33'd0;
                    inst1 <= 33'd0;
                    inst2 <= 33'd0;
                    inst3 <= 33'd0;
                end
            endcase
        end else begin
            inst0 <= {1'b1, memory_data[127:96]};
            inst1 <= {1'b1, memory_data[95:64]};
            inst2 <= {1'b1, memory_data[63:32]};
            inst3 <= {1'b1, memory_data[31:0]};
        end
    end

endmodule

module I_cache(
    input wire clk,
    input wire resetn,
    input wire lookup_request,
    input wire [31:0] pc,
    output wire [32:0] inst0,
    output wire [32:0] inst1,
    output wire [32:0] inst2,
    output wire [32:0] inst3,
    //
    input wire [255:0] memory_data,
    input wire addr_ok, //slave is ready to receive addr
    input wire data_ok, //master has received data
    output wire [31:0] addr,
    output wire addr_send
);

    wire way0_hit;
    wire way1_hit;

    wire [20:0] tagv0;
    wire [20:0] tagv1;

    wire [7:0] index;
    wire [18:0] tag;
    wire [4:0] offset;

    wire [255:0] way0_data;
    wire [255:0] way1_data;

    wire [255:0] cache_data;
    wire hit;

    wire TAGV0_wea;
    wire TAGV1_wea;
    wire [20:0] TagV0_dina;
    wire [20:0] TagV1_dina;
    wire DATA0_wea;
    wire DATA1_wea;
    wire [255:0] DATA0_dina;
    wire [255:0] DATA1_dina;
    
//////////the procedure of judging cache hit or miss
    assign way0_hit = tagv0[19] & (tagv0[18:0] == tag);
    assign way1_hit = tagv1[19] & (tagv1[18:0] == tag);

    assign index = pc[12:5];
    assign tag = pc[31:13];
    assign offset = pc[4:0];

    assign cache_data = way0_hit ? way0_data : way1_data;
    assign hit = way0_hit | way1_hit;
//////////State machine
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
                    if(addr_ok) begin
                        state <= REFILL;
                    end
                end
                REFILL : begin
                    if(data_ok) begin
                        state <= IDEL;
                    end
                end
                default : begin
                    
                end
            endcase
        end
    end

    assign addr = pc;
    assign addr_send = state == MISS;
//////////LRU cache replace algorithm
    assign TAGV0_wea = (state == LOOKUP & hit) | (state == REFILL & ~tagv0[20]);
    assign TAGV1_wea = (state == LOOKUP & hit) | ((state == REFILL) & ~tagv1[20] & tagv0[20]);
    assign TagV0_dina = state == LOOKUP ? (way0_hit ? {1'b1, 1'b1, tagv0[18:0]} : {1'b0, tagv0[19:0]}) : {1'b1, 1'b1, pc[31:13]};
    assign TagV1_dina = state == LOOKUP ? (way1_hit ? {1'b1, 1'b1, tagv1[18:0]} : {1'b0, tagv1[19:0]}) : {1'b1, 1'b1, pc[31:13]};
    assign DATA0_wea = (state == REFILL) & ~tagv0[20];
    assign DATA1_wea = (state == REFILL) & ~tagv1[20] & tagv0[20];
    assign DATA0_dina = memory_data;
    assign DATA1_dina = memory_data;
//////////implement two TagV-tables, two Data-tables
    TAGV_table TAGV0(
        .clka(clk),    // input wire clka
        .ena(1'b1),      // input wire ena
        .wea(TAGV0_wea),      // input wire [0 : 0] wea
        .addra(index),  // input wire [7 : 0] addra
        .dina(TagV0_dina),    // input wire [20 : 0] dina
        .douta(tagv0)  // output wire [20 : 0] douta
    );

    TAGV_table TAGV1(
        .clka(clk),    // input wire clka
        .ena(1'b1),      // input wire ena
        .wea(TAGV1_wea),      // input wire [0 : 0] wea
        .addra(index),  // input wire [7 : 0] addra
        .dina(TagV1_dina),    // input wire [20 : 0] dina
        .douta(tagv1)  // output wire [20 : 0] douta
    );

    DATA_table DATA0(
        .clka(clk),    // input wire clka
        .ena(1'b1),      // input wire ena
        .wea(DATA0_wea),      // input wire [0 : 0] wea
        .addra(index),  // input wire [7 : 0] addra
        .dina(DATA0_dina),    // input wire [255 : 0] dina
        .douta(way0_data)  // output wire [255 : 0] douta
    );

    DATA_table DATA1(
        .clka(clk),    // input wire clka
        .ena(1'b1),      // input wire ena
        .wea(DATA1_wea),      // input wire [0 : 0] wea
        .addra(index),  // input wire [7 : 0] addra
        .dina(DATA1_dina),    // input wire [255 : 0] dina
        .douta(way1_data)  // output wire [255 : 0] douta
    );

    cache_fetch cf(
        .offset(offset),
        .cache_data(cache_data),
        .memory_data(RDATA),
        .hit(hit),
        .inst0(inst0),
        .inst1(inst1),
        .inst2(inst2),
        .inst3(inst3)
    );

endmodule