//////////////////////////////////////////////////////////////////////////////////
// Company: Jotshaw Electronics
// Engineer: John Bagshaw
// Create Date: 12/18/2023 11:43:39 AM
// Design Name: Optimized Clock Divider
// Module Name: clk_div_opt
// Project Name: Optimized Clock Divider Testbench
// Target Devices: Basys3 (Artix 7)
// Tool Versions: Vivado 2023.2
// Description: A versatile, parameterized clock divider design
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps
  
module clk_div_opt_TB;

    // Inputs
    reg rst;
    reg clk;
    reg en;

    // Outputs
    wire div2;
    wire div4;
    wire div8;
    wire div16;

    // Instantiate the Unit Under Test (UUT)
    clk_div_opt #(.MAX_COUNT(4'd15)) uut (
        .rst(rst), 
        .clk(clk), 
        .en(en), 
        .div2(div2), 
        .div4(div4), 
        .div8(div8), 
        .div16(div16)
    );

    // Generate a clock with a period of 10ns
    initial begin
        clk = 0;
        forever #5 clk = !clk; // 100MHz clock
    end

    // Apply random test values
    initial begin
        // Initialize Inputs
        rst = 1'b1;
        en = 1'b0;
        #20 rst = 1'b0; // Deassert reset after 20ns

        // Begin testing with random values
        repeat (100) begin
            @(posedge clk); // Wait for the positive edge of the clock
            en = $urandom_range(0, 1); // Randomly enable or disable counting
            if ($urandom_range(0, 1))
                rst = 1'b1; // Randomly assert reset
            @(posedge clk); // Wait for another positive edge of the clock
            rst = 1'b0; // Ensure reset is deasserted
        end

        // Additional test to check if the counter stops when 'en' is deasserted
        en = 1'b0;
        repeat (5) @(posedge clk); // Observe for 5 clock cycles

        // Test that the counter resumes when 'en' is asserted
        en = 1'b1;
        repeat (5) @(posedge clk); // Observe for 5 more clock cycles

        $finish; // End the simulation
    end

    // Monitor and display the results
    initial begin
        $monitor("Time=%t rst=%b en=%b div2=%b div4=%b div8=%b div16=%b",
                  $time, rst, en, div2, div4, div8, div16);
    end

endmodule
