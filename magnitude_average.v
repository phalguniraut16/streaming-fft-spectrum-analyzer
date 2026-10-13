`timescale 1ns/1ps
module magnitude_average #(
    parameter AVG_SHIFT = 2
) (
    input  wire        clk,
    input  wire        rst,
    input  wire        valid_in,
    input  wire [15:0] magnitude_in,
    output reg         valid_out,
    output reg  [15:0] magnitude_out
);
    reg [15:0] average;
    wire [15:0] delta = magnitude_in - average;

    always @(posedge clk) begin
        if (rst) begin
            average <= 16'd0;
            magnitude_out <= 16'd0;
            valid_out <= 1'b0;
        end else begin
            valid_out <= valid_in;
            if (valid_in) begin
                average <= average + (delta >>> AVG_SHIFT);
                magnitude_out <= average + (delta >>> AVG_SHIFT);
            end
        end
    end
endmodule
