module mux4x32(
    input [1:0] s,
    input [31:0] a0,
    input [31:0] a1,
    input [31:0] a2,
    input [31:0] a3,
    output [31:0] out
);

    assign out = s == 2'b00 ? a0 : (s == 2'b01 ? a1 : (s == 2'b10 ? a2 : (s == 2'b11 ? a3 : 32'd0)));
    
endmodule

module branch(
    input clk,
    input resetn,
    input [31:0] pc,
    output [31:0] next_pc
);

    wire [3:0] BHR;
    wire taken_en;
    wire [31:0] BTA;
    wire [1:0] type;
    wire [31:0] RAS_addr;
    wire [31:0] indirect_addr;
    wire [1:0] select;

    assign select = taken_en ? (type == 2'b00 ? 2'b00 : (type == 2'b01 | type == 2'b10 ? 2'b01 : (type == 2'b11 ? 2'b10 : 2'b11))) : 2'b11;
    
//////////
    branch_history BH(
        .clk(clk),
        .resetn(resetn),
        .pc(pc),
        .update_PHT_index(),
        .update_BHT_index(),
        .update_en(),
        .branch_en(),
        .taken_en(taken_en),
        .o_PHT_index(),
        .o_BHT_index(),
        .BHR(BHR)
    );

    Branch_Target_Address BTA(
        .clk(clk),
        .resetn(resetn),
        .pc(pc),
        .update_pc(),
        .update_en(),
        .update_type(),
        .update_BTA(),
        .BTA(BTA),
        .type(type)
    );

    Return_Address_Stack RAS(
        .clk(clk),
        .resetn(resetn),
        .type(type),
        .next_pc(pc + 32'd4),
        .target_pc(RAS_addr)
    );
    
    Target_Cache TC(
        .clk(clk),
        .resetn(resetn),
        .pc(pc),
        .BHR(BHR),
        .update_pc(),
        .update_target(),
        .update_en(),
        .update_BHR(),
        .target_address(indirect_addr)
    );

    mux4x32 MUX(
        .s(select),
        .a0(BTA),
        .a1(RAS_addr),
        .a2(indirect_addr),
        .a3(pc + 32'd4),
        .out(next_pc)
    );

endmodule