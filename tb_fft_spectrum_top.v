`timescale 1ns/1ps
module tb_fft_spectrum_top;
    reg clk = 0;
    always #5 clk = ~clk;
    reg rst = 1;
    reg sample_valid = 0;
    reg signed [15:0] sample_in = 0;
    reg [2:0] read_addr = 0;
    wire [15:0] read_data;
    wire bin_valid;
    wire [2:0] bin_index;
    wire [15:0] bin_magnitude;
    integer n;
    integer bins_seen = 0;

    fft_spectrum_top dut (
        .clk(clk), .rst(rst), .sample_valid(sample_valid),
        .sample_in(sample_in), .read_addr(read_addr), .read_data(read_data),
        .bin_valid(bin_valid), .bin_index(bin_index), .bin_magnitude(bin_magnitude)
    );

    initial begin
        $dumpfile("fft_spectrum.vcd");
        $dumpvars(0, tb_fft_spectrum_top);
        repeat (4) @(posedge clk);
        rst <= 0;

        // Send 32 samples from a repeatable sequence. The purpose of this
        // smoke test is to check reset, valid propagation, and output activity.
        for (n = 0; n < 32; n = n + 1) begin
            @(negedge clk);
            sample_valid = 1'b1;
            case (n % 8)
                0: sample_in = 16'sd12000;
                1: sample_in = 16'sd8485;
                2: sample_in = 16'sd0;
                3: sample_in = -16'sd8485;
                4: sample_in = -16'sd12000;
                5: sample_in = -16'sd8485;
                6: sample_in = 16'sd0;
                default: sample_in = 16'sd8485;
            endcase
        end
        @(negedge clk);
        sample_valid = 0;
        repeat (40) @(posedge clk);
        if (bins_seen == 0) begin
            $display("FAIL: no spectrum outputs observed");
            $fatal;
        end
        $display("PASS: smoke test observed %0d output updates", bins_seen);
        $finish;
    end

    always @(posedge clk) begin
        if (!rst && bin_valid) begin
            bins_seen <= bins_seen + 1;
            $display("bin=%0d magnitude=%0d", bin_index, bin_magnitude);
        end
    end
endmodule
