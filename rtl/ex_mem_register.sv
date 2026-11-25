
module ex_mem_register (
   
    input  logic        clk,
    input  logic        reset,
    
    input  logic [31:0] alu_result_in,
    input  logic [31:0] store_data_in,
    
    input  logic [4:0]  rd_in,
    input  logic        reg_write_in,
    input  logic        mem_read_in,
    input  logic        mem_write_in,
    input  logic        mem_to_reg_in,

    output logic [31:0] alu_result_out,
    
    // Store Data
    output logic [31:0] store_data_out,
    
    // Destination Register
    output logic [4:0]  rd_out,
    
    // Control Signals
    output logic        reg_write_out,
    output logic        mem_read_out,
    output logic        mem_write_out,
    output logic        mem_to_reg_out
);

    always_ff @(posedge clk) begin
        if (reset) begin
            // Reset: Clear all outputs
            alu_result_out  <= 32'd0;
            store_data_out  <= 32'd0;
            rd_out          <= 5'd0;
            reg_write_out   <= 1'b0;
            mem_read_out    <= 1'b0;
            mem_write_out   <= 1'b0;
            mem_to_reg_out  <= 1'b0;
        end else begin
           
            alu_result_out  <= alu_result_in;
            store_data_out  <= store_data_in;
            rd_out          <= rd_in;
            reg_write_out   <= reg_write_in;
            mem_read_out    <= mem_read_in;
            mem_write_out   <= mem_write_in;
            mem_to_reg_out  <= mem_to_reg_in;
        end
    end


endmodule