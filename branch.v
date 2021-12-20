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
    input [31:0] inst,
    output [31:0] next_pc
);

//////////
    wire [6:0] op;
    wire [2:0] func;

    assign op = inst[6:0];
    assign func = inst[14:12];

    wire inst_bj;
    wire inst_jal;
    wire inst_jalr;
    wire inst_beq;
    wire inst_bne;
    wire inst_blt;
    wire inst_bge;
    wire inst_bltu;
    wire inst_bgeu;
    
    assign inst_jal =  op == 7'b1101111;
    assign inst_jalr = op == 7'b1100111 && func == 3'b000;
    assign inst_beq =  op == 7'b1100011 && func == 3'b000;
    assign inst_bne =  op == 7'b1100011 && func == 3'b001;
    assign inst_blt =  op == 7'b1100011 && func == 3'b100;
    assign inst_bge =  op == 7'b1100011 && func == 3'b101;
    assign inst_bltu = op == 7'b1100011 && func == 3'b110;
    assign inst_bgeu = op == 7'b1100011 && func == 3'b111;
    assign inst_bj = inst_jal | inst_jalr | inst_beq | inst_bne | inst_blt | inst_bge | inst_bltu | inst_bgeu;
//////////
    wire [3:0] BHR;
    wire taken_en;
    wire [31:0] BTA;
    wire [1:0] type;
    wire [31:0] RAS_addr;
    wire [31:0] indirect_addr;
    wire [1:0] select;

    //assign select = ~inst_bj | (inst_bj & ~taken_en) ? 2'b11 : (type == 2'b00 ? BTA : (type == 2'b01 | type == 2'b10 ? RAS_addr : indirect_addr)); 
    
//////////
    branch_history BH(
        .clk(clk),
        .resetn(resetn),
        .pc(pc),
        .update_BHR(),
        .update_pc(),
        .update_en(),
        .branch_en(),
        .taken_en(taken_en),
        .BHR(BHR)
    );

    Branch_Target_Buffer BTB(
        .clk(clk),
        .resetn(resetn),
        .pc(pc),
        .update_pc(),
        .update_en(),
        .update_type(),
        .update_BTA(),
        .inst_bj(),
        .BTA(BTA),
        .type(type)
    );

    Return_Address_Stack RAS(
        .clk(clk),
        .resetn(resetn),
        .type(type),
        .next_pc(),
        .inst_bj(inst_bj),
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
        .a3(),
        .out(next_pc)
    );

endmodule