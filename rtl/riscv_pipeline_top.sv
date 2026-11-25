

module riscv_pipeline_top (

    input  logic        clk,
    input  logic        reset,
    

    output logic [31:0] pc        // Program Counter (for waveform)
);

    // 1. IF STAGE SIGNALS
   
    logic [31:0] pc_next;          // PC + 4 (sequential)
    logic [31:0] instruction;      // Instruction from IMEM
    
    // Branch/Jump signals from EX stage to IF stage
    logic        branch_taken_ex;
    logic [31:0] branch_target_ex;

    // 2. IF/ID PIPELINE REGISTER SIGNALS
    logic [31:0] if_id_pc;
    logic [31:0] if_id_instruction;

    // 3. ID STAGE SIGNALS
    // Register File
    logic [31:0] rs1_data;
    logic [31:0] rs2_data;
    
    // Immediate Generator
    logic [31:0] immediate;
    
    // Control Unit
    logic        reg_write;
    logic        mem_read;
    logic        mem_write;
    logic        mem_to_reg;
    logic        alu_src;
    logic [2:0]  alu_control;
    logic        branch;
    logic        bne;
    logic        jal;
    logic        jalr;
    logic        lui;
    logic        auipc;

    // 4. ID/EX PIPELINE REGISTER SIGNALS
    logic [31:0] id_ex_pc;
    logic [31:0] id_ex_rs1_data;
    logic [31:0] id_ex_rs2_data;
    logic [31:0] id_ex_immediate;
    logic [4:0]  id_ex_rs1;
    logic [4:0]  id_ex_rs2;
    logic [4:0]  id_ex_rd;
    logic        id_ex_reg_write;
    logic        id_ex_mem_read;
    logic        id_ex_mem_write;
    logic        id_ex_mem_to_reg;
    logic        id_ex_alu_src;
    logic [2:0]  id_ex_alu_control;
    logic        id_ex_branch;
    logic        id_ex_bne;
    logic        id_ex_jal;
    logic        id_ex_jalr;
    logic        id_ex_lui;
    logic        id_ex_auipc;

    // 5. EX STAGE SIGNALS
    logic [31:0] alu_input_a;
    logic [31:0] alu_input_b;
    logic [31:0] alu_result;
    logic        zero_flag;
    
    // Branch/Jump target calculation
    logic [31:0] branch_target_normal;
    logic [31:0] jal_target;
    logic [31:0] jalr_target;
    logic        branch_condition;
    
    // LUI/AUIPC result
    logic [31:0] ex_result_final;
    logic [31:0] ex_result_for_wb;

    // 6. EX/MEM PIPELINE REGISTER SIGNALS
    logic [31:0] ex_mem_alu_result;
    logic [31:0] ex_mem_store_data;
    logic [4:0]  ex_mem_rd;
    logic        ex_mem_reg_write;
    logic        ex_mem_mem_read;
    logic        ex_mem_mem_write;
    logic        ex_mem_mem_to_reg;

    // 7. MEM STAGE SIGNALS
    logic [31:0] dmem_read_data;    // From Data Memory


    // 8. MEM/WB PIPELINE REGISTER SIGNALS
    logic [31:0] mem_wb_alu_result;
    logic [31:0] mem_wb_memory_data;
    logic [4:0]  mem_wb_rd;
    logic        mem_wb_reg_write;
    logic        mem_wb_mem_to_reg;

    // 9. WB STAGE SIGNALS
    logic [31:0] wb_write_data;
    logic        wb_reg_write;

    //                    PIPELINE STAGE 1: IF (Instruction Fetch)
    assign pc_next = pc + 32'd4;

    // Program Counter (IF Stage)
    program_counter PC (
        .clk(clk),
        .reset(reset),
        .branch_taken(branch_taken_ex),
        .branch_target(branch_target_ex),
        .pc_next(pc_next),
        .pc(pc)
    );

    // Instruction Memory (IF Stage)
    instruction_memory IMEM (
        .address(pc),
        .instruction(instruction)
    );

    // IF/ID Pipeline Register (Stage 1 → Stage 2)
    if_id_register IF_ID (
        .clk(clk),
        .reset(reset),
        .pc_in(pc),
        .instr_in(instruction),
        .pc_out(if_id_pc),
        .instr_out(if_id_instruction)
    );

    //                    PIPELINE STAGE 2: ID (Instruction Decode)
    register_file RF (
        .clk(clk),
        .rs1(if_id_instruction[19:15]),
        .rs2(if_id_instruction[24:20]),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .rd(mem_wb_rd),
        .write_data(wb_write_data),
        .reg_write(wb_reg_write)
    );

    // Immediate Generator (ID Stage)
    immediate_generator IMM_GEN (
        .instruction(if_id_instruction),
        .immediate(immediate)
    );

    // Control Unit (ID Stage)
    control_unit CU (
        .opcode(if_id_instruction[6:0]),
        .funct3(if_id_instruction[14:12]),
        .funct7(if_id_instruction[31:25]),
        .reg_write(reg_write),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_to_reg(mem_to_reg),
        .alu_src(alu_src),
        .alu_control(alu_control),
        .branch(branch),
        .bne(bne),
        .jal(jal),
        .jalr(jalr),
        .lui(lui),
        .auipc(auipc)
    );

    // ID/EX Pipeline Register (Stage 2 → Stage 3)
    id_ex_register ID_EX (
        .clk(clk),
        .reset(reset),
        .pc_in(if_id_pc),
        .rs1_data_in(rs1_data),
        .rs2_data_in(rs2_data),
        .immediate_in(immediate),
        .rs1_in(if_id_instruction[19:15]),
        .rs2_in(if_id_instruction[24:20]),
        .rd_in(if_id_instruction[11:7]),
        .reg_write_in(reg_write),
        .mem_read_in(mem_read),
        .mem_write_in(mem_write),
        .mem_to_reg_in(mem_to_reg),
        .alu_src_in(alu_src),
        .alu_control_in(alu_control),
        .branch_in(branch),
        .bne_in(bne),
        .jal_in(jal),
        .jalr_in(jalr),
        .lui_in(lui),
        .auipc_in(auipc),
        .pc_out(id_ex_pc),
        .rs1_data_out(id_ex_rs1_data),
        .rs2_data_out(id_ex_rs2_data),
        .immediate_out(id_ex_immediate),
        .rs1_out(id_ex_rs1),
        .rs2_out(id_ex_rs2),
        .rd_out(id_ex_rd),
        .reg_write_out(id_ex_reg_write),
        .mem_read_out(id_ex_mem_read),
        .mem_write_out(id_ex_mem_write),
        .mem_to_reg_out(id_ex_mem_to_reg),
        .alu_src_out(id_ex_alu_src),
        .alu_control_out(id_ex_alu_control),
        .branch_out(id_ex_branch),
        .bne_out(id_ex_bne),
        .jal_out(id_ex_jal),
        .jalr_out(id_ex_jalr),
        .lui_out(id_ex_lui),
        .auipc_out(id_ex_auipc)
    );

    //                    PIPELINE STAGE 3: EX (Execute)

    assign alu_input_a = id_ex_rs1_data;
    assign alu_input_b = (id_ex_alu_src) ? id_ex_immediate : id_ex_rs2_data;

    // ALU Instance
    alu ALU (
        .a(alu_input_a),
        .b(alu_input_b),
        .control(id_ex_alu_control),
        .result(alu_result),
        .zero(zero_flag)
    );

    // LUI / AUIPC Handling
    always_comb begin
        if (id_ex_lui) begin
            ex_result_final = id_ex_immediate;
        end else if (id_ex_auipc) begin
            ex_result_final = id_ex_pc + id_ex_immediate;
        end else begin
            ex_result_final = alu_result;
        end
    end

    // Branch/Jump Target Calculation
    assign branch_target_normal = id_ex_pc + id_ex_immediate;
    assign jal_target = id_ex_pc + id_ex_immediate;
    assign jalr_target = (id_ex_rs1_data + id_ex_immediate) & 32'hFFFFFFFE;

    // Branch Condition (BEQ vs BNE)
    always_comb begin
        branch_condition = 1'b0;
        if (id_ex_branch) begin
            if (id_ex_bne) begin
                branch_condition = (id_ex_rs1_data != id_ex_rs2_data);
            end else begin
                branch_condition = (id_ex_rs1_data == id_ex_rs2_data);
            end
        end
    end

    // PC Redirection (JAL, JALR, Branch)
    always_comb begin
        branch_taken_ex  = 1'b0;
        branch_target_ex = 32'd0;

        if (id_ex_jal) begin
            branch_taken_ex  = 1'b1;
            branch_target_ex = jal_target;
        end else if (id_ex_jalr) begin
            branch_taken_ex  = 1'b1;
            branch_target_ex = jalr_target;
        end else if (branch_condition) begin
            branch_taken_ex  = 1'b1;
            branch_target_ex = branch_target_normal;
        end
    end

    // JAL / JALR Return Address (PC + 4)
    always_comb begin
        if (id_ex_jal || id_ex_jalr) begin
            ex_result_for_wb = id_ex_pc + 32'd4;
        end else begin
            ex_result_for_wb = ex_result_final;
        end
    end

    // EX/MEM Pipeline Register (Stage 3 → Stage 4)
    ex_mem_register EX_MEM (
        .clk(clk),
        .reset(reset),
        .alu_result_in(ex_result_for_wb),
        .store_data_in(id_ex_rs2_data),
        .rd_in(id_ex_rd),
        .reg_write_in(id_ex_reg_write),
        .mem_read_in(id_ex_mem_read),
        .mem_write_in(id_ex_mem_write),
        .mem_to_reg_in(id_ex_mem_to_reg),
        .alu_result_out(ex_mem_alu_result),
        .store_data_out(ex_mem_store_data),
        .rd_out(ex_mem_rd),
        .reg_write_out(ex_mem_reg_write),
        .mem_read_out(ex_mem_mem_read),
        .mem_write_out(ex_mem_mem_write),
        .mem_to_reg_out(ex_mem_mem_to_reg)
    );

    //                    PIPELINE STAGE 4: MEM (Memory Access)

    data_memory DMEM (
        .clk(clk),
        .mem_read(ex_mem_mem_read),
        .mem_write(ex_mem_mem_write),
        .address(ex_mem_alu_result),
        .write_data(ex_mem_store_data),
        .read_data(dmem_read_data)
    );

    // MEM/WB Pipeline Register (Stage 4 → Stage 5)
    mem_wb_register MEM_WB (
        .clk(clk),
        .reset(reset),
        .alu_result_in(ex_mem_alu_result),
        .memory_data_in(dmem_read_data),
        .rd_in(ex_mem_rd),
        .reg_write_in(ex_mem_reg_write),
        .mem_to_reg_in(ex_mem_mem_to_reg),
        .alu_result_out(mem_wb_alu_result),
        .memory_data_out(mem_wb_memory_data),
        .rd_out(mem_wb_rd),
        .reg_write_out(mem_wb_reg_write),
        .mem_to_reg_out(mem_wb_mem_to_reg)
    );

    //                    PIPELINE STAGE 5: WB (Write Back)

    wb_stage WB (
        .alu_result(mem_wb_alu_result),
        .memory_data(mem_wb_memory_data),
        .mem_to_reg(mem_wb_mem_to_reg),
        .reg_write(mem_wb_reg_write),
        .write_data(wb_write_data),
        .reg_write_out(wb_reg_write)
    );

endmodule