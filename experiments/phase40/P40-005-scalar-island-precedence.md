# P40-005 — Preserve existing Nat scalar island precedence

- Owner / independent reviewer: list investigator; tree investigator and root.
- Prospective record: 2026-10-03 07:17:01 UTC, authored before corrective build or timing.
- Starting candidate: checked05 API `c1d70130a12e6309e9a964004221d61b41d74078b3a252fb7f573b9654fefc54`.
- Baseline: Phase39 checked05 API `04d9ebf417a20297598bb6b047936a02228f3b8fb3a3b0cc4b59eeea04bad49f`.
- Correctness: correction unchecked. Measurement: corrective timing not run. Decision: investigate.

## Observation motivating this separate hypothesis

The still-running checked05 historical raytrace campaign has reported partial
baseline/candidate execution near777/1884ms; final samples remain unassessed.
Static emission comparison shows new colf/rowf structural workers and bench
region admission bypassing the retained local colf scalar island. Its former
private colf.px leaf helper becomes a curried generic runtime call on the new
path. The historical fixture traverses1048576 leaves, mostly outside width80.
This is a plausible mechanism, not an isolated measured causal attribution.
The four original Phase40 hypothesis records remain frozen.

## Prediction, minimal change and disproof

**Hypothesis:** giving existing scalar islands precedence restores historical
raytrace performance while retaining the new List and Nat-to-data improvements.
Prediction: corrected historical raytrace output is byte-identical to Phase39;
new Nat data workers and List/ADT-first scalar folds retain admission.

Only the newly introduced primitive-Nat first-input alternative in
j_component_plan gains one condition:

```bend
Bool.not(j_region_scalar(book, j_fold_root_result(book, dt(d), da(d))))
```

The existing result telescope peeler identifies canonical U32/Bool/Nat/F32
results; full existing JPure signature proof validates the retained data results.
No definition name or benchmark-specific condition is used. Other first-input
alternatives, descendant analysis, purity/backedges, guard ownership and runtime
fallbacks remain as checked05. Source delta is
[list-nat-scalar-precedence.patch](../../selfhost/tools/performance/phase40/list-nat-scalar-precedence.patch).

Disproof: raytrace bytes still differ or scalar-island guards change; data/List
worker admissions disappear; fresh independent oracles, before/child/after order,
alias/error/host controls fail; or corrected paired timing retains the slowdown.

## Planned validation and preservation

Root alone runs heavy work serially. Acquire a fresh checked attempt and actual
emissions. Run static entire-raytrace byte equality plus typed Nat→U32 refusals,
retained private leaf helper and guard-owner checks through
[list-scalar-island-controls.py](../../selfhost/tools/performance/phase40/list-scalar-island-controls.py).
Rerun actual List/Nat/linear controls and independent TypeScript fixture oracles
against the new API. Run a bounded small actual ray/tree/list confirmation
(control budget60seconds), then repeat the45-point final campaign only if fresh
candidate admission changes require it. Keep paired rounds, ranges and drift.

Preserve all checked05 artifacts, its initial passing controls and its regression
timing. All corrective outputs use fresh directories and immutable consumed tool
copies; future outcomes belong in implementation/phase40/lists.md and the ledger.
No corrective success is claimed by this prospective record.
