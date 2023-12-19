//////////////////////////////////////////////////////////////////////////////////
// Company: Jotshaw Electronics
// Engineer: John Bagshaw
// Create Date: 12/18/2023 11:43:39 AM
// Design Name: Optimized Clock Divider
// Module Name: clk_div_opt
// Project Name: Optimized Clock Divider
// Target Devices: Basys3 (Artix 7)
// Tool Versions: Vivado 2023.2
// Description: A versatile, parameterized clock divider design

// Revision 0.01 - File Created

//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module clk_div_opt #(
    parameter MAX_COUNT = 4'd15  // Parameter for maximum count value
)
(
    input wire rst,
    input wire clk,
    input wire en,
    output wire div2,
    output wire div4,
    output wire div8,
    output wire div16
);

    reg [3:0] count;

    always @(posedge clk or posedge rst) begin
    if (rst)
        count <= 0;
    else if (en)
        count <= (count == MAX_COUNT) ? 0 : count + 1;
    end

    // Direct assignment of outputs from the count register
    assign div2 = count[0];
    assign div4 = count[1];
    assign div8 = count[2];
    assign div16 = count[3];

endmodule
