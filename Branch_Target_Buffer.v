module Branch_Target_Buffer(
    input clk,
    input resetn,
    input [31:0] pc,
    input [31:0] update_pc,
    input update_en,
    input [1:0] update_type, // 2'b00 direct_brach, 2'b01 call, 2'b10 return, 2'b11 indirect_branch
    input [31:0] update_BTA,

    input inst_bj0,
    output [31:0] BTA0,
    output [1:0] type0,
    input inst_bj1,
    output [31:0] BTA1,
    output [1:0] type1,
    input inst_bj2,
    output [31:0] BTA2,
    output [1:0] type2,
    input inst_bj3,
    output [31:0] BTA3,
    output [1:0] type3
);

    wire [9:0] BTB_tag;
    wire [9:0] BTB_update_tag;

    wire [1:0] hit0_en;
    wire [1:0] hit1_en;
    wire [1:0] hit2_en;
    wire [1:0] hit3_en;

    reg [45:0] BTB1_bank0 [0:31];
    reg [45:0] BTB1_bank1 [0:31];
    reg [45:0] BTB1_bank2 [0:31];
    reg [45:0] BTB1_bank3 [0:31]; // 1 bit used signal, 1 bit valid signal, 10 bits tag, 32 bits BTA, 2 bits types
    reg [45:0] BTB2_bank0 [0:31];
    reg [45:0] BTB2_bank1 [0:31];
    reg [45:0] BTB2_bank2 [0:31];
    reg [45:0] BTB2_bank3 [0:31];

    assign BTB_tag = {pc[28:24] ^ pc[23:19], pc[18:14] ^ pc[13:9]};
    assign BTB_update_tag = {update_pc[28:24] ^ update_pc[23:19], update_pc[18:14] ^ update_pc[13:9]};

    assign hit0_en = BTB1_bank0[pc[8:4]][44] && BTB1_bank0[pc[8:4]][43:34] == BTB_tag ? 2'b01 : (BTB2_bank0[pc[8:4]][44] && BTB2_bank0[pc[8:4]][43:34] == BTB_tag ? 2'b10 : 2'b00);
    assign hit1_en = BTB1_bank1[pc[8:4]][44] && BTB1_bank1[pc[8:4]][43:34] == BTB_tag ? 2'b01 : (BTB2_bank1[pc[8:4]][44] && BTB2_bank1[pc[8:4]][43:34] == BTB_tag ? 2'b10 : 2'b00);
    assign hit2_en = BTB1_bank2[pc[8:4]][44] && BTB1_bank2[pc[8:4]][43:34] == BTB_tag ? 2'b01 : (BTB2_bank2[pc[8:4]][44] && BTB2_bank2[pc[8:4]][43:34] == BTB_tag ? 2'b10 : 2'b00);
    assign hit3_en = BTB1_bank3[pc[8:4]][44] && BTB1_bank3[pc[8:4]][43:34] == BTB_tag ? 2'b01 : (BTB2_bank3[pc[8:4]][44] && BTB2_bank3[pc[8:4]][43:34] == BTB_tag ? 2'b10 : 2'b00);

    assign BTA0 = hit0_en == 2'b00 ? {pc[31:4], 4'b0000} + 32'd4 : (hit0_en == 2'b01 ? BTB1_bank0[pc[8:4]][33:2] : (hit0_en == 2'b10 ? BTB2_bank0[pc[8:4]][33:2] : 32'd0));
    assign BTA1 = hit1_en == 2'b00 ? {pc[31:4], 4'b0100} + 32'd8 : (hit1_en == 2'b01 ? BTB1_bank1[pc[8:4]][33:2] : (hit1_en == 2'b10 ? BTB2_bank1[pc[8:4]][33:2] : 32'd0));
    assign BTA2 = hit2_en == 2'b00 ? {pc[31:4], 4'b1000} + 32'd12 : (hit2_en == 2'b01 ? BTB1_bank2[pc[8:4]][33:2] : (hit2_en == 2'b10 ? BTB2_bank2[pc[8:4]][33:2] : 32'd0));
    assign BTA3 = hit3_en == 2'b00 ? {pc[31:4], 4'b1100} + 32'd16 : (hit3_en == 2'b01 ? BTB1_bank3[pc[8:4]][33:2] : (hit3_en == 2'b10 ? BTB2_bank3[pc[8:4]][33:2] : 32'd0));

    assign type0 = hit0_en == 2'b01 ? BTB1_bank0[pc[8:4]][1:0] : (hit0_en == 2'b10 ? BTB2_bank0[pc[8:4]][1:0] : 2'b00);
    assign type1 = hit1_en == 2'b01 ? BTB1_bank1[pc[8:4]][1:0] : (hit1_en == 2'b10 ? BTB2_bank1[pc[8:4]][1:0] : 2'b00);
    assign type2 = hit2_en == 2'b01 ? BTB1_bank2[pc[8:4]][1:0] : (hit2_en == 2'b10 ? BTB2_bank2[pc[8:4]][1:0] : 2'b00);
    assign type3 = hit3_en == 2'b01 ? BTB1_bank3[pc[8:4]][1:0] : (hit3_en == 2'b10 ? BTB2_bank3[pc[8:4]][1:0] : 2'b00);

