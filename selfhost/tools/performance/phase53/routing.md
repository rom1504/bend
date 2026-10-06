# Phase53 JavaScript routing

The driver defaults to direct JavaScript for checked `compile` and `library`
requests and `execute`. Pure interpreter requests still use the normalizer; an
IO interpreter request uses the direct program emitter. Parse/check and native
planning retain their previous route. An unsupported direct construct fails
explicitly; no TypeScript or legacy fallback is implicit.

`--legacy-js` explicitly selects the old descriptor interface. `--direct-js`
remains an explicit alias for the new default. These selectors are mutually
exclusive and reject native-only output requests. Without a JS selector, C,
binary, CPU, Metal and CUDA requests retain native routing; a mixed `.mjs`/`.c`
request selects each emitter independently.

API callers can retain the old descriptor contract with `backend:'js'`.
`legacy-driver.mjs` supplies this default for successor historical control plans
without modifying their consumed producers. Explicit `backend:'direct'` remains
available. Bootstrap `stage0-library.mjs` directly calls pinned `C.js_lib`;
compiler-image generation never depends on the new public default.

Maintained `backend-test-api.mjs` only loads a checked API and does not emit
JavaScript, so it has no implicit backend selector to migrate. Existing private compiler images freeze their own historical driver and remain
unchanged. Newly built private images need explicit legacy selection in their
worker/session/reference controls because packaging presently copies only the
legacy runtime; public-default adoption there is a separate migration.
Historical Phase30 library-cost and Phase52 legacy emit jobs omitted their
backend: their successor plans must use an explicit selector or this adapter.
Neither old byte-equality receipts nor old descriptor tests can be relabeled as
direct qualification.

The narrow routing test executes the actual CLI router with emission/run spies,
without compiling or running Bend programs:

```sh
node selfhost/tools/performance/phase53/default-routing-tests.mjs
```

For a selected and installed qualified image, the new release smoke
checks ordinary and relocated default direct interfaces plus explicit legacy
interfaces, all 24 rows, runtime tampering and restoration. It requires exact
selected hashes and a fresh output, under the existing bounded supervisor:

```sh
node selfhost/tools/performance/phase53/default-release-smoke-v1.mjs \
  selfhost NEW_OUTPUT API_SHA256 SOURCE_SHA256 DIRECT_RUNTIME_SHA256
```

This is an interface/release check, not a replacement for the semantic or
performance gates. Selected ordered02 passes all 24 rows; the companion
explicit legacy gate passes all 42. The
[installed-release receipt](evidence/installed-release.json) records ordinary and
relocated checks, integrity, tamper restoration and the installed complete-row
acquisition probe. The first legacy run had six sandbox Clang spawn refusals;
an unchanged permitted retry passes, and both attempts remain preserved.

The release installer verifies the full selected source/host/runtime snapshots
before publishing; however, its existing history preservation condition keys
only on API change. The original same-API correction proposal therefore included
`prior-installed-archive-plan-v1.json`, a data-only plan to preserve old manifest,
API, Base and lineage. That plan was not needed or executed: the selected ordered02
API differs, so ordinary installer history preserved all seven prior-release files
in the old API-keyed directory. Every copy was verified. No installer changed.

`legacy-release-smoke-launch-v1.mjs` retains the earlier 42-row release gate,
including CPU build/run and normalizer checks. Its runner adds `--legacy-js`
only to JS emission commands. Historical runners remain unchanged. Use this
successor for explicit legacy qualification, followed by the 24-row default
release smoke; running the old omitted-selector gate would instead test default
JS and must not be called legacy qualification.

## Final selected-attempt release commands

Prepare only after the selected checked attempt exists. The plan reads and
verifies its API/source/runtime/provider identities; no fixed image hash is
substituted. Root approval and closed semantic/performance gates precede all
execution. `NEW_OUTPUT` and `NEW_PLAN` must be fresh.

```sh
python3 selfhost/tools/performance/phase53/release-qualification-plan-v1.py \
  SELECTED_ATTEMPT NEW_OUTPUT --plan NEW_PLAN.json
```

The generated `steps` contain exact `argv` and `guardedArgv` for install,
verify-before, explicit legacy42, default24 and verify-after. From an unlocked
serial scheduler, root runs each `guardedArgv` in order. If a scheduler already
owns the execution guard, run the inner `argv` instead; never nest locks.
An optional `--ledger EXISTING_LEDGER` adds the journal wrapper only.
Require all five supervised jobs, both full reports and final identity checks
to pass. Preserve failed attempts and use fresh retry outputs.
