# Streaming FFT Spectrum Analyzer (Vivado / Verilog)

A small, self-contained FPGA learning project demonstrating a streaming radix-2 FFT signal path, coefficient ROMs, magnitude estimation, temporal averaging, and a BRAM-style output buffer.

> **Scope / honesty note:** This repository is an educational RTL prototype, not a vendor-verified production FFT IP. The included 8-point radix-2 SDF stage chain is intended for architectural study. Validate numerical ordering, scaling, and timing in Vivado before using it in a real design. No synthesis or hardware measurements are claimed here.

## Features

- Verilog RTL targeted at Xilinx Vivado
- 8-point, 3-stage radix-2 SDF-style streaming datapath
- Small Q1.15 window coefficient ROM (Hann-like)
- Twiddle coefficient ROM
- Fixed-point complex multiply and butterfly logic
- Magnitude approximation: `max(|Re|,|Im|) + 3/8*min(|Re|,|Im|)`
- Exponential moving average of magnitude bins
- 8-bin output memory with synchronous write/read interface
- Self-checking smoke testbench and Vivado simulation steps
- Python reference model for comparison and architecture notes

## Repository layout

```text
rtl/
  fft_spectrum_top.v
  radix2_sdf_stage.v
  window_rom.v
  twiddle_rom.v
  complex_mult_q15.v
  magnitude_approx.v
  magnitude_average.v
  output_buffer_bram.v
tb/
  tb_fft_spectrum_top.v
scripts/
  reference_fft.py
docs/
  architecture.md
  vivado_quickstart.md
```

## Top-level interface

`fft_spectrum_top` accepts signed 16-bit real samples and a `sample_valid` strobe. It emits `bin_valid`, `bin_index`, and `bin_magnitude` as spectrum-bin results are written to the output buffer. `read_addr` / `read_data` provide a synchronous read port for inspection.

## Fixed-point conventions

- Input samples: signed Q1.15-ish integer format (the full signed 16-bit range is accepted)
- Window/twiddle coefficients: signed Q1.15
- Complex multiply: 32-bit products, rounded by taking bits `[30:15]`
- Internal butterfly datapath: 16-bit wraparound arithmetic; this is intentionally compact for an educational design and **does not implement block floating point or saturation**.
- Magnitude: approximate, not exact Euclidean magnitude.
- Averaging: first-order moving average with configurable shift (default shift 2, i.e. 1/4 update).

## Important validation checklist

1. Run the testbench in Vivado Simulator (xsim).
2. Check stage-to-stage valid alignment and bin ordering for your intended sample cadence.
3. Compare output against `scripts/reference_fft.py`.
4. Inspect inferred memories and DSP usage after synthesis.
5. Add saturation/guard bits and a scaling strategy before increasing FFT size or input amplitude.
6. Confirm timing constraints and target FPGA part.

## Run a quick Python reference

```bash
python scripts/reference_fft.py
```

This script uses only the Python standard library and prints the expected 8-point FFT of a sample tone. It is a numerical reference, not a simulation of the RTL.

## License

MIT — see `LICENSE`.
