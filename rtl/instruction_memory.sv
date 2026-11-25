
module instruction_memory (

    input  logic [31:0] address,  // Address from Program Counter (PC)
    
    output logic [31:0] instruction  // 32-bit instruction
); 

    logic [31:0] memory [0:1023];
 
    assign instruction = memory[address[11:2]];

endmodule