# Phase192: compose verified recursive regions in direct x86

**Generated-program runtime improves 19.67% geometrically**, from 2.749665× to
2.208723× our mature C target in freshly paired measurements of all 44 timed
native45 cases. The35 timed held-out cases improve 18.59%; all 45 expected outputs
pass. Parity remains unmet. Source commit `21918bf` is frozen and native qualification is complete.
Installed Phase189 and the previous qualified Phase191 remain untouched.

The most important discovery is architectural: our shared native pipeline
already produced checked P114H recursive-region plans, but direct x86 ignored
them. QBE used those plans to keep descent and continuation resumption inside a
local loop. The new 206-line x86 consumer reuses their legality checks, canonical
renaming, runtime stack layout and existing typed machine lowering. It needs no
new recursion recognizer or global SSA representation.

## What changed

| Selected capability | Work eliminated | Correctness boundary |
|---|---|---|
| Verified recursive regions | Public scheduler transitions between admitted recursion and closed continuation cases | Original H readiness, hygiene, arity and closure limits; explicit runtime frame depth, capture restoration and fallback; no recursive native self-call |
| F32/U32 conversions composed with value lowering | Generic conversion calls and staging stores that previously prevented private-buffer elimination | Exact ABI11102 low-word and MXCSR behavior, including COMISS; original rounding points and checked typed instruction encoding |
| Shared scaled addresses | A repeated scale multiply and transport copy in actual local-fold; repeated address materialization in other helpers | Bounded def/use and mutation certificate, unchanged ordered loads/stores and fallback |
| Predicate normalization | Boolean copy diamonds and compare-to-Boolean-to-compare chains | Proven finite Boolean values, pure matched copies, exact widths; calls and unresolved joins discard facts |

Compiler algorithms remain Bend. Both direct ELF and rendered assembly consume
the same typed instruction sequence. The selected assembled source is
1,803,092 bytes/41,468 lines, SHA256
`301435947ae813b64eebaf30610d2be4aa3be5b7ddd772bd0e68f1b6aac48c20`.
Compared with Phase191 this adds 56,955 bytes and 1,197 assembled lines. The four
maintained new modules total 576 lines; additional assembled growth includes
previously unretained canonical H dependencies. This is a capability gain with
source growth, not a line-count reduction. All five other source profiles remain
byte-identical in the canonical closure audit.

## Evidence and research decisions

The [independent architectural survey](../../research/phase192/architectural-survey.md)
compares scalar, F32, tree, expression, lexer and Map evidence with primary LLVM,
QBE, Zig and Rust sources. Fresh physical profiles falsify a register-only
explanation: expression's named evaluation leaf was already close to C, while
its complete computation paid heavily for continuations and dispatch. Static
instruction counts alone would have ranked the wrong work.

Initial development screen, not the full-suite claim:

| Workload | Selected experiment / Phase191 | Scope |
|---|---:|---|
| numeric-recurrence256 |0.5143| Conversion/value composition; nine-case screen |
| tree-bitonic |0.6769| First H-region screen |
| expression 32 |0.4302| First H-region screen; approximately 1.15× C |
| lexer |0.5240| First H-region screen; dispersion retained |

The maintained integration reproduces the three H-prototype objects exactly.
Shared-address and predicate effects have actual machine witnesses but no
isolated runtime credit; see [pass economics](../../research/phase192/pass-economics-audit.md).

Rejected or deferred experiments remain reproducible:

- **Scoped continuation-frame expansion:** removed all six selected frame-helper
  sites. Six balanced rounds versus plain H gave tree 0.9801, expression 0.9604,
  lexer 1.0168. Lexer gained nine instructions and outgoing-argument snapshots
  because register placement changed. A helper call disappearing was not enough
  to justify the extra shared traversal machinery. Default-off objects were
  byte-identical; independent review also tightened duplicate-allocation guards.
- **Bounded path facts/value identities:**17 compiler-data and 2,873 C observations
  per machine route passed. No runtime benefit was measured, so it is excluded.
- **Wider floating regions:** static inspection found that reused local names mix
  F32 and integer definitions. Merely extending region boundaries still triggers
  the existing conservative exclusions; a per-definition identity experiment is
  more informative than another larger permissive region.

