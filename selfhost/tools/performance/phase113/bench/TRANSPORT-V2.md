# Version2 direct/array transport

Existing emitters, planners, manifests and current direct-job pins are unchanged.
New files are `../staged-emit-v2.mjs`, `prepare-hosted-plan-v3.py`,
`hosted45-v2.py`, `../controls/prepare-jobs-v3.py` and shared
`transport-v2.py`.

The new emitter takes `API SOURCE FRESH_OUT cache direct|array`. It always
performs the explicit verifier stage. Direct selects `p113d_lower_request` and
`p113d_verify`; array selects `p113a_lower_request` and `p113a_verify`, retaining
the returned `P113AProgram` certificate wrapper.

If the checked API exports `p113e_admitted_chunks` or
`p113a_admitted_chunks`, respectively, the transport calls that renderer only
after the same in-memory program passes explicit verification. Otherwise it
uses the corresponding checked `*_chunks` API and records
`rendererReverifies:true`. Receipts record `transportVersion:2`, the pipeline,
actual lowering/verifier/renderer symbols, exact `requiredExports`,
`explicitVerificationPasses:1` and `rendererReverifies`. This does not count
internal optimizer or fallback verifier calls. Array certificate flags are
observed from the returned record; no second lowering or inspection API call
is made. False flags are a valid fallback, not an admission failure.

Prepare six benchmark products:

```sh
python3 -B selfhost/tools/performance/phase113/bench/prepare-hosted-plan-v3.py \
  --api CHECKED_API --pipeline array --runtime PRODUCT_RUNTIME_O \
  --tag p113-array17 --out FRESH_PLAN.json
```

Prepare frozen independent controls:

```sh
python3 -B selfhost/tools/performance/phase113/controls/prepare-jobs-v3.py \
  --api CHECKED_API --pipeline array --runtime PRODUCT_RUNTIME_O --all \
  --prefix selfhost/build/phase111/p113-array17-control \
  --out FRESH_CONTROL_PLAN.json
```

Prepare broad45 with `hosted45-v2.py prepare --api CHECKED_API --pipeline array
--runtime PRODUCT_RUNTIME_O --tag p113-array17-broad --out FRESH_PLAN.json`.
Its optional `--reuse-reports` requires the identical version2 pipeline,
renderer, API, transport and runtime. Old version1 direct receipts cannot be
relabeled as version2 observations.

After root executes a six or broad45 plan, `hosted45-v2.py audit --plan PLAN
--label LABEL --out FRESH_AUDIT.json` validates every declared case and creates
`FRESH_AUDIT-binding.json`. It verifies the actual pipeline/export/rendering
contract, completed stages, API/transport/runtime and the existing binder's
source/toolchain/build gates. Case count is explicit. The old compatibility
export `p111_compile_source` is still required by product binders; it is not
the staged renderer. Use the existing six or broad45 measurement runner with
the corresponding manifest and unchanged profile.

All preparation is offline. Root owns target execution and real source,
runtime, structured-IR, output and native-reproduction qualification.
