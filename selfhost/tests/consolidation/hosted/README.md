# Hosted continuity controls

The maintained hosted adapter is [`tools/build/hosted.mjs`](../../../tools/build/hosted.mjs). It imports the existing typed driver for the frontend, direct JavaScript, legacy JavaScript and C. Every language operation runs the selected generated Bend API. The upstream TypeScript compiler is used only by the explicit `acquire` command to check the assembled compiler and construct B1; ordinary requests have no TypeScript fallback.

`hosted-exports.json` lists the public driver roots, including the native checked-body capture entry and QBE request/cursor entries. The unchanged qualified source used in this consolidation contains all 99 actual `api.*` calls in the typed driver. The 40 declarations absent from its older modular predecessor are internal frontend/C helpers, not missing driver exports. No frontend copy or entry merge is required for hosted JS/C acquisition. Native C still needs its IO entry/profile and its own native-CLI packaging contract.

## Checked acquisition

First assemble the canonical source with `tools/build/source.py`. Run the following **inside one outer build-retention guard**, supplying an explicit disk budget and fresh output root:

```sh
selfhost/.bootstrap/bun-1.4.3/bun selfhost/tools/build/hosted.mjs acquire \
  --source /absolute/assembled/compiler.bend \
  --out /absolute/selfhost/build/hosted-b1 \
  --upstream /absolute/pinned-upstream-checkout \
  --engine /absolute/bun
```

This checks the complete source and ownership through `stage0-library.mjs`, verifies the upstream revision and inputs, and preserves stdout/stderr and a checked-B1 image binding. It neither installs an image nor claims B2 reproduction. `request.py` consumes this binding; `hosted.mjs --request PLAN --report REPORT` writes only complete emitted bytes to stdout. QBE uses the sealed Bend cursor, retaining its exact newline convention. Direct/legacy JS and C use the existing typed driver and explicitly bound runtime. JS/C currently accept live preparation only. The adapter passes `useBaseCache: false`, bypassing Base-cache reads, preparation writes and prepared backend products. Public CLI controls can select the same behavior with `BEND_TYPED_BASE_CACHE=off`; unset preserves ordinary CLI caching. The original continuity adapter incorrectly inventoried caches before the driver could create one; its output comparisons remain evidence, but its old “no preparation created” description is not an admitted preparation claim.

## Current qualification and retained migration evidence

Use the maintained [qualification runner](../../../tools/conformance/qualification.md) for current-image JS/C positive and negative gates. `live-cache.mjs` supplies the separate live-mode filesystem control described below. The independent fixtures and `worker.mjs` remain available; no ordinary request falls back to TypeScript.

The consolidation originally used three successive continuity runners against the installed JavaScript B2 and native CLI. Those runners assumed the initial checked-probe receipt and historical native-package schema; they are retired transition methods, recoverable at commit `739cb09`, rather than current release commands. Their complete emitted products, complete stdout, input pins and failures remain historical evidence. The four fixtures cover scalar calls, a nested-redex body, recursive IO/data output and a type error. A timeout, crash or stack overflow never satisfies the final negative judgment.

The initial numeric screen retained identical C output but failed machine construction because the Lean-distributed Clang needed its explicit `include/clang` resource directory. The subsequent positive screen used that directory and compared the same target runtime/provider bytes on both sides. The C reference was the actual installed native package, not the older `projection-api04` whose source differed. These finite compatibility results do not establish broad conformance or performance.

## Observed continuity and self-emission boundary

The full positive screen compared nine case/backend products byte for byte and passed all 18 complete-output executions. Its native negative was initially rejected by the harness because its text matcher did not include the actual constructor/goal error. The preserved successor uses the exact native diagnostic, status 1, empty stdout and no process failure; all three paired backend refusals passed. Neither earlier failed report was relabeled.

`live-cache.mjs` is a separate root-run control. It traps synchronous access to both driver cache directories, runs two live requests against an independently retained complete product, and checks rejection of a non-Boolean cache option. This is a filesystem/control gate, not a speed measurement.

`tools/build/js-bootstrap.mjs` performs genuine public-API B2 emission, followed by a B3 run with a fresh own-source type check and optional whole-image byte comparison. It binds the same checked source, Base, root list and current method closure. The first attempt stopped at the 3 GiB guard during annotation; its source/method/progress records remain in build evidence. The retry releases host references between stages without changing the compiler pipeline. A successful checked B1 acquisition alone never replaces the installed B2 claim.
