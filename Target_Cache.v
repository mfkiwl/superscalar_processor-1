module Target_Cache(
    input clk,
    input resetn,
    input [31:0] pc,
    input [3:0] BHR,
    input [31:0] update_pc,
    input [31:0] update_target,
    input update_en,
    input [3:0] update_BHR,
    output [31:0] target_address
);

    reg [31:0] cache [0:255]

    wire [7:0] index;
    wire [7:0] update_index;

    assign index = {pc[3:0], BHR};
    assign update_index = {update_pc[3:0], update_BHR};
    assign target_address = cache[index];

    always @(posedge clk) begin
        if(~resetn) begin : initialize
            integer i;
            for(i = 0;i <= 255;i = i + 1) begin : loop
                cache[i] = 32'd0;
            end
        end else if(update_en) begin
            cache[update_index] = update_target;
        end
    end

endmodule