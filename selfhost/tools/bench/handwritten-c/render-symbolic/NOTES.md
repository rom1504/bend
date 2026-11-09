# Native45 render and symbolic C counterparts

Each mapped source exports only `uint32_t bench_u32(uint32_t a, uint32_t b)` as
its public entry and has no `main`. Build it as a separate C11 translation unit
from the common driver, without LTO. The ray sources require `-lm`, binary32
`float` evaluation, `-ffp-contract=off`, and no fast-math. Pin the shared
`ray-kernel.h` as well as the mapped `.c` source when recording build inputs.

The implementations adapt the handwritten twins in
`bench/runtime/raytrace/main.c` and `bench/runtime/symreg/main.c`. A source diff
against the catalog fixtures confirmed that their original Bend algorithm
prefixes match the corresponding `bench/runtime/*/main.bend`, apart from the
catalog's renamed original entry and one trailing blank line. The benchmark
entry adapters below come from the catalog, not the twins' large fixed `main`.

| Catalog ID | Arguments `(a,b)` | Fixture's expected U32 |
| --- | --- | --- |
| raytrace | `(80,0)` | 402971 |
| variation-ray-active-64-2440 | `(64,2440)` | 1457676559 |
| variation-ray-active-256-2240 | `(256,2240)` | 2166930202 |
| symreg | `(6,42)` | 2490246820 |
| variation-symreg-4-17 | `(4,17)` | 2759212979 |
| variation-symreg-7-123 | `(7,123)` | 3769601746 |

These numbers are copied from the Bend fixtures for root's comparison; none is
embedded in a C kernel. This directory was prepared and reviewed without
compiling or running a target. No output or performance qualification is claimed.

## Ray kernel and adapters

The references are
`selfhost/tools/bench/catalogs/native45/fixtures/raytrace.bend:91` (`isect5`),
`:163` (`nearest`), `:215` (`nearest.t`), `:239` (`trace`), `:305` (`pixel`),
`:324`/`:332` (column/row folds), and `:356` (`bench`). Both active variations
add the same `coverage.active.loop` at line 364 and `coverage.active` at 372.

- The nine-sphere scene, near-root quadratic, strict epsilon comparison,
  descending sphere order 8 through 0, and strict nearest-distance comparison
  are retained. Equal distances therefore retain the earlier descending-order
  winner. Shadow probes still inspect all nine spheres.
- All arithmetic is `float`, with the original parentheses. In particular,
  dot products are left-associated; supersample addition is
  `(l1+l2)+(l3+l4)`; intermediate bounce accumulation is
  `acc + ((w*lum)*(1-kr))`; the final level is `acc + w*lum`. Depth four means
  up to five shaded hits. Misses return the current accumulator immediately.
- The C decimal constants are the same binary32 values as the fixture's
  single rounded divisions of small exact integers. `sqrtf`, individual
  divisions, and the branch-based clamp preserve the source operations.
  The float-to-U32 conversion additionally guards NaN before a C cast; the
  finite clamped result is always in `[0,255]`. This avoids C's undefined
  out-of-range conversion without changing ordinary pixels.
- `raytrace.c` fixes 64 rows, takes width from `a`, and ignores `b`, exactly as
  `bench` does. Half-width uses integer division before float conversion.
  It preserves the actual balanced `rowf` depth-six and `colf` depth-fourteen
  recursion, with the same parameter order and left-then-right child calls.
  Both odd index multipliers and all 16,384 column leaves per row remain,
  including the `x < width` test and inactive zero results. Every internal node
  performs the wrapping U32 child addition, including sums involving inactive
  leaves. No manual flattening or zero-reduction elimination is applied; Clang
  may optimize this source automatically. The earlier flat-loop draft was
  corrected before C acquisition and does not qualify as the primary baseline.
- `ray-active.c` starts at `b`, renders each of `a` positions, and updates
  `acc = acc * 16777619 + pixel`. Position increment wraps as U32. Its image
  coordinates always use `%80` and `/80`, with half-width 40 and half-height
  32; these are independent of the count. Both active IDs use this one source.

The sphere table is immutable. There is no heap allocation or mutable retained
state, and every call recomputes all requested pixels and rays.

## Symbolic regression

The reference is `selfhost/tools/bench/catalogs/native45/fixtures/symreg.bend`:
`prng` at 51, `gen` at 88, `eval` at 98, `esize` at 114, `floop` at 130,
`cand` at 140, `pick` at 146, `batch` at 152, `climb` at 161, and `bench` at
190. The two variation fixtures differ only in driver arguments and expected
result, so all three IDs map to `symreg.c`.

- `a` is the tournament depth, `b` is the seed. Every population leaf and each
  of the 32 climb rounds constructs an actual depth-five expression tree from
  the xorshift stream. No expression is replaced by a formula or seed lookup.
- The original C twin's global arena becomes a fresh automatic 64-node arena
  inside each candidate evaluation. A full depth-five tree uses 63 nodes;
  the arena's counter is reset before construction, and no tree pointer escapes
  the candidate. There is no heap allocation to free and no state shared across
  candidates or benchmark invocations.
- The recursive interpreter reads the materialized tree for all 16 points in
  descending order 15 through 0. The parsimony calculation recursively counts
  its actual nodes; it is not replaced by a constant penalty.
- All seeds, hash steps, fitness values, checksums, subtractions and products
  use `uint32_t`, hence modulo-2^32 arithmetic. Fitness comparisons are
  unsigned. `value_select(0,x,y)` selects `x`: reversing this unusual helper
  would invert the tournament and hill-climb behavior. Tournament ties select
  the right candidate; hill-climb ties preserve the incumbent.
- Both candidate seed hashing stages, the two distinct population branch
  recurrences, mutation factors from 32 down to 1, and the population checksum
  are retained. The final result adds the climbed winner hash to that checksum.

Native stack arenas and ordinary structs replace Bend ownership/constructor
representation. Sequential child calls replace parallel evaluation syntax while
retaining the balanced ray reduction tree. These are representation/scheduling
choices, not changed algorithms;
they are part of the handwritten-C comparison rather than a claim about an
identical allocation mechanism or generated machine code.

## Root-owned checks before measurement

First compare all six catalog inputs above with the independently compiled Bend
fixtures. Then use the existing root driver/oracle route for small noncatalog
checks; the following are proposed checks, not recorded passes:

- Ray full image: width 0, width 1, width 2, and odd width 81. Compare `(80,0)`
  with `(80,4294967295)` to check the ignored seed.
- Ray active: `(0,2440)`, `(1,2440)`, `(2,79)` across a row boundary, and
  `(2,4294967295)` across the U32 position wrap. Do not interpret the zero-count
  result as a representative runtime workload.
- Symreg: depths 0 and 1 with seeds 0 and 4294967295, plus the six catalog
  comparisons. Depth zero still evaluates one population candidate and all
  32 climb rounds.
- Alternate argument pairs and repeat the original pair within one process to
  check invocation independence. Build/link each implementation separately
  with the driver, and preserve the required floating-point flags.
