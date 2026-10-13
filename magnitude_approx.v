`timescale 1ns/1ps
module magnitude_approx (
    input  wire signed [15:0] x_re,
    input  wire signed [15:0] x_im,
    output wire [15:0] magnitude
);
    wire [15:0] abs_re = x_re[15] ? (~x_re + 16'd1) : x_re;
    wire [15:0] abs_im = x_im[15] ? (~x_im + 16'd1) : x_im;
    wire [15:0] hi = (abs_re >= abs_im) ? abs_re : abs_im;
    wire [15:0] lo = (abs_re >= abs_im) ? abs_im : abs_re;
    // Common low-cost approximation to sqrt(re^2 + im^2).
    assign magnitude = hi + (lo >> 1) - (lo >> 3);
endmodule
