`timescale 1ns/1ps
module complex_mult_q15 (
    input  wire signed [15:0] a_re,
    input  wire signed [15:0] a_im,
    input  wire signed [15:0] b_re,
    input  wire signed [15:0] b_im,
    output wire signed [15:0] y_re,
    output wire signed [15:0] y_im
);
    wire signed [31:0] p0 = a_re * b_re;
    wire signed [31:0] p1 = a_im * b_im;
    wire signed [31:0] p2 = a_re * b_im;
    wire signed [31:0] p3 = a_im * b_re;
    wire signed [32:0] re_full = $signed(p0) - $signed(p1);
    wire signed [32:0] im_full = $signed(p2) + $signed(p3);

    // Q1.15 product; truncation is used to keep this module simple.
    assign y_re = re_full[30:15];
    assign y_im = im_full[30:15];
endmodule
