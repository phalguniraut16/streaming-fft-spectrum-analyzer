`timescale 1ns/1ps
module fft_spectrum_top (
    input  wire               clk,
    input  wire               rst,
    input  wire               sample_valid,
    input  wire signed [15:0] sample_in,
    input  wire [2:0]         read_addr,
    output wire [15:0]        read_data,
    output reg                bin_valid,
    output reg  [2:0]         bin_index,
    output reg  [15:0]        bin_magnitude
);
    reg [2:0] sample_index;
    wire signed [15:0] window_coeff;
    wire signed [31:0] window_product = sample_in * window_coeff;
    wire signed [15:0] windowed_sample = window_product[30:15];

    window_rom u_window (.addr(sample_index), .coeff(window_coeff));

    // Three radix-2 SDF-style delay/feedback stages (8-point teaching design).
    wire v1, v2, v3;
    wire signed [15:0] s1_re, s1_im, s2_re, s2_im, s3_re, s3_im;
    radix2_sdf_stage #(.DELAY(4)) u_stage0 (
        .clk(clk), .rst(rst), .valid_in(sample_valid),
        .x_re(windowed_sample), .x_im(16'sd0),
        .valid_out(v1), .y_re(s1_re), .y_im(s1_im)
    );
    radix2_sdf_stage #(.DELAY(2)) u_stage1 (
        .clk(clk), .rst(rst), .valid_in(v1),
        .x_re(s1_re), .x_im(s1_im),
        .valid_out(v2), .y_re(s2_re), .y_im(s2_im)
    );
    radix2_sdf_stage #(.DELAY(1)) u_stage2 (
        .clk(clk), .rst(rst), .valid_in(v2),
        .x_re(s2_re), .x_im(s2_im),
        .valid_out(v3), .y_re(s3_re), .y_im(s3_im)
    );

    wire [15:0] mag_raw;
    magnitude_approx u_mag (.x_re(s3_re), .x_im(s3_im), .magnitude(mag_raw));
    wire avg_valid;
    wire [15:0] avg_mag;
    magnitude_average #(.AVG_SHIFT(2)) u_avg (
        .clk(clk), .rst(rst), .valid_in(v3), .magnitude_in(mag_raw),
        .valid_out(avg_valid), .magnitude_out(avg_mag)
    );

    reg buffer_we;
    reg [2:0] buffer_waddr;
    reg [15:0] buffer_wdata;
    output_buffer_bram #(.ADDR_WIDTH(3), .DATA_WIDTH(16), .DEPTH(8)) u_buffer (
        .clk(clk), .we(buffer_we), .waddr(buffer_waddr), .wdata(buffer_wdata),
        .raddr(read_addr), .rdata(read_data)
    );

    always @(posedge clk) begin
        if (rst) begin
            sample_index <= 0;
            bin_valid <= 0;
            bin_index <= 0;
            bin_magnitude <= 0;
            buffer_we <= 0;
            buffer_waddr <= 0;
            buffer_wdata <= 0;
        end else begin
            buffer_we <= 1'b0;
            bin_valid <= 1'b0;
            if (sample_valid)
                sample_index <= sample_index + 1'b1;
            if (avg_valid) begin
                buffer_we <= 1'b1;
                buffer_waddr <= bin_index;
                buffer_wdata <= avg_mag;
                bin_magnitude <= avg_mag;
                bin_valid <= 1'b1;
                bin_index <= bin_index + 1'b1;
            end
        end
    end
endmodule
