`timescale 1ns / 1ps

module tb_riscv_pipeline;

    logic        clk;
    logic        reset;
    logic [31:0] pc;

    riscv_pipeline_top DUT (
        .clk(clk),
        .reset(reset),
        .pc(pc)
    );

    // Clock
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // Load Program
    initial begin
        for (int i = 0; i < 1024; i++) begin
            DUT.IMEM.memory[i] = 32'h00000013;
        end

        // ADDI x8, x0, 100
        DUT.IMEM.memory[0] = 32'h06400413;
        DUT.IMEM.memory[1] = 32'h00000013;  // NOP
        DUT.IMEM.memory[2] = 32'h00000013;  // NOP
        DUT.IMEM.memory[3] = 32'h00000013;  // NOP

        // ADDI x9, x8, 50
        DUT.IMEM.memory[4] = 32'h03240493;
        DUT.IMEM.memory[5] = 32'h00000013;  // NOP
        DUT.IMEM.memory[6] = 32'h00000013;  // NOP
        DUT.IMEM.memory[7] = 32'h00000013;  // NOP

        // ADD x10, x8, x9
        DUT.IMEM.memory[8] = 32'h009504B3;
        DUT.IMEM.memory[9] = 32'h00000013;  // NOP
        DUT.IMEM.memory[10] = 32'h00000013; // NOP
        DUT.IMEM.memory[11] = 32'h00000013; // NOP

        // LW x11, 0(x8)
        DUT.IMEM.memory[12] = 32'h00040583;
        DUT.IMEM.memory[13] = 32'h00000013; // NOP
        DUT.IMEM.memory[14] = 32'h00000013; // NOP
        DUT.IMEM.memory[15] = 32'h00000013; // NOP

        // SW x9, 4(x8)
        DUT.IMEM.memory[16] = 32'h00942423;
        DUT.IMEM.memory[17] = 32'h00000013; // NOP
        DUT.IMEM.memory[18] = 32'h00000013; // NOP
        DUT.IMEM.memory[19] = 32'h00000013; // NOP

        // More NOPs
        DUT.IMEM.memory[20] = 32'h00000013;
        DUT.IMEM.memory[21] = 32'h00000013;
        DUT.IMEM.memory[22] = 32'h00000013;
        DUT.IMEM.memory[23] = 32'h00000013;
    end

    // Initialize Data Memory
    initial begin
        for (int i = 0; i < 1024; i++) begin
            DUT.DMEM.memory[i] = 32'd0;
        end
        DUT.DMEM.memory[25] = 32'hDEADBEEF;
        DUT.DMEM.memory[26] = 32'hCAFEBABE;
    end

   
    initial begin
        reset = 1;
        #80;        // Hold reset for 4 cycles
        reset = 0;  //  MUST HAVE THIS LINE!
        #2000;
        $finish;
    end

    // Monitor
    always @(posedge clk) begin
        if (!reset) begin
            $display("[%0t] PC=%0d, Instr=0x%08h", 
                     $time, pc, DUT.IMEM.instruction);
        end
    end

endmodule