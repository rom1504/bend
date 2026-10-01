# Direct recursive component investigation

Status: the narrow source rule passes its final checked05 owner controls and is retained by performance admission. Final measurements below preserve the observed drift and costs; installation is recorded separately.

[Design](../../design/phase39/components.md) and
[prospective experiment](../../experiments/phase39/P39-003-components.md).
The baseline is installed Phase37 checked03; previous Phase37 prototype timings
are not measurements of this rebase. Root owns all target execution.

Read-only findings: tree-bitonic has four saturated `warp` sites (three normal,
one tail) inside the existing guarded scalar bench. Finite leaf/zip selectors
are already present. The expression family already has an iterative direct
`eval` fold, so its independent experiment must target the still-generic tagged
constructor producer instead of claiming that existing optimization as new.

Root executed the rebase controls: 312 complete oracles, 112 boundary controls
and 10 admission observations passed. The clean three-round tree screen took
21.94 seconds. Relative to the installed Phase37 compiler output, the complete
handwritten component was 2.465× faster at depth 8, 2.248× at depth 6 and 3.147×
at depth 9. These are saved-output mechanism results, not source compiler gains;
the depth-9 current baseline also had substantial half-run drift.

A stricter prototype retained generic leaf and combine calls, saved the original
argument vector, and replayed only proven inert prefix reads while unwinding.
Its 310 oracle, 112 boundary and 5 admission observations passed. The 8.51-second
screen measured 19.6476 ms current versus 13.0183 ms framed at depth 8: 1.509×.
That smaller result, rather than the larger handwritten specialization result,
is the production rule's evidence.

The independent expression producer prototype passed 71 oracle, 76 boundary and
2 admission observations. Its initial screen measured 7.016× (depth 32) and
9.199× (depth 128) gains, while still 10.34× and 6.26× slower than TypeScript.
Both baseline and candidate had material drift in some rounds. This justifies
separate warmed confirmation and a producer proof investigation, not transferring
those gains to the binary structural rule.

The first checked source build, checked02, compiled successfully in 43.706 seconds
with 1.166 GB peak RSS. Its first generated tree execution failed with an undefined
`scan$tree` helper (encoded identifier in emitted JavaScript): 12 calls were
present but no helper declarations. The helper suffix had been attached below
the existing worker choice, where that choice could bypass it. That integration
weakness was identified statically; it was not the complete cause established by
the later probe. No performance or correctness admission is claimed for checked02. The first correction moved the suffix to common `j_l_def` emission, after that
choice, and removed the narrower suffix. Checked03 still emitted the same missing
helpers; its failed output is preserved and was not retimed.

An observation-only copied-API probe then isolated the second integration mismatch
in 5.83 seconds: declaration emission saw annotated selected definitions while
call planning saw the original context definitions. For both `warp` and `scan`,
the annotated traversal counted three self references and failed the structural
prefix check; the original had two, passed the prefix and full plan, and could
emit helpers of 3821 and 1349 bytes. Both passed the 512-node bound and depth
check. The final correction uses `lookup(book,dn(d))` for both declaration proof
and helper body, exactly matching call-side analysis. Actual-output controls now
require every component call target to have exactly one declared helper. These
are compiler integration failures, not revised correctness expectations.

The independent component fixture v2 was rejected before target execution:
three wrapper functions used their affine `size` parameter twice. Version 3
changes only these parameters to `+size`. Its separate source/acquirer preserve
v2 and its failed acquisition. No output oracle has been relaxed.

The source rule adds no IR tags. It admits complete, closed, pure typed matches
with two independent saturated self calls, both descending through the original
first ADT argument. A bounded transitive backedge check rejects helper cycles
into the worker. Generic leaves, combines, layout, evaluation order and public
wrappers remain. Repeated proof discovery and extra generated declarations are
explicit compiler-time and code-size risks requiring measurement before release.


The corrected checked04 source build passed in 41.78 seconds. Its first clean
three-round tree screen passed all three points in 22.581 seconds. Current
Phase37 output versus candidate execution was 18.774 → 11.848 ms at depth 8
(1.585×), 2.959 → 1.693 ms at depth 6 (1.748×), and 53.949 → 30.807 ms at depth 9
(1.751×). The candidate remained approximately 40.8×, 44.6× and 42.1× slower
than the pinned TypeScript output at those points. These are initial actual
compiler-output screens, not a release decision or a warmed confirmation. At
depth 8 the candidate had +42.58%, +43.38% and +42.90% half-run drift, despite
tight whole-sample ranges; the baseline was near zero. Longer confirmation is
therefore necessary before describing these results as steady state.

Read-only output inspection found both `warp` and `scan` structural helpers,
98,342 emitted tree bytes, and no undeclared structural helper identifiers.
The source rule naturally admitted `scan` as well as `warp`; the actual result
therefore must not be attributed solely to the single-helper saved-output
ablation. Independent source controls, broad correctness and compiler cost
measurements are still required before promotion.


