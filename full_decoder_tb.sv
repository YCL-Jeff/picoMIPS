`timescale 1ns / 1ps
import cpu_pkg::*; // Import package

module full_decoder_tb;

    // --- Parameters ---
    parameter I_WIDTH = cpu_pkg::I_WIDTH;
    parameter OPCODE_WIDTH = cpu_pkg::OPCODE_WIDTH;
    parameter REG_ADDR_WIDTH = cpu_pkg::REG_ADDR_WIDTH;
    parameter IMM_WIDTH = cpu_pkg::IMM_WIDTH;
    localparam PAD_WIDTH_MUL_TB = IMM_WIDTH - cpu_pkg::IMM5_WIDTH;

    // --- Testbench Signals ---
    logic [I_WIDTH-1:0] tb_instruction;
    logic tb_SW8;

    // --- Wires for Decoder Outputs ---
    logic [OPCODE_WIDTH-1:0] dec_opcode;
    logic [REG_ADDR_WIDTH-1:0] dec_rd, dec_rs, dec_rt;
    logic [IMM_WIDTH-1:0] dec_imm;
    aluFunc_t dec_ALUfunc;
    logic dec_reg_write, dec_branch_en, dec_PCincr;
    logic [IMM_WIDTH-1:0] dec_branch_target;
    logic dec_load, dec_out;
    logic dec_aluSrcA_is_Rs, dec_aluSrcB_is_Imm, dec_aluSrcB_is_SW;

    // --- Wires for Extracted Fields (Simulating cpu.sv assigns) ---
    logic [OPCODE_WIDTH-1:0] tb_opcode_extracted;
    logic [REG_ADDR_WIDTH-1:0] tb_rd_r_type1, tb_rd_r_type2, tb_rd_r_type3, tb_rd_load;
    logic [REG_ADDR_WIDTH-1:0] tb_rs_r_type1, tb_rs_r_type2, tb_rs_mul, tb_rs_mul_rr, tb_rs_load;
    logic [REG_ADDR_WIDTH-1:0] tb_rt_add, tb_rt_mul_rr;
    logic [IMM_WIDTH-1:0]    tb_imm_8bit, tb_imm_mul;
    logic [PAD_WIDTH_MUL_TB-1:0] tb_mul_imm_padding;

    // --- Instantiate DUT ---
    decoder #() dut (
        .opcode_in(tb_opcode_extracted),
        .rd_in_r_type1(tb_rd_r_type1), .rd_in_r_type2(tb_rd_r_type2),
        .rd_in_r_type3(tb_rd_r_type3), .rd_in_load(tb_rd_load),
        .rs_in_r_type1(tb_rs_r_type1), .rs_in_r_type2(tb_rs_r_type2),
        .rs_in_mul(tb_rs_mul), .rs_in_mul_rr(tb_rs_mul_rr), .rs_in_load(tb_rs_load),
        .rt_in_add(tb_rt_add), .rt_in_mul_rr(tb_rt_mul_rr),
        .imm_in_8bit(tb_imm_8bit), .imm_in_mul(tb_imm_mul),
        .SW8(tb_SW8),
        .opcode(dec_opcode), .rd(dec_rd), .rs(dec_rs), .rt(dec_rt), .imm(dec_imm),
        .ALUfunc(dec_ALUfunc), .reg_write(dec_reg_write), .branch_en(dec_branch_en),
        .PCincr(dec_PCincr), .branch_target(dec_branch_target), .load(dec_load), .out(dec_out),
        .aluSrcA_is_Rs(dec_aluSrcA_is_Rs), .aluSrcB_is_Imm(dec_aluSrcB_is_Imm), .aluSrcB_is_SW(dec_aluSrcB_is_SW)
    );

    // --- Extract fields in Testbench ---
    assign tb_opcode_extracted = tb_instruction[I_WIDTH-1 : I_WIDTH-OPCODE_WIDTH];
    assign tb_rd_r_type1 = tb_instruction[12:10]; // For ADD
    assign tb_rd_r_type2 = tb_instruction[10:8]; // For ADDI, OUTPUT, IN
    assign tb_rd_r_type3 = tb_instruction[9:7];  // For MUL_RR
    assign tb_rd_load = tb_instruction[6:4];     // For LOAD
    assign tb_rs_r_type1 = tb_instruction[9:7];  // For ADD
    assign tb_rs_r_type2 = tb_instruction[10:8]; // For OUTPUT
    assign tb_rs_mul = tb_instruction[7:5];      // For MUL
    assign tb_rs_mul_rr = tb_instruction[6:4];   // For MUL_RR
    assign tb_rs_load = tb_instruction[11:9];    // For LOAD
    assign tb_rt_add = tb_instruction[6:4];      // For ADD
    assign tb_rt_mul_rr = tb_instruction[3:1];   // For MUL_RR
    assign tb_imm_8bit = tb_instruction[IMM_WIDTH-1:0]; // For ADDI, BRANCH
    assign tb_mul_imm_padding = {PAD_WIDTH_MUL_TB{1'b0}};
    assign tb_imm_mul = {tb_mul_imm_padding, tb_instruction[cpu_pkg::IMM5_WIDTH-1:0]}; // For MUL

    // --- Test Sequence ---
    initial begin
        $display("--- Starting Standalone Decoder Test (Using Package + Debug) ---");
        tb_SW8 = 1'b0;

        // --- Test 1: ADDI (048a -> Opcode 01h, rd=4, rs=4, imm=8a) ---
        tb_instruction = 16'h048a; #1;
        $display("\n[Test 1] Input ADDI: %h", tb_instruction);
        $display("  TB Passing: op=%h, rd_r2=%d, rs_r2=%d, imm8=%h",
                 tb_opcode_extracted, tb_rd_r_type2, tb_rs_r_type2, tb_imm_8bit);
        $display("  Decoder Output: op=%h rd=%d rs=%d rt=%d imm=%h | ALUf=%b RegW=%b ...",
                 dec_opcode, dec_rd, dec_rs, dec_rt, dec_imm, dec_ALUfunc, dec_reg_write);
        assert (dec_opcode === P_ADDI) else $error("ADDI: Opcode Error");
        // Fixed: Assert based on actual extraction [10:8]
        assert (dec_rd === tb_instruction[10:8]) else $error("ADDI: rd Error (Expected %d), Got %d", tb_instruction[10:8], dec_rd);
        assert (dec_rs === tb_instruction[10:8]) else $error("ADDI: rs Error (Expected %d), Got %d", tb_instruction[10:8], dec_rs);
        assert (dec_imm === 8'h8a) else $error("ADDI: imm Error");
        assert (dec_ALUfunc === ALU_ADD) else $error("ADDI: ALUfunc Error");
        assert (dec_reg_write === 1'b1) else $error("ADDI: reg_write Error");
        assert (dec_aluSrcB_is_Imm === 1'b1) else $error("ADDI: aluSrcB_is_Imm Error");

        // --- Test 2: OUTPUT (1040 -> Opcode 04h, rs=1) ---
        tb_instruction = 16'h1040; #1; // Increased delay to ensure stable sampling
        $display("\n[Test 2] Input OUTPUT: %h", tb_instruction);
        $display("  TB Passing: op=%h, rs_r2=%d", tb_opcode_extracted, tb_rs_r_type2);
        $display("  Decoder Output: op=%h rd=%d rs=%d rt=%d imm=%h | ALUf=%b RegW=%b Out=%b ...",
                 dec_opcode, dec_rd, dec_rs, dec_rt, dec_imm, dec_ALUfunc, dec_reg_write, dec_out);
        assert (dec_opcode === P_OUTPUT) else $error("OUTPUT: Opcode Error");
        // Fixed: Assert based on actual extraction [10:8]
        assert (dec_rs === tb_instruction[10:8]) else $error("OUTPUT: rs Error (Expected %d), Got %d", tb_instruction[10:8], dec_rs);
        assert (dec_ALUfunc === ALU_PASS_A) else $error("OUTPUT: ALUfunc Error");
        assert (dec_out === 1'b1) else $error("OUTPUT: out Error");
        assert (dec_reg_write === 1'b0) else $error("OUTPUT: reg_write Error");

        // --- Test 3: BRANCH_IF_SW8_CLEAR (0804 -> Opcode 02h, target=04), SW8=0 ---
        tb_instruction = {P_BRANCH_IF_SW8_CLEAR, 10'h004}; // Correct instruction code
        tb_SW8 = 1'b0; #1;
        $display("\n[Test 3] Input BRANCH (SW8=0): %h", tb_instruction);
        $display("  TB Passing: op=%h, imm8=%h", tb_opcode_extracted, tb_imm_8bit);
        $display("  Decoder Output: op=%h rd=%d rs=%d rt=%d imm=%h | BrEn=%b PCInc=%b Target=%h ...",
                 dec_opcode, dec_rd, dec_rs, dec_rt, dec_imm, dec_branch_en, dec_PCincr, dec_branch_target);
        assert (dec_opcode === P_BRANCH_IF_SW8_CLEAR) else $error("BRANCH(0): Opcode Error");
        assert (dec_branch_target === 8'h04) else $error("BRANCH(0): target Error");
        assert (dec_branch_en === 1'b1) else $error("BRANCH(0): branch_en Error (Expected 1)");
        assert (dec_PCincr === 1'b0) else $error("BRANCH(0): PCincr Error (Expected 0)");

        // --- Test 4: BRANCH_IF_SW8_CLEAR (0804 -> Opcode 02h, target=04), SW8=1 ---
        tb_instruction = {P_BRANCH_IF_SW8_CLEAR, 10'h004};
        tb_SW8 = 1'b1; #1;
        $display("\n[Test 4] Input BRANCH (SW8=1): %h", tb_instruction);
        $display("  TB Passing: op=%h, imm8=%h", tb_opcode_extracted, tb_imm_8bit);
        $display("  Decoder Output: op=%h rd=%d rs=%d rt=%d imm=%h | BrEn=%b PCInc=%b Target=%h ...",
                 dec_opcode, dec_rd, dec_rs, dec_rt, dec_imm, dec_branch_en, dec_PCincr, dec_branch_target);
        assert (dec_opcode === P_BRANCH_IF_SW8_CLEAR) else $error("BRANCH(1): Opcode Error");
        assert (dec_branch_target === 8'h04) else $error("BRANCH(1): target Error");
        assert (dec_branch_en === 1'b0) else $error("BRANCH(1): branch_en Error (Expected 0)");
        assert (dec_PCincr === 1'b1) else $error("BRANCH(1): PCincr Error (Expected 1)");

        // --- Test 5: MUL_RR (C2B8 -> Opcode 30h, rd=5, rs=3, rt=4) ---
        tb_instruction = 16'hC2B8; #1;
        $display("\n[Test 5] Input MUL_RR: %h", tb_instruction);
        $display("  TB Passing: op=%h, rd_r3=%d, rs_rr=%d, rt_rr=%d",
                 tb_opcode_extracted, tb_rd_r_type3, tb_rs_mul_rr, tb_rt_mul_rr);
        $display("  Decoder Output: op=%h rd=%d rs=%d rt=%d imm=%h | ALUf=%b RegW=%b ...",
                 dec_opcode, dec_rd, dec_rs, dec_rt, dec_imm, dec_ALUfunc, dec_reg_write);
        assert (dec_opcode === P_MUL_RR) else $error("MUL_RR: Opcode Error");
        assert (dec_rd === 3'd5) else $error("MUL_RR: rd Error (Expected 5), Got %d", dec_rd);
        assert (dec_rs === 3'd3) else $error("MUL_RR: rs Error (Expected 3), Got %d", dec_rs);
        assert (dec_rt === 3'd4) else $error("MUL_RR: rt Error (Expected 4), Got %d", dec_rt);
        assert (dec_ALUfunc === ALU_MUL) else $error("MUL_RR: ALUfunc Error");
        assert (dec_reg_write === 1'b1) else $error("MUL_RR: reg_write Error");

        // --- Test 6: NOP (0000 -> Opcode 00h) ---
        tb_instruction = 16'h0000; #1;
        $display("\n[Test 6] Input NOP: %h", tb_instruction);
        $display("  TB Passing: op=%h", tb_opcode_extracted);
        $display("  Decoder Output: op=%h rd=%d rs=%d rt=%d imm=%h | ALUf=%b RegW=%b ...",
                 dec_opcode, dec_rd, dec_rs, dec_rt, dec_imm, dec_ALUfunc, dec_reg_write);
        assert (dec_opcode === P_NOP) else $error("NOP: Opcode Error");
        assert (dec_reg_write === 1'b0) else $error("NOP: reg_write Error");
        assert (dec_ALUfunc === ALU_PASS_A) else $error("NOP: ALUfunc Error");

        $display("\n--- Standalone Decoder Test Finished ---");
        $finish;
    end

endmodule