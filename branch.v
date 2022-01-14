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

////////////////////////////////////////////////////////////////////////////////////////////////////
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

////////////////////////////////////////////////////////////////////////////////////////////////////
module Target_Cache(
    input clk,
    input resetn,
    input [31:0] pc,
    input [9:0] BHR,
    input [31:0] update_pc,
    input [31:0] update_target,
    input update_en,
    input [9:0] update_BHR,
    output wire [31:0] target_address
);

    reg [31:0] cache [0:255];
    
    wire [7:0] index;
    wire [7:0] update_index;
    wire [9:0] Hash;
    wire [9:0] update_Hash;

    assign Hash = {pc[23:19] ^ pc[18:14], pc[13:9] ^ pc[8:4]} ^ BHR;
    assign update_Hash = {update_pc[23:19] ^ update_pc[18:14], update_pc[13:9] ^ update_pc[8:4]} ^ update_BHR;
    assign index = Hash[7:0];
    assign update_index = update_Hash[7:0];
    assign target_address = cache[index];

    always @(posedge clk) begin
        if(~resetn) begin : initialize
            integer i;
            for(i = 0;i <= 63;i = i + 1) begin : loop
                cache[i] = 32'd0;
            end
        end else if(update_en) begin
            cache[update_index] <= update_target;
        end
    end

endmodule

