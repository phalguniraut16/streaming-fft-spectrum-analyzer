# Vivado quick start

1. Create a new RTL project in Vivado. Select your target Xilinx part or board.
2. Add every `.v` file under `rtl/` as Design Sources.
3. Add `tb/tb_fft_spectrum_top.v` as a Simulation Source.
4. Set `tb_fft_spectrum_top` as the simulation top.
5. Click **Run Simulation → Run Behavioral Simulation**.
6. Inspect the console for `PASS: smoke test...` and inspect `sample_valid`, stage valids, `bin_valid`, and `bin_magnitude`.
7. To synthesize, select `fft_spectrum_top` as the synthesis top and run **Run Synthesis**.
8. Inspect inferred memory, DSP, LUT, and timing reports. Actual resource counts depend on the FPGA part and Vivado version.

## Optional command-line simulation

With Icarus Verilog installed:

```bash
iverilog -g2012 -o simv rtl/*.v tb/tb_fft_spectrum_top.v
vvp simv
```

The testbench is a smoke test only; it verifies that output updates occur, not FFT numerical correctness.
