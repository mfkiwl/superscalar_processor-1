module Target_Cache(
    input clk,
    input resetn,
    input [31:0] pc,
    input [9:0] BHR,
    input [31:0] update_pc,
    input [31:0] update_target,
    input update_en,
    input [9:0] update_BHR,
    output wire [31:0] target0_address,
    output wire [31:0] target1_address,
    output wire [31:0] target2_address,
    output wire [31:0] target3_address
);

    reg [31:0] cache_bank0 [0:63];
    reg [31:0] cache_bank1 [0:63];
    reg [31:0] cache_bank2 [0:63];
    reg [31:0] cache_bank3 [0:63];
    

    wire [5:0] index0;
    wire [5:0] index1;
    wire [5:0] index2;
    wire [5:0] index3;

    wire [5:0] update_index;
    wire [9:0] Hash;
    wire [9:0] update_Hash;

    assign Hash = {pc[28:24] ^ pc[23:19], pc[18:14] ^ pc[13:9]} ^ BHR;
    assign update_Hash = {update_pc[28:24] ^ update_pc[23:19], update_pc[18:14] ^ update_pc[13:9]} ^ update_BHR;

    assign index0 = Hash[5:0];
    assign index1 = Hash[5:0];
    assign index2 = Hash[5:0];
    assign index3 = Hash[5:0];

    assign update_index = update_Hash[5:0];

    assign target0_address = cache_bank0[index0];
    assign target1_address = cache_bank1[index1];
    assign target2_address = cache_bank2[index2];
    assign target3_address = cache_bank3[index3];

    always @(posedge clk) begin
        if(~resetn) begin : initialize
            integer i;
            for(i = 0;i <= 63;i = i + 1) begin : loop
                cache_bank0[i] = 32'd0;
                cache_bank1[i] = 32'd0;
                cache_bank2[i] = 32'd0;
                cache_bank3[i] = 32'd0;
            end
        end else if(update_en) begin
            case(update_pc[3:2])
                2'b00 : begin
                    cache_bank0[update_index] <= update_target;
                end
                2'b01 : begin
                    cache_bank1[update_index] <= update_target;
                end
                2'b10 : begin
                    cache_bank2[update_index] <= update_target;
                end
                2'b11 : begin
                    cache_bank3[update_index] <= update_target;
                end
                default : begin
                    
                end
            endcase
        end
    end

endmodule