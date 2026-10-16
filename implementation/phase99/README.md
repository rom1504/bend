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
executions, including aliased roots, Unicode strings, escaping-child refusal and
the existing origin-swapping regression. Both checked entry points agree; raw,
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

The [qualification preparation](qualification-plan.md) reuses Phase98 methods
with the actual current B1/B2 baseline. A checked acquisition for the borrowed candidate is in progress; no full compiler
qualification or release gate is complete. The runtime bytes used by the micro and native chain are identical;
the dispatch implementation differs because `FID_ENTER` is 117 in the micro and
39,147 in the compiler, above the runtime's 4,096-entry threshold. This limits
transfer of a micro result and is not a runtime-file mismatch.

## Release status

Native B1/B2 compilation, generated-program speed, conformance and selected
source size retain their Phase98 qualified values. No scalar experiment has
been installed, and no speedup is claimed. Canonical modules, installed JS,
runtime atomic protocols and the public selection are unchanged. No PR comment
has been posted. This report will be completed after the borrowed-call test.
