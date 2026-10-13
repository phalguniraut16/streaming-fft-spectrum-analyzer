`timescale 1ns/1ps
module twiddle_rom (
    input  wire [2:0] addr,
    output reg signed [15:0] cos_q15,
    output reg signed [15:0] sin_q15
);
    // W8^k = exp(-j*2*pi*k/8), represented as cos and signed sin.
    // Sine is negative for the forward FFT convention.
    always @* begin
        case (addr)
            3'd0: begin cos_q15=16'sd32767; sin_q15=16'sd0; end
            3'd1: begin cos_q15=16'sd23170; sin_q15=-16'sd23170; end
            3'd2: begin cos_q15=16'sd0;     sin_q15=-16'sd32767; end
            3'd3: begin cos_q15=-16'sd23170;sin_q15=-16'sd23170; end
            default: begin cos_q15=16'sd32767; sin_q15=16'sd0; end
        endcase
    end
endmodule
