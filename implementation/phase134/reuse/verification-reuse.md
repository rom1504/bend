# Split verification cost and an isolated reuse experiment

The follow-up keeps the exact frozen source and exports three additional existing
functions: the inline transformation, range transformation and commit verifier.
Six complete outputs again equal the qualified Phase131 native QBE. The hosted
diagnostic took 36.41 s under CPU6, peaking at 516 MB; these are not native N1/N2
stage percentages.

Second-pass results:

| Request | Inline transform | Inline commit | Range transform | Range commit | Commits/backend |
|---|---:|---:|---:|---:|---:|
| Lexer | 0.770 s | 0.354 s | 0.623 s | 0.356 s | 15.7% |
| Closures | 0.010 s | 0.030 s | 0.013 s | 0.009 s | 7.1% |
| Map | 0.126 s | 0.124 s | 0.113 s | 0.139 s | 3.1% |

This falsifies the strongest interpretation of the first diagnostic: repeated
commit verification does **not** explain most inline/range time on lexer.
Actual transformations still consume 30.9% of its backend. Existing
`P114SBoundary` already retains the original-program ID context, so introducing
another cache for those IDs would duplicate an existing capability.

## Candidate and trust boundary

The isolated candidate reuses successful verification for an exactly unchanged
function inside the **same genuine verified boundary**. Before reuse, it checks
the entire ordered header list: names, parameter IDs/names/kinds, result arities
and public flags. If that list differs, it calls the original whole-function
commit path. For matching headers, changed bodies still run the existing
`p113e_function`; only structurally identical functions skip it. Ready signatures
are rebuilt in the original order. No final verifier changes.

Why this is sound within that boundary: successful opening verified each old
function against a prefix of previously admitted signatures. Those signatures
depend only on headers, not callee bodies. Equal ordered headers therefore give
the same ready context at every position. The original IDs remain unchanged.
An exactly unchanged function has the same complete verification input; a changed
function is independently checked again. The first error still rejects the whole
candidate as before.

An independent source audit found complete field coverage for all nine scalar
statement variants, five direct variants, three scalar types, five value variants
and four binding kinds. It also checked all actual boundary constructors.
Additional controls cover changed earlier callee bodies, unchanged later callers,
public flags, runtime symbols and argument types.

This is **not a trusted arbitrary-boundary API**. `valid: Bool` is not an
unforgeable proof. A caller could fabricate an invalid boundary with `True`;
equivalence to the original commit function is not claimed for that input. The
closed experimental entry obtains its boundary from existing `p114s_open_lowered`
and prior successful commits; the unchanged independent final verifier remains
mandatory. Diagnostic exports are internal testing interfaces, not public cache
artifacts.

The candidate introduces no persistent cache, cross-revision state or new data
types. Its equality and context checks are charged in timing. Whether their cost
is lower than the avoided verification must be measured before integration.

## Checked experiment results

`verify-source04` independently passes source checking; all 26 finite controls
pass. An earlier check rejected missing duplication annotations in the diagnostic
counter's two captured list tails. The fix changes that counter only; the audited
equality and commit implementation remain unchanged. The failed check is retained.

All six paired three-case measurements produce exactly the frozen native QBE.
The same checked API calls the original commit and the new commit on identical
inputs, alternating order in the second pass. Equality scans, header checks,
ready-index reconstruction and changed-body verification are inside candidate
timing. Extra diagnostic comparison/counters are outside those timed calls.

| Request | Commit reuse/original, two-pair geometric ratio | Unchanged functions at inline commit | Unchanged functions at range commit |
|---|---:|---:|---:|
| Lexer | 0.527 | 10/31 | 30/31 |
| Closures | 0.425 | 4/7 | 6/7 |
| Map | 0.473 | 24/34 | 33/34 |

This is measured removal of repeated function verification on three unrelated
requests. It is not reuse of compiler output across source revisions. In
particular, the almost-entirely unchanged range output explains why a second
whole-function verification is expensive relative to useful new validation.

The real lexer edit changes `prng`'s shift from 13 to 12. The unchanged request
first reproduces the frozen native product. For the edited request, independent
fresh compilation through the original pipeline and the candidate complete
pipeline produce identical 577,297-byte QBE with SHA-256
`a2e4c548b86fb1a3b7915d24eb6934315a9752e944f39e19df01e0b4814b48e8`.
Four balanced hosted pairs give candidate/fresh ratios **0.813, 1.036, 0.886,
0.967**: geometric ratio 0.922, median times 4.349 versus 4.673 seconds. The
initial two-pair experiment was mixed (0.826 and 1.021) and is also retained.
These observations support a modest whole-request gain while showing noise and
order effects. They do not establish native speed, statistical significance or
an across-edit cache speedup.

The independently audited integration module is only 124 physical lines,
introduces no types, and changes only `p114s_inline`/`p114s_ranges` to call the new
commit helper. The original `p114s_commit` remains unchanged as fallback; the
entire final verifier remains unchanged. That module is separate from the
experimental counter, controls and full-request adapter. The final composed
candidate must run all 26 controls against its actual integrated definitions;
passing only the earlier isolated source is insufficient.

The exact candidate for native acquisition is now frozen as
`verify-selected-source01/compiler.bend`, SHA-256
`a00019246b5181b288ab4d3e09e616bd41415fe6381e89a96185c05efa19fb57`.
It combines the no-copy writer, the 124-line verification core and its separate
controls, without range memo machinery. Its actual source passes independent
checking, all **59 controls** (26 reuse, 18 optimizer, 15 emission), and all three
frozen full-output/cursor comparisons. Native qualification and native request
timing remain necessary before selection.

The next stronger opportunity is now explicit: `p113i_function_done` already runs
the range pass internally, then the outer pipeline runs ranges again. An exact
input/output record could avoid a duplicate pure transformation when the input
actually matches. This requires no claim that the pass is idempotent; mismatches
must run the original pass. It is a separate experiment, not part of these gains.

## Reproducible evidence

- [Split-stage timings and six frozen products](phase134/stage-split01/report.json).
- [Checked candidate API](phase111/p134-verify-api02/report.json) and
  [26 finite controls](phase134/verify-finite01/report.json).
- [Six paired commit observations](phase134/verify-stages01/report.json).
- [Initial edited request pairs](phase134/verify-edit01/report.json) and
  [four balanced pairs](phase134/verify-edit02/report.json).
- [Independent source audit](../../../selfhost/tools/performance/phase134/compact/verify-reuse-audit.md).
- [124-line integration module](../../../selfhost/tools/performance/phase134/reuse/verify-core-v01.bend).
- [Actual selected-source checking](phase111/p134-verify-selected-api01/report.json),
  [59 controls](phase134/verify-selected-finite01/report.json), and
  [three frozen pure/cursor comparisons](phase134/verify-selected-differential01/report.json).

The exact commands, input hashes and resource limits are retained in adjacent
guard receipts and [archive.json](archive.json). No generated APIs, native
binaries, cache trees or complete QBE products are added to this archive.
