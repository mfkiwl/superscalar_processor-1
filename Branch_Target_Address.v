module Branch_Target_Address(
    input clk,
    input resetn,
    input [31:0] pc,
    input [31:0] update_pc,
    input update_en,
    input [1:0] update_type, // 2'b01 call, 2;b10 return
    input [31:0] update_BTA,
    output [31:0] BTA
);

    wire [9:0] BTB_tag;
    wire [1:0] hit_en;
    wire [9:0] BTB_update_tag;

    reg [45:0] BTB1 [0:127]; // 1 bit used signal, 1 bit valid signal, 10 bits tag, 32 bits BTA, 2 bits types
    reg [45:0] BTB2 [0:127];

    assign BTB_tag = {pc[25:21] ^ pc[20:16], pc[15:11] ^ pc[10:6]};
    assign BTB_update_tag = {update_pc[25:21] ^ update_pc[20:16], update_pc[15:11] ^ update_pc[10:6]};
    assign hit_en = BTB1[pc[5:0]][44] && BTB1[pc[5:0]][43:34] == BTB_tag ? 2'b01 : (BTB2[pc[5:0]][44] && BTB2[pc[5:0]][43:34] == BTB_tag ? 2'b10 : 2'b00);
    assign BTA = hit_en == 2'b00 ? pc : (hit_en == 2'b01 ? BTB1[pc[5:0]][33:2] : (hit_en == 2'b10 ? BTB2[pc[5:0]][33:2] : 32'd0));

/////////
    always @(posedge clk) begin
        if(~resetn) begin : initialize
            integer i;
            for(i = 0;i <= 127;i = i + 1) begin : loop
                BTB1[i] = 46'd0;
                BTB2[i] = 46'd0; 
            end
        end else begin
            if(hit_en == 2'b01) begin
                BTB1[pc[5:0]][45] <= 1'b1;
                BTB2[pc[5:0]][45] <= 1'b0;
            end else if(hit_en == 2'b10) begin
                BTB2[pc[5:0]][45] <= 1'b1;
                BTB1[pc[5:0]][45] <= 1'b0;
            end
            //BTB replace algorithm
            if(update_en & BTB1[pc[5:0]][45] == 1'b1) begin
                BTB1[pc[5:0]][43:34] <= {2'b11, BTB_update_tag, update_type};
            end else if(update_en & BTB2[pc[5:0]][45] == 1'b1) begin
                BTB2[pc[5:0]][43:34] <= {2'b11, BTB_update_tag, update_type};
            end else if(update_en) begin
                BTB1[pc[5:0]][43:34] <= {2'b11, BTB_update_tag, update_type};
            end
        end
    end
endmodule