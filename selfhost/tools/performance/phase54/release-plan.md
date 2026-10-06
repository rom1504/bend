# Phase54 provisional release handoff

Prepared data only; no installation, verification subprocess or compiler target
was run. `checked-graph02` is a candidate until root selects it after the required
semantic, maintained, scaling, performance/profile and release review gates.
This plan does not grant admission. Historical Phase53 producers and receipts
remain unchanged.

## Exact prepared identities

The fresh plan is `selfhost/build/phase54/release-plan-graph02/plan-v1.json`.
It binds the checked attempt, source, selected equality-derived API, Node,
providers, runtime and tools. Its current pins are:

- API: `d7d0396cda189918299ddeb0105e9d682f6a22bffa70004ab6d0ebeac20f4857`.
- Source: `32cddcf1a970a9726a9785b30269cdd8a0047f917f769a964995fa6a0633de84`.
- Direct runtime: `c328b77360c98489343d4752d4644d93f64de9d697d2c964f5fbae6442a77d23`.

If root selects another attempt, prepare a new plan/output. Do not edit this
consumed plan, substitute hashes or select the newest directory by timestamp.
The following command uses the unchanged reviewed Phase53 plan maker; it only
prepares argv and hashes. The already-produced graph02 plan cannot be overwritten.

```sh
python3 -B selfhost/tools/performance/phase53/release-qualification-plan-v1.py \
  SELECTED_ATTEMPT NEW_RELEASE_OUTPUT --plan NEW_PLAN.json
```

The historical `phase53-default-release-qualification-plan` kind identifies the
method. The selected attempt/API/source/runtime identities establish which image
is being qualified; no receipt label is rewritten into new evidence.

## Five execution steps, only after slot transfer

Run the exact generated steps sequentially:

1. `install`: `release.mjs --install-attempt SELECTED_ATTEMPT` (300 seconds).
2. `verify-before`: `release.mjs --verify` (120 seconds).
3. `legacy42`: unchanged Phase53 legacy launcher/runner, explicitly selecting
   `--legacy-js`; exactly 42 ordinary/relocated checks, including CPU build/run,
   source checking, interpretation and integrity (1200 seconds).
4. `default24`: unchanged Phase53 default controller; exactly 24 checks covering
   omitted/default direct JS, emitted ESM, callable/partial exports without G,
   IO print, explicit legacy exports, relocation, copied-runtime tamper rejection
   and exact restoration (900 seconds).
5. `verify-after`: `release.mjs --verify` (120 seconds).

The plan's `argv` supplies the selected Node, 4096 KiB V8 stack and 1024 MiB heap.
Its `guardedArgv` applies the existing Phase46 sole execution guard on CPU3,
2048 MiB tree RSS and 4096 MiB available-memory floor. Run `guardedArgv` from an
unlocked serial scheduler. If an outer scheduler already owns that guard, run
`argv` instead. Never nest execution locks. An optional existing ledger adds the
Phase43 journal wrapper; it does not add an execution guard.

Require successful job/process receipts, legacy launcher plus all 42 rows,
default report plus all 24 rows, unchanged inventories and final exact API/source/
runtime identity. Preserve failures. A retry uses fresh output directories and
a hash-bound argv-only successor; it retains the same producer and assertions.
Sandbox `spawnSync EPERM` previously affected Clang/Node children. If repeated,
preserve the failed receipt before an appropriately authorized environment retry.
Do not reinterpret it as a compiler semantic failure or a successful gate.

## Preserve the previous Phase53 release

Current installed API is
`3e3fb8c3bc4c445567696ce62bd95979e36746ddde5bb9e0aad3038fc362c9b9`.
Graph02 has a different API, so the existing installer automatically preserves
seven previous artifacts under:

```text
selfhost/dist/release-history/3e3fb8c3bc4c445567696ce62bd95979e36746ddde5bb9e0aad3038fc362c9b9/
  typed-api.mjs
  base.bend
  release-lineage/checked-api.mjs
  release-lineage/checked-bootstrap.json
  release-lineage/derivation.json
  release-lineage/equality.mjs
  release.json
```

`selfhost/build/phase54/release-plan-graph02/history-plan-v1.json` binds their
current bytes/hashes. Rehash before installing, then verify every saved copy.
The new directory is separate from the four protected inherited history dirs;
root stages only these new files after verification. No archive copy or staging
was performed here. The final closure must retain the authoritative 103-file
protected audit, including those inherited history directories.

If a later selected image has the same API as the installed one, the installer
API-only history condition does not preserve a changed manifest/runtime by itself.
Use a fresh manifest-addressed prior-release preservation plan before installation.
Do not change the historical installer or overwrite an existing history file.

## Limits and final receipt

No new release blocker was found in plan generation: candidate/live driver,
release producer, runtime and provider manifest match the frozen candidate inputs.
The installer additionally checks every live manifest Bend module against the
selected snapshot. Source/host/provider drift after plan preparation requires
fresh admission and a fresh plan rather than altered expected hashes.

After all five steps pass, a small final release receipt should join selected
identities, every successful job, any preserved failed attempt/retry, 42/24 counts,
prior-history byte verification and inventory/tamper restoration. The unchanged
Phase53 controllers may retain their historical report kinds; record their exact
hashes and selected image. Installation/interface success remains separate from
semantic equivalence, compiler-throughput, native/GPU performance and any new
self-emitted fixed point. Root owns installation, publication, staging and commits.
