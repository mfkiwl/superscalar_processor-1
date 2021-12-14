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
        if(!resetn) begin
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
    output taken_en, //taken_en is used to indicate whether pc is going to branch, 1 is taken, 0 is not taken
    output [6:0] o_PHT_index //transmittd through the pipeline to retire stage
    output [3:0] o_BHT_index,
    output [3:0] BHR

);

    parameter Strongly_taken = 2'b11;
    parameter Weakly_taken = 2'b10;
    parameter Weakly_not_taken = 2'b01;
    parameter Strongly_not_taken = 2'b00;

    wire [3:0] BHR;
    wire [3:0] BHT_index;
    wire [6:0] PHT_index;
    wire [1:0] PHT_value;
    wire [1:0] PHT_FSM_outout;
    wire [1:0] old_PHT_value;
    
    reg [3:0] BHT [0:15];
    reg [1:0] PHT [0:127];

    //use Hash algorithm to calculate BHT_index , splice BHR value and PC to generate PHT_index
    BHT_index = pc[31:28] ^ pc[27:24] ^ pc[23:20] ^ pc[19:16] ^ pc[15:12] ^ pc[11:8] ^ pc[7:4] ^ pc[3:0];
    BHR = BHT[BHT_index];
    PHT_index = {pc[2:0], BHR};
    o_PHT_index = PHT_index;
    PHT_value = PHT[PHT_index];
    old_PHT_value = PHT[update_PHT_index];
    taken_en = PHT_value == Strongly_taken | PHT_value == Weakly_taken ? 1 : 0;

    always @(posedge clk) begin
        if(!resetn) begin : initialize
            integer i;
            for(i = 0;i <= 7;i = i + 1) begin : loop
                BHT[i] <= 4'b0000;
            end
        end else begin
            BHT[update_BHT_index] <= BHT[update_BHT_index] << 1 + {3'b000, taken_en};
        end
    end

    always @(posedge clk) begin
        if(!resetn) begin : initialize
            integer i;
            for(i = 0;i <= 127;i = i + 1) begin : loop
                PHT <= 2'b00;
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