// cpu.sv (修正 assign 語法)
import cpu_pkg::*; // 匯入 package

module cpu (
    input logic clk,
    input logic reset,
    input logic [8:0] SW,
    output logic [7:0] LED,
    output logic [5:0] pc
);
    // --- Pipeline Signals ---
    // ... (保持之前的信號宣告) ...
    logic [5:0] pc_reg;
    logic [I_WIDTH-1:0] fetched_instruction;
    logic [I_WIDTH-1:0] decoded_instruction;
    logic [OPCODE_WIDTH-1:0] opcode_extracted;
    logic [REG_ADDR_WIDTH-1:0] rd_extracted_r_type1, rd_extracted_r_type2, rd_extracted_r_type3, rd_extracted_load;
    logic [REG_ADDR_WIDTH-1:0] rs_extracted_r_type1, rs_extracted_r_type2, rs_extracted_mul, rs_extracted_mul_rr, rs_extracted_load;
    logic [REG_ADDR_WIDTH-1:0] rt_extracted_add, rt_extracted_mul_rr;
    logic [IMM_WIDTH-1:0]    imm_extracted_8bit, imm_extracted_mul;
    logic [5:0] opcode;
    logic [2:0] rd, rs, rt;
    logic [7:0] imm;
    aluFunc_t ALUfunc;
    logic reg_write, branch_en, PCincr;
    logic [7:0] branch_target;
    logic load, out;
    logic aluSrcA_is_Rs, aluSrcB_is_Imm, aluSrcB_is_SW;
    logic [5:0] opcode_latched;
    logic [2:0] rd_latched, rs_latched, rt_latched;
    logic [7:0] imm_latched;
    aluFunc_t ALUfunc_latched;
    logic reg_write_latched, branch_en_latched, PCincr_latched;
    logic [7:0] branch_target_latched;
    logic load_latched, out_latched;
    logic aluSrcA_is_Rs_latched, aluSrcB_is_Imm_latched, aluSrcB_is_SW_latched;
    logic [7:0] reg_data1, reg_data2;
    logic [7:0] alu_a_in, alu_b_in;
    logic [7:0] alu_result;
    logic execute_branch_en;
    logic [7:0] execute_branch_target;
    logic execute_PCincr;
    logic [7:0] ex_mem_alu_result;
    logic [7:0] ex_mem_write_data;
    logic [2:0] ex_mem_rd;
    logic reg_write_ex_mem;
    logic load_ex_mem;
    logic out_ex_mem;
    logic [5:0] ex_mem_opcode;
    logic [7:0] waveform_data;
    logic [7:0] mem_read_data;
    logic [7:0] mem_wb_alu_result;
    logic [7:0] mem_wb_mem_read_data;
    logic [2:0] mem_wb_rd;
    logic reg_write_mem_wb;
    logic load_mem_wb;
    logic out_mem_wb;
    logic mem_wb_valid;
    logic [5:0] mem_wb_opcode;
    logic [7:0] writeback_data;
    logic stall;

    // --- Localparam and Wire for MUL Immediate Padding ---
    localparam PAD_WIDTH_MUL_CPU = IMM_WIDTH - IMM5_WIDTH;
    logic [PAD_WIDTH_MUL_CPU-1:0] mul_imm_padding_wire; // Intermediate wire


    // --- Module Instantiations (保持不變) ---
    program_memory prog_mem (.reset, .address(pc_reg), .instruction(fetched_instruction));
    pc pc_inst (.clk, .reset, .PCincr(execute_PCincr && !stall), .branch_en(execute_branch_en), .branch_target(execute_branch_target[5:0]), .pc(pc_reg));
    regs #( .DATA_WIDTH(IMM_WIDTH), .ADDR_WIDTH(REG_ADDR_WIDTH) )
         regs_inst (.clk, .reset, .w(reg_write_mem_wb && mem_wb_valid), .waddr(mem_wb_rd), .raddr1(rs), .raddr2(rt), .wdata(writeback_data), .data1_q(reg_data1), .data2_q(reg_data2));
    waveform_rom #( .DATA_WIDTH(IMM_WIDTH), .ADDR_WIDTH(IMM_WIDTH) )
                 waveform_inst (.address(ex_mem_alu_result), .data(waveform_data));
    alu #( .N(IMM_WIDTH) )
        alu_inst (.a(alu_a_in), .b(alu_b_in), .func(ALUfunc_latched), .result(alu_result));

    // --- Combinational Field Extraction (ID Stage) ---
    assign opcode_extracted = decoded_instruction[I_WIDTH-1 : I_WIDTH-OPCODE_WIDTH];
    assign rd_extracted_r_type1 = decoded_instruction[12:10];
    assign rd_extracted_r_type2 = decoded_instruction[10:8];
    assign rd_extracted_r_type3 = decoded_instruction[9:7];
    assign rd_extracted_load    = decoded_instruction[6:4];
    assign rs_extracted_r_type1 = decoded_instruction[9:7];
    assign rs_extracted_r_type2 = decoded_instruction[10:8];
    assign rs_extracted_mul     = decoded_instruction[7:5];
    assign rs_extracted_mul_rr  = decoded_instruction[6:4];
    assign rs_extracted_load    = decoded_instruction[11:9];
    assign rt_extracted_add     = decoded_instruction[6:4];
    assign rt_extracted_mul_rr  = decoded_instruction[3:1];
    assign imm_extracted_8bit   = decoded_instruction[IMM_WIDTH-1:0];
    // *** FIX: Calculate padding separately ***
    assign mul_imm_padding_wire = {PAD_WIDTH_MUL_CPU{1'b0}};
    // *** FIX: Use intermediate wire in concatenation ***
    assign imm_extracted_mul    = { mul_imm_padding_wire, decoded_instruction[IMM5_WIDTH-1:0] };

    // Instruction Decoder (ID Stage)
    decoder #( .OPCODE_WIDTH(OPCODE_WIDTH), .REG_ADDR_WIDTH(REG_ADDR_WIDTH), .IMM_WIDTH(IMM_WIDTH) )
    decoder_inst (
        .opcode_in(opcode_extracted),
        .rd_in_r_type1(rd_extracted_r_type1), .rd_in_r_type2(rd_extracted_r_type2),
        .rd_in_r_type3(rd_extracted_r_type3), .rd_in_load(rd_extracted_load),
        .rs_in_r_type1(rs_extracted_r_type1), .rs_in_r_type2(rs_extracted_r_type2),
        .rs_in_mul(rs_extracted_mul), .rs_in_mul_rr(rs_extracted_mul_rr), .rs_in_load(rs_extracted_load),
        .rt_in_add(rt_extracted_add), .rt_in_mul_rr(rt_extracted_mul_rr),
        .imm_in_8bit(imm_extracted_8bit), .imm_in_mul(imm_extracted_mul),
        .SW8(SW[8]),
        .opcode(opcode), .rd(rd), .rs(rs), .rt(rt), .imm(imm),
        .ALUfunc(ALUfunc), .reg_write(reg_write), .branch_en(branch_en),
        .PCincr(PCincr), .branch_target(branch_target), .load(load), .out(out),
        .aluSrcA_is_Rs(aluSrcA_is_Rs), .aluSrcB_is_Imm(aluSrcB_is_Imm), .aluSrcB_is_SW(aluSrcB_is_SW)
    );

    // --- Data Hazard Detection and Stall Logic (保持不變) ---
    assign stall = (load_latched && reg_write_latched && (rd_latched != 0) &&
                   ((rd_latched == rs) || (rd_latched == rt)));

    // --- Pipeline Latches (保持不變, 可以移除內部 $display 以減少日誌混亂) ---
    // IF/ID Latch
    always_ff @(posedge clk or posedge reset) begin
        if (reset) decoded_instruction <= P_NOP;
        else if (stall) decoded_instruction <= decoded_instruction;
        else decoded_instruction <= fetched_instruction;
    end

    // ID/EX Latch
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin /* Reset logic */
            opcode_latched <= P_NOP; rd_latched <= 0; rs_latched <= 0; rt_latched <= 0;
            imm_latched <= 0; ALUfunc_latched <= ALU_PASS_A; reg_write_latched <= 0;
            branch_en_latched <= 0; PCincr_latched <= 1; branch_target_latched <= 0;
            load_latched <= 0; out_latched <= 0; aluSrcA_is_Rs_latched <= 1;
            aluSrcB_is_Imm_latched <= 0; aluSrcB_is_SW_latched <= 0;
        end else if (stall) begin /* Stall logic */
            opcode_latched <= P_NOP; rd_latched <= 0; rs_latched <= 0; rt_latched <= 0;
            imm_latched <= 0; ALUfunc_latched <= ALU_PASS_A; reg_write_latched <= 0;
            branch_en_latched <= 0; PCincr_latched <= 1; branch_target_latched <= 0;
            load_latched <= 0; out_latched <= 0; aluSrcA_is_Rs_latched <= 1;
            aluSrcB_is_Imm_latched <= 0; aluSrcB_is_SW_latched <= 0;
        end else begin /* Normal latch */
            opcode_latched <= opcode; rd_latched <= rd; rs_latched <= rs; rt_latched <= rt;
            imm_latched <= imm; ALUfunc_latched <= ALUfunc; reg_write_latched <= reg_write;
            branch_en_latched <= branch_en; PCincr_latched <= PCincr; branch_target_latched <= branch_target;
            load_latched <= load; out_latched <= out; aluSrcA_is_Rs_latched <= aluSrcA_is_Rs;
            aluSrcB_is_Imm_latched <= aluSrcB_is_Imm; aluSrcB_is_SW_latched <= aluSrcB_is_SW;
        end
    end

    // EX/MEM Latch
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin /* Reset logic */
            ex_mem_alu_result <= 0; ex_mem_write_data <= 0; ex_mem_rd <= 0;
            reg_write_ex_mem <= 0; load_ex_mem <= 0; out_ex_mem <= 0; ex_mem_opcode <= P_NOP;
        end else begin /* Normal latch */
            ex_mem_alu_result <= alu_result;
            ex_mem_write_data <= alu_b_in;
            ex_mem_rd <= rd_latched;
            reg_write_ex_mem <= reg_write_latched;
            load_ex_mem <= load_latched;
            out_ex_mem <= out_latched;
            ex_mem_opcode <= opcode_latched;
        end
    end

    // MEM/WB Latch
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin /* Reset logic */
            mem_wb_alu_result <= 0; mem_wb_mem_read_data <= 0; mem_wb_rd <= 0;
            reg_write_mem_wb <= 0; load_mem_wb <= 0; out_mem_wb <= 0;
            mem_wb_valid <= 0; mem_wb_opcode <= P_NOP;
        end else begin /* Normal latch */
            mem_wb_alu_result <= ex_mem_alu_result;
            mem_wb_mem_read_data <= waveform_data;
            mem_wb_rd <= ex_mem_rd;
            reg_write_mem_wb <= reg_write_ex_mem;
            load_mem_wb <= load_ex_mem;
            out_mem_wb <= out_ex_mem;
            mem_wb_valid <= (ex_mem_opcode != P_NOP);
            mem_wb_opcode <= ex_mem_opcode;
        end
    end

    // --- Forwarding & ALU Input Mux Logic (保持不變) ---
    always_comb begin
        logic [IMM_WIDTH-1:0] forwarded_alu_a;
        logic [IMM_WIDTH-1:0] forwarded_alu_b;

        forwarded_alu_a = reg_data1; // Default
        forwarded_alu_b = reg_data2; // Default

        // Forwarding for ALU Input A (rs)
        if (reg_write_mem_wb && mem_wb_valid && (mem_wb_rd != 0) && (mem_wb_rd == rs_latched)) begin
            forwarded_alu_a = writeback_data;
        end else if (reg_write_ex_mem && (ex_mem_rd != 0) && (ex_mem_rd == rs_latched)) begin
            forwarded_alu_a = ex_mem_alu_result;
        end

        // Forwarding for ALU Input B (rt) - only if needed
        if (aluSrcB_is_Imm_latched == 0 && aluSrcB_is_SW_latched == 0) begin // If input B should be Rt
             if (reg_write_mem_wb && mem_wb_valid && (mem_wb_rd != 0) && (mem_wb_rd == rt_latched)) begin
                 forwarded_alu_b = writeback_data;
             end else if (reg_write_ex_mem && (ex_mem_rd != 0) && (ex_mem_rd == rt_latched)) begin
                 forwarded_alu_b = ex_mem_alu_result;
             end
        end

        // Select final ALU inputs
        alu_a_in = forwarded_alu_a;
        if (aluSrcB_is_Imm_latched) begin
            alu_b_in = imm_latched;
        end else if (aluSrcB_is_SW_latched) begin
            alu_b_in = SW[IMM_WIDTH-1:0]; // Use lower bits of SW
        end else begin
            alu_b_in = forwarded_alu_b; // Use forwarded Rt or reg_data2
        end

        // Update signals for PC module
        execute_branch_target = branch_target_latched;
        execute_branch_en = branch_en_latched;
        execute_PCincr = PCincr_latched;
    end

    // --- Writeback Data Selection (保持不變) ---
    always_comb begin
        if (load_mem_wb && mem_wb_valid) begin
            writeback_data = mem_wb_mem_read_data;
        end else if (mem_wb_valid) begin
            writeback_data = mem_wb_alu_result;
        end else begin
            writeback_data = {IMM_WIDTH{1'bx}};
        end
    end

    // --- LED Output Logic (保持不變) ---
    always_ff @(posedge clk) begin
        if (reset) begin
            LED <= {IMM_WIDTH{1'b0}};
        end else if (out_mem_wb && mem_wb_valid) begin
            LED <= mem_wb_alu_result;
        end
    end

    // Assign PC output
    assign pc = pc_reg;

endmodule
