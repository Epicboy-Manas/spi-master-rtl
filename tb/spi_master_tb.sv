// File: testbench.sv
module spi_tb;
    logic clk, rst_n, start, busy, done, sclk, cs_n, mosi, miso;
    logic [7:0] tx_data, rx_data;

    // Connect to our Design
    spi_master dut (.*);

    // Generate a Clock
    always #5 clk = ~clk;

    initial begin
        $dumpfile("dump.vcd"); $dumpvars(0, spi_tb);
        clk = 0; rst_n = 0; start = 0; tx_data = 8'hA5; miso = 0;
        
        #20 rst_n = 1;      // Release reset
        #20 start = 1;      // Start transmission
        #10 start = 0;
        
        wait(done);         // Wait until finished
        #50 $finish;
    end
endmodule
