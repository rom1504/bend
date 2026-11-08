# Compact frontend migration — authoritative handoff

Status: **closed: partial application migration rejected; no production changes**.
Baseline: `07e72c4` on `selfhost/bootstrap`; maintained Phase178 source.
Scope: canonical application terms only. No whole AST, symbol-table, backend,
runtime, or general IR rewrite. Research questions and completion gates are in
[the plan](PLAN.md). Completed experiment:
[Phase180 report](../../../../implementation/phase180/README.md).

## Finite checklist

- [x] Inspect real maintained producers/consumers and generated native code.
- [x] Confirm `app` still allocates two list cells plus the general term.
- [x] Identify metadata boundary: parser Apps use quantity1; canonical Apps use0.
- [x] Freeze baseline source and exact experiment recipe.
- [x] Implement `KApply` plus direct child access and lossless legacy projection.
- [x] Implement fixed-arity substitution frames inside the existing recursive owner.
- [x] Preserve compact results at checking/rebuilding boundaries.
- [x] Source-check both extracted implementations and compare complete finite values.
- [x] Inspect generated native allocation/call shape; run complete medium frontend pair.
- [x] Make explicit accept/reject decision before broad migration: reject.
- [x] Retain compact evidence and close this approach; production was never changed.
- Integration, broader targets and installation are **not applicable** after the
  failed transfer gate. No pending full-build campaign or hidden promotion task.

## Exact starting references

- Native producer: Phase175 N2 `selfhost/build/phase175/full-native-n2/program`
  and its `report.json`; qualified reference, not overwritten.
- Phase177 N1 is also available with separate `image-binding.json`.
- Recent own-source build context: Phase179 median175.662s; isolated emission150.921s.
  These are context, not a same-source baseline for the changed Phase178 source.
- Medium real input: Phase175 `baseline-source03/compiler.bend`.
- Existing native frontend harness: `selfhost/tests/phase175/native-frontend.py`.
- Existing complete-value frontend controls: Phase175–178 fixtures and adapters.
- Resource policy: one root CPU3 target lane, guarded2GiB RSS,5GiB disk reserve.

## Findings and traps

`kid` must read compact fields directly; implementing only `ks(KApply)=[f,x]`
would allocate two cells on every child access. Substitution must retain its
single recursive owner; a mutually recursive helper cycle previously lost direct
native lowering. Raw/malformed App metadata and optional lambda quantity syntax
are observable. Compatibility projection must preserve every field and source
span, not merely a structural hash. The new variant is not a proof certificate.

## Closing evidence

Final checked experimental snapshot: `selfhost/build/phase180/snapshot06`; candidate source
uses32 replacements plus three helpers/laws. Checked APIs are `base-api01` and
`compact-api06`; `application-values01` passes669 full-value observations and
`frontend-values01` passes70 complete frontend observations across14 inputs and
five cumulative modes. Both `front-{base,compact}-check01` accept the native
closures. Source/affinity errors in compact-api01–05 are retained as failures.

Native sources: `front-base-source01` and `front-compact-source01`; executables:
`front-base-native01` and `front-compact-native01`. `front-medium01` records
baseline/candidate/candidate/baseline on the fixed656,302-byte input: median
frontend12.2465→12.1540s,0.76% lower, below5% and smaller than run variation.
Whole-process14.8286→14.7093s. `inspection01` confirms construction shrinks
33→13 machine instructions, while `ks` reboxes and substitution grows1122→1300.
Both retain direct workers. No complete cold-build or generated-user-runtime claim.

All receipts, failed snapshots and selected machine bodies are in the verified
[evidence archive](../../../../implementation/phase180/evidence-index.json).
Fifteen guarded jobs cost299.223 target seconds; five source failures cost8.105s.
The [replay guide](../../../../implementation/phase180/reproduce.md) authenticates
the exact artifacts. Plan commit: `3ad6fdf`; result commit is the Git commit
containing this closing status/report (avoid a self-referential hash).

## Next decision, not unfinished work

Do not resume by extending this overlay to every AST variant. A successor needs
a new bounded hypothesis: retire a measured hot producer/consumer child-list
contract, including its downstream walks. Concrete retained boundaries are in
the [audit](../../../../selfhost/tests/phase180/boundary-audit.md): normalization
comparison, reachability, and application erasure/reference scanning. Their
runtime contributions remain unmeasured; source inspection is not a gain forecast.
Reusing checked facts to eliminate a complete walk is a separate alternative.
Select a new decisive experiment before reopening representation work.
