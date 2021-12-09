module branch_global(
    input [31:0] pc,
    input clk,
    input resetn,
    input [1:0] updated_state,
    output [1:0] PHT_value
);

    wire [3:0] BHR;
    wire [3:0] BHT_index;
    wire [6:0] PHT_index;
    
    reg [3:0] BHT [0:15];
    reg [1:0] PHT [0:127];

    //use Hash algorithm to calculate index ,XOR index and PC to generate PHT_index
    index = pc[31:28] ^ pc[27:24] ^ pc[23:20] ^ pc[19:16] ^ pc[15:12] ^ pc[11:8] ^ pc[7:4] ^ pc[3:0];
    PHT_index = index & pc[3:0];
    PHT_value = PHT[PHT_index];

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

    

endmodule