# Compact frontend migration — authoritative handoff

Status: **bounded experiment; no production changes**.
Baseline: `07e72c4` on `selfhost/bootstrap`; maintained Phase178 source.
Scope: canonical application terms only. No whole AST, symbol-table, backend,
runtime, or general IR rewrite. Research questions and completion gates are in
[the plan](PLAN.md). Current experiment: [Phase180](../../../../design/phase180/README.md).

## Finite checklist

- [x] Inspect real maintained producers/consumers and generated native code.
- [x] Confirm `app` still allocates two list cells plus the general term.
- [x] Identify metadata boundary: parser Apps use quantity1; canonical Apps use0.
- [ ] Freeze baseline source and exact experiment recipe.
- [ ] Implement `KApply` plus direct child access and lossless legacy projection.
- [ ] Implement fixed-arity substitution frames inside the existing recursive owner.
- [ ] Preserve compact results at checking/rebuilding boundaries.
- [ ] Source-check both extracted implementations and compare complete finite values.
- [ ] Inspect generated native allocation/call shape; run complete medium frontend pair.
- [ ] Make explicit accept/reject decision before broad migration.
- [ ] If accepted: retire selected canonical legacy producers, qualify all targets,
      compare full compiler/request metrics, remove temporary adapters, document.
- [ ] If rejected: retain compact evidence, restore production unchanged, close project
      or specify a bounded next hypothesis with a new measurable obstruction.

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

## Next action

Finish experimental application adapters and substitution frames, freeze the
baseline/candidate sources, then run source acceptance and independent complete
value comparisons before acquiring any native image. Update this file after each
decision with exact receipts, commit and next command; do not resume by scanning
the entire historical ledger. Completed work must be committed/pushed.
