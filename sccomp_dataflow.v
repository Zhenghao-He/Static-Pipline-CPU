`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/07/17 11:29:20
// Design Name: 
// Module Name: sccomp_dataflow
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module sccomp_dataflow(
    input clk_in,
    input reset,
    output [31:0]inst,
    output [31:0]pc
    );
    wire [31:0] addr;
    wire [10:0] addr1;
    wire [31:0]rdata;
    wire wena;
    wire rena;
    wire [31:0]wdata;
    wire [31:0]addr2;
    assign addr2 = addr-32'h10010000;
    assign addr1=addr2[12:2];


    wire zero,carry,negative,overflow;
    wire [31:0] A,B,C;
    wire [3:0]aluc;
    wire [31:0] id_ir, ex_ir, mem_ir, wb_ir;
    wire [53:0] if_instr,id_instr,ex_instr,mem_instr,wb_instr;
    control_unit cu(
    .clock(clk_in),
    .reset(reset),
    .instr(inst),
    .if_instr(if_instr),
    .id_instr(id_instr),
    .ex_instr(ex_instr),
    .mem_instr(mem_instr),
    .wb_instr(wb_instr),
	.C(C),
	.zero(zero),
	.dm_data(rdata),
	.A(A),
	.B(B),
    .pc(pc),
    .dm_we(wena),
    .dm_re(rena),
	.dm_addr(addr),
	.dm_wdata(wdata),
	.aluc(aluc),
	.id_ir(id_ir), 
	.ex_ir(ex_ir), 
	.mem_ir(mem_ir),
	.wb_ir(wb_ir)
	);
	
	instr_decoder if_decoder(
	.instr_code(inst),
    .decoder_ena(1),
    .i(if_instr));
    
    instr_decoder id_decoder(
	.instr_code(id_ir),
    .decoder_ena(1),
    .i(id_instr));
    
    instr_decoder ex_decoder(
	.instr_code(ex_ir),
    .decoder_ena(1),
    .i(ex_instr));
    
    instr_decoder mem_decoder(
	.instr_code(mem_ir),
    .decoder_ena(1),
    .i(mem_instr));
    
    instr_decoder wb_decoder(
	.instr_code(wb_ir),
    .decoder_ena(1),
    .i(wb_instr));
    
	alu thealu(	
	.a(A),
	.b(B),
	.aluc(aluc),
	.r(C),
	.zero(zero),
	.carry(carry),
	.negative(negative),
	.overflow(overflow)
	);
	
    dmem dmemory(.clk(clk_in),.wena(wena),.rena(rena),.addr(addr1),.data_in(wdata),.data_out(rdata));
    imem imemory(pc,inst);
endmodule
