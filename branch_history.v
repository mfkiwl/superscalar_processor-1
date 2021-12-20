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
    input wire [9:0] update_BHR,
    input wire [31:0] update_pc,
    input wire update_en,
    input wire branch_en, //branch_en is used to update the PHT_FSM and PHT
    output wire taken_en, //taken_en is used to indicate whether pc is going to branch, 1 is taken, 0 is not taken
    output wire [9:0] BHR
);

    parameter Strongly_taken = 2'b11;
    parameter Weakly_taken = 2'b10;
    parameter Weakly_not_taken = 2'b01;
    parameter Strongly_not_taken = 2'b00;

    wire [9:0] BHT_index;
    wire [9:0] PHT_index;
    wire [1:0] PHT_value;
    wire [9:0] update_PHT_index;

    wire [1:0] PHT_FSM_outout;
    wire [1:0] old_PHT_value;
    
    reg [9:0] BHT [0:1023];
    reg [1:0] PHT [0:1023];

    //use Hash algorithm to calculate BHT_index , splice BHR value and PC to generate PHT_index
    assign BHT_index = pc[13:4];
    assign BHR = BHT[BHT_index];
    assign PHT_index = BHR ^ BHT_index;
    assign update_PHT_index = update_BHR ^ update_pc[13:4];
    assign PHT_value = PHT[PHT_index];
    assign taken_en = PHT_value == Strongly_taken | PHT_value == Weakly_taken ? 1 : 0;
    assign old_PHT_value = PHT[update_PHT_index];
    
    always @(posedge clk) begin
        if(!resetn) begin : initialize
            integer i;
            for(i = 0;i <= 1023;i = i + 1) begin : loop
                BHT[i] <= 10'd0;
            end
        end else begin
            if(update_en) begin
                BHT[update_pc[13:4]] <= BHT[update_pc[13:4]] << 1 + {9'd0, branch_en};
            end
        end
    end

    always @(posedge clk) begin
        if(!resetn) begin : initialize2
            integer i;
            for(i = 0;i <= 1023;i = i + 1) begin : loop
                PHT[i] <= 2'b00;
            end
        end else begin
            if(update_en) begin
                PHT[update_pc[13:4]] <= PHT_FSM_outout;
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