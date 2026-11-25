
module control_unit (

    input  logic [6:0] opcode,    // Instruction[6:0]
    input  logic [2:0] funct3,    // Instruction[14:12]
    input  logic [6:0] funct7,    // Instruction[31:25]
    
    output logic        reg_write,    // Write to register file
    output logic        mem_read,     // Read from data memory
    output logic        mem_write,    // Write to data memory
    output logic        mem_to_reg,   // Write-back source (0=ALU, 1=Memory)
    
    // ALU Control
    output logic        alu_src,      // ALU input B (0=register, 1=immediate)
    output logic [2:0]  alu_control,  // ALU operation
    
    // Branch/Jump Control
    output logic        branch,       // Branch instruction
    output logic        bne,          // Branch if Not Equal
    output logic        jal,          // Jump and Link
    output logic        jalr,         // Jump and Link Register
    output logic        lui,          // Load Upper Immediate
    output logic        auipc         // Add Upper Immediate to PC
);

    localparam [6:0] OPCODE_RTYPE  = 7'b0110011;  // 0x33 - R-type
    localparam [6:0] OPCODE_ITYPE  = 7'b0010011;  // 0x13 - I-type ALU
    localparam [6:0] OPCODE_LOAD   = 7'b0000011;  // 0x03 - Load
    localparam [6:0] OPCODE_STORE  = 7'b0100011;  // 0x23 - Store
    localparam [6:0] OPCODE_BRANCH = 7'b1100011;  // 0x63 - Branch
    localparam [6:0] OPCODE_JAL    = 7'b1101111;  // 0x6F - JAL
    localparam [6:0] OPCODE_JALR   = 7'b1100111;  // 0x67 - JALR
    localparam [6:0] OPCODE_LUI    = 7'b0110111;  // 0x37 - LUI
    localparam [6:0] OPCODE_AUIPC  = 7'b0010111;  // 0x17 - AUIPC

    always_comb begin
        reg_write   = 1'b0;
        mem_read    = 1'b0;
        mem_write   = 1'b0;
        mem_to_reg  = 1'b0;
        alu_src     = 1'b0;
        alu_control = 3'b000;
        branch      = 1'b0;
        bne         = 1'b0;
        jal         = 1'b0;
        jalr        = 1'b0;
        lui         = 1'b0;
        auipc       = 1'b0;

        case (opcode)

            OPCODE_RTYPE: begin
                reg_write = 1'b1;        // Write result to rd
                alu_src   = 1'b0;         // Use register for ALU input B
                
                case (funct3)
                    3'b000: begin         // ADD or SUB
                        if (funct7 == 7'b0100000)
                            alu_control = 3'b001;  // SUB
                        else
                            alu_control = 3'b000;  // ADD
                    end
                    3'b001: alu_control = 3'b110;  // SLL
                    3'b010: alu_control = 3'b101;  // SLT
                    3'b011: alu_control = 3'b101;  // SLTU (same as SLT for now)
                    3'b100: alu_control = 3'b100;  // XOR
                    3'b101: begin         // SRL or SRA
                        if (funct7 == 7'b0100000)
                            alu_control = 3'b011;  // SRA (same as SRL for now)
                        else
                            alu_control = 3'b011;  // SRL
                    end
                    3'b110: alu_control = 3'b010;  // OR
                    3'b111: alu_control = 3'b111;  // AND
                    default: alu_control = 3'b000;
                endcase
            end

            OPCODE_ITYPE: begin
                reg_write = 1'b1;        // Write result to rd
                alu_src   = 1'b1;         // Use immediate for ALU input B
                
                case (funct3)
                    3'b000: alu_control = 3'b000;  // ADDI
                    3'b001: alu_control = 3'b110;  // SLLI
                    3'b010: alu_control = 3'b101;  // SLTI
                    3'b011: alu_control = 3'b101;  // SLTIU
                    3'b100: alu_control = 3'b100;  // XORI
                    3'b101: alu_control = 3'b011;  // SRLI
                    3'b110: alu_control = 3'b010;  // ORI
                    3'b111: alu_control = 3'b111;  // ANDI
                    default: alu_control = 3'b000;
                endcase
            end

            OPCODE_LOAD: begin
                reg_write  = 1'b1;        // Write loaded data to rd
                mem_read   = 1'b1;         // Read from data memory
                mem_to_reg = 1'b1;         // Write-back source = memory
                alu_src    = 1'b1;         // Use immediate for address calculation
                alu_control = 3'b000;      // ADD (address = base + offset)
            end

            OPCODE_STORE: begin
                mem_write = 1'b1;         // Write to data memory
                alu_src   = 1'b1;         // Use immediate for address calculation
                alu_control = 3'b000;      // ADD (address = base + offset)
            end

            OPCODE_BRANCH: begin
                branch = 1'b1;            // Branch instruction
                alu_src = 1'b0;           // Compare registers (rs1 vs rs2)
                alu_control = 3'b001;      // SUB (to compare rs1 - rs2)
                

                if (funct3 == 3'b001)
                    bne = 1'b1;
                else
                    bne = 1'b0;
            end

            OPCODE_JAL: begin
                jal       = 1'b1;         // Jump and Link
                reg_write = 1'b1;         // Save return address (PC+4) to rd
            end

            OPCODE_JALR: begin
                jalr      = 1'b1;         // Jump and Link Register
                reg_write = 1'b1;         // Save return address (PC+4) to rd
                alu_src   = 1'b1;         // Use immediate (rs1 + offset)
                alu_control = 3'b000;      // ADD (address = rs1 + imm)
            end

            OPCODE_LUI: begin
                lui       = 1'b1;         // LUI instruction
                reg_write = 1'b1;         // Write immediate << 12 to rd
            end

            OPCODE_AUIPC: begin
                auipc     = 1'b1;         // AUIPC instruction
                reg_write = 1'b1;         // Write PC + (imm << 12) to rd
            end

            default: begin
            end

        endcase
    end



endmodule