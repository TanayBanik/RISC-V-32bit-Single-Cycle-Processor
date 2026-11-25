
module wb_stage (
   
    input  logic [31:0] alu_result,   // ALU result from EX stage
    input  logic [31:0] memory_data,  // Data from Data Memory (LW)
    input  logic        mem_to_reg,   // Select write-back source
    input  logic        reg_write,    // Enable register write

    output logic [31:0] write_data,   // Data to write to register
    output logic        reg_write_out // Pass-through to Register File
);

 
    assign write_data = (mem_to_reg) ? memory_data : alu_result;

  
    assign reg_write_out = reg_write;




endmodule