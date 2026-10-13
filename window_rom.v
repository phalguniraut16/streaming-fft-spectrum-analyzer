`timescale 1ns/1ps
module window_rom (
    input  wire [2:0] addr,
    output reg  signed [15:0] coeff
);
    // 8-point Hann-like window in Q1.15. Endpoints are near zero.
    always @* begin
        case (addr)
            3'd0: coeff = 16'sd0;
            3'd1: coeff = 16'sd6393;
            3'd2: coeff = 16'sd18795;
            3'd3: coeff = 16'sd27853;
            3'd4: coeff = 16'sd27853;
            3'd5: coeff = 16'sd18795;
            3'd6: coeff = 16'sd6393;
            default: coeff = 16'sd0;
        endcase
    end
endmodule
