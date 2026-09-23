# Final selected backend validation (API05)

The genuine checked API05 passed **42 selected observations against each compiler**: 84 oracle passes across pinned TypeScript and Bend. Nine positive programs executed through the interpreter, JavaScript and native C backends, producing the expected outputs. All 18 native compilations retained their actual emitted C, executable and available build metadata.

The pinned negative matcher fixture matched its exact diagnostic across all three execution entry points. Six custom negative fixtures passed explicit rejection/phase oracles in parse and check. **Ten exact diagnostic differences remain** for five of those fixtures: Base law freshness, Base type freshness, spaced Nat syntax, parallel constructor binders and an unsafe law. The namespace-closing negative agreed exactly. A selected semantic pass is not an exact-diagnostic or whole-language conformance claim.

The selection covers Nat precedence/nested namespaces, parallel binder order and adjacency, local namespace propagation, do-bound constructor names, ordinary law filling, an imported helper and legal shared constructor/top-level spelling. See the [selection](../../selfhost/tests/frontend/phase5-final-backends/cases.json) and [original plan](frontend-final-validation-plan.md).

The two newly prepared positive fixtures initially had author errors: a quoted import path and a match directly on a definition call. Both were rejected by pinned TypeScript before the paired gate. The corrections use an unquoted import and match on a helper parameter; both then checked and normalized to `42`. Original sources and diagnostics remain under `historical-fixtures/` and `fresh-controls-01.json` in the evidence. No compiler or oracle was changed to make the controls pass.

## Identity and execution

The API is SHA `5969c53d34a088bc9630eb2c065c2eea7fd260294cf3fefb14dffb305b7e4667`, from genuine integration attempt-05. Its source/modules, bootstrap provenance, Base/runtime and host inputs were verified before and after execution. The frozen attempt's existing `target.mjs` supplied the paired harness with `retain: all`; the normal workflow's `retain: failed` would have discarded successful native inputs. Custom dependency files, including the imported helper, are included in the harness input hashes.

The gate ran on CPU3 at **2026-09-23 00:38:31.412–00:40:26.442 UTC**, with 4 GiB heap, 4 MiB stack, isolated workers and a 120-second probe timeout. The finite parent deadline was 15 minutes. Root's frontend correctness work ran concurrently: these times are operational records, **not a performance comparison**. No unsupported/crashed/timed-out observations occurred. The launcher and all conformance children exited successfully.

Clang16's exact executable hash/version and `CC`, `CPATH`, `LIBRARY_PATH`, `LD_LIBRARY_PATH` are recorded. Candidate/reference native runtime inputs and foreign effect files are retained. System headers/libraries and the recorded Node/Clang binaries remain external toolchain prerequisites; this is not a hermetic toolchain archive or GPU validation.

From `selfhost/`, set the same toolchain environment documented in the plan, then use a fresh output directory:

```sh
timeout --kill-after=5s 930s taskset -c 3 \
  node --stack-size=4096 --max-old-space-size=4096 \
  tools/performance/phase5/final-backends.mjs \
  build/phase5/integration/attempt-05 \
  tests/frontend/phase5-final-backends/cases.json NEW_OUTPUT
```

The [evidence manifest](final-backends-evidence/manifest.json) indexes the raw paired observations, retained requests/responses and replay commands, all C/program artifacts, exact consumed tool/source inputs and earlier fixture failures. `native-inputs.json` maps each positive native observation to its C/executable hashes. Every compressed archive member was read back and checked.
