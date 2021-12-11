module branch_tournament(
    input clk,
    input resetn,
    input [31:0] pc,
    output taken_en
);

    parameter Strongly_p2 = 2'b11;
    parameter Weakly_p2 = 2'b10;
    parameter Weakly_p1 = 2'b01;
    parameter Strongly_p1 = 2'b00;

    reg [1:0] CPHT [0:127];

    wire [3:0] index;
    wire [6:0] CPHT_index;
    wire choose_predictor; // 0 is history predictor, 1 is global predictor
    wire history_res;
    wire global_res;

    index = pc[31:28] ^ pc[27:24] ^ pc[23:20] ^ pc[19:16] ^ pc[15:12] ^ pc[11:8] ^ pc[7:4] ^ pc[3:0];
    CPHT_index = {index, pc[3:0]};
    choose_predictor = CPHT[CPHT_index] == Strongly_p1 | CPHT[CPHT_index] == Weakly_p1 ? 0 : 1;
    taken_en = choose_predictor ? history_res : global_res;

//////////
    branch_history(
        .pc(pc),
        .clk(clk),
        .resetn(resetn),
        .branch_en(),
        .taken_en(history_res)
    );

    branch_global(
        .pc(pc),
        .clk(clk),
        .resetn(resetn),
        .branch_en(),
        .taken_en(global_res)
    );
//////////

endmodule