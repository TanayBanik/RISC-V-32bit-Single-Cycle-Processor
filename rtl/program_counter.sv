
module program_counter (
    input  logic        clk,          // System clock (rising edge triggered)
    input  logic        reset,        // Active-high synchronous reset
    
    input  logic        branch_taken, // 1 = branch/jump taken, redirect PC
    input  logic [31:0] branch_target,// Target address from EX stage
    
    input  logic [31:0] pc_next,      // PC+4 from combinational adder
    
    output logic [31:0] pc            // Current instruction address
);

    logic [31:0] pc_reg;        // Actual PC flip-flop (32-bit register)
    logic [31:0] pc_mux_out;    // Output of the PC MUX (before register)

    assign pc_mux_out = (branch_taken) ? branch_target : pc_next;

    always_ff @(posedge clk) begin
        if (reset) begin
            pc_reg <= 32'd0;         
        end else begin
            pc_reg <= pc_mux_out;     // Update PC
        end
    end


    assign pc = pc_reg;



endmodule