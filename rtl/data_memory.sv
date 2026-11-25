
module data_memory (
    
    input  logic        clk,
    
    input  logic        mem_read,     // Enable memory read
    input  logic        mem_write,    // Enable memory write
   
    input  logic [31:0] address,      // Memory address (from ALU result)
    input  logic [31:0] write_data,   // Data to write (from rs2_data)
    
    output logic [31:0] read_data     // Data read from memory
);

    logic [31:0] memory [0:1023];

    integer i;
    initial begin
        // Initialize all memory to 0
        for (i = 0; i < 1024; i++) begin
            memory[i] = 32'd0;
        end
        
        // Load some test data
        memory[0] = 32'hDEADBEEF;   // Address 0
        memory[1] = 32'hCAFEBABE;   // Address 4
        memory[2] = 32'h12345678;   // Address 8
        memory[3] = 32'h90ABCDEF;   // Address 12
        memory[4] = 32'hFEDCBA98;   // Address 16
    end

    always_ff @(posedge clk) begin
        if (mem_write) begin
            memory[address[11:2]] <= write_data;
        end
    end

    always_comb begin
        if (mem_read) begin
            read_data = memory[address[11:2]];
        end else begin
            read_data = 32'd0;
        end
    end



endmodule