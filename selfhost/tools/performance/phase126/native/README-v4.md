# Exact local, table, resume and Nat composition

Use `rebind-abi-v4.py` with the checked `inline-source20` composition. It
includes local primitives v02, staged table-call projection (`modules03.json`),
whole-function tables, scalar resume, and Nat extraction. The runtime is still
the selected Phase125 runtime. No new owning ABI or external call is admitted.

```sh
python3 -B selfhost/tools/performance/phase126/native/rebind-abi-v4.py \
  --source-manifest selfhost/build/phase126/inline-source20/manifest.json \
  --api-report selfhost/build/phase111/p126-inline20-api/report.json \
  --runtime-report selfhost/build/phase125/runtime-verified01/report.json \
  --out selfhost/build/phase126/final-native-abi01.json
```

Then prepare a fresh plan using unchanged `native/plan.py`, this receipt, the
same source/API/runtime, and a fresh p126 tag. Root alone executes the plan.

`combination04.json` pins the ordered module closure and its parent. In addition
to the existing original-verifier/runtime gates, the rebinder independently
compares the complete 6,168-declaration source against the selected parent plus
these exact overlays. Its projection closure contains 170 declarations. This
replaces only the explicitly pinned local/table hook; it is not permission to
replace arbitrary emitters. Nat extraction remains bound to its exact expansion
and fallback. The whole runtime/import catalogue remains unchanged, and `$sqrt`
is still the only admitted additional literal external symbol. Any later source
change requires a new exact recipe/admission; a changed runtime needs separate
runtime authority.

`review04.json` records source-only refusals for altered private-emitter hook,
table load, Nat expansion, primitive dispatch, and original verifier declaration.
Data-only full ABI admission and plan preparation pass after the root-produced
checked inline20 API:

- `phase126/tooling-native-rebind-inline20-smoke01.json`
- `phase126/tooling-native-plan-inline20-smoke01.json`

The earlier `combination03.json` / `rebind-abi-v3.py` are preserved source-only
preparation for inline18, whose source-pattern syntax was rejected. They have
no successful checked-API/native admission. Inventory04 uses the explicit
Con/Nil source repair; it does not silently rewrite the earlier inventory.
All previous local-only/typed receipts and helper bytes remain unchanged.
No compiler, target, or benchmark was executed by this preparation.
