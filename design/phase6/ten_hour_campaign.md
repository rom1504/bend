# Phase 6: faster compilation, fewer duplicated rules, closer conformance

Authorized window: 2026-09-23 05:06:12–15:06:12 UTC, at most ten hours.
Baseline commit: `a6459af179d646ddcfec5136495dd844f2829ab7`.
The user authorizes implementing all eight proposed directions, with validation,
commits, pushes, documentation and a usable resulting compiler. Estimates from
our discussion are hypotheses, not acceptance criteria or promised achievements.
This extends the [opening Phase 6 experiments](../../implementation/phase6/report.md).

## Baseline and constraints

The release API is `e2b5463678a26558e8fea1d585782e0863f1046067949a374f0469080281b15a`,
checked parent `5969c53d34a088bc9630eb2c065c2eea7fd260294cf3fefb14dffb305b7e4667`,
source `e3b927d13dc2645e19171b72de60c49dd5bc5e5059863937153b957e2ce0ec1d`.
The existing controlled full-source comparison is valid for these unchanged
compiler bytes: 363.392 seconds versus pinned TS 60.248 seconds, 6.03×, under
its published cache policy. Verify identity before reusing this baseline; a new
source or workload needs a new controlled comparison, not division of unrelated
runs. Preserve upstream `6018e28ecc67cf1fffc0c20c64b11023474c2df8` unchanged.

Production is 59 modules, 16,509 physical lines, 13,803 nonblank, 1,526 definitions,
1,280 laws and 66 types. Maintained support is 12,919 physical lines; experimental
performance tools are a separate 14,771 lines. Removing evidence, minifying or
moving files is not a compiler simplification. Exact current file-selection rules
are in the Phase 5 recount.

Pinned frontend: 919/919 positives; 318 strict check failures, 444 exact live
frontend differences, 16 status/phase differences. Three strict oracles also fail
TS. Outside-inventory semantic witnesses, including `+U32`, are mandatory controls.
The broad native gate has one positive arity-wall timeout. Prior source experiments
are not part of the release; their failed gates remain failed.

## Workstreams and falsifiers

| Experiment | Change and hypothesis | First gate / stop rule | Owner |
| --- | --- | --- | --- |
| P6-003 | Correct prefix operand precedence and erased names, preserving fresh unbound variables without capture. | `+f(1)` versus `(+f)(1)`, empty application, local/unbound/qualified/ADT names, `+U32`, first error and valid neighbors. Preserve the prior failed marker attempt. | Semantics agent, CPU1 |
| P6-004 | Carry sufficient parser-owned source locations once through transformations; remove reconstruction when replaced. | Reproduce the 150 same-error/missing-excerpt cases; isolate a small cluster and verify exact source selection, Unicode, multiline strings, imports and repeated subterms. No reparsing per application. | Diagnostics agent, CPU2 |
| P6-005 | Avoid continuation frames for proven immediate native scalar words. | 32/64/128/255 field emission, mixed/nonliteral fields, affine disposal/sharing, evaluation/error order, packed layouts and actual native executions. Reject unsafe generalization even if C shrinks. | Native agent, CPU3 |
| P6-006 | Remove superseded freshening/provenance implementations. | Static root/export/host/test reachability, explicit public ABI policy, checked build, exact unaffected observations and byte-equivalent representative outputs. Do not delete a path merely because a textual caller search misses dynamic use. | Root, CPU0 |
| P6-007 | Reuse authoritative checked facts during annotation instead of reconstructing types. | Instrument exact repeated facts and immutable context dependencies; prototype one narrow result handoff, compare annotation graphs and outputs on dependent/quantity/template/import-change cases. Stop broad rewrite if validity or opportunity is absent. | Root, then available reviewer |
| P6-008 | Return structured failure information from the authoritative checker instead of replaying it for diagnostics. | Prove current replay scope, preserve first error, binder/ownership context and public text. Compare positive and negative request histories. Separate from typed-result reuse until each is understood. | Root + diagnostics agent |
| P6-009 | Finish structured parser-error families. | Cluster remaining generic errors, fix grammar/error choice once per family, require exact pinned diagnostics plus valid and competing-error controls. No fixture-name special cases. | Semantics/diagnostics agents after first gates |
| P6-010 | Validate or replace the Boolean source workers. | Retain original failed H malformed-data gate; resolve actual positional/partial-function contract, then independent H timing and broader B1 gates. H already lowers choices; do not assume B1 gains transfer. | Root / available agent |
| P6-011 | Correct declared missing-import phase and provenance. | Tag only declared-import failures; retain root/Base/API IO classification. Test missing import plus malformed body and actual import spans before changing error order. | Root |

