# Architecture notes

## Signal path

```text
signed sample
    |
    v
Hann-like coefficient ROM ---- sample index
    |
    v
Q1.15 window multiply
    |
    v
radix-2 delay/feedback stage (delay 4)
    |
    v
radix-2 delay/feedback stage (delay 2)
    |
    v
radix-2 delay/feedback stage (delay 1)
    |
    v
magnitude approximation -> exponential moving average
    |
    v
8 x 16-bit synchronous output memory -> read port
```

## Design trade-offs

- **Delay memory vs. throughput:** SDF structures reuse a butterfly and delay storage per stage while accepting a sample each active clock. The delay length decreases by stage.
- **ROMs vs. logic:** Window and twiddle coefficients are stored as case-ROMs. For larger transforms, ROM inference and address generation affect area/timing.
- **Magnitude:** The approximation `max + 3/8 min` avoids squaring and square root. It costs less logic but is not exact.
- **Averaging:** The shift-based update `avg += (x - avg) / 4` smooths noise with no general divider.
- **Output memory:** A synchronous simple dual-port memory provides a stream-write and addressable-read pattern. The `ram_style` attribute is a hint, not a guarantee of BRAM inference.

## Important implementation limitation

This starter is deliberately compact and demonstrates SDF-like delay/feedback stage primitives, ROMs, magnitude processing, averaging, and output storage. It does **not yet implement a fully verified canonical 8-point SDF FFT**: stage-specific twiddle scheduling, exact bit-reversed/natural-order mapping, frame boundaries, and valid/data alignment must be completed and verified before claiming mathematically correct FFT results. The twiddle ROM and complex multiplier are included as building blocks for that next step; the current top-level does not yet use the twiddle multiplier. Treat output values as datapath activity, not calibrated FFT bins.

A production-ready version should include:
1. Canonical SDF control for each stage and twiddle-address sequencing.
2. Explicit frame-start/frame-end or a documented continuous-frame cadence.
3. Guard bits, saturation, and stage scaling.
4. A bit-accurate Python fixed-point model.
5. Automated numerical assertions for impulse, DC, and single-bin tones.
