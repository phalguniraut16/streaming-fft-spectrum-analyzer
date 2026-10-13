`timescale 1ns/1ps
// Educational radix-2 single-delay-feedback stage primitive.
// A complete N-point SDF pipeline requires stage-specific scheduling and
// twiddle addressing. This primitive illustrates the delay/feedback butterfly
// pattern and is instantiated in the top-level streaming datapath.
module radix2_sdf_stage #(
    parameter DELAY = 4
) (
    input  wire clk,
    input  wire rst,
    input  wire valid_in,
    input  wire signed [15:0] x_re,
    input  wire signed [15:0] x_im,
    output reg  valid_out,
    output reg  signed [15:0] y_re,
    output reg  signed [15:0] y_im
);
    reg signed [15:0] delay_re [0:DELAY-1];
    reg signed [15:0] delay_im [0:DELAY-1];
    reg [$clog2(2*DELAY)-1:0] phase;
    integer i;
    reg signed [15:0] old_re, old_im;
    reg signed [15:0] sum_re, sum_im, diff_re, diff_im;

    always @(posedge clk) begin
        if (rst) begin
            phase <= 0;
            valid_out <= 1'b0;
            y_re <= 0;
            y_im <= 0;
            for (i=0; i<DELAY; i=i+1) begin
                delay_re[i] <= 0;
                delay_im[i] <= 0;
            end
        end else begin
            valid_out <= valid_in;
            if (valid_in) begin
                if (phase < DELAY) begin
                    delay_re[phase] <= x_re;
                    delay_im[phase] <= x_im;
                    y_re <= x_re;
                    y_im <= x_im;
                end else begin
                    old_re = delay_re[phase-DELAY];
                    old_im = delay_im[phase-DELAY];
                    sum_re = old_re + x_re;
                    sum_im = old_im + x_im;
                    diff_re = old_re - x_re;
                    diff_im = old_im - x_im;
                    delay_re[phase-DELAY] <= diff_re;
                    delay_im[phase-DELAY] <= diff_im;
                    y_re <= sum_re;
                    y_im <= sum_im;
                end
                if (phase == 2*DELAY-1)
                    phase <= 0;
                else
                    phase <= phase + 1'b1;
            end
        end
    end
endmodule
