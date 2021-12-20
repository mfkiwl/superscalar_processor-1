module Target_Cache(
    input clk,
    input resetn,
    input [31:0] pc,
    input [9:0] BHR,
    input [31:0] update_pc,
    input [31:0] update_target,
    input update_en,
    input [9:0] update_BHR,
    output wire [31:0] target_address
);

    reg [31:0] cache [0:255];
    
    wire [7:0] index;
    wire [7:0] update_index;
    wire [9:0] Hash;
    wire [9:0] update_Hash;

    assign Hash = {pc[23:19] ^ pc[18:14], pc[13:9] ^ pc[8:4]} ^ BHR;
    assign update_Hash = {update_pc[23:19] ^ update_pc[18:14], update_pc[13:9] ^ update_pc[8:4]} ^ update_BHR;
    assign index = Hash[7:0];
    assign update_index = update_Hash[7:0];
    assign target_address = cache[index];

    always @(posedge clk) begin
        if(~resetn) begin : initialize
            integer i;
            for(i = 0;i <= 63;i = i + 1) begin : loop
                cache[i] = 32'd0;
            end
        end else if(update_en) begin
            cache[update_index] <= update_target;
        end
    end

endmodule