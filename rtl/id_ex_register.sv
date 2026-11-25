
module id_ex_register (
    input  logic        clk,          // System clock (rising edge triggered)
    input  logic        reset,        // Active-high synchronous reset
    
    // Program Counter
    input  logic [31:0] pc_in,
    
    // Register Data
    input  logic [31:0] rs1_data_in,
    input  logic [31:0] rs2_data_in,
    
    // Immediate Value
    input  logic [31:0] immediate_in,
    
    // Register Addresses
    input  logic [4:0]  rs1_in,
    input  logic [4:0]  rs2_in,
    input  logic [4:0]  rd_in,
    
    // Register File Control
    input  logic        reg_write_in,
    input  logic        mem_read_in,
    input  logic        mem_write_in,
    input  logic        mem_to_reg_in,
    
    // ALU Control
    input  logic        alu_src_in,
    input  logic [2:0]  alu_control_in,
    
    // Branch/Jump Control
    input  logic        branch_in,
    input  logic        bne_in,
    input  logic        jal_in,
    input  logic        jalr_in,
    input  logic        lui_in,
    input  logic        auipc_in,
    
    // Program Counter
    output logic [31:0] pc_out,
    
    // Register Data
    output logic [31:0] rs1_data_out,
    output logic [31:0] rs2_data_out,
    
    // Immediate Value
    output logic [31:0] immediate_out,
    
    // Register Addresses
    output logic [4:0]  rs1_out,
    output logic [4:0]  rs2_out,
    output logic [4:0]  rd_out,
    
    // Register File Control
    output logic        reg_write_out,
    output logic        mem_read_out,
    output logic        mem_write_out,
    output logic        mem_to_reg_out,
    
    // ALU Control
    output logic        alu_src_out,
    output logic [2:0]  alu_control_out,
    
    // Branch/Jump Control
    output logic        branch_out,
    output logic        bne_out,
    output logic        jal_out,
    output logic        jalr_out,
    output logic        lui_out,
    output logic        auipc_out
);

    always_ff @(posedge clk) begin
        if (reset) begin
            
            // PC and Data
            pc_out          <= 32'd0;
            rs1_data_out    <= 32'd0;
            rs2_data_out    <= 32'd0;
            immediate_out   <= 32'd0;
            
            // Register Addresses
            rs1_out         <= 5'd0;
            rs2_out         <= 5'd0;
            rd_out          <= 5'd0;
            
            // Control Signals
            reg_write_out   <= 1'b0;
            mem_read_out    <= 1'b0;
            mem_write_out   <= 1'b0;
            mem_to_reg_out  <= 1'b0;
            alu_src_out     <= 1'b0;
            alu_control_out <= 3'b000;
            branch_out      <= 1'b0;
            bne_out         <= 1'b0;
            jal_out         <= 1'b0;
            jalr_out        <= 1'b0;
            lui_out         <= 1'b0;
            auipc_out       <= 1'b0;
            
        end else begin
            
            // PC and Data
            pc_out          <= pc_in;
            rs1_data_out    <= rs1_data_in;
            rs2_data_out    <= rs2_data_in;
            immediate_out   <= immediate_in;
            
            // Register Addresses
            rs1_out         <= rs1_in;
            rs2_out         <= rs2_in;
            rd_out          <= rd_in;
            
            // Control Signals
            reg_write_out   <= reg_write_in;
            mem_read_out    <= mem_read_in;
            mem_write_out   <= mem_write_in;
            mem_to_reg_out  <= mem_to_reg_in;
            alu_src_out     <= alu_src_in;
            alu_control_out <= alu_control_in;
            branch_out      <= branch_in;
            bne_out         <= bne_in;
            jal_out         <= jal_in;
            jalr_out        <= jalr_in;
            lui_out         <= lui_in;
            auipc_out       <= auipc_in;
            
        end
    end


endmodule