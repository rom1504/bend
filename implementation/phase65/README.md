# Phase65: faster prepared requests and reusable Base annotations

Selected **State10 takes 1.28945× TypeScript compilation time**, down from
1.41737× for Phase64 State09 in the same controlled campaign: **9.03% less
compilation time**. All 23 source medians improve and all 207 complete module
comparisons pass. Imports plus compilation reach **0.969256× TypeScript** on
that separate clock. Compilation parity still requires about **22.45% less
time**; this phase makes no new generated-program execution-speed claim.

**Phase65 State10 is installed and verified.** The
[compiler qualification](evidence/state10-qualification.json) checks 4,171 input
identities and passes the full checked/B2, self-hosting and host gates. The
[release receipt](evidence/state10-release.json) records installation,
verification before and after CLI checks, legacy42, default24 and helper5,
with 392 verified inputs. Installed checked B1 is `3a7fedb7…`; the separately
measured and self-reproducing genuine B2 is `239f7970…`.
The [detailed State10 results](state10-results.md) contain all source timings;
the [qualification plan](qualification-plan.md) preserves the method and reuse boundaries.

Started October 8, 2026 at 00:49:17 UTC from `49431ba`, following the user's
[authorization and design](../../design/phase65/reusable-backend-products.md).
Root serializes bounded CPU3 targets; source/data/review agents use CPU0. Closed
Phase64 evidence remains immutable. An [external interruption](evidence/interruption.json)
is recorded separately from active work and validation time.

![Selected State10 compilation and import-inclusive ratios](state10-compilation-ratios.svg)

## Controlled result

| Metric | Phase64 State09 B2 | Phase65 State10 B2 | Time reduction |
| --- | ---: | ---: | ---: |
| Compilation / pinned TypeScript | 1.41737× | 1.28945× | 9.03% |
| Imports + compilation / pinned TypeScript | 1.04969× | 0.969256× | 7.66% |
| Sources faster than TypeScript, compilation | 1/23 | 4/23 | — |
| Sources faster than TypeScript, with imports | 5/23 | 10/23 | — |

The [final broad receipt](evidence/state10-b2-broad.json) measures 23 sources,
three roles and three balanced rounds in 207 fresh processes. The headline is
an equal-source geometric mean of within-source median ratios. All 23 medians
improve on both clocks; 21 sources have nonoverlapping candidate/baseline sample
ranges. These observations are not confidence intervals. State10 compilation
ranges from 0.681× to 1.640× TypeScript across sources.

The compiler images are genuine B2, emitted by checked Bend compilers. Persistent
Base caches and the candidate sidecar are prepared before timing; identity checks
and complete output verification are outside the clocks. This is neither an
OS-cold storage measurement nor installed checked-B1 CLI latency. The 23 unique
sources map to the established 45-point program suite. Earlier State09 and
four-source campaigns retain their own denominators and are not relabeled as
final State10 results. See [measurement and profiles](measurement.md).

## What is selected

**H6: static frame4 decoder readers.** Twelve small static JavaScript readers
replace one large constructor-decoding loop. The frame schema, eager checks,
object shapes, field order and graph sharing remain unchanged. Compiler
algorithms remain in Bend; this JavaScript change is transport. The isolated
first complete decode improves **64.47 → 27.13 ms**, excluding file reading and
imports. A separate same-image four-source screen improves whole compilation
by **10.93%** before final integration. The [decoder report](decoder.md) retains
both this result and the rejected load-only predecessor.

**H2: optional checked Base annotations.** Bend produces, selects and admits
reusable annotations for Base definitions with at least **64 body terms**.
This generic threshold retains 12 products in a 438,959-byte sidecar; seven Map
annotations qualify in the initial census. Header and key checks precede heavy
body reading. Current stops take priority; absent, stale, malformed or
ineligible products retain ordinary annotation. The public annotation API and
existing prepared-world/frame schemas remain unchanged. See the
[Base product analysis](base-products.md) and [transport contract](cache-contract.md).

State10 permits both optional production and consumption only for the **exact
pinned Base content**, in addition to compiler/API/path/ABI and parent-frame
identity checks. Identical bytes copied to a different path remain eligible
under those checks; changed, custom or future Base content uses ordinary
annotation until independently qualified. This preserves demand for arbitrary
checked Base files containing unselected unsafe or TODO definitions. The
[artifact guide](../../docs/self_hosted/prepared-base-artifacts.md) documents the
permission and fallback contract.

A separate [same-B2 sidecar ablation](evidence/base-annotations-incremental-b2.json)
passes all 12 outputs: Map **−5.13%**, map-churn **−3.15%**, and no-hit Numeric
−0.46% with overlapping ranges. This uses the combined State09 B2 and H6 helper,
changing only sidecar presence. It establishes incremental artifact value on
three selected sources, not complete H2 code removal or H2's contribution to
the final 23-source mean. Separate campaign gains must not be multiplied.

## Qualification and implementation cost

