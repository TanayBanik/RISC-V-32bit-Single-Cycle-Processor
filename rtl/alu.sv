
module alu (
    // Inputs
    input  logic [31:0] a,          // Operand A (from rs1_data)
    input  logic [31:0] b,          // Operand B (rs2_data or immediate)
    input  logic [2:0]  control,    // ALU operation control

    // Outputs
    output logic [31:0] result,     // ALU result
    output logic        zero        // Zero flag (result == 0)
);

    logic [31:0] alu_result;
    // ALU Operation - Combinational Logic
    always_comb begin
        case (control)
            3'b000: alu_result = a + b;
            3'b001: alu_result = a - b;
            3'b010: alu_result = a | b;
            3'b011: alu_result = a >> b[4:0];
            3'b100: alu_result = a ^ b;
            3'b101: alu_result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
            3'b110: alu_result = a << b[4:0];
            3'b111: alu_result = a & b;

            default: alu_result = 32'd0;

        endcase
    end

    assign result = alu_result;
    assign zero   = (alu_result == 32'd0);


endmodule