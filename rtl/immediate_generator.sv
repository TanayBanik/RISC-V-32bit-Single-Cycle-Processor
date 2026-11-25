
// Immediate Formats:
//   I-type : imm[11:0]   = instruction[31:20]
//   S-type : imm[11:5]   = instruction[31:25]
//            imm[4:0]    = instruction[11:7]
//   B-type : imm[12]     = instruction[31]
//            imm[11]     = instruction[7]
//            imm[10:5]   = instruction[30:25]
//            imm[4:1]    = instruction[11:8]
//            imm[0]      = 0
//   U-type : imm[31:12]  = instruction[31:12]
//            imm[11:0]   = 0
//   J-type : imm[20]     = instruction[31]
//            imm[19:12]  = instruction[19:12]
//            imm[11]     = instruction[20]
//            imm[10:1]   = instruction[30:21]
//            imm[0]      = 0

module immediate_generator (

    input  logic [31:0] instruction,  
    
    output logic [31:0] immediate     // 32-bit sign-extended immediate
);

    logic [6:0] opcode;
    assign opcode = instruction[6:0];
    
    always_comb begin
        immediate = 32'd0;  // Default value (R-type or unknown)

        case (opcode)

            // Format: [imm[11:0]] [rs1] [funct3] [rd] [opcode]
            // imm[11:0] = instruction[31:20]
            7'b0010011,  // I-type ALU (ADDI, ANDI, ORI, XORI, etc.)
            7'b0000011,  // Load (LW, LH, LB, LBU, LHU)
            7'b1100111:  // JALR
                immediate = { {20{instruction[31]}}, instruction[31:20] };

            // Format: [imm[11:5]] [rs2] [rs1] [funct3] [imm[4:0]] [opcode]
            // imm[11:5] = instruction[31:25]
            // imm[4:0]  = instruction[11:7]

            7'b0100011:  // Store (SW, SH, SB)
                immediate = { {20{instruction[31]}}, 
                              instruction[31:25], 
                              instruction[11:7] };

            // Format: [imm[12]] [imm[10:5]] [rs2] [rs1] [funct3] [imm[4:1]] [imm[11]] [opcode]
            // imm[12]   = instruction[31]
            // imm[11]   = instruction[7]
            // imm[10:5] = instruction[30:25]
            // imm[4:1]  = instruction[11:8]
            // imm[0]    = 0 (always 0 for word alignment)
            7'b1100011:  // Branch (BEQ, BNE, BLT, BGE)
                immediate = { {19{instruction[31]}}, 
                              instruction[31], 
                              instruction[7], 
                              instruction[30:25], 
                              instruction[11:8], 
                              1'b0 };

            // U-TYPE: LUI, AUIPC
            // Format: [imm[31:12]] [rd] [opcode]
            // imm[31:12] = instruction[31:12]
            // Lower 12 bits are zero

            7'b0110111,  // LUI
            7'b0010111:  // AUIPC
                immediate = { instruction[31:12], 12'b0 };

            // Format: [imm[20]] [imm[10:1]] [imm[11]] [imm[19:12]] [rd] [opcode]
            // imm[20]   = instruction[31]
            // imm[19:12] = instruction[19:12]
            // imm[11]   = instruction[20]
            // imm[10:1] = instruction[30:21]
            // imm[0]    = 0 (always 0 for word alignment)

            7'b1101111:  // JAL
                immediate = { {11{instruction[31]}}, 
                              instruction[31], 
                              instruction[19:12], 
                              instruction[20], 
                              instruction[30:21], 
                              1'b0 };


            default:
                immediate = 32'd0;

        endcase
    end


endmodule