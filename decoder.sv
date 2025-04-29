// decoder.sv (Bit-slicing moved inside if-else branches)
import cpu_pkg::*; // Import package definitions

module decoder #(
    parameter OPCODE_WIDTH = cpu_pkg::OPCODE_WIDTH,
    parameter REG_ADDR_WIDTH = cpu_pkg::REG_ADDR_WIDTH,
    parameter IMM_WIDTH = cpu_pkg::IMM_WIDTH
) (
    input logic [cpu_pkg::I_WIDTH-1:0] instruction, // Use package parameter for width
    input logic SW8,
    output logic [OPCODE_WIDTH-1:0] opcode,
    output logic [REG_ADDR_WIDTH-1:0] rd, rs, rt,
    output logic [IMM_WIDTH-1:0] imm,
    output aluFunc_t ALUfunc,
    output logic reg_write, branch_en, PCincr,
    output logic [IMM_WIDTH-1:0] branch_target,
    output logic load, output logic out,
    output logic aluSrcA_is_Rs,
    output logic aluSrcB_is_Imm,
    output logic aluSrcB_is_SW
);

    always_comb begin
        // Extract opcode first
        logic [OPCODE_WIDTH-1:0] current_opcode;
        current_opcode = instruction[cpu_pkg::I_WIDTH-1 : cpu_pkg::I_WIDTH-OPCODE_WIDTH];

        // --- Default Values ---
        ALUfunc = ALU_PASS_A; // Use enum from package
        reg_write = 1'b0;
        branch_en = 1'b0;
        PCincr = 1'b1;
        load = 1'b0;
        out = 1'b0;
        branch_target = {IMM_WIDTH{1'b0}};
        rd = {REG_ADDR_WIDTH{1'b0}};
        rs = {REG_ADDR_WIDTH{1'b0}};
        rt = {REG_ADDR_WIDTH{1'b0}};
        imm = {IMM_WIDTH{1'b0}};
        aluSrcA_is_Rs = 1'b1;
        aluSrcB_is_Imm = 1'b0;
        aluSrcB_is_SW = 1'b0;

        opcode = current_opcode; // Assign extracted opcode to output

        // --- Decode based on opcode using if-else if ---
        // --- Slicing is now done *inside* each specific branch ---
        if (current_opcode == P_BRANCH_IF_SW8_CLEAR) begin
            branch_target = instruction[IMM_WIDTH-1:0]; // Slice imm
            branch_en = ~SW8;
            PCincr = ~branch_en;
        end else if (current_opcode == P_BRANCH_IF_SW8_SET) begin
            branch_target = instruction[IMM_WIDTH-1:0]; // Slice imm
            branch_en = SW8;
            PCincr = ~branch_en;
        end else if (current_opcode == P_ADDI) begin
            // $display(">>> Decoder entering ADDI branch"); // Optional Debug
            rd = instruction[10:8];         // Slice rd
            rs = instruction[10:8];         // Slice rs (assuming same bits for this ISA)
            imm = instruction[IMM_WIDTH-1:0]; // Slice imm
            ALUfunc = ALU_ADD;
            reg_write = 1'b1;
            aluSrcB_is_Imm = 1'b1;
        end else if (current_opcode == P_MUL) begin // MUL rd, rs, imm5
            // $display(">>> Decoder entering MUL branch"); // Optional Debug
            rd = instruction[10:8];         // Slice rd
            rs = instruction[7:5];          // Slice rs
            imm = { (IMM_WIDTH-cpu_pkg::IMM5_WIDTH){1'b0}, instruction[cpu_pkg::IMM5_WIDTH-1:0] }; // Slice imm5
            ALUfunc = ALU_MUL;
            reg_write = 1'b1;
            aluSrcB_is_Imm = 1'b1;
        end else if (current_opcode == P_ADD) begin // ADD rd, rs, rt
            // $display(">>> Decoder entering ADD branch"); // Optional Debug
            rd = instruction[12:10];        // Slice rd
            rs = instruction[9:7];          // Slice rs
            rt = instruction[6:4];          // Slice rt
            ALUfunc = ALU_ADD;
            reg_write = 1'b1;
        end else if (current_opcode == P_LOAD) begin
            // $display(">>> Decoder entering LOAD branch"); // Optional Debug
            rd = instruction[6:4];          // Slice rd
            rs = instruction[11:9];         // Slice rs
            ALUfunc = ALU_PASS_B;
            load = 1'b1;
            reg_write = 1'b1;
        end else if (current_opcode == P_IN) begin
            // $display(">>> Decoder entering IN branch"); // Optional Debug
             rd = instruction[10:8];        // Slice rd
             ALUfunc = ALU_PASS_B;
             reg_write = 1'b1;
             aluSrcB_is_SW = 1'b1;
         end else if (current_opcode == P_OUTPUT) begin
            // $display(">>> Decoder entering OUTPUT branch"); // Optional Debug
             rs = instruction[10:8];        // Slice rs
             ALUfunc = ALU_PASS_A;
             out = 1'b1;
         end else if (current_opcode == P_NOP) begin
            // $display(">>> Decoder entering NOP branch"); // Optional Debug
            // All defaults apply
         end else if (current_opcode == P_MUL_RR) begin // MUL rd, rs, rt
            // $display(">>> Decoder entering MUL_RR branch"); // Optional Debug
            rd = instruction[9:7];          // Slice rd
            rs = instruction[6:4];          // Slice rs
            rt = instruction[3:1];          // Slice rt
            ALUfunc = ALU_MUL;
            reg_write = 1'b1;
         end else begin // Default case
            // $display(">>> Decoder entering DEFAULT branch"); // Optional Debug
            // All defaults apply
         end
    end
endmodule
