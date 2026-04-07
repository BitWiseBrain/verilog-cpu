module testbench;
    reg clk;
    reg rst;

    ct cpu (
        .clk(clk),
        .rst(rst)
    );
    always #5 clk = ~clk;

    initial begin
        $dumpfile("cpu_waves.vcd");
        $dumpvars(0, testbench);


        clk = 0;
        rst = 1;
        
        // hardcoding values since we dont have ADDI yet
        cpu.dp.rf.registers[1] = 32'd5;
        cpu.dp.rf.registers[2] = 32'd10;

        #10;
        rst = 0;

        #200;
        
        $display("Simulation finished.");
        $display("$1 = %d", cpu.dp.rf.registers[1]);
        $display("$2 = %d", cpu.dp.rf.registers[2]);
        $display("$3 = %d", cpu.dp.rf.registers[3]);
        $display("$4 = %d", cpu.dp.rf.registers[4]);
        
        $finish;
    end
endmodule
