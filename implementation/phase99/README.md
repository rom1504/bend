# Phase99: native scalar and borrowed-call experiments

Status: in progress. Design committed as `ee7664a`; Phase98 remains selected.
Compiler and program targets run serially under the existing resource guard.

## Scalar experiments: useful code change, no measured speed benefit

The first implementation separates typed scalar emission from the packed-array
certificate. It reuses existing `N_WordKind` facts and the authenticated checked
provider boundary. Source02 adds four physical lines and 269 bytes to Phase98.
Source01 is preserved: review found that `packed || observers` is necessary to
preserve all old admissions, rather than relying on `packed => observers`.

Source02 passes 21 native executions, including full-width U32/F32/Char, a 48-bit
Nat, erased fields, dependent families, generic arrays and surviving strings.
Both checked entry points agree, and changed/unknown providers plus raw/denied
paths preserve their restrictions. Only typed-scalar permission changes.
Source03 additionally marks the authenticated Base String character field as
32-bit; it adds four lines and 354 bytes. It passes the same 21 executions plus
the full-width character/alias control, including `0xffffffff` and `0x80000000`.
The tail remains a full pointer and raw/denied paths do not get the field flag.

| Experiment | Baseline median | Candidate median | Ratio | Decision |
| --- | ---: | ---: | ---: | --- |
| Typed scalar locals, 100k append repetitions | 0.24639 s | 0.24654 s | 1.00058 | Too close to the guard's timing resolution; use longer work. |
| Typed scalar locals, 1m repetitions | 2.26550 s | 2.32665 s | 1.02699 | No improvement; do not build a full image. |
| Typed scalars plus String field0, 1m repetitions | 2.30233 s | 2.36550 s | 1.02743 | No improvement; do not promote. |

Each row has four balanced baseline/candidate pairs, one CPU, identical dynamic
inputs and complete result/alias output. These are synthetic whole-process times,
not compiler-speed ratios. The roughly 2.7% regressions are observations, not a
universal slowdown claim. Generated C and exact append-continuation assembly
confirm the intended 32-bit capture and removal of the character reference-tag
branch. Simpler assembly alone did not establish a speed benefit.

Raw receipts: `selfhost/build/phase99/scalars-small01..03`, `scalars-micro01..03`,
and `full-width01`. The fixture and implementation safety review is in
[scalar-audit.md](scalar-audit.md).

Five named statements (four contracts and one support lemma) extracted from
source03 pass safe elaboration and the independent Lean kernel, with no opaque
helper assumptions. Three deliberately incorrect helpers admit alone and then
fail the unchanged laws. The contracts constrain metadata/kind transport and
opaque fallback, not the validity of runtime kinds, C narrowing or ownership.
Receipts: `scalar-laws01` and `scalar-law-negatives01`.

## Borrowed calls: small controls and measured boundary win

The [borrowed-tag audit](borrowed-tags.md) finds schema and interprocedural-call
limitations, rather than a permission switch. Current KTerm constructors have
8/8/5 fields; width is not the problem. The next bounded prototype permits calls
between already certified scalar observers using the existing String schema.
It targets the public equality boundary first. Source03 adds 123 physical lines
and 8,337 bytes. It publishes a callee certificate only after worker and adapter
admission, checks exact plain types and live caller-root ancestry, and keeps the
scalar result in a full `Term`. Ordinary owning fallback remains. General KTerm
schema expansion and virtual literal specialization remain unimplemented.

`borrowed-small04` passes 15 finite internal admission/refusal cases and 11 native
executions. Expanded `borrowed-small09` passes 18 finite cases and 13 native
executions, including aliased roots, Unicode strings, escaping-child refusal,
newly constructed single-owner inputs and the existing origin-swapping regression. Both checked entry points agree; raw,
false-permission, modified-provider and unknown-provider paths retain their
restrictions. The public String equality wrapper now has a borrowed worker that
calls the certified walker directly. These tests are not a native lifetime proof.

The retained-root equality benchmark has four balanced pairs on one CPU and
checks complete output and both surviving aliases. At 1m calls, the medians are
0.34811 s baseline and 0.30738 s candidate, but these short processes approach the
guard's 20ms resolution. The 10m-call confirmation gives **3.27932 s baseline,
3.05750 s candidate, ratio 0.93236**: about 6.8% less time. All four paired runs
improve. This warrants a native image screen; it does not establish a compiler
speedup. Raw receipts: `borrowed-micro01` and `borrowed-micro02`.

