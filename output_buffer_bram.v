`timescale 1ns/1ps
module output_buffer_bram #(
    parameter ADDR_WIDTH = 3,
    parameter DATA_WIDTH = 16,
    parameter DEPTH = 8
) (
    input  wire                  clk,
    input  wire                  we,
    input  wire [ADDR_WIDTH-1:0] waddr,
    input  wire [DATA_WIDTH-1:0] wdata,
    input  wire [ADDR_WIDTH-1:0] raddr,
    output reg  [DATA_WIDTH-1:0] rdata
);
    // Inferred synchronous simple dual-port memory. Vivado may map this
    // to distributed RAM or block RAM depending on target and constraints.
    (* ram_style = "block" *) reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    always @(posedge clk) begin
        if (we)
            mem[waddr] <= wdata;
        rdata <= mem[raddr];
    end
endmodule
