# Final installed-release qualification commands

Prepared only; nothing in this bundle grants installation or reports a pass.
Root must first close final checked-candidate semantics, maintained conformance,
full 45-point timing, and cost/release selection. The current data-only plan uses
`checked-direct06`; regenerate it for a later selected attempt (for example 07).
The generator reads selected equality API and compiler-source hashes from the
attempt/bootstrap receipts and binds the direct runtime from that snapshot.

From the repository root, prepare a fresh plan without executing targets:

```sh
python3 selfhost/tools/performance/phase52/release-qualification-plan-v2.py \
  selfhost/build/phase52/checked-direct06 \
  selfhost/build/phase52/release-qualification06 \
  --plan selfhost/build/phase52/release-qualification06-plan.json
```

The v2 generator creates its plan exclusively and refuses an existing path; the
prepared v1 example and producer remain unchanged. An optional `--ledger EXISTING_LEDGER` adds the maintained Phase43 journal wrapper;
the ledger must already exist. The prepared example is
`tools/performance/phase52/release-qualification06-plan.json` (relative to
`selfhost/`). It contains exact ordered argv for install, verify, the inherited
42-check CLI smoke, the new 18-check direct smoke, and final verify. Both smoke
controllers receive the selected API identity; direct smoke additionally receives
the selected compiler-source and direct-runtime identities. Installation uses the
attempt's explicit derivation when present.

When root assigns the serial target slot and approves release admission, execute
each `guardedArgv` from the plan, in order, from its `cwd`. The existing Phase46
job guard owns the **only** execution lock, pins CPU 3, caps the process-tree RSS
at 2048 MiB, requires 4096 MiB host headroom, and writes `job-NAME/process.json`.
The optional Phase43 journal does not acquire a lock. The inherited 42-check
launcher supervises children without acquiring another execution lock; the direct
controller also has no lock. Do not wrap `guardedArgv` in another ExecutionGuard.
If the parent scheduler already owns the guard, execute the plan's raw `argv`
through that scheduler instead. Each output path must be fresh.

Require every supervised job to complete. Inspect `legacy42/launcher.json` and
`legacy42/checks/report.json`: both pass, exactly 42 steps, selected API, no failed
children or changed inputs. Inspect `direct18/report.json`: complete/pass, exactly
18 steps, all selected pins correct, no changed inventory/fixtures/generated
modules, ordinary and relocated interface checks passed, deliberate copied
runtime tamper rejected for that exact path and original bytes restored. Final
`release.mjs --verify` must return the selected API/source identities; the release
manifest must bind the selected direct runtime. Smoke success is packaging and
interface evidence; it does not replace runtime performance or broad conformance.

## Frozen 06 static packaging inspection

The frozen 06 driver canonicalizes the selected Base path before effect-directory
comparison. Its request-local resolver requires exact pinned Base content,
canonical sibling `effs/` directory, and the 37-name provider allowlist. It keeps
the original source name for namespace resolution and records the actual vendored
source and manifest as inputs. Custom Base content/unlisted names retain original
paths. All 37 frozen providers match the pinned source hashes and byte counts;
the selected Base hash matches the provider manifest. Current driver, release
producer, manifest, and direct runtime match the frozen 06 files. The release
producer inventories the entire vendored directory against the selected snapshot,
so both smoke relocation inventories include providers, manifest, attribution,
and license. No standalone-path blocker was found in this static inspection.
