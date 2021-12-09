module branch(
    input [31:0] instruction,
    input [31:0] pc,

);
    wire inst_beq;
    wire inst_bgez;
    wire inst_bgezal;
    wire inst_bgtz;
    wire inst_blez;
    wire inst_bltz;
    wire inst_bltzal;

    assign inst_beq = (op == 6'd4);
    assign inst_bgez = (op == 6'd1) & (rt == 5'd1);
    assign inst_bgezal = (op == 6'd1) & (rt == 5'd17);
    assign inst_bgtz = (op == 6'd7) & (rt == 5'd0);
    assign inst_blez = (op == 6'd6) & (rt == 5'd0);
    assign inst_bltz = (op == 6'd1) & (rt == 5'd0);
    assign inst_bltzal = (op == 6'd1) & (rt == 5'd16);

    wire inst_branch = inst_beq | inst_bgez | inst_bgezal | inst_bgtz | inst_blez | inst_bltz | inst_bltzal;
    

endmodule