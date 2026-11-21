# Four-element modular scan ceiling

The experiment completed; see [RESULTS.md](RESULTS.md) and the retained
`evidence/` receipts. The first Clang attempt refused a missing intrinsic
header; the authorized GCC10 retry passed. This is an isolated source-kernel
feasibility test, not a compiler optimization.

The actual `local-fold.bend` recurrence is `acc += a[i & 127];
a[i & 127] = acc ^ i; i++`, with U32 arithmetic. Its ordinary point is
4096 iterations, initial carry/index zero, and 128 cells initialized to 17;
the independent retained expected result is 2339999928. The current exact
object has SHA256 `69a7c43e3379703fcf5a13f49b7098cbb7b2021d156ca5ae550433e5d7358d1c`,
identical to the object inspected in the earlier loop-memory investigation.
`frozen.json` pins source, exact current and mature C executables, tools,
measurement code and the preregistered hypothesis.

After at most three scalar iterations, the U32 index is a multiple of four.
Four consecutive ring cells then lie in one non-wrapping chunk. Load them,
compute inclusive sums with two SSE2 byte shifts/additions, add the incoming
carry, XOR with the four unmasked U32 indices, and write the same four cells.
The last sum becomes the next carry. All additions and index increments wrap
modulo 2^32; a group ending at UINT32_MAX correctly wraps to zero. Later chunks
observe earlier writes, including every 128-cell wrap. A scalar tail handles
the remaining zero to three elements. This needs an exclusively writable ring
of ordinary U32 cells: volatile/atomic cells and observable concurrent aliases
are outside the experiment. SSE2 is an explicit target requirement; no AVX.

The hypothesis is a gain above 25% against ordinary optimized scalar C by
reducing the carry dependence to one vector add and one shuffle per four
elements. Extra scan instructions, load/store costs or a strong scalar
compiler may disprove that hypothesis. Both kernels use the same pinned
Clang -O3 policy; scalar optimization is not disabled. Retained disassembly
will establish what Clang actually emitted.

The single attempt compiles and links a tiny C program, checks 22,080 cases
over 23 lengths, 15 initial indices and 64 initial-state seeds, compares all
128 final cells and carry, and checks surrounding canaries. Cases include
zero/odd lengths, 127/128/129, long traversal, arbitrary initial carry,
unaligned ring addresses and U32 index wrap. Six complete initial/final
vectors are additionally recomputed with Python integer arithmetic. Five
ordinary-source inputs are checked against both pinned whole programs.
Six rotated rounds time scalar, SIMD4, mature C and current Bend, targeting
100 ms per sample. A short sample or any correctness failure stops the attempt.

Proxy timing includes initialization of all 128 cells and complete carry
validation on every repetition. Full state is checked separately and the last
timed array is consumed after the clock. The proxy uses a flat stack array and
omits Bend ownership, allocation, destruction and generic runtime costs; its
ratio against mature C or current Bend is a ceiling, not measured compiler
transfer. The scalar/SIMD ratio is the matched kernel comparison. No production
edit, compiler rule, broad-score update or general vectorization claim follows
from this test alone.

Root dispatched the initial attempt after qualification:

```sh
python3 -B research/phase198/numeric/job.py simd-scan01 12 32 python3 -B research/phase198/numeric/simd-scan/run.py --out selfhost/build/phase198/simd-scan01
```

After its build-only refusal, root authorized and dispatched the versioned
`run-gcc.py` / `frozen-gcc.json` retry as `simd-scan02`, with the same 12-second
hard cap. Both scalar and SIMD kernels used the same verified GCC10 options
`-std=c11 -O3 -msse2 -mno-avx`; no optimization was disabled. The original
Clang source, freeze and failure remain retained.
