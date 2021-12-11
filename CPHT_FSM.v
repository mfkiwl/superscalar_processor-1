module CPHT_FSM(
    input [1:0] old_state,
    input p1_res,
    input p2_res,
    input clk,
    input resetn,
    output reg [1:0] updated_state
);
    parameter Strongly_p2 = 2'b11;
    parameter Weakly_p2 = 2'b10;
    parameter Weakly_p1 = 2'b01;
    parameter Strongly_p1 = 2'b00;

    always @(posedge clk) begin
        if(!resetn) begin
            updated_state = Strongly_p1;
        end else begin
            case(updated_state)
                Strongly_p1 : begin
                    updated_state = (~p1_res & ~p2_res) | (p1_res & ~p2_res) | (p1_res & p2_res) ? Strongly_p1 : Weakly_p1;
                end
                Weakly_p1 : begin
                    updated_state = (~p1_res & ~p2_res) | (p1_res & p2_res) ? Weakly_p1 : ((p1_res & ~p2_res) ? Strongly_p1 : Weakly_p2);
                end
                Weakly_p2 : begin
                    updated_state = (~p1_res & ~p2_res) | (p1_res & p2_res) ? Weakly_p2 : ((p1_res & ~p2_res) ? Weakly_p1 : Strongly_p2);
                end
                Strongly_p2 : begin
                    updated_state = (~p1_res & ~p2_res) | (~p1_res & p2_res) | (p1_res & p2_res) ? Strongly_p2 : Weakly_p2;
                end
                default : begin
                    
                end
            endcase
        end
    end
    
endmodule