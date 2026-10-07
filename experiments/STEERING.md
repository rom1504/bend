# Current frontier: Phase60 broad compiler survey

**Last01 is installed and verified.**
Direct JavaScript remains the default; explicit legacy JavaScript and native C
remain available. Ordinary compilation runs Bend code without TypeScript fallback.
Archive closure and member verification are complete; see the Phase58 publication index. No PR comments are authorized.

[Design](../design/phase58/compiler-allocation-and-code-generation.md) ·
[Report](../implementation/phase58/README.md) ·
[Final measurements](../implementation/phase58/final-measurements.md) ·
[Reproduction](../selfhost/tools/performance/phase58/README.md) ·
[Hypotheses](phase58/).

Selected attempt: `selfhost/build/phase58/checked-last01`.
Checked B1 API: `641381f638f1f4c1c8b349bef06502b42738c1c7feff0391f2e09b90f4ef282a`.
Source: `85454aab7a6ef25d1e78970b1c24d68ac2a90a23a4b39b64a30de311c2fc5091`.
Qualified direct B2/B3: `a73daccf86a807092a334d5f3121745e0b91c3054164c25462f1658644b7b081`.
Upstream: `018751270e800bc222a93dad7f257083ee53a5f7`; Node 24.18.0.
Both runtimes, driver and all 17 native modules retain Phase56 bytes.
The installed artifact is checked B1; emitted B2 has no fabricated checked sidecar.

## Established results

Six general changes survive: last-live-constructor-key placement, allocation-free
intermediate constructor misses with checked-owner fallback, scalar provenance
through exact residual Word reconstruction, proved literal continuations,
validated per-definition dependency deduplication, and shared mutual-tail SCC
workers. Partial application, ordered effects/errors, aliasing/capture, erased
fields, special keys, cycles and tail/reentry boundaries retain focused controls.
The final key rule is last LIVE constructor field computed, earlier ordinary keys
literal, __proto__ always computed; ordinary marshalling keys remain literal.
All-literal and whole-computed rollback evidence remain historical, with their
program/compiler tradeoff. No width cutoff is selected; its grid is unexecuted.

Final checked/source/B2 gates pass, including 14 B1 integration jobs,96 source,
34 numeric,18 composition,2 overapplication,8 maintained suites, native retention,
fresh own-source type acceptance and exact B2→B3 reproduction. Type acceptance
and expected unsafe proof-trust refusal remain separate from kernel validity.
Known pinned-reference NaN defects stay explicit; no new mismatch is waived.

Fresh full-program timing passes23 sources / 45 points / 669 samples. Equal-point
new/TS is 1.046110 versus old/TS 1.061731; new/old 0.985287. Equal-source new/TS is
1.040502. No point regresses >10%; worst regression 2.949%, zero timing flags.
These are corpus aggregates, not universal parity or a promise for other hosts.

Changed-source B2 request comparisons take49–56% less import+first time and 59–67%
less later-window time on Evening/lexer. B2 still takes 2.4–2.7× same-campaign TS.
B1 is mixed, including 3.89% later lexer regression. Separate sampled lexer
allocation drops 89.41% versus old B2; cumulative sampled allocation is not RSS.
Own-source emission 36.06s versus retained old 223.48s yields descriptive 6.198×;
the baseline was not freshly rerun consecutively. Peak RSS does not improve.
Samples still warm; no steady-state or isolated six-factor attribution claim.

Source grows 314 physical/238 code lines to 26,560 physical/21,823 code,
3,055 definitions,101 types,108 modules. 98 modules retain bytes. Generated-code
shrinkage and source growth are different quantities; no source-simplification claim.

## Phase60 survey complete; no optimization promoted

[Design](../design/phase60/broad-compiler-survey.md) · [Hypotheses](phase60/) ·
[Clean measurements](../implementation/phase60/measurements.md) ·
[Common-frontend audit](../implementation/phase60/common-frontend.md).
Measurement only; no compiler/runtime/driver/source or installed-release change.

The audited population is 23 compilation inputs mapped to 45 runtime points.
Post-emission observers do not create extra requests. Clean 23×2×3 completes 138
fresh processes/552 compiles, no missing/excluded sources, every output equal to
its role's qualified raw bytes. Runtime oracles are inherited by exact identity,
not fresh executions. Combined-first equal-source B2/TS GM is 2.461296885; ratio
of summed medians 2.485×. Every source is slower, spanning 2.103–3.049×. Later
windows still warm; diagnostic times/profiles do not enter clean ratios.

Check-and-complete is 611–726 ms and largest individual stage on 22/23 inputs.
ABI2's validated prefix is unused: Base source events are checked again in a
fresh world. The source-only cache preserves parsed IR, not checked memo/output.
This establishes shared work, not its isolated time or permission to skip it;
user checking, specialization, GC and first-process V8 work remain bundled.
Pinned TS also loads/checks Base each request; rechecking alone is not the
explanation of the relative gap.

[Final diagnostics](../implementation/phase60/diagnostics.md),
[bottleneck ranking](../implementation/phase60/bottlenecks.md) and
[tested fast loop](../implementation/phase60/fast-loop.md) are complete. All 138
rows classify; the original data-only reader failure remains separate from zero
failed targets. Its TS allocation missing-node 138,000 bytes stays in the sample
denominator and explicit unknown bins. All 46 CPU count views are valid; 38
weighted views admit and 8 refuse. Uniform count shares never mix with weights.

1. Separate shared world/check/completion from source-dependent work before any
   checked-state reuse proposal. Both pipelines recheck Base, so this alone does
   not explain their relative gap; source-only cache is not a resume proof.
2. Investigate String/reference transport on contrasting contexts: allocation
   family ≥5% on 18/23 and 8/23 respectively. Preserve liveness/order and provenance;
   shared dispatcher names are not single-member causal attribution.
3. Keep index/substitution coverage: index CPU/allocation family ≥5% on 23/23,
   substitution allocation 22/23. Metadata is smaller (CPU 4/23, allocation none
   above 5%), not the universal explanation or guaranteed physical table cost.
4. Tested first-only subset: Numeric recurrence + MapSet, four workers/full CLI
   17.528899 s; add active raytrace/two rotated rounds, 12 workers/49.509634 s.
   Excludes reusable preparation; observed costs, not guarantees. Lexer/Evening
   held out, all 23 remain population gate. Selection preceded allocation evidence.

300 targets/712 compilations pass (298 first/414 later), child sum 1,246.100 s,
peak 630.91 MiB. Final preservation passes 30,687 closed Phase58/59 files plus 7
installed plus 103 protected unchanged. Raw writers closed 05:42:28 UTC; [publication](../selfhost/tools/performance/phase60/artifacts/raw/publication.json)
and [reopened/member verification](../selfhost/tools/performance/phase60/artifacts/raw/archive.json)
pass with stable raw inputs; no compiler, runtime, driver, release or PR comment changed.

Closed Phase59 history stays unchanged. No new compiler image generation,
optimization, full45 program execution campaign, release or PR comment occurs.

Heavy jobs remain root-serialized under one guard, private staging and fresh paths.
Preserve failed attempts, consumed producers, closed Phase54–59 history, seven
previous release files and all 103 unrelated files. Stage explicit owned paths.
No additional target is authorized by this frontier document.
