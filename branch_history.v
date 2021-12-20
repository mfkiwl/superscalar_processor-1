module PHT_FSM(
    input [1:0] old_state,
    input branch_en,
    input clk,
    input resetn,
    output reg [1:0] updated_state
);
    parameter Strongly_taken = 2'b11;
    parameter Weakly_taken = 2'b10;
    parameter Weakly_not_taken = 2'b01;
    parameter Strongly_not_taken = 2'b00;

    always @(*) begin
        if(~resetn) begin
            updated_state = Strongly_taken;
        end else begin
            case(updated_state)
                Strongly_taken : begin
                    updated_state = branch_en ? Strongly_taken : Weakly_taken;
                end
                Weakly_taken : begin
                    updated_state = branch_en ? Strongly_taken : Weakly_not_taken;
                end
                Weakly_not_taken : begin
                    updated_state = branch_en ? Weakly_taken : Strongly_not_taken;
                end
                Strongly_not_taken : begin
                    updated_state = branch_en ? Weakly_not_taken : Strongly_not_taken;
                end
                default : begin
                    
                end
            endcase
        end
    end
    
endmodule

module branch_history(
    input wire [31:0] pc,
    input wire clk,
    input wire resetn,
    input wire [7:0] update_PHT_index,
    input wire [31:0] update_pc,
    input wire update_en,
    input wire branch_en, //branch_en is used to update the PHT_FSM and PHT
    output wire taken_en, //taken_en is used to indicate whether pc is going to branch, 1 is taken, 0 is not taken
    output wire [1:0] choose
);

    parameter Strongly_taken = 2'b11;
    parameter Weakly_taken = 2'b10;
    parameter Weakly_not_taken = 2'b01;
    parameter Strongly_not_taken = 2'b00;

    wire [9:0] BHR0;
    wire [9:0] BHR1;
    wire [9:0] BHR2;
    wire [9:0] BHR3;
    wire [7:0] BHT0_index;
    wire [7:0] BHT1_index;
    wire [7:0] BHT2_index;
    wire [7:0] BHT3_index;
    wire [7:0] PHT0_index;
    wire [7:0] PHT1_index;
    wire [7:0] PHT2_index;
    wire [7:0] PHT3_index;
    wire [1:0] PHT0_value;
    wire [1:0] PHT1_value;
    wire [1:0] PHT2_value;
    wire [1:0] PHT3_value;

    wire [1:0] PHT_FSM_outout;
    wire [1:0] old_PHT_value;
    
    reg [9:0] BHT_bank0 [0:255];
    reg [9:0] BHT_bank1 [0:255];
    reg [9:0] BHT_bank2 [0:255];
    reg [9:0] BHT_bank3 [0:255];

    reg [1:0] PHT_bank0 [0:255];
    reg [1:0] PHT_bank1 [0:255];
    reg [1:0] PHT_bank2 [0:255];
    reg [1:0] PHT_bank3 [0:255];

    //use Hash algorithm to calculate BHT_index , splice BHR value and PC to generate PHT_index
    assign BHT0_index = pc[11:4];
    assign BHT1_index = pc[11:4];
    assign BHT2_index = pc[11:4];
    assign BHT3_index = pc[11:4];

    assign BHR0 = BHT_bank0[BHT0_index];
    assign BHR1 = BHT_bank1[BHT1_index];
    assign BHR2 = BHT_bank2[BHT2_index];
    assign BHR3 = BHT_bank3[BHT3_index];
     
    assign PHT0_index = {BHR0[3:0], pc[7:4]};
    assign PHT1_index = {BHR1[3:0], pc[7:4]};
    assign PHT2_index = {BHR2[3:0], pc[7:4]};
    assign PHT3_index = {BHR3[3:0], pc[7:4]};

    assign PHT0_value = PHT_bank0[PHT0_index];
    assign PHT1_value = PHT_bank1[PHT1_index];
    assign PHT2_value = PHT_bank2[PHT2_index];
    assign PHT3_value = PHT_bank3[PHT3_index];

    assign taken0_en = PHT0_value == Strongly_taken | PHT0_value == Weakly_taken ? 1 : 0;
    assign taken1_en = PHT1_value == Strongly_taken | PHT1_value == Weakly_taken ? 1 : 0;
    assign taken2_en = PHT2_value == Strongly_taken | PHT2_value == Weakly_taken ? 1 : 0;
    assign taken3_en = PHT3_value == Strongly_taken | PHT3_value == Weakly_taken ? 1 : 0; 

    assign choose[0] = (~pc[3] & ~pc[2] & ~taken0_en & taken1_en) | (~pc[2] & ~taken0_en & ~taken2_en & ~taken3_en) | (~pc[2] & ~taken0_en & ~taken1_en & ~taken2_en & taken3_en) | (pc[2] & ~taken1_en & ~taken2_en & taken3_en) |
                  (pc[3] & ~pc[2] & taken0_en & ~taken1_en & ~taken2_en & taken3_en) | (pc[3] & pc[2] & ~taken0_en & ~taken1_en & taken3_en) | (pc[2] & taken0_en & taken3_en) | (~pc[3] & pc[2] & taken1_en) | (pc[2] & ~taken0_en & taken1_en) |
                  (~pc[2] & taken1_en & ~taken2_en);
    
    assign choose[1] = (pc[2] & ~taken1_en & taken3_en) | (pc[3] & ~pc[2] & taken2_en) | (pc[3] & taken1_en & taken3_en) | (pc[2] & ~taken0_en & ~taken1_en & taken2_en) | (~pc[2] & ~taken0_en & ~taken1_en & taken2_en) |
                       (~pc[3] & pc[2] & ~taken1_en & taken2_en & ~taken3_en) | (~pc[2] & ~taken0_en & ~taken1_en & ~taken2_en & taken3_en) | (pc[3] & ~pc[2] & taken0_en & ~taken1_en & ~taken2_en & taken3_en);

    assign taken_en = taken0_en | taken1_en | taken2_en | taken3_en;

    assign old_PHT_value = update_PHT_index[3:2] == 2'b00 ? PHT_bank0[update_PHT_index] : (update_PHT_index == 2'b01 ? PHT_bank1[update_PHT_index] : (update_PHT_index == 2'b10 ? PHT_bank2[update_PHT_index] : PHT_bank3[update_PHT_index]));
    
    always @(posedge clk) begin
        if(!resetn) begin : initialize
            integer i;
            for(i = 0;i <= 255;i = i + 1) begin : loop
                BHT_bank0[i] <= 10'd0;
                BHT_bank1[i] <= 10'd0;
                BHT_bank2[i] <= 10'd0;
                BHT_bank3[i] <= 10'd0;
            end
        end else begin
            if(update_en) begin
                case(update_pc[3:2])
                    2'b00 : begin
                        BHT_bank0[pc[11:4]] <= BHT_bank0[pc[11:4]] << 1 + {9'd0, branch_en};
                    end
                    2'b01 : begin
                        BHT_bank1[pc[11:4]] <= BHT_bank1[pc[11:4]] << 1 + {9'd0, branch_en};
                    end
                    2'b10 : begin
                        BHT_bank2[pc[11:4]] <= BHT_bank2[pc[11:4]] << 1 + {9'd0, branch_en};
                    end
                    2'b11 : begin
                        BHT_bank3[pc[11:4]] <= BHT_bank3[pc[11:4]] << 1 + {9'd0, branch_en};
                    end
                    default : begin
                        
                    end
                endcase
            end
        end
    end

    always @(posedge clk) begin
        if(!resetn) begin : initialize2
            integer i;
            for(i = 0;i <= 255;i = i + 1) begin : loop
                PHT_bank0[i] <= 2'b00;
                PHT_bank1[i] <= 2'b00;
                PHT_bank2[i] <= 2'b00;
                PHT_bank3[i] <= 2'b00;
            end
        end else begin
            if(update_en) begin
                case(update_PHT_index[3:2])
                    2'b00 : begin
                        BHT_bank0[pc[11:4]] <= BHT_bank0[pc[11:4]] << 1 + {9'd0, branch_en};
                    end
                    2'b01 : begin
                        BHT_bank1[pc[11:4]] <= BHT_bank1[pc[11:4]] << 1 + {9'd0, branch_en};
                    end
                    2'b10 : begin
                        BHT_bank2[pc[11:4]] <= BHT_bank2[pc[11:4]] << 1 + {9'd0, branch_en};
                    end
                    2'b11 : begin
                        BHT_bank3[pc[11:4]] <= BHT_bank3[pc[11:4]] << 1 + {9'd0, branch_en};
                    end
                    default : begin
                        
                    end
                endcase
            end
        end
    end

//////////add PHT_FSM
    PHT_FSM fsm(
        .old_state(old_PHT_value),
        .branch_en(branch_en),
        .clk(clk),
        .resetn(resetn),
        .updated_state(PHT_FSM_outout)
    );

endmodule