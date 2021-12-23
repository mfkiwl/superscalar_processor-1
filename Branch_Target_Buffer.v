module Branch_Target_Buffer(
    input wire clk,
    input wire resetn,
    input wire [31:0] pc,
    input wire [31:0] update_pc,
    input wire update_en,
    input wire [1:0] update_type, // 2'b00 direct_brach, 2'b01 call, 2'b10 return, 2'b11 indirect_branch
    input wire [31:0] update_BTA,
    input wire inst_bj,
    output wire [31:0] BTA,
    output wire [1:0] type,
    output wire [1:0] offset
);

    wire [9:0] BTB_tag;
    wire [9:0] BTB_update_tag;
    wire [1:0] hit_en;

    reg [47:0] BTB1 [0:127];// 1 bit valid signal, 1 bit used signal, 10 bits tag, 32 bits BTA, 2 bits types, 2bits offset
    reg [47:0] BTB2 [0:127];

    assign BTB_tag = {pc[28:24] ^ pc[23:19], pc[18:14] ^ pc[13:9]};
    assign BTB_update_tag = {update_pc[28:24] ^ update_pc[23:19], update_pc[18:14] ^ update_pc[13:9]};
    assign hit_en = BTB1[pc[10:4]][47] && BTB1[pc[10:4]][45:36] == BTB_tag ? 2'b01 : (BTB2[pc[10:4]][47] && BTB2[pc[10:4]][45:36] == BTB_tag ? 2'b10 : 2'b00);
    assign BTA = hit_en == 2'b00 ? pc + 32'd4 : (hit_en == 2'b01 ? BTB1[pc[10:4]][35:4] : (hit_en == 2'b10 ? BTB2[pc[10:4]][35:4] : 32'd0));
    assign type = hit_en == 2'b01 ? BTB1[pc[10:4]][3:2] : (hit_en == 2'b10 ? BTB2[pc[10:4]][3:2] : 2'b00);
    assign offset = hit_en == 2'b01 ? BTB1[pc[10:4]][1:0] : (hit_en == 2'b10 ? BTB2[pc[10:4]][1:0] : 2'b00);

/////////
    always @(posedge clk) begin
        if(~resetn) begin : initialize
            integer i;
            for(i = 0;i <= 127;i = i + 1) begin : loop
                BTB1[i] = 48'd0;
                BTB2[i] = 48'd0; 
            end
        end else begin
            if((hit_en == 2'b01) & inst_bj) begin
                BTB1[pc[10:4]][46] <= 1'b1;
                BTB2[pc[10:4]][46] <= 1'b0;
            end else if((hit_en == 2'b10) & inst_bj) begin
                BTB2[pc[10:4]][46] <= 1'b1;
                BTB1[pc[10:4]][46] <= 1'b0;
            end
            //BTB replace algorithm
            if(update_en & BTB1[pc[10:4]][46] == 1'b1) begin
                BTB2[update_pc[10:4]][45:0] <= {2'b11, BTB_update_tag, update_BTA, update_type, update_pc[3:2]};
            end else if(update_en & BTB2[pc[10:4]][46] == 1'b1) begin
                BTB1[update_pc[10:4]][45:0] <= {2'b11, BTB_update_tag, update_BTA, update_type, update_pc[3:2]};
            end else if(update_en) begin
                BTB2[update_pc[10:4]][45:0] <= {2'b11, BTB_update_tag, update_BTA, update_type, update_pc[3:2]};
            end
        end
    end
endmodule