Selected host controls pass: frame domain **87**, ordinary driver admission
**79**, optional product transport/custom-content checks **60**, actual owned B2
product consumption, and actual custom-Base fallback. The custom-Base test
prepares twice and compiles Map with exact output while proving that no optional
annotation demand or sidecar occurs. Full checked/B2 source96, numeric34,
composition18 and overapplication2 pass, as do native3, runtime45, fresh own-source
type acceptance and exact B2/B3 reproduction. The 3,269 unsafe definitions retain
the expected proof-trust refusal; finite suites and self-reproduction are not a
mathematical soundness proof. All installation, release-integrity and installed
CLI gates pass. The package is equality-derived checked B1; the measured genuine
B2 is a separately qualified image.

The [final size audit](size.md) and [State10 size receipt](evidence/state10-size.json)
verify all manifest inputs: **28,396 physical Bend lines in 115 modules**, up
117 lines (+0.414%), 15 definitions and one type. All 114 previous modules are
byte-identical. Host support adds **146 lines**: 83 in the driver and 63 in the
decoder helper. Genuine B2 grows 13,290 bytes (+0.329%); exports grow from 95 to
99 for the four private product APIs. This is a measured performance improvement
with additional artifact ownership contracts, not a simplification claim.

## Rejected and deferred directions

| Experiment | Decisive observation | Disposition and report |
| --- | --- | --- |
| H1 normalized annotation heads, State02 | 16 focused controls pass; two-source B1 −0.23%, below observed noise | Reject advancement; no public API redesign or B2 claim. [Typed facts](typed-plan.md). |
| H5 prepared constructor index, State03 | 15 controls pass; B1 −0.20%, below 2% advancement threshold | Reject; host/B2 qualification left unrun. [Constructor index](constructor-index.md). |
| H3 broad shallow substitution, State04 | 265 controls pass; B1 +0.20%, Map +4.24% | Reject this guard. [Term reuse](term-reuse.md). |
| Boolean constructor projection, State05 | Four-source B1 −0.63%, Lexer +3.00% | Mixed; deferred and absent from selected source. [Boolean lookup](boolean-lookup.md). |
| Leaf-only substitution, State06 | B1 Numeric +7.28%, Map −2.60%, aggregate +2.22% | Mixed; deferred and absent from selected source. [Term reuse](term-reuse.md). |
| H4 ordered-let metadata | Zero eligible groups on four actual B2 sources | Defer without a build. [Output opportunities](output-metadata.md). |
| Nested-closure output | 798 actual lowering-state entries, zero eligible arms | Defer without a build. [Output opportunities](output-metadata.md). |
| H6 case-local decoder loads | Fresh decode 62.33 → 65.29 ms | Reject; warm-call gain did not meet the fresh-request objective. [Decoder](decoder.md). |

B1 screens do not establish genuine-B2 effects. Fewer recursive substitution
entries, allocated bytes or syntactic operations did not reliably predict lower
complete-request latency. Actual activation censuses stopped two proposals
before unnecessary builds. The successful decoder change altered V8's execution
units; retained annotations removed demonstrated repeated semantic work.

## Preserved method failures and evidence index

- [State01 invalid H1 snapshot](evidence/state01-invalid-h1.json): the patch was
  restored before snapshot capture. Exact identity caught the baseline image;
  no H1 timing or correctness claim was made from it.
- [Closure observer preflight](../../selfhost/build/phase65/closure-opportunity-numeric-recurrence01/report.json):
  the first observer missed the actual shared dispatcher. The corrected
  [output census](output-metadata.md) observed 798 entries and zero opportunities.
- [Leaf controller preflight](evidence/state06-leaf-controls01-failure.json):
  an unreachable private helper was absent. The reviewed successor explicitly
  qualifies/skips that raw probe while preserving real consumer controls; see
  [term-reuse lineage](term-reuse.md).
- [H2 export declaration and controller methods](cache-contract.md): initial
  export admission stopped before compilation; a later
  [owned-controller run](../../selfhost/build/phase65/base-annotations-owned-state08-01/report.json)
  selected raw B1 and failed before product consumption. Successors preserve
  those failures and bind the qualified API rather than relabeling them passes.
- [Checked-stage resume and reuse proof](qualification-plan.md): an affinity
  preflight interrupted the original run after eleven passing commands. The
  immutable resume and explicit join cover all fourteen; the failed execution
  stays failed. The first join attempt and final program-reference adjustment
  remain separately recorded. A later B2 equality preflight required fresh
  selected-host checked-program outputs and an explicit retry; the
  [final qualification receipt](evidence/state10-qualification.json) records the
  four-command prefix and successful final command without rewriting failure.

Use [State10 results](state10-results.md) for final timings,
[measurement](measurement.md) for experiment clocks and source/profile evidence,
[qualification](qualification-plan.md) for required gates, and [size](size.md)
for the maintained-code cost. The earlier [State09 result](state09-results.md)
is historical evidence for the combined candidate before the pinned-Base guard.
The [artifact index](../../selfhost/tools/performance/phase65/artifacts/README.md)
and [manifest](../../selfhost/tools/performance/phase65/artifacts/manifest.json)
record raw-evidence packaging and preservation.