////////////////////////////////////////////////////////////////////////////////////////////////////
module Branch_Target_Buffer(
    input wire clk,
    input wire resetn,
    input wire [31:0] pc,
    input wire [31:0] update_pc,
    input wire update_en,
    input wire [1:0] update_type, // 2'b00 direct_brach, 2'b01 call, 2'b10 return, 2'b11 indirect_branch
    input wire [31:0] update_BTA,
    input wire inst_bj,
    output wire [31:0] BTA,
    output wire [1:0] type,
    output wire [1:0] offset
);

    wire [9:0] BTB_tag;
    wire [9:0] BTB_update_tag;
    wire [1:0] hit_en;

    reg [47:0] BTB1 [0:127];// 1 bit valid signal, 1 bit used signal, 10 bits tag, 32 bits BTA, 2 bits types, 2bits offset
    reg [47:0] BTB2 [0:127];

    assign BTB_tag = {pc[28:24] ^ pc[23:19], pc[18:14] ^ pc[13:9]};
    assign BTB_update_tag = {update_pc[28:24] ^ update_pc[23:19], update_pc[18:14] ^ update_pc[13:9]};
    assign hit_en = BTB1[pc[10:4]][47] && BTB1[pc[10:4]][45:36] == BTB_tag ? 2'b01 : (BTB2[pc[10:4]][47] && BTB2[pc[10:4]][45:36] == BTB_tag ? 2'b10 : 2'b00);
    assign BTA = hit_en == 2'b00 ? pc + 32'd4 : (hit_en == 2'b01 ? BTB1[pc[10:4]][35:4] : (hit_en == 2'b10 ? BTB2[pc[10:4]][35:4] : 32'd0));
    assign type = hit_en == 2'b01 ? BTB1[pc[10:4]][3:2] : (hit_en == 2'b10 ? BTB2[pc[10:4]][3:2] : 2'b00);
    assign offset = hit_en == 2'b01 ? BTB1[pc[10:4]][1:0] : (hit_en == 2'b10 ? BTB2[pc[10:4]][1:0] : 2'b00);

/////////
    always @(posedge clk) begin
        if(~resetn) begin : initialize
            integer i;
            for(i = 0;i <= 127;i = i + 1) begin : loop
                BTB1[i] = 48'd0;
                BTB2[i] = 48'd0; 
            end
        end else begin
            if((hit_en == 2'b01) & inst_bj) begin
                BTB1[pc[10:4]][46] <= 1'b1;
                BTB2[pc[10:4]][46] <= 1'b0;
            end else if((hit_en == 2'b10) & inst_bj) begin
                BTB2[pc[10:4]][46] <= 1'b1;
                BTB1[pc[10:4]][46] <= 1'b0;
            end
            //BTB replace algorithm
            if(update_en & BTB1[pc[10:4]][46] == 1'b1) begin
                BTB2[update_pc[10:4]][45:0] <= {2'b11, BTB_update_tag, update_BTA, update_type, update_pc[3:2]};
            end else if(update_en & BTB2[pc[10:4]][46] == 1'b1) begin
                BTB1[update_pc[10:4]][45:0] <= {2'b11, BTB_update_tag, update_BTA, update_type, update_pc[3:2]};
            end else if(update_en) begin
                BTB2[update_pc[10:4]][45:0] <= {2'b11, BTB_update_tag, update_BTA, update_type, update_pc[3:2]};
            end
        end
    end
endmodule

////////////////////////////////////////////////////////////////////////////////////////////////////
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
        if(~resetn) begin
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
    input wire [31:0] pc,
    input wire clk,
    input wire resetn,
    input wire [9:0] update_BHR,
    input wire [31:0] update_pc,
    input wire update_en,
    input wire branch_en, //branch_en is used to update the PHT_FSM and PHT
    output wire taken_en, //taken_en is used to indicate whether pc is going to branch, 1 is taken, 0 is not taken
    output wire [9:0] BHR
);

    parameter Strongly_taken = 2'b11;
    parameter Weakly_taken = 2'b10;
    parameter Weakly_not_taken = 2'b01;
    parameter Strongly_not_taken = 2'b00;

    wire [9:0] BHT_index;
    wire [9:0] PHT_index;
    wire [1:0] PHT_value;
    wire [9:0] update_PHT_index;

    wire [1:0] PHT_FSM_outout;
    wire [1:0] old_PHT_value;
    
    reg [9:0] BHT [0:1023];
    reg [1:0] PHT [0:1023];

    //use Hash algorithm to calculate BHT_index , splice BHR value and PC to generate PHT_index
    assign BHT_index = pc[13:4];
    assign BHR = BHT[BHT_index];
    assign PHT_index = BHR ^ BHT_index;
    assign update_PHT_index = update_BHR ^ update_pc[13:4];
    assign PHT_value = PHT[PHT_index];
    assign taken_en = PHT_value == Strongly_taken | PHT_value == Weakly_taken ? 1 : 0;
    assign old_PHT_value = PHT[update_PHT_index];
    
    always @(posedge clk) begin
        if(!resetn) begin : initialize
            integer i;
            for(i = 0;i <= 1023;i = i + 1) begin : loop
                BHT[i] <= 10'd0;
            end
        end else begin
            if(update_en) begin
                BHT[update_pc[13:4]] <= BHT[update_pc[13:4]] << 1 + {9'd0, branch_en};
            end
        end
    end

    always @(posedge clk) begin
        if(!resetn) begin : initialize2
            integer i;
            for(i = 0;i <= 1023;i = i + 1) begin : loop
                PHT[i] <= 2'b00;
            end
        end else begin
            if(update_en) begin
                PHT[update_pc[13:4]] <= PHT_FSM_outout;
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

////////////////////////////////////////////////////////////////////////////////////////////////////
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
    //assign inst_bj = inst_jal | inst_jalr | inst_beq | inst_bne | inst_blt | inst_bge | inst_bltu | inst_bgeu;
//////////
    wire [3:0] BHR;
    wire taken_en;
    wire [31:0] BTA;
    wire [1:0] type;
    wire [1:0] offset;
    wire [31:0] RAS_addr;
    wire [31:0] indirect_addr;
    wire [1:0] select;
    wire inst_bj;

    assign inst_bj = pc[3:2] >= offset;

    assign select = ~inst_bj | (inst_bj & ~taken_en) ? 2'b11 : (type == 2'b00 ? BTA : (type == 2'b01 | type == 2'b10 ? RAS_addr : indirect_addr));
    
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
        .inst_bj(inst_bj),
        .BTA(BTA),
        .type(type),
        .offset(offset)
    );

    Return_Address_Stack RAS(
        .clk(clk),
        .resetn(resetn),
        .type(type),
        .next_pc({pc[31:4], offset, 2'b00} + 32'd4),
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
        .a3(pc + 32'd16),
        .out(next_pc)
    );

endmodule