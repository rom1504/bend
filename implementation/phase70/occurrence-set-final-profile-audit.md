# Occurrence insertion: final-profile audit and causal screen

Status: source/data audit complete; causal screen prepared, not yet executed.
The ten-line occurrence insertion change is semantically qualified by the exact
helper controls but currently has no isolated measured compilation-speed win.
The whole compiler02 request regression cannot be assigned to this change from
these saved profiles alone.

## Saved-profile comparison

The baseline is checked Phase69 typed10; current is checked Phase70 compiler02.
The identical data-only reducer `compiler-work/profile-uses.py` verifies saved
profile hashes against each original summary before counting stack unions.
Results are saved in `compiler-work/uses-profile-v2.json` and
`build/phase70/compiler02-occurrence-profile-audit01.json`.

All numbers below are sampled milliseconds from one observation, not clean
request medians or estimates of a causal effect. The collector union includes
`nc_uses`, `nc_uses_term` and `nc_uses_list`; membership-only queries are excluded.

| Case | Collector before → after | Index work inside collector | Index insertion | Index join |
| --- | ---: | ---: | ---: | ---: |
| B2 Numeric | 133.159 → 153.049 | 80.900 → 70.454 | 69.635 → 67.415 | 33.804 → 33.841 |
| B2 Array | 120.708 → 153.291 | 52.747 → 55.629 | 45.541 → 48.732 | 24.362 → 27.821 |
| B2 Lexer | 135.031 → 147.820 | 68.504 → 71.051 | 55.283 → 67.888 | 28.968 → 33.966 |
| B1 Numeric | 343.348 → 375.392 | 6.133 → 9.510 | 4.121 → 3.536 | 0 → 3.178 |

The B1 index attribution is incomplete: anonymous continuation and `run_loop`
frames account for 327.111 ms before and 361.568 ms after. B1 cannot be compared
to B2 index costs using those visible helper frames. No actual production-input
duplicate frequency is present in these profiles. An increase in a sampled
helper total is not a count of added calls.

The complete profiled B2 Numeric/Array/Lexer requests were
1680.446/1720.787/2181.858 ms before and
1760.567/1765.292/2168.929 ms after. B1 Numeric was
2527.223 → 2707.789 ms. The collector change therefore does not explain the
whole request movement; separate observer work and code-layout/JIT effects are
confounders. GC samples likewise do not show a clear general allocation saving.

## What the source and controls establish

The exact helper controls prove that repeated insertion avoids rebuilding the
same path, while all-unique insertions retain the original insertion work.
For the synthetic repeated-single case, leaf construction is 64 → 1 and
index insertion calls 63 → 0; all-unique 67-ID controls preserve 67 leaves and
1,008 recursive insertion calls. These synthetic controls prove the mechanism,
not that ordinary compiler inputs repeat IDs frequently enough to benefit.

The checked B1 image has a concrete competing cost. Its new nonempty path calls
`nc_uses_put_mask`, whose conditional emits a `run_tail` continuation; the old
`index_set` path immediately returned `index_insert`. Every nonempty insertion
pays this extra step, including novel IDs. B2 lowers that helper to a direct
conditional, so this overhead may differ by stage. The source algorithm still
performs one existing-tip lookup, not two. The observed B2 `index_join` work
stays roughly flat, consistent with much unavoidable insertion of novel IDs,
but sampled profiles cannot establish the duplicate fraction.

## Isolated diagnostic prepared

`compiler-work/derive-occurrence-ablation-v1.py` derives saved B1/B2 JS images
that change only the `nc_uses_term` call back to
`index_set(uses, marker, id, 32)`. It validates original pins, uses the exact old
function (with B2 generated binder IDs renamed), verifies the explicit expected
replacement, preserves every byte outside that function, and checks exact
reverse recovery. Results, two tiny source patches and all hashes are in
`build/phase70/occurrence-ablation-images01/derivation.json`.

No helper definition is removed in this diagnostic, so the experiment isolates
the insertion mechanism while keeping compiler02 layout as close as possible.
These files are diagnostic generated images and cannot be shipped as checked
Bend compiler builds.

Before targets, P70-006 registers the decision threshold and the joint factorial
with the observer-ready experiment. Three rounds compare occurrence on/off for
each observer state and B1/B2. Within an observer state, C must be byte-identical.
Retain the extra ten Bend lines only with at least a 1% aggregate gain, no stage
regressing over 1%, and a favorable direction in at least two of three paired
rounds per stage; an uncertain or smaller effect favors the simpler source.
Root owns target execution and any checked-source successor. This lane ran only
CPU0 source/data operations and made no production edits or commits.