[Scoped machine evidence](../../research/phase192/scoped-frame-machine-work.md)
shows why smaller local code can create more transport elsewhere. Negative
results, failed fixtures and resource refusals are retained, not relabeled.

## Validation and trust

See [correctness boundaries](correctness-boundaries.md) for exact receipts and
[test methods](../../selfhost/tests/phase192/README.md). Checked compiler-data
controls, independent C observations, source checking, benchmark outputs and
native self-reproduction establish different properties. None is a general
compiler-correctness theorem or evidence of recursive research acceleration.

The frozen split has9 development and 36 held-out programs;44 of 45 have nonzero
work for ratios. Held-out means withheld from this campaign's tuning, not new
algorithms. Runtime comparisons retain every workload, dispersion and regression;
C means our mature Bend C backend, not handwritten C or compilation throughput.

## Full-suite runtime

The [full table](runtime-summary.md) and [authenticated data](runtime-summary.json)
retain all 44 eligible cases and nine dispersion flags. Four roles ran four
position-balanced rounds. A C-reference calibration stopped after 30 admitted
cases; only the remaining15 were run again. The authenticated join preserves
both original reports, exact policy and all completed measurements. Independent
reanalysis checks582 retained pilots and 720 timed observations. The incomplete
calibration attempt remains evidence; it contributes no runtime ratio.

| Metric | Phase191 | Phase192 |
|---|---:|---:|
|44-case geometric runtime / C |2.749665|2.208723|
|35 held-out cases / C |2.613669|2.127884|
|Mean positive log slowdown vs C |1.134097|0.907716|
|Cases above 1.1× C |40|36|
|Cases above 2× C |37|32|
|Equal weight per 22 families / C |2.795918|2.312123|
|Fixed-catalog work, seconds |34.2552|27.5701|
|Positive fixed-work excess over C, seconds |24.1669|17.4805|

The equal-family improvement is 17.30%; fixed-work time falls19.52%. Mature C
takes 10.2550 fixed-work seconds; QBE takes 16.6477 and scores1.350141× C
geometrically. New x86 remains approximately 1.636× QBE. The diagnostic positive
log metric improves even without credit from programs already faster than C.
[Family diagnostics](family-summary.json) preserve each group and denominator.

The largest regression is closures256,1.26367× previous runtime; closures64 is
1.09643×. Both remain much faster than C and remain in every aggregate. Exact
inspection finds the repeated callback's 102 bytes/28 instructions identical,
and the enclosing loop unchanged after relocation normalization. Its address
moves 126 bytes and branch alignment changes. Placement is a leading hypothesis,
not a measured causal explanation. See the [regression audit](../../research/phase192/closure-regression-audit.md).
Other small regressions and all flagged cases appear in the full table.

The [static coverage](region-coverage.json) shows non-String.length H workers in
27/45 programs. This is emitted capability coverage, not a dynamic frequency
or a claim that every admitted worker produced a speedup.

## What the post-change profiles teach us

[Fresh profiles](../../research/phase192/post-h-profile-assessment.md) independently
recompute all 12 raw analyses and admit six pooled workloads with 570–606 samples,
zero lost samples and preserved unknown PCs. Individual captures remain below
the 500-sample threshold; pooling only joins periods of the exact same workload.
No cache-miss or hardware-stall counters were collected.

Dispatch/continuation attribution falls sharply. Absolute constructor/take CPU
stays roughly 149→159 microseconds in tree and 179→177 in lexer. Those fractions
are now larger because other work disappeared. They are not all removable cost.
The next strongest experiments are checked ownership/allocation fast paths and
more direct local control inside H workers. Lexer generator alone now has about
198 microseconds of sampled CPU per invocation, while its ready helper is much
closer to C. A small per-definition value identity experiment remains promising
for mixed F32/integer homes, but is not the demonstrated cause of every gap.

The profiler's sampler/transport/analysis machinery is host tooling; the new
semantic-IR capture runs checked Bend exports. No claim is made that the entire
profiler is written in Bend. The offline profile recomputation uses the maintained
Python analyzer and ELF metadata, not an independent formal or Bend proof.

## Native qualification and compiler cost

The [qualification evidence](evidence.json) records complete independent source
checking,64 backend cases,10 runtime controls, and 45 benchmark outputs from N2.
All 45 checked-hosted/N1 objects and 135 linked code/data sections match; all 45
N1/N2 products also match. N2 reproduces the complete N2 object through N3.
This transfers the measured program-runtime result without another timing run.
The fixed point is an object comparison, not a whole-executable byte comparison
or a semantic correctness theorem.

Qualified N2: `selfhost/build/phase192/native-self01/program`, with its adjacent
`report.json`. Executable SHA256:
`8065c04b7005e0d942653ffe330fb5e7a3ac396227dd38f02160dea631685b01`.
Its object is 28,796,936 bytes and executable23,759,472 bytes, respectively 3.19%
and 3.11% larger than Phase191. Installed selection remains unchanged.

The [paired compiler-cost screen](compiler-cost-summary.json) uses the frozen
Phase191 and Phase192 N2 executables, identical sources and preparation, two
balanced rounds, and complete exact-object oracles for each role. It excludes
linking and program execution; process startup, checking, lowering and object
emission are included.

| Fixed request | Phase191 median seconds | Phase192 median seconds | Ratio |
|---|---:|---:|---:|
|numeric256 |1.32135|1.27661|0.96614|
|expression 32 |1.44922|1.37573|0.94929|
|tree-bitonic |1.84189|1.84271|1.00045|

The three-request geometric ratio is 0.97173,2.83% less time. All12 complete
outputs match their own frozen objects. Peak RSS ranges 40.5–43.6 MiB. This small
screen is not a broad compiler-throughput claim or evidence of significance.

| Full native operation | Phase191 seconds | Phase192 seconds |
|---|---:|---:|
|Native QBE seed acquires N1 |160.167|167.904|
|QBE-produced N1 emits direct-object N2 |242.093|254.875|
|Direct-x86 N2 emits/reproduces N3 |342.329|354.521|

These are historical acquisition observations on different compiler sources,
not a controlled same-source speedup. The larger Phase192 source adds 3.26% bytes
and 2.97% lines, and full self-build time is higher. Within the selected source,
N2's observed self-request is 1.391× N1's; that is a compiler-executable comparison,
not the native45 generated-program ratio. No full-build speedup is claimed.

## Research cost, failures and next step

The [cost ledger](cost-final.json) counts 61 guarded jobs:45 succeeded,16 failed,
plus two pre-admission failures. Recorded guard wall time totals46.43 minutes,
including 6.46 minutes in failed jobs. Most of the largest failed job is the
runtime02 calibration interruption, whose30 fully admitted cases were retained;
that duration is not all wasted work. Native qualification takes 18.71 minutes
including orchestration. These durations are not total research wall time,
agent effort, token consumption or billing; unavailable quota data is not inferred.

The first source-control harness retained host IR while starting native children
and hit its 2 GiB guard. Scoping that data and collecting before child execution
reduced the subsequent peak to 383 MiB. Corrected source fixtures fix a do-block
syntax error and an illegally duplicated affine closure. The first scoped C
observer omitted normal runtime activation; its valid corrected observer passes
84 observations per route. The duplicate-allocation validator gap found by an
independent reviewer is fixed in the excluded scoped prototype. One premature
job was refused by the shared execution lock; one long case-list argument hit
an ENAMETOOLONG path probe before admission. Every failure remains distinguishable.

Keep the frozen candidate and its evidence. The next high-value cycle should
prototype ownership/allocation fast paths and simpler local control inside an
actual H worker, with source/machine oracles and a cheap transferable slice.
Per-definition value identity is a complementary experiment for mixed numeric
register homes. Avoid another broad optimizer framework until either demonstrates
an advantage. The present result shows that sharing an existing verified semantic
capability can eliminate broad runtime work; it does not demonstrate recursive
acceleration of optimization discovery.

Exact receipts and archive verification are indexed in [ARTIFACTS.md](ARTIFACTS.md).
