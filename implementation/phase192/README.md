# Phase192: compose verified recursive regions in direct x86

**Generated-program runtime improves19.67% geometrically**, from2.749665× to
2.208723× our mature C target in freshly paired measurements of all44 timed
native45 cases. The35 timed held-out cases improve18.59%; all45 expected outputs
pass. Parity remains unmet. Source commit `21918bf` is frozen, and native
self-reproduction is still running. Installed Phase189 and qualified Phase191
remain untouched.

The most important discovery is architectural: our shared native pipeline
already produced checked P114H recursive-region plans, but direct x86 ignored
them. QBE used those plans to keep descent and continuation resumption inside a
local loop. The new206-line x86 consumer reuses their legality checks, canonical
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
1,803,092bytes/41,468lines, SHA256
`301435947ae813b64eebaf30610d2be4aa3be5b7ddd772bd0e68f1b6aac48c20`.
Compared with Phase191 this adds56,955bytes and1,197 assembled lines. The four
maintained new modules total576lines; additional assembled growth includes
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
| expression32 |0.4302| First H-region screen; approximately1.15× C |
| lexer |0.5240| First H-region screen; dispersion retained |

The maintained integration reproduces the three H-prototype objects exactly.
Shared-address and predicate effects have actual machine witnesses but no
isolated runtime credit; see [pass economics](../../research/phase192/pass-economics-audit.md).

Rejected or deferred experiments remain reproducible:

- **Scoped continuation-frame expansion:** removed all six selected frame-helper
  sites. Six balanced rounds versus plain H gave tree0.9801, expression0.9604,
  lexer1.0168. Lexer gained nine instructions and outgoing-argument snapshots
  because register placement changed. A helper call disappearing was not enough
  to justify the extra shared traversal machinery. Default-off objects were
  byte-identical; independent review also tightened duplicate-allocation guards.
- **Bounded path facts/value identities:**17 compiler-data and2,873 C observations
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

The frozen split has9 development and36 held-out programs;44 of45 have nonzero
work for ratios. Held-out means withheld from this campaign's tuning, not new
algorithms. Runtime comparisons retain every workload, dispersion and regression;
C means our mature Bend C backend, not handwritten C or compilation throughput.

## Full-suite runtime

The [full table](runtime-summary.md) and [authenticated data](runtime-summary.json)
retain all44 eligible cases and nine dispersion flags. Four roles ran four
position-balanced rounds. A C-reference calibration stopped after30 admitted
cases; only the remaining15 were run again. The authenticated join preserves
both original reports, exact policy and all completed measurements. Independent
reanalysis checks582 retained pilots and720 timed observations. The incomplete
calibration attempt remains evidence; it contributes no runtime ratio.

| Metric | Phase191 | Phase192 |
|---|---:|---:|
|44-case geometric runtime / C |2.749665|2.208723|
|35 held-out cases / C |2.613669|2.127884|
|Mean positive log slowdown vs C |1.134097|0.907716|
|Cases above1.1× C |40|36|
|Cases above2× C |37|32|
|Equal weight per22 families / C |2.795918|2.312123|
|Fixed-catalog work, seconds |34.2552|27.5701|
|Positive fixed-work excess over C, seconds |24.1669|17.4805|

The equal-family improvement is17.30%; fixed-work time falls19.52%. Mature C
takes10.2550 fixed-work seconds; QBE takes16.6477 and scores1.350141× C
geometrically. New x86 remains approximately1.636× QBE. The diagnostic positive
log metric improves even without credit from programs already faster than C.
[Family diagnostics](family-summary.json) preserve each group and denominator.

The largest regression is closures256,1.26367× previous runtime; closures64 is
1.09643×. Both remain much faster than C and remain in every aggregate. Exact
inspection finds the repeated callback's102bytes/28instructions identical,
and the enclosing loop unchanged after relocation normalization. Its address
moves126bytes and branch alignment changes. Placement is a leading hypothesis,
not a measured causal explanation. See the [regression audit](../../research/phase192/closure-regression-audit.md).
Other small regressions and all flagged cases appear in the full table.

The [static coverage](region-coverage.json) shows non-String.length H workers in
27/45 programs. This is emitted capability coverage, not a dynamic frequency
or a claim that every admitted worker produced a speedup.

## What the post-change profiles teach us

[Fresh profiles](../../research/phase192/post-h-profile-assessment.md) independently
recompute all12 raw analyses and admit six pooled workloads with570–606 samples,
zero lost samples and preserved unknown PCs. Individual captures remain below
the500-sample threshold; pooling only joins periods of the exact same workload.
No cache-miss or hardware-stall counters were collected.

Dispatch/continuation attribution falls sharply. Absolute constructor/take CPU
stays roughly149→159microseconds in tree and179→177 in lexer. Those fractions
are now larger because other work disappeared. They are not all removable cost.
The next strongest experiments are checked ownership/allocation fast paths and
more direct local control inside H workers. Lexer generator alone now has about
198microseconds of sampled CPU per invocation, while its ready helper is much
closer to C. A small per-definition value identity experiment remains promising
for mixed F32/integer homes, but is not the demonstrated cause of every gap.

The profiler's sampler/transport/analysis machinery is host tooling; the new
semantic-IR capture runs checked Bend exports. No claim is made that the entire
profiler is written in Bend. The offline profile recomputation uses the maintained
Python analyzer and ELF metadata, not an independent formal or Bend proof.

## Remaining qualification

Complete native N1→N2→N3, native64/runtime10, native45 product equivalence and
paired compiler-request timing. Independent checking of the complete maintained
source now passes. Six corrected ordinary source controls pass together through
both machine routes. The additional scoped reentry observer passes84 observations
per route after proper normal runtime activation; the optional scoped optimization
remains excluded for profitability. Keep the qualified baseline and installed
selection intact until the final qualification decision.
