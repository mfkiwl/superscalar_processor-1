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
    input [31:0] pc,
    input clk,
    input resetn,
    input [6:0] update_PHT_index,
    input [3:0] update_BHT_index,
    input update_en,
    input branch_en, //branch_en is used to update the PHT_FSM and PHT
    output taken_en //taken_en is used to indicate whether pc is going to branch, 1 is taken, 0 is not taken
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

    wire last;

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

    assign old_PHT_value = ;

    assign last = (~pc[3] & ~pc[2] & ~PHT0_value & PHT1_value) | (~pc[2] & ~PHT0_value & ~PHT2_value & ~PHT3_value) | (~pc[2] & ~PHT0_value & ~PHT0_value & ~PHT2_value & PHT3_value) | (pc[2] & ~PHT1_value & ~PHT2_value & PHT3_value) |
                  (pc[3] & ~pc[2] & PHT0_value & ~PHT1_value & ~PHT2_value & PHT3_value) | (pc[3] & pc[2] & ~PHT0_value & ~PHT1_value & PHT3_value) | (pc[2] & PHT0_value & PHT3_value) | (~pc[3] & pc[2] & PHT1_value) | (pc[2] & ~PHT0_value & PHT1_value) |
                  (~pc[2] & PHT1_value & ~PHT2_value);

    always @(posedge clk) begin
        if(!resetn) begin : initialize
            integer i;
            for(i = 0;i <= 7;i = i + 1) begin : loop
                BHT[i] <= 4'b0000;
            end
        end else begin
            if(update_en) begin
                BHT[update_BHT_index] <= BHT[update_BHT_index] << 1 + {3'b000, branch_en};
            end
        end
    end

    always @(posedge clk) begin
        if(!resetn) begin : initialize2
            integer i;
            for(i = 0;i <= 127;i = i + 1) begin : loop
                PHT[i] <= 2'b00;
            end
        end else begin
            if(update_en) begin
                PHT[update_PHT_index] <= PHT_FSM_outout;
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