/////////
    always @(posedge clk) begin
        if(~resetn) begin : initialize
            integer i;
            for(i = 0;i <= 31;i = i + 1) begin : loop
                BTB1_bank0[i] = 46'd0;
                BTB2_bank0[i] = 46'd0; 
                BTB1_bank1[i] = 46'd0;
                BTB2_bank1[i] = 46'd0; 
                BTB1_bank2[i] = 46'd0;
                BTB2_bank2[i] = 46'd0; 
                BTB1_bank3[i] = 46'd0;
                BTB2_bank3[i] = 46'd0; 
            end
        end else begin
            if((hit0_en == 2'b01) & inst_bj0) begin
                BTB1_bank0[pc[8:4]][45] <= 1'b1;
                BTB2_bank0[pc[8:4]][45] <= 1'b0;
            end else if((hit0_en == 2'b10) & inst_bj0) begin
                BTB2_bank0[pc[8:4]][45] <= 1'b1;
                BTB1_bank0[pc[8:4]][45] <= 1'b0;
            end

            if((hit1_en == 2'b01) & inst_bj1) begin
                BTB1_bank1[pc[8:4]][45] <= 1'b1;
                BTB2_bank1[pc[8:4]][45] <= 1'b0;
            end else if((hit1_en == 2'b10) & inst_bj1) begin
                BTB2_bank1[pc[8:4]][45] <= 1'b1;
                BTB1_bank1[pc[8:4]][45] <= 1'b0;
            end

            if((hit2_en == 2'b01) & inst_bj2) begin
                BTB1_bank2[pc[8:4]][45] <= 1'b1;
                BTB2_bank2[pc[8:4]][45] <= 1'b0;
            end else if((hit2_en == 2'b10) & inst_bj2) begin
                BTB2_bank2[pc[8:4]][45] <= 1'b1;
                BTB1_bank2[pc[8:4]][45] <= 1'b0;
            end

            if((hit3_en == 2'b01) & inst_bj3) begin
                BTB1_bank3[pc[8:4]][45] <= 1'b1;
                BTB2_bank3[pc[8:4]][45] <= 1'b0;
            end else if((hit3_en == 2'b10) & inst_bj3) begin
                BTB2_bank3[pc[8:4]][45] <= 1'b1;
                BTB1_bank3[pc[8:4]][45] <= 1'b0;
            end
            //BTB replace algorithm
            case(update_pc[3:2])
                2'b00 : begin
                    if(update_en & BTB1_bank0[pc[8:4]][45] == 1'b1) begin
                        BTB1_bank0[pc[8:4]][43:34] <= {2'b11, BTB_update_tag, update_type};
                    end else if(update_en & BTB2_bank0[pc[8:4]][45] == 1'b1) begin
                        BTB2_bank0[pc[8:4]][43:34] <= {2'b11, BTB_update_tag, update_type};
                    end else if(update_en) begin
                        BTB1_bank0[pc[8:4]][43:34] <= {2'b11, BTB_update_tag, update_type};
                    end
                end
                2'b01 : begin
                    if(update_en & BTB1_bank1[pc[8:4]][45] == 1'b1) begin
                        BTB1_bank1[pc[8:4]][43:34] <= {2'b11, BTB_update_tag, update_type};
                    end else if(update_en & BTB2_bank1[pc[8:4]][45] == 1'b1) begin
                        BTB2_bank1[pc[8:4]][43:34] <= {2'b11, BTB_update_tag, update_type};
                    end else if(update_en) begin
                        BTB1_bank1[pc[8:4]][43:34] <= {2'b11, BTB_update_tag, update_type};
                    end
                end
                2'b10 : begin
                    if(update_en & BTB1_bank2[pc[8:4]][45] == 1'b1) begin
                        BTB1_bank2[pc[8:4]][43:34] <= {2'b11, BTB_update_tag, update_type};
                    end else if(update_en & BTB2_bank2[pc[8:4]][45] == 1'b1) begin
                        BTB2_bank2[pc[8:4]][43:34] <= {2'b11, BTB_update_tag, update_type};
                    end else if(update_en) begin
                        BTB1_bank2[pc[8:4]][43:34] <= {2'b11, BTB_update_tag, update_type};
                    end
                end
                2'b11 : begin
                    if(update_en & BTB1_bank3[pc[8:4]][45] == 1'b1) begin
                        BTB1_bank3[pc[8:4]][43:34] <= {2'b11, BTB_update_tag, update_type};
                    end else if(update_en & BTB2_bank3[pc[8:4]][45] == 1'b1) begin
                        BTB2_bank3[pc[8:4]][43:34] <= {2'b11, BTB_update_tag, update_type};
                    end else if(update_en) begin
                        BTB1_bank3[pc[8:4]][43:34] <= {2'b11, BTB_update_tag, update_type};
                    end
                end
            endcase
        end
    end
endmodule