module Branch_Target_Address(
    input clk,
    input resetn,
    input [31:0] pc,
    output [31:0] BTA
);

    wire [9:0] BTB_index;

    reg [44:0] BTB1 [0:127];
    reg [44:0] BTB2 [0:127];

    assign BTB_index = {pc[25:21] ^ pc[20:16], pc[15:11] ^ pc[10:6]};
    assign BTA = BTB1[pc[5:0]][44] == 1 ? (BTB1[pc[5:0]][43:34] == BTB_index ? BTB1[pc[5:0]][33:2]) : (BTB2[44] == 1 ? BTB2[pc[5:0]][43:34] == BTB_index ? BTB2[pc[5:0]][33:2] : (pc));

/////////
    always @(posedge clk) begin
        if(~resetn) begin : initialize
            integer i;
            for(i = 0;i <= 127;i = i + 1) begin : loop
                BTB1[i] = 45'd0;
                BTB2[i] = 45'd0; 
            end
        end else begin
            //BTB replace algorithm
        end
    end
endmodule