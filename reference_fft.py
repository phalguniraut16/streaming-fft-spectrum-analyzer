#!/usr/bin/env python3
"""Standard-library floating-point reference for an 8-point forward FFT."""
import cmath
import math

N = 8
samples = [12000 * math.cos(2 * math.pi * n / N) for n in range(N)]
window = [0.5 - 0.5 * math.cos(2 * math.pi * n / (N - 1)) for n in range(N)]
windowed = [samples[n] * window[n] for n in range(N)]
spectrum = [
    sum(windowed[n] * cmath.exp(-2j * math.pi * k * n / N) for n in range(N))
    for k in range(N)
]
print("8-point Hann-windowed FFT reference (floating point)")
for k, value in enumerate(spectrum):
    print(f"bin {k}: real={value.real:10.3f}, imag={value.imag:10.3f}, magnitude={abs(value):10.3f}")
print("\nNote: this is a mathematical reference, not a bit-accurate model of the fixed-point RTL.")
