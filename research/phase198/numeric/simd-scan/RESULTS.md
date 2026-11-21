# Measured four-element modular scan ceiling

**The SIMD kernel passed and substantially beat optimized scalar C.** Six
rotated rounds at the actual ordinary input (4096 steps, seed 17) gave:

| Role | Median per call | SIMD / role |
| --- | ---: | ---: |
| Matched GCC10 scalar kernel | 3.368 µs | 0.41773 |
| GCC10 SSE2 four-element scan | 1.407 µs | 1.00000 |
| Retained mature C whole program | 2.766 µs | 0.50857 |
| Exact current Bend whole program | 5.625 µs | 0.25009 |

The matched reduction is **58.23%**, exceeding the frozen 25% hypothesis.
Every round favored SIMD over scalar (ratios 0.4105–0.4359) and mature C
(0.5052–0.5317). Samples lasted 71–104 ms; whole-program clocks have millisecond
resolution. This is one short acquisition, not independent session replication.

All **22,080** finite cases checked all 128 final cells, carry, and surrounding
canaries, covering zero/odd lengths, 127/128/129, multiple ring wraps, U32 index
wrap, arbitrary initial carry, varied initial cells and unaligned addresses.
Six complete states were independently recomputed with Python integers.
Five source-level inputs agreed with both exact current Bend and mature C
executables (ten bindings). All 24 timed observations validated every complete
carry result. The ordinary result was 2339999928.

The first `simd-scan01` guard stopped at compilation because the pinned
standalone Clang lacks `emmintrin.h`; it produced no execution or timing claim.
Root authorized one versioned retry with the existing verified GCC10 toolchain.
`simd-scan02` completed in **2.890 seconds**, within its 12-second hard cap;
both guards and retention closures are archived. Both kernels used exactly
`-std=c11 -O3 -msse2 -mno-avx`. Disassembly confirms scalar integer code in the
reference and the expected SSE2 prefix shifts/adds, XOR, store and carry
shuffle in the candidate. GCC emitted two loads of each vector; even this
unrefined lowering won. No further tuning or rerun was performed.

The kernel comparison is matched and directly supports an associative scan
opportunity. The ratios against mature C/current Bend are **flat-array ceilings**:
the C kernels include array initialization but omit Bend allocation, ownership,
destruction and runtime paths. Current-program output binding and exact loop
object identity establish the algorithm, not compiler transfer. No compiler
pass, broad-suite gain or production promotion is claimed. A future admission
would need to prove the ring shape/exclusive access, U32 arithmetic and index
semantics, preserve scalar edges, lower the SIMD representation, and measure
the resulting complete program against mature C.

`evidence/gcc-result.json` retains all samples and input/output bindings;
`evidence/checks.jsonl` retains complete independent state vectors;
`evidence/kernels.asm` retains decoded kernels; `evidence/summary.json` pins
original outputs and the omitted reproducible ELF/object. The two freezes
authenticate source, tools, actual products and methodology.