The forecasts guide prioritization: typed reuse could save 17–38% of full-source
wall if viable; provenance could repair 50–100 of the identified 150 strict
cases; structured parser families might repair another 30–60; obsolete-path
cleanup could remove 150–350 production lines. The Boolean core pilot measured
about 6% on one component only. Native scalar lowering might reduce pathological
C by 80–94% and native emission by 2–5×, neither yet measured. These ranges overlap,
may yield zero, and never substitute for actual gates.

## Implementation and integration

Start with isolated source projects and fresh immutable attempts under
`selfhost/build/phase6/campaign/`. Agents do not edit production source or default
artifacts. Root reviews patches and integrates nonconflicting survivors in named
batches. Track source additions and deletions, public-root changes and exact
consumed tool versions. Preserve initial rejected formulations and failed oracles
before correction. Use existing checked build/validate tools, not a new general
validation framework.

Source provenance, freshening, checker results and annotation interact. Agree on
shared contracts before combining patches; two independent passing overlays are
not evidence for their merge. Keep temporary markers out of the public core and
retain raw/decoded ABI controls where representations change. Removing internal
exports may require updating intended compiler-library roots, but never silently
change the benchmark workload or claim old output hashes for a new library.

After focused independent review, a combined source receives the complete
2,756-observation frontend gate against the frozen live reference, with a fresh
reference witness when behavior or harness assumptions need verification.
Affected emitter changes also compile and execute actual JS/native programs.
A long proof and broad backend run belong to the final frozen source. Update the
usable distribution only after its required gates, preserving genuine bootstrap,
derivation and fixed-point identities. A derived artifact never gets fabricated
bootstrap provenance. The previous release and raw evidence remain recoverable.

## Measurement and resource schedule

Correctness work can use four distinct cores, normally at most 4 GiB Node heap
and 4 MiB stack per process, with explicit outer deadlines. Current host has
about 32 GiB physical RAM; avoid aggregate memory pressure. Short experiments use
minutes-scale limits and small affected selections. Root authorizes any full
inventory, whole-source or native Clang stress run.

For timing, pause competing intentional compiler/archive/hash work, freeze all
inputs, verify cache policy, use fresh processes and opposite-order samples,
retain every observation, and require correctness first. A small pilot must show
a repeatable material effect before spending a long full-source window. Profile
samples, wall times, generated size, Clang build time and runtime execution are
separate measurements. Do not multiply independent historical speedup percentages.

First checkpoint is 06:15–06:30 UTC: bounded semantic/native candidates and a
provenance mechanism, with failures preserved. Review strategy after each decisive
result; abandon an unsafe or unsupported formulation without abandoning its user
objective. Aim to freeze the final combined source by 12:15 UTC and reserve the
last roughly three hours for controlled final comparisons, checked B1→H→H,
complete artifact frontend and affected broad backend gates, release rebuilding,
source recount, documentation, archival verification and commit/push. If a proof
runs longer, reduce later optional experiments rather than exceed 15:06:12 UTC.
No gate is called passed merely because time is short.

## Deliverables

Maintain one file per hypothesis, chronological ledger, current strategy and
[the campaign report](../../implementation/phase6/campaign-report.md). Commit this
design before implementation, then validated increments and evidence. Keep the
compiler guide and README linked to the current version, measurements, known
failures and exact build/use commands. Finish with a clean pushed branch, explicit
unpromoted/rejected work and measurements for speed, conformance and size using
unchanged definitions of those metrics.
