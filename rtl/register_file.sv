
module register_file (

    input  logic        clk,
    
    input  logic [4:0]  rs1,          // Read register 1 address
    input  logic [4:0]  rs2,          // Read register 2 address
    output logic [31:0] rs1_data,     // Data from rs1
    output logic [31:0] rs2_data,     // Data from rs2
    
    input  logic [4:0]  rd,           // Write register address
    input  logic [31:0] write_data,   // Data to write
    input  logic        reg_write     // Write enable
);

    logic [31:0] registers [0:31];

    integer i;
    initial begin
        for (i = 0; i < 32; i++) begin
            registers[i] = 32'd0;
        end
    end

    always_ff @(posedge clk) begin
        if (reg_write && (rd != 5'd0)) begin
            registers[rd] <= write_data;
        end
    end

    always_comb begin
        // Read rs1
        if (rs1 == 5'd0)
            rs1_data = 32'd0;
        else
            rs1_data = registers[rs1];
        
        // Read rs2
        if (rs2 == 5'd0)
            rs2_data = 32'd0;
        else
            rs2_data = registers[rs2];
    end



endmodule