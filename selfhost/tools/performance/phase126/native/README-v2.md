# Selected local-projection ABI rebinding

Use `rebind-abi-v2.py` for the simpler local renderer. The original
`rebind-abi.py`, typed-path smoke receipts, and original Phase125 ABI authority
remain unchanged. The existing `plan.py` accepts either exact receipt; all eight
qualification jobs and their gates remain unchanged.

```sh
python3 -B selfhost/tools/performance/phase126/native/rebind-abi-v2.py \
  --source-manifest FINAL_SOURCE_MANIFEST --api-report FINAL_API_REPORT \
  --runtime-report selfhost/build/phase125/runtime-verified01/report.json \
  --out selfhost/build/phase126/final-native-abi01.json
```

Then use the `plan.py prepare` command in `README.md`, with that fresh receipt.
Only root may execute its guarded target plan.

The rebinder authenticates the frozen local inventory and compares every final
declaration from its shared/local module closure: 66 declarations for the
original local primitives, 67 for `primitives-v02.bend`. It requires the exact
compiled source to contain those declarations and their module input pins.
The optional v02 file has a fixed SHA-256, rather than permission to accept an
arbitrary primitive implementation. Extra `p126l_` helpers are refused.

The `p126l_sqrt` body is the reviewed helper after exact renaming. It still emits
F32→F64→double `sqrt`→F32, retaining the existing libm signature and word result.
Operation 58 adds no call: its exact ordered comparisons admit only values in
[0,2^32), then emit `stoui` and zero-extension; all other values return zero.
Its result clears the destination float fact. The runtime source/object and
primitive-ID header are authenticated; the materialized header must be exactly
equal to the inherited header pinned by the runtime build. The parent nine
runtime imports, 12 authority declarations, original verifier gates and
source-contract replay remain mandatory. New literal external symbols other
than `$sqrt` are refused.

Data-only checks passed for checked `clean-source11` / `p126-clean11-api` and
`combined-source14` / `p126-combined14-api`. The latter also prepared a complete
native plan without executing it. Receipts:

- `phase126/tooling-native-rebind-clean11-smoke02.json`
- `phase126/tooling-native-rebind-combined14-smoke01.json`
- `phase126/tooling-native-plan-combined14-smoke01.json`

`review02.json` records five source-only refusals: changed sqrt symbol, changed
operation-58 dispatch, changed conversion boundary, incorrect float-result
classification, and an unexpected local helper. It also records the first
strict header-path refusal and its exact inherited/materialized-byte repair.
No compiler, generated target, benchmark, or native image was executed.

A future unrelated statement-emitter overlay does not itself change this
runtime ABI. It must still pass source replay, original verifier equality,
the complete local-projection check, and the unchanged import catalogue; any
new foreign symbol or changed authority requires separate reviewed admission.
