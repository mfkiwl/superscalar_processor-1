module Return_Address_Stack(
    input clk,
    input resetn,
    input [1:0] type,
    input [31:0] next_pc,
    input inst_bj,
    output [31:0] target_pc
);

    parameter PUSH = 2'b01;
    parameter POP = 2'b10;

    reg [31:0] RAS [0:7];
    reg [2:0] sp;
    reg full;
    reg empty;

    assign target_pc = RAS[sp];

    always @(posedge clk) begin
        if(~resetn) begin : initialize
            integer i;
            for(i = 0;i <= 7;i = i + 1) begin : loop
                RAS[i] <= 32'd0;
            end
            sp <= 3'b000;
            full <= 1'b0;
            empty <= 1'b1;
        end else begin
            if((type == PUSH) & inst_bj) begin
                empty <= 1'b0;
                if(sp < 3'b111) begin
                    sp <= sp + 3'b001;
                    RAS[sp] <= next_pc;
                end else if(sp == 3'b111 & ~full) begin
                    RAS[sp] <= next_pc;
                    full <= 1'b1;
                end
            end else if((type == POP) & inst_bj) begin
                full <= 1'b0;
                if(sp > 3'b000) begin
                    RAS[sp] <= 32'd0;
                    sp <= sp - 3'b001;
                end else if(sp == 3'b000 & ~empty) begin
                    RAS[sp] <= 32'd0;
                    empty <= 1'b1;
                end
            end
        end
    end

endmodule