
module if_id_register (

    input  logic        clk,          
    input  logic        reset,        
    
    // Inputs from IF Stage
    input  logic [31:0] pc_in,        // PC from IF stage
    input  logic [31:0] instr_in,     // Instruction from IF stage
    
    // Outputs to ID Stage
    output logic [31:0] pc_out,       // PC to ID stage
    output logic [31:0] instr_out     // Instruction to ID stage
);
 

    always_ff @(posedge clk) begin
        if (reset) begin
            
            pc_out    <= 32'd0;
            instr_out <= 32'h00000013;  // NOP = ADDI x0, x0, 0
        end else begin
            pc_out    <= pc_in;
            instr_out <= instr_in;
        end
    end


endmodule