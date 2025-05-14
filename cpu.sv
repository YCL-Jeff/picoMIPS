import cpu_pkg::*;

module cpu (
    input wire clk,
    input wire reset,
    input wire handshake,
    input wire [7:0] index,
    output reg [7:0] result
);
    // Program counter
    wire [5:0] pc;
    reg pc_incr;
    reg pc_reset;

    pc pc_inst (
        .clk(clk),
        .reset(pc_reset),
        .incr(pc_incr),
        .pc(pc)
    );

    // Program and instruction decode
    wire [I_WIDTH-1:0] instr;
    wire [OPCODE_WIDTH-1:0] opcode;
    wire signed [2:0] offset;
    wire [2:0] imm;

    program_memory pmem (.reset(reset), .address(pc), .instruction(instr));
    decoder decode (.instruction(instr), .opcode(opcode), .offset(offset), .imm(imm));

    // Memory
    wire [IMM_WIDTH-1:0] mem_val;
    reg signed [2:0] offset_reg;
    reg [OPCODE_WIDTH-1:0] opcode_reg;
    reg [2:0] imm_reg;
    wire [8:0] mem_address = index + $signed(offset_reg); // 保持 index 無符號，offset 有符號
    wire [7:0] safe_address = (mem_address > 255) ? 8'd255 : mem_address[7:0]; // 僅檢查上界
    waveform_rom wmem (
        .address(safe_address),
        .data(mem_val)
    );

    // Debug K values
    initial begin
        $display("K[0]=%h, K[1]=%h, K[2]=%h, K[3]=%h, K[4]=%h", K[0], K[1], K[2], K[3], K[4]);
    end

    // ALU I/O
    reg [IMM_WIDTH-1:0] alu_a, alu_b;
    aluFunc_t alu_func;
    wire [IMM_WIDTH-1:0] alu_result;

    alu ALU (
        .a(alu_a),
        .b(alu_b),
        .func(alu_func),
        .result(alu_result)
    );

    // Registers
    wire [IMM_WIDTH-1:0] acc_val, regfile_val;
    reg reg_write;
    reg [0:0] waddr;

    regs #(.ADDR_WIDTH(1)) reg_inst (
        .clk(clk),
        .reset(reset),
        .w(reg_write),
        .waddr(waddr),
        .raddr1(1'b0),
        .raddr2(1'b1),
        .wdata(alu_result),
        .data1_q(acc_val),
        .data2_q(regfile_val)
    );

    // FSM
    localparam IDLE = 0, FETCH = 1, FETCH_WAIT = 2, EXECUTE = 3, EXECUTE_WAIT = 4, WRITE_WAIT = 5, OUTPUT = 6, READ_WAIT = 7, HALT = 8;
    reg [3:0] state;
    reg prev_reset;
    reg prev_state;
    reg prev_handshake;

    initial begin
        state = IDLE;
        pc_incr = 0;
        pc_reset = 1;
        reg_write = 0;
        waddr = 0;
        result = 0;
        offset_reg = 0;
        opcode_reg = 0;
        imm_reg = 0;
        prev_reset = reset;
        prev_state = IDLE;
        prev_handshake = handshake;
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            if (reset != prev_reset) begin
                $display("Time: %0t, Reset active: reset=%b, state=IDLE", $time, reset);
                prev_reset <= reset;
            end
            state <= IDLE;
            pc_incr <= 0;
            pc_reset <= 1;
            reg_write <= 0;
            waddr <= 0;
            result <= 0;
            offset_reg <= 0;
            opcode_reg <= 0;
            imm_reg <= 0;
        end else begin
            if (reset != prev_reset) begin
                $display("Time: %0t, Reset inactive: reset=%b", $time, reset);
                prev_reset <= reset;
            end
            if (state != prev_state) begin
                prev_state <= state;
            end
            case (state)
                IDLE: begin
                    if (handshake) begin
                        state <= FETCH;
                        pc_reset <= 0;
                    end
                    pc_incr <= 0;
                end
                FETCH: begin
                    state <= FETCH_WAIT;
                end
                FETCH_WAIT: begin
                    state <= EXECUTE;
                    pc_incr <= 1;
                end
                EXECUTE: begin
                    offset_reg <= offset;
                    opcode_reg <= opcode;
                    imm_reg <= imm;
                    state <= EXECUTE_WAIT;
                    pc_incr <= 0;
                end
                EXECUTE_WAIT: begin
                    case (opcode_reg)
                        MUL: begin
                            alu_a <= mem_val;
                            alu_b <= K[imm_reg];
                            alu_func <= ALU_MUL;
                            waddr <= 1;
                            reg_write <= 1;
                            state <= WRITE_WAIT;
                        end
                        ADD: begin
                            alu_a <= acc_val;
                            alu_b <= regfile_val;
                            alu_func <= ALU_ADD;
                            waddr <= 0;
                            reg_write <= 1;
                            state <= WRITE_WAIT;
                        end
                        END: begin
                            state <= HALT;
                        end
                        default: begin
                            state <= HALT;
                        end
                    endcase
                end
                WRITE_WAIT: begin
                    state <= OUTPUT;
                    pc_incr <= 0;
                end
                OUTPUT: begin
                    state <= READ_WAIT;
                    pc_incr <= 0;
                end
                READ_WAIT: begin
                    reg_write <= 0;
                    pc_reset <= 0;
                    pc_incr <= 0;
                    state <= FETCH;
                end
                HALT: begin
                    result <= acc_val[7:0];
                    reg_write <= 0;
                    pc_incr <= 0;
                    if (!handshake) begin
                        state <= IDLE;
                        pc_reset <= 1;
                    end
                    prev_handshake <= handshake;
                end
            endcase
        end
    end
endmodule