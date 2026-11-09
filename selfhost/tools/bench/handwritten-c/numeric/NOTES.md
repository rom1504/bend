# Numeric handwritten C counterparts

These five independent C11 translation units expose only the common public
entry `uint32_t bench_u32(uint32_t a, uint32_t b)`. Link one selected translation
unit with the separately compiled driver, without LTO. There is no `main`, timer,
validation loop, cached result, catalog-result constant, or argument-specific
shortcut. All ten catalog IDs are listed in `mapping.json`.

No compiler, target, benchmark, or executable check was run while preparing
these files. Equivalence remains a root-owned execution gate. The expected
values below are copied from fixture validation trailers, not observed C results.

## Algorithms and representation

- `mandelbrot.c` follows `hchunk`, `hzip`, `hfold`, `cdf`, `rpix`, `rcol`,
  and `rend.mix` from `catalogs/native45/fixtures/mandelbrot.bend`.
  It retains both pixel passes, eight histogram counters, the binary histogram
  reduction, the binary recolor reduction, eight masked color selections, and
  the LUT/checksum mixing. Its `bench` uses seven iterations and ignores `b`,
  exactly as the fixture adapter does. `a` is histogram depth, not image width.
  Histograms and LUTs are small by-value structs; recursion uses automatic
  storage. No heap allocation or retained product exists. The upstream
  [`bench/runtime/mandelbrot/main.c`](../../../../../bench/runtime/mandelbrot/main.c)
  supplied a structural cross-check, not its different hardcoded `main` input.
- `mandelbrot-grid.c` follows `coverage.grid` and `coverage.grid.loop` in
  `variation-mandelbrot-grid-{4-7,5-31}.bend`. It samples each grid-cell center,
  computes that pixel independently, and accumulates its position-weighted
  escape time. It does not run the histogram renderer merely because both
  fixtures include that unused source. `a` is grid depth and `b` is the number
  of iterations.
- `scalar-region.c` follows `bench` in `scalar-region-{0,8192}.bend`.
  It derives signed fixed-point coordinates from the seed and executes exactly
  `a` rounds of the same `mit` recurrence. It does not replace an interior point
  with the iteration count or stop work when a point escapes.
- `mandelbrot-core.h` holds the genuinely shared `mit`, `pix`, bucket, and word
  helpers. Pin this header along with each including translation unit.
  Tail recursion becomes a loop; the two non-tail tree reductions remain trees.
  Signed 8.8 values stay in unsigned 32-bit words. Arithmetic right shift uses
  explicit sign extension, avoiding the upstream C twin's implementation-defined
  signed shift. Shifts of 32 or more yield zero, and U32 division by zero yields
  zero, matching the language intrinsics.
- `local-fold.c` follows `fold.step`, `fold.cell`, `fold.loop`, and `bench` in
  `local-fold.bend` and both `variation-local-fold` fixtures. Every invocation
  allocates and initializes 128 words, then performs the ordered read, accumulator
  addition, and XOR write for every step. Both read and write wrap the slot with
  127; the XOR uses the full unmasked index. It frees the allocation before
  returning. A flat uniquely owned word buffer replaces the abstract Array and
  transient tuple transport; this is a representation difference, not a claim
  that C performs Bend's runtime ownership checks. Allocation failure aborts
  rather than returning a fabricated benchmark value.
- `numeric-recurrence.c` follows `p37.numeric` and `bench` in
  `coverage-numeric-recurrence-{256,1024}.bend`. Each multiply, subtract, division,
  and final scale rounds separately to binary32 before the next dependent
  operation. The word hash observes every iteration. Compile with
  `-O3 -ffp-contract=off`, no fast-math, IEEE binary32 `float`, and the normal
  round-to-nearest environment. Float-to-word conversion has the same range
  guard as the current runtime, so out-of-range/NaN conversion never invokes C
  undefined behavior. This kernel has no dynamic storage.

All word operations use `uint32_t` on the target's ordinary 32-bit unsigned
integer model; sums/products wrap modulo 2^32. Decrementing Nat loop counts
originating from U32 use an equivalent nonnegative word countdown. Mandelbrot
tree depths use `uint64_t`, including `a + 6`, so no spurious U32 wrap is
introduced into that Nat addition; these depths remain below the Nat48 limit.
Exponential rendering work remains exponential, so huge depth inputs are not
practical resource controls. C compilation may optimize ordinary expressions,
but no algebraic formula or precomputed pixel/array result replaces a kernel.

## Source references and checks for root

Fixture paths above are relative to `selfhost/tools/bench/`. Word division,
shifts and F32 intrinsics are in `bend2/comp.ts` near lines 148–195 and
`f32_to_u32` near line 3662. Array index wrapping is explicit in
`bend2/base.bend` definitions `Array.get.at` and `Array.swap.at`.

| Catalog ID | Inputs `(a,b)` | Fixture result |
| --- | --- | --- |
| mandelbrot | (2,0) | 887240761 |
| variation-mandelbrot-grid-4-7 | (4,7) | 3135859970 |
| variation-mandelbrot-grid-5-31 | (5,31) | 2471659814 |
| local-fold | (4096,17) | 2339999928 |
| variation-local-fold-128-0 | (128,0) | 0 |
| variation-local-fold-8192-123 | (8192,123) | 805701512 |
| scalar-region-0 | (0,524800) | 0 |
| scalar-region-8192 | (8192,524800) | 8192 |
| coverage-numeric-recurrence-256 | (256,17) | 2747714257 |
| coverage-numeric-recurrence-1024 | (1024,123) | 1376326140 |

Useful additional comparisons with the actual Bend entry:

- Local fold: sizes 0, 1, 127, 128, 129, and 257; seeds 0, 1, and 0xffffffff.
  These distinguish initialization, first wrap, updated-cell reads, and wrapping
  arithmetic. Size zero still initializes and frees the array in the C source.
- Scalar region: sizes 0, 1, 2, 7, and 31 at seeds 0, 524800, and 0xffffffff;
  cover an escaping point and the origin, not just the catalog's interior point.
- Mandelbrot: depths 0, 1, 2, and 3 with differing ignored seed values; retain
  full two-pass checksum validation. The grid should cover depths 0, 1, 4, 5,
  16, and 32, and iteration counts 0, 1, 7, and 31. Depths 16/32 exercise the
  source's wrapped zero pixel count without a large work allocation.
- F32 recurrence: sizes 0, 1, 2, 31, 256, and 1024; seeds 0, 17, 96, 97, 123,
  and 0xffffffff. Size zero returns the original seed through the algorithm.
  Any mismatch calls for checking floating contraction/rounding flags first;
  no tolerance or approximate-output comparison is appropriate.