Preserved failures: source02's missing affine sharing annotation, then two aliases
fixture errors (unsupported match expression and missing String annotations).
Source03 and `aliases-v3.bend` fix those errors; no failed run is counted as a pass.
The expanded fixtures also exposed two missing constructor/list annotations and a
forward reference that upstream rejects as an unfilled definition. The corrected
`fixtures-v4.bend` and `unique-v2.bend` pass. The unique fixture's expected scalar
flag was corrected to its actual existing baseline value, 1; candidate and
baseline flags remain equal. Declaration-order/retry coverage is not claimed.

Three laws extracted from source03 prove residual argument order and complete
failure-value propagation through `nob_words_cons`. Safe elaboration and the
independent Lean kernel pass. Three admitted bad helpers fail those unchanged
laws. The bad-tail mutation corrupts the failure payload, not successful call
admission; these contracts do not prove lifetime, type authority or the complete
call analysis. Receipts: `borrowed-args-laws01`, `borrowed-args-negatives01`.

The checked native B1 acquisition took 48.47 s; its Clang build took 187.09 s,
peaking at 4.03 GiB RSS. The actual B1 six-source screen has 48 timed requests
plus 12 separate oracle emissions: request-time ratio **1.00131**, process-wall
ratio 0.97641. Short process-wall quantization precludes a speedup claim. All six
C products remain byte-identical to Phase98; all timed C/diagnostics match.
Source03 B2 now reproduces its B1's complete self C. One same-source comparison
is **142.951 s current Phase98 B2 vs 128.322 s source03 B2** (0.89766×, about
10.2% shorter); this is preliminary, not a balanced full-self estimate. Its
four-round six-source screen gives 0.97215× request time and 0.98681× process wall,
with 48 exact timed outputs/diagnostics. Own-self C gains four observer owners
(`f_eq`, `f_seed_text_equal`, `kp_eq`, `p88_string_eq`), rising from 7 to 11. All
original owned fallbacks, global representation flags and cold macros are exact.
Source-bound baseline identities and raw evidence live under
`borrowed-qualification-plan01`; inspection is `borrowed-self-c01`.

## Refined static-root route

Inspection identified a missed case: the old guard is ANY shared root, not ALL;
static literal nodes have no RFC bit and do not activate it. Source04 adds only
`OR ALL schema roots term_triv`, retaining the shared alternative first. Runtime
`term_sink` returns immediately for all newly admitted roots, so this case cannot
add a dynamic cleanup traversal. Mixed static/unique and two-unique dynamic
inputs retain the owned path. The [design](../../experiments/phase99/P99-003-static-observers.md)
and [review](borrowed-static-route.md) state the remaining authority/runtime
assumptions. Source04 adds 132 lines/8,877 bytes to Phase98 in total.

`static-small01` passes 22 finite cases and 13 native executions. Four balanced
pairs on each generated micro give:

| Workload | Baseline median | Source04 median | Ratio |
| --- | ---: | ---: | ---: |
| Static/static equality, 10m calls | 2.08293 s | 1.24146 s | 0.59602 |
| Shared dynamic equality, 10m calls | 3.25875 s | 2.94456 s | 0.90358 |

Both check complete results and retained inputs. They are synthetic execution
times, not compilation-speed claims. Six exact-source04 laws pass the independent
kernel: three residual-argument contracts and three guard-text contracts. Six
mutated helpers admit alone and fail the unchanged laws. None proves runtime RC
or the full compiler. Receipts: `static-laws01`, `static-law-negatives01`,
`borrowed-args-laws02`, `borrowed-args-negatives02`.

Source04's checked B1 image and six-source screen pass: 0.99826× request time,
48 exact timed outputs/diagnostics. Its B1 emits the complete own C in 117.266 s;
the same-source Phase98 B2 reference takes 145.461 s. This compares different
stages and is not the candidate B2 speedup. The fresh own-C audit passes all 21
assertions, including the complete ANY-shared OR ALL-trivial guard, scalar-slot
exclusion, saved-root cleanup, exact ordinary fallbacks and unchanged runtime.
Source03 measurements are preserved separately and cannot qualify this successor.

The [qualification preparation](qualification-plan.md) reuses Phase98 methods
with the actual current B1/B2 baseline. The borrowed candidate has a checked B1 image and passing six-source screen;
source03 has a self-reproducing B2, while source04 and release qualification are
still in progress. The runtime bytes used by the micro and native chain are identical;
the dispatch implementation differs because `FID_ENTER` is 117 in the micro and
39,147 in the compiler, above the runtime's 4,096-entry threshold. This limits
transfer of a micro result and is not a runtime-file mismatch.

## Release status

Native B1/B2 compilation, generated-program speed, conformance and selected
source size retain their Phase98 qualified values. No scalar experiment has
been installed, and no speedup is claimed. Canonical modules, installed JS,
runtime atomic protocols and the public selection are unchanged. No PR comment
has been posted. This report will be completed after the borrowed-call test.
