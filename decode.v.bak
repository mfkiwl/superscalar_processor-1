module decode_mod(
    input [31:0] inst,
    input [31:0] pc,

    output wire write_mem,
    output wire write_regfile,
    output wire mem_to_regfile,
    output wire jal,
    output wire aluimm,
    output wire shift,
    output wire sext,
    output wire [14:0] ALUControl,
    output wire [7:0] mem_control,
    output wire shift_v,
    output wire [31:0] imm,
    output wire [4:0] rn,
    output wire [31:0] bpc,
    output wire [31:0] jpc,
    output wire [4:0] rs,
    output wire [4:0] rt,
    output wire is_branch
    //output wire [31:0] jrpc,
    //output wire [31:0] shamt
);

    wire [5:0] op;
    wire [5:0] func;

    assign op = inst[31:26];
    assign rs = inst[25:21];
    assign rt = inst[20:16];
    assign func = inst[5:0];

    wire inst_add;
    wire inst_addi;
    wire inst_addiu;
    wire inst_addu;
    wire inst_clo;
    wire inst_clz;
    wire inst_div;
    wire inst_divu;
    wire inst_madd;
    wire inst_maddu;
    wire inst_msub;
    wire inst_msubu;
    wire inst_mul;
    wire inst_mult;
    wire inst_multu;
    wire inst_slt;
    wire inst_slti;
    wire inst_sltiu;
    wire inst_sltu;
    wire inst_sub;
    wire inst_subu;
    wire inst_beq;
    wire inst_bgez;
    wire inst_bgezal;
    wire inst_bgtz;
    wire inst_blez;
    wire inst_bltz;
    wire inst_bltzal;
    wire inst_bne;
    wire inst_j;
    wire inst_jal;
    wire inst_jalr;
    wire inst_jr;
    wire inst_lb;
    wire inst_lbu;
    wire inst_lh;
    wire inst_lhu;
    wire inst_ll;
    wire inst_lw;
    wire inst_lwl;
    wire inst_lwr;
    wire inst_pref;
    wire inst_sb;
    wire inst_sc;
    wire inst_sh;
    wire inst_sw;
    wire inst_swl;
    wire inst_swr;
    wire inst_sync;
    wire inst_and;
    wire inst_andi;
    wire inst_lui;
    wire inst_nor;
    wire inst_or;
    wire inst_ori;
    wire inst_xor;
    wire inst_xori;
    wire inst_mfhi;
    wire inst_mflo;
    wire inst_movf;
    wire inst_movn;
    wire inst_movt;
    wire inst_movz;
    wire inst_mthi;
    wire inst_mtlo;
    wire inst_sll;
    wire inst_sllv;
    wire inst_sra;
    wire inst_srav;
    wire inst_srl;
    wire inst_srlv;
    wire inst_break;
    wire inst_syscall;
    wire inst_teq;
    wire inst_teqi;
    wire inst_tge;
    wire inst_tgei;
    wire inst_tgeiu;
    wire inst_tgeu;
    wire inst_tlt;
    wire inst_tlti;
    wire inst_tltiu;
    wire inst_tltu;
    wire inst_tne;
    wire inst_tnei;
    wire inst_beql;
    wire inst_bgezall;
    wire inst_bgtzl;
    wire inst_blezl;
    wire inst_bltzall;
    wire inst_bltzl;
    wire inst_bnel;
    wire inst_cache;
    wire inst_eret;
    wire inst_mfc0;
    wire inst_mtc0;
    wire inst_tlbp;
    wire inst_tlbr;
    wire inst_tlbwi;
    wire inst_tlbwr;
    wire inst_wait;

    assign inst_add = (op == 6'd0) & (func == 6'd32);
    assign inst_addi = (op == 6'd8);
    assign inst_addiu = (op == 6'd9);
    assign inst_addu = (op == 6'd0) & (func == 6'd33);
    assign inst_clo = (op == 6'd28) & (func == 6'd33);
    assign inst_clz = (op == 6'd28) & (func == 6'd32);
    assign inst_div = (op == 6'd0) & (func == 6'd26);
    assign inst_divu = (op == 6'd0) & (func == 6'd27);
    assign inst_madd = (op == 6'd28) & (func == 6'd0);
    assign inst_maddu = (op == 6'd28) & (func == 6'd1);
    assign inst_msub = (op == 6'd28) & (func == 6'd4);
    assign inst_msubu = (op == 6'd28) & (func == 6'd5);
    assign inst_mul = (op == 6'd28) & (func == 6'd2);
    assign inst_mult = (op == 6'd0) & (func == 6'd24);
    assign inst_multu = (op == 6'd0) & (func == 6'd25);
    assign inst_slt = (op == 6'd0) & (func == 6'd42);
    assign inst_slti = (op == 6'd10);
    assign inst_sltiu = (op == 6'd11);
    assign inst_sltu = (op == 6'd0) & (func == 6'd43);
    assign inst_sub = (op == 6'd0) & (func == 6'd34);
    assign inst_subu = (op ==6'd0) & (func == 6'd35);
    assign inst_beq = (op == 6'd4);
    assign inst_bgez = (op == 6'd1) & (rt == 5'd1);
    assign inst_bgezal = (op == 6'd1) & (rt == 5'd17);
    assign inst_bgtz = (op == 6'd7) & (rt == 5'd0);
    assign inst_blez = (op == 6'd6) & (rt == 5'd0);
    assign inst_bltz = (op == 6'd1) & (rt == 5'd0);
    assign inst_bltzal = (op == 6'd1) & (rt == 5'd16);
    assign inst_bne = (op == 6'd5);
    assign inst_j = (op == 6'd2);
    assign inst_jal = (op == 6'd3);
    assign inst_jalr = (op == 6'd0) & (func == 6'd9);
    assign inst_jr = (op == 6'd0) & (func == 6'd8);
    assign inst_lb = (op == 6'd32);
    assign inst_lbu = (op == 6'd36);
    assign inst_lh = (op == 6'd33);
    assign inst_lhu = (op == 6'd37);
    assign inst_ll = (op == 6'd48);
    assign inst_lw = (op == 6'd35);
    assign inst_lwl = (op == 6'd34);
    assign inst_lwr = (op == 6'd38);
    assign inst_pref = (op == 6'd51);
    assign inst_sb = (op == 6'd40);
    assign inst_sc = (op == 6'd56);
    assign inst_sh = (op == 6'd41);
    assign inst_sw = (op == 6'd43);
    assign inst_swl = (op == 6'd42);
    assign inst_swr = (op == 6'd46);
    assign inst_sync = (op == 6'd0) & (func == 6'd15);
    assign inst_and = (op == 6'd0) & (func == 6'd36);
    assign inst_andi = (op == 6'd12);
    assign inst_lui = (op == 6'd15);
    assign inst_nor = (op == 6'd0) & (func == 6'd39);
    assign inst_or = (op == 6'd0) & (func == 6'd37);
    assign inst_ori = (op == 6'd13);
    assign inst_xor = (op == 6'd0) & (func == 6'd38);
    assign inst_xori = (op == 6'd14);
    assign inst_mfhi = (op == 6'd0) & (func == 6'd16);
    assign inst_mflo = (op == 6'd0) & (func == 6'd18);
    assign inst_movf = (op == 6'd0) & (func == 6'd1) & (inst[17:16] == 2'b0);
    assign inst_movn = (op == 6'd0) & (func == 6'd11);
    assign inst_movt = (op == 6'd0) & (func == 6'd1) & (inst[17:16] == 2'b1);
    assign inst_movz = (op == 6'd0) & (func == 6'd10);
    assign inst_mthi = (op == 6'd0) & (func == 6'd17);
    assign inst_mtlo = (op == 6'd0) & (func == 6'd18);
    assign inst_sll = (op == 6'd0) & (func == 6'd0);//
    assign inst_sllv = (op == 6'd0) & (func == 6'd4);
    assign inst_sra = (op == 6'd0) & (func == 6'd3);
    assign inst_srav = (op == 6'd0) & (func == 6'd7);
    assign inst_srl = (op == 6'd0) & (func == 6'd2);
    assign inst_srlv = (op == 6'd0) & (func == 6'd6);//
    assign inst_break = (op == 6'd0) & (func == 6'd13);
    assign inst_syscall = (op == 6'd0) & (func == 6'd12);
    assign inst_teq = (op == 6'd0) & (func == 6'd52);
    assign inst_teqi = (op == 6'd1) & (rt == 5'd12);
    assign inst_tge = (op == 6'd0) & (func == 6'd48);
    assign inst_tgei = (op == 6'd1) & (rt == 5'd8);
    assign inst_tgeiu = (op == 6'd10) & (rt == 5'd9);
    assign inst_tgeu = (op == 6'd0) & (func == 6'd49);
    assign inst_tlt = (op == 6'd0) & (func == 6'd50);
    assign inst_tlti = (op == 6'd1) & (rt == 5'd10);
    assign inst_tltiu = (op == 6'd1) & (rt == 5'd11);
    assign inst_tltu = (op == 6'd0) & (func == 6'd51);
    assign inst_tne = (op == 6'd0) & (func == 6'd54);
    assign inst_tnei = (op == 6'd1) & (rt == 5'd18);
    assign inst_beql = (op == 6'd20);
    assign inst_bgezall = (op == 6'd1) & (rt == 5'd19);
    assign inst_bgtzl = (op == 6'd23) & (rt == 5'd0);
    assign inst_blezl = (op == 6'd22) & (rt == 5'd0);
    assign inst_bltzall = (op == 6'd1) & (rt == 5'd18);
    assign inst_bltzl = (op == 6'd1) & (rt == 5'd2);
    assign inst_bnel = (op == 6'd21);
    assign inst_cache = (op == 6'd47);
    assign inst_eret = (op == 6'd16) & (func == 6'd24);
    assign inst_mfc0 = (op == 6'd16) & (rs == 5'd0) & (func == 6'd0);
    assign inst_mtc0 = (op == 6'd16) & (rs == 5'd4) & (func == 6'd0);
    assign inst_tlbp = (op == 6'd16) & (rs == 5'd16) & (func == 6'd8);
    assign inst_tlbr = (op == 6'd16) & (rs == 5'd16) & (func == 6'd1);
    assign inst_tlbwi = (op == 6'd16) & (rs == 5'd16) & (func == 6'd2);
    assign inst_tlbwr = (op == 6'd16) ^ (rs == 5'd16) & (func == 6'd6);

    wire ADDU_inst, ADD_inst, SUB_inst, SUBU_inst, AND_inst, OR_inst, XOR_inst, NOR_inst, SLT_inst, SLTU_inst, SLL_inst, SRL_inst,
         SRA_inst, LUI_inst, JUMP_BRANCH_inst, MULT_inst, MULTU_inst, DIV_inst, DIVU_inst, MFHI_inst, MFLO_inst, MTHI_inst, MTLO_inst;

    wire rd_or_rt;

    assign ADDU_inst = inst_addu | inst_addiu | inst_lw | inst_sw | inst_sb | inst_sh | inst_lb | inst_lbu | inst_lh | inst_lhu;
    assign ADD_inst = inst_add | inst_addi;
    assign SUB_inst = inst_sub;
    assign SUBU_inst = inst_subu;
    assign AND_inst = inst_and | inst_andi;
    assign OR_inst = inst_or | inst_ori;
    assign XOR_inst = inst_xor | inst_xori;
    assign NOR_inst = inst_nor;
    assign SLT_inst = inst_slt | inst_slti;
    assign SLTU_inst = inst_sltu | inst_sltiu;
    assign SLL_inst = inst_sll | inst_sllv;
    assign SRL_inst = inst_srl | inst_srlv;
    assign SRA_inst = inst_sra | inst_srav;
    assign LUI_inst = inst_lui;
    assign JUMP_BRANCH_inst = inst_jr | inst_beq | inst_bne | inst_j | inst_jal | inst_jalr;
    assign MULT_inst = inst_mult;
    assign MULTU_inst = inst_multu;
    assign DIV_inst = inst_div;
    assign DIVU_inst = inst_divu;
    assign MFHI_inst = inst_mfhi;
    assign MFLO_inst = inst_mflo;
    assign MTHI_inst = inst_mthi;
    assign MTLO_inst = inst_mtlo;

    //
    assign R_type = inst_add | inst_addu | inst_sub | inst_subu | inst_or | inst_xor | inst_nor | inst_slt | inst_sltu | inst_sll | inst_srl | inst_sra | inst_sllv | inst_srlv |
                    inst_srav | inst_jr  | inst_jalr;
    assign I_type = inst_addi | inst_addiu | inst_andi | inst_ori | inst_xori | inst_lui | inst_lw | inst_sw | inst_beq | inst_bne | inst_slti | inst_sltiu;
    assign J_type = inst_j | inst_jal;

    assign ALUControl = {
        ADDU_inst,
        ADD_inst,
        SUB_inst,
        SUBU_inst,
        AND_inst,
        OR_inst,
        XOR_inst,
        NOR_inst,
        SLT_inst,
        SLTU_inst,
        SLL_inst,
        SRL_inst,
        SRA_inst,
        LUI_inst,
        JUMP_BRANCH_inst
    };

    assign write_mem = inst_sw | inst_sb | inst_sh;
    assign write_regfile = inst_add | inst_addu | inst_sub | inst_subu | inst_add | inst_or | inst_xor |
                           inst_nor | inst_slt | inst_sltu | inst_sll | inst_srl | inst_sra | inst_sllv |
                           inst_srlv | inst_srav | inst_addi | inst_addiu | inst_andi | inst_ori | inst_xori |
                           inst_lui | inst_slti | inst_sltiu | inst_jal | inst_mfhi | inst_mflo  | inst_jalr;
    assign mem_to_regfile = inst_lw | inst_lb | inst_lbu | inst_lh | inst_lhu;
    assign jal = inst_jal | inst_jalr;
    assign aluimm = inst_addi | inst_addiu | inst_andi | inst_ori | inst_xori | inst_lui | inst_lw | inst_sw |
                    inst_slti | inst_sltiu | inst_lb | inst_lbu | inst_lh | inst_lhu | inst_sb | inst_sh;
    assign shift = inst_sll | inst_srl | inst_sra | inst_sllv | inst_srlv | inst_srav;
    assign shift_v = inst_sllv | inst_srlv | inst_srav;
    assign sext = inst_addi | inst_lw   | inst_sw   | inst_beq  | inst_bne | inst_slti | inst_sltiu |
                  inst_bgez | inst_bgtz | inst_blez | inst_bltz | inst_lb  | inst_lbu  | inst_sb; //1'b1 sign : 1'b0 zero
    assign rd_or_rt = inst_add  | inst_addu | inst_sub | inst_subu | inst_and | inst_or | inst_xor | inst_nor |
                      inst_slt  | inst_sltu | inst_sll | inst_srl | inst_sra | inst_sllv | inst_srlv | inst_srav |
                      inst_mfhi | inst_mflo; //1'b1 rd : 1'b0 rt
    
    assign rn = rd_or_rt ? inst[15:11] : inst[20:16];

    
    assign bpc = pc + {{14{inst[15]}}, inst[15:0], 2'b00}; //no delayslot
    
    assign jpc = {pc[31:28], inst[25:0], 2'b00}; //no delayslot

    assign mem_control = {
        inst_lb,
        inst_lbu,
        inst_lh,
        inst_lhu,
        inst_lw,
        inst_sb,
        inst_sh,
        inst_sw
    };

    assign imm = sext ? {{16{inst[15]}}, inst[15:0]} : {16'd0, inst[15:0]};

    assign is_branch = inst_jalr |  inst_jr | inst_beq | inst_bgez | inst_bgtz | inst_blez | inst_bne | inst_j | inst_jal;
    
endmodule

module decode(
    input wire [31:0] pc0,
    input wire [31:0] inst0,
    input wire [31:0] pc1,
    input wire [31:0] inst1,
    input wire [31:0] pc2,
    input wire [31:0] inst2,
    input wire [31:0] pc3,
    input wire [31:0] inst3,

    output wire write_mem0,
    output wire write_regfile0,
    output wire mem_to_regfile0,
    output wire jal0,
    output wire aluimm0,
    output wire shift0,
    output wire sext0,
    output wire [14:0] ALUControl0,
    output wire [7:0] mem_control0,
    output wire shift_v0,
    output wire [31:0] imm0,
    output wire [4:0] rn0,
    output wire [31:0] bpc0,
    output wire [31:0] jpc0,
    output wire [4:0] rs0,
    output wire [4:0] rt0,
    output wire is_branch0,

    output wire write_mem1,
    output wire write_regfile1,
    output wire mem_to_regfile1,
    output wire jal1,
    output wire aluimm1,
    output wire shift1,
    output wire sext1,
    output wire [14:0] ALUControl1,
    output wire [7:0] mem_control1,
    output wire shift_v1,
    output wire [31:0] imm1,
    output wire [4:0] rn1,
    output wire [31:0] bpc1,
    output wire [31:0] jpc1,
    output wire [4:0] rs1,
    output wire [4:0] rt1,
    output wire is_branch1,

    output wire write_mem2,
    output wire write_regfile2,
    output wire mem_to_regfile2,
    output wire jal2,
    output wire aluimm2,
    output wire shift2,
    output wire sext2,
    output wire [14:0] ALUControl2,
    output wire [7:0] mem_control2,
    output wire shift_v2,
    output wire [31:0] imm2,
    output wire [4:0] rn2,
    output wire [31:0] bpc2,
    output wire [31:0] jpc2,
    output wire [4:0] rs2,
    output wire [4:0] rt2,
    output wire is_branch2,

    output wire write_mem3,
    output wire write_regfile3,
    output wire mem_to_regfile3,
    output wire jal3,
    output wire aluimm3,
    output wire shift3,
    output wire sext3,
    output wire [14:0] ALUControl3,
    output wire [7:0] mem_control3,
    output wire shift_v3,
    output wire [31:0] imm3,
    output wire [4:0] rn3,
    output wire [31:0] bpc3,
    output wire [31:0] jpc3,
    output wire [4:0] rs3,
    output wire [4:0] rt3,
    output wire is_branch3
);

    decode_mod m0(
        .inst(inst0),
        .pc(pc0),

        .write_mem(write_mem0),
        .write_regfile(write_regfile0),
        .mem_to_regfile(mem_to_regfile0),
        .jal(jal0),
        .aluimm(aluimm0),
        .shift(shift0),
        .sext(sext0),
        .ALUControl(ALUControl0),
        .mem_control(mem_control0),
        .shift_v(shift_v0),
        .imm(imm0),
        .rn(rn0),
        .bpc(bpc0),
        .jpc(jpc0),
        .rs(rs0),
        .rt(rt0),
        .is_branch(is_branch0)
    );

    decode_mod m1(
        .inst(inst1),
        .pc(pc1),

        .write_mem(write_mem1),
        .write_regfile(write_regfile1),
        .mem_to_regfile(mem_to_regfile1),
        .jal(jal1),
        .aluimm(aluimm1),
        .shift(shift1),
        .sext(sext1),
        .ALUControl(ALUControl1),
        .mem_control(mem_control1),
        .shift_v(shift_v1),
        .imm(imm1),
        .rn(rn1),
        .bpc(bpc1),
        .jpc(jpc1),
        .rs(rs1),
        .rt(rt1),
        .is_branch(is_branch1)
    );

    decode_mod m2(
        .inst(inst2),
        .pc(pc2),

        .write_mem(write_mem2),
        .write_regfile(write_regfile2),
        .mem_to_regfile(mem_to_regfile2),
        .jal(jal2),
        .aluimm(aluimm2),
        .shift(shift2),
        .sext(sext2),
        .ALUControl(ALUControl2),
        .mem_control(mem_control2),
        .shift_v(shift_v2),
        .imm(imm2),
        .rn(rn2),
        .bpc(bpc2),
        .jpc(jpc2),
        .rs(rs2),
        .rt(rt2),
        .is_branch(is_branch2)
    );

    decode_mod m3(
        .inst(inst3),
        .pc(pc3),

        .write_mem(write_mem3),
        .write_regfile(write_regfile3),
        .mem_to_regfile(mem_to_regfile3),
        .jal(jal3),
        .aluimm(aluimm3),
        .shift(shift3),
        .sext(sext3),
        .ALUControl(ALUControl3),
        .mem_control(mem_control3),
        .shift_v(shift_v3),
        .imm(imm3),
        .rn(rn3),
        .bpc(bpc3),
        .jpc(jpc3),
        .rs(rs3),
        .rt(rt3),
        .is_branch(is_branch3)
    );

endmodule