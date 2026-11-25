

module mem_wb_register (
    input  logic        clk,
    input  logic        reset,
    
    // ALU Result
    input  logic [31:0] alu_result_in,
    
    // Memory Data (from data_memory)
    input  logic [31:0] memory_data_in,
    
    // Destination Register
    input  logic [4:0]  rd_in,
    
    // Control Signals
    input  logic        reg_write_in,
    input  logic        mem_to_reg_in,
    

    output logic [31:0] alu_result_out,
    
    // Memory Data
    output logic [31:0] memory_data_out,
    
    // Destination Register
    output logic [4:0]  rd_out,
    
    // Control Signals
    output logic        reg_write_out,
    output logic        mem_to_reg_out
);

    always_ff @(posedge clk) begin
        if (reset) begin
            // Reset: Clear all outputs
            alu_result_out  <= 32'd0;
            memory_data_out <= 32'd0;
            rd_out          <= 5'd0;
            reg_write_out   <= 1'b0;
            mem_to_reg_out  <= 1'b0;
        end else begin
            // Normal operation: Capture all signals
            alu_result_out  <= alu_result_in;
            memory_data_out <= memory_data_in;
            rd_out          <= rd_in;
            reg_write_out   <= reg_write_in;
            mem_to_reg_out  <= mem_to_reg_in;
        end
    end



endmodule