The independent actual-source cohort passed on checked04 API
`4317f28e0c40308955c4a6fa322cd7b4f776948c7f3f5b43d6805f5206dac152`.
Root executed 159 oracle observations, 113 boundary observations and 3 admission
controls in 1.812 seconds, with 133 MB peak RSS. This includes exact baseline,
candidate and TypeScript outputs for the four source wrappers; full abstract
trees for distinct input ADTs, mismatched depths, shared/frozen inputs and both
alias choices; and mutation, getter, demand, first-error, host and reentry
controls. The complete source fixture and acquirer are version 3.

Actual emission had one `component.mix` helper and four call sites, all resolved.
Tail-only recursion, sequential result dependence, a transitive owner backedge
and mutual tail recursion had no structural helper declaration. An ordinary
source bench entered exactly one emitted component under one existing scalar
proof. Each 30,000-step mutual-tail case also entered the terminal component
once and closed the proof. The separate candidate-only owned-input adapter
inspected all 60,001 output nodes at depth 30,000 using an iterative observer;
its two worker entries are diagnostic evidence, not a fabricated source-root
admission. Clean candidate files remained byte-identical to the checked output.

The actual derivation binds source, checked emission receipts, selected attempt,
frozen driver, API/runtime/Base and bootstrap source identity, then rechecks its
input identities. The controls consume only these identities and diagnostic
counters/adapters; they do not replace the optimizer. Reports are
`component-actual-derived01/derive.json` and
`component-actual-controls01/report.json` under `selfhost/build/phase39/`.
Broad release controls, stable timings and compiler cost remain separate gates.


## Final checked05 semantic confirmation

The frozen final candidate re-acquired the independent fixture in
`selfhost/build/phase39/component-cohort04/derive.json`; it did not reuse the
checked04 output as evidence for the final image. Its selected checked05 API is
`04d9ebf417a20297598bb6b047936a02228f3b8fb3a3b0cc4b59eeea04bad49f`.
The source remains fixture version 3, with the same full-tree oracles, alias and
demand cases, foreign mutation and reentry boundaries, refusal shapes, and
30,000-step stack obligations.

Root executed the final controls successfully: **159 oracle observations,
113 boundary observations and 3 admission controls**, in **1.710 seconds** with
**123,645,952 bytes** peak process-tree RSS. The actual source bench enters one
structural helper under one scalar root, and each deep mutual-tail case enters
the terminal helper once. All generated component call targets resolve to one
declaration. These are semantic and admission observations; diagnostic counter
values and durations are not program-speed measurements.

Exact final evidence under `selfhost/build/phase39/`:

| Record | SHA256 |
| --- | --- |
| `component-cohort04/derive.json` | `a3d474644f6786b90903380d913ff1b0216d2004d382b68c81b6ad44c1b30889` |
| `component-final-derived01/derive.json` | `547cdb09be6ac96ba4bc05169c8d67b061d16550a6da6268dd6e863c4bb874d0` |
| `component-final-controls01/report.json` | `6e60c5726b79144e18c0c2b54f4803f679c87305ae4e9901e8d61eb583a30768` |
| `component-final-control-run01/run.json` | `fd47a3553582264e8017ce3fce65f3f6f74c19e6f2ff88cdb9669beca36b0e22` |

The [performance admission](performance-admission.md) uses fresh final checked05
timings against Phase37 checked03 and the pinned TypeScript output. Earlier tree
and expression screens above remain their original, separately qualified
experiments; they are not substituted into that final comparison.

## Final clean execution and costs

The final three tree points win all five paired rounds and have disjoint faster
candidate ranges. Times are median [minimum–maximum] milliseconds per call:

| Depth / seed | Phase37 | Checked05 | Gain | Checked05 / TS |
| --- | ---: | ---: | ---: | ---: |
| 6 / 17 | 2.86865 [2.86510–2.90995] | 1.62926 [1.61719–1.64598] | 1.761× | 44.003× |
| 8 / 0 | 18.3023 [18.2662–18.3919] | 10.2073 [10.0934–10.4466] | 1.793× | 36.801× |
| 9 / 123 | 50.0104 [49.7905–51.0186] | 22.2058 [22.0266–22.3375] | 2.252× | 31.846× |

These are measured-protocol results. Depth8 candidate half-drift is −15.63% to
−12.27%; depth9 baseline is +20.54% to +22.47%. The full
[execution report](execution/report.md) retains that uncertainty and every raw
pair. All three use the changed 98,342-byte tree module; they are not unchanged-
code noise controls. The module grows 7,010 bytes. Normal checked tree requests
rise 3.50% by ratio of medians, with all three pairs slower and disjoint ranges;
[compiler-cost.md](compiler-cost.md) keeps that separate price explicit.

The separate actual unary producer achieves final expression32/128 gains
4.461× / 8.052×, remaining 10.465× / 5.239× TypeScript. Those results belong to
the [unary producer](unary-producer.md), not to the binary structural proof or
the earlier handwritten expression prototype. The final image contains all four
retained changes, so total tree gains are not solely attributed to `warp`.
