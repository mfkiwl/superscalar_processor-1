module branch_global(
    input [31:0] pc,
    input clk,
    input resetn,
    input branch_en, //branch_en is used to update the PHT_FSM and PHT
    output taken_en, //taken_en is used to indicate whether pc is going to branch, 1 is taken, 0 is not taken
);

    parameter Strongly_taken = 2'b11;
    parameter Weakly_taken = 2'b10;
    parameter Weakly_not_taken = 2'b01;
    parameter Strongly_not_taken = 2'b00;

    wire [3:0] index;
    wire [6:0] PHT_index;
    wire [1:0] PHT_FSM_output;
    
    reg [3:0] BHT [0:15];
    reg [1:0] PHT [0:127];

    //use Hash algorithm to calculate index ,XOR index and PC to generate PHT_index
    index = pc[31:28] ^ pc[27:24] ^ pc[23:20] ^ pc[19:16] ^ pc[15:12] ^ pc[11:8] ^ pc[7:4] ^ pc[3:0];
    PHT_index = {index, pc[3:0]};
    PHT_value = PHT[PHT_index];
    taken_en = PHT_value == Strongly_taken | PHT_value == Weakly_taken ? 1 : 0;

    always @(posedge clk) begin
        if(!resetn) begin : initialize
            integer i;
            for(i = 0;i <= 127;i = i + 1) begin : loop
                PHT = 2'b00;
            end
        end else begin
            //add update function
        end
    end

//////////add PHT_FSM
    PHT_FSM fsm(
        .old_state(PHT_value),
        .branch_en(branch_en),
        .clk(clk),
        .resetn(resetn),
        .updated_state(PHT_FSM_outout)
    );

endmodule