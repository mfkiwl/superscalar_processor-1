module instruction_buffer(
    input wire clk,
    input wire resetn,

    input wire [31:0] inst0,
    input wire [31:0] inst1,
    input wire [31:0] inst2,
    input wire [31:0] inst3,
    input wire [2:0] inst_valid,

    input wire [2:0] read_valid,

    output wire [31:0] o_inst0,
    output wire [31:0] o_inst1,
    output wire [31:0] o_inst2,
    output wire [31:0] o_inst3,
    
    output wire empty,
    output wire full
);

    four_ports_fifo fifo(
        .clk(clk),
        .resetn(resetn),
        .data0(inst0),
        .data1(inst1),
        .data2(inst2),
        .data3(inst3),
        .wen(inst_valid),
        .ren(read_valid),
        .dout0(o_inst0),
        .dout1(o_inst1),
        .dout2(o_inst2),
        .dout3(o_inst3),
        .empty(empty),
        .full(full)
    );

endmodule