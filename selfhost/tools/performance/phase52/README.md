# Direct JavaScript backend qualification and comparison

Phase52 evaluates a new JavaScript calling contract. The three timing roles are
the selected Phase51 compiler, a checked direct-backend candidate, and pinned
upstream TypeScript. See [ABI.md](ABI.md) for the contract. No result here implies
compatibility with the old selfhost `G`, descriptors, private-entry permissions or
their mutation hooks. Compiler acquisition, semantic observations, runtime timing
and release decisions remain separate.

The [45-point catalog](../phase37/catalog.json), input values and exact output
oracles remain unchanged. The [timing worker](../programs/execute.mjs) already
calls `module.default[exportName](...args)` and needs no direct-backend change.
It validates every invocation, with import/first-call measurements separate from
warmup and timing. The [comparison wrapper](compare.py) reuses the unchanged
runner and writes a separate `phase52-comparison.json` that explicitly labels
the contract change. The underlying `report.json` remains the retained timing
method's receipt; it is not silently redefined as legacy-ABI qualification.

## Current acquisition status

Root-authorized upstream acquisition of frozen `semantic-catalog-v3.json`
completed **18/18 checked emissions**: 14 libraries and four programs. This is
not execution of the 59 semantic scenarios. The manifest is
`selfhost/build/phase52/semantic-upstream04/manifest.json`, SHA-256
`c0e0e8f6fc03939806b05e1773073eea8b783f04a143cb0bf156a55f0b24cab4`.
The 18 guarded jobs occupied 11.8852 seconds in total and peaked at 154,800,128
bytes of process-tree RSS. Each retained a 1GiB heap, 2GiB RSS limit, 4GiB
available-memory floor and CPU3 affinity.

The first `semantic-upstream03` attempt failed before parsing because the sandbox
denied Node's read-only `spawnSync git` verification. All failures remain intact.
The successful retry used the identical scripts/catalog with approved execution
permission. No fixture was rewritten in response to that environment failure.
No direct compiler or generated program was executed by the harness author.

The data-only [reference freezer](freeze-reference.py) copied the saved Phase51
and TypeScript modules without compiling or executing them. All 45 points are
available at `selfhost/build/phase52/reference01/manifest.json`, SHA-256
`b64c2be861da1a69dc51cfddae6d90c64942d1e9a106ae240cb18752b6117930`.
Phase51 API is `c15718cbf3e744e47c0795d7d78db6351a61c21983f53ec9c722272782dba061`;
its runtime is `3158f543b3fb67d2319a83e18485c116708bc8f17998e602f29ee95e83c05e46`.
Both original portable bundles remain untouched.

## Checked acquisition interface

[prepare.py](prepare.py) is a versioned successor of the maintained program
acquirer. Its candidate backend is explicit: `--backend direct` calls
`inspect(source,{mode:'library',backend:'direct'})`. A successful checked result
must explicitly report `backend:'direct'`; unsupported emission never silently
uses the legacy backend. The actual direct runtime is required in the driver's
`result.files`, separately pinned as `compiler.directRuntime`, and checked
against the emitted prefix. The old `attempt.runtime` is labelled identity-only
for this backend and is not prepended by the acquisition worker.

Adjacent `.mjs.json` receipts retain checked attempt/API/Base/driver/source/catalog
identities and actual emission inputs. Candidate bundles use role `candidate`
and `callingContract:'upstream-compatible-direct-v1'`. For the one generic-row
observer, direct candidates use the same named/native layout as upstream:
`JSON.stringify([st.a,st.b,st.prev,st.cur])`. The Phase51 baseline preserves its
original complete observer. All four arrays are observed and observer work
remains timed; this is not a reduced checksum or partial-result comparison.

The [eight-point screen](profiles.json) covers RLE, Morning, expression128, lexer,
numeric1024, complete generic row, closures64 and tree-bitonic. These cover
independent ADT/recursive, callback, numeric and array workloads. They are a
deliberately selected rejection screen, not a representative probability sample
of every Bend program. Full45 retains all existing families and point weights.

Root alone authorizes and serializes checked builds and target jobs. Example
commands below are recipes; choose an actual checked attempt and fresh outputs.
Do not rerun an acquisition already bound to the same checked source and image.
Do not pin the launcher parent to CPU0: target launchers must see CPU3 in their
inherited affinity. Each tool owns one existing ExecutionGuard; do not nest guards.

```sh
P52_NODE=/home/ai/.nvm/versions/node/v24.18.0/bin/node
P52_ATTEMPT=selfhost/build/phase52/checked-direct01
P52_CASES=test-rle-roundtrip,test-morning-program,coverage-expression-128,lexer,coverage-numeric-recurrence-1024,complete-generic-row32,coverage-closures-64,tree-bitonic
python3 selfhost/tools/performance/phase52/prepare.py \
  --attempt "$P52_ATTEMPT" --backend direct --role candidate \
  --catalog selfhost/tools/performance/phase37/catalog.json --cases "$P52_CASES" \
  --node "$P52_NODE" --cpu 3 --heap-mib 1024 --rss-mib 2048 \
  --available-mib 4096 --timeout 180 --out selfhost/build/phase52/prepared-direct01
python3 selfhost/tools/performance/phase52/compare.py \
  --catalog selfhost/tools/performance/phase37/catalog.json \
  --baseline selfhost/build/phase52/reference01/manifest.json \
  --candidate selfhost/build/phase52/prepared-direct01/manifest.json \
  --budget 60 --cases "$P52_CASES" --node "$P52_NODE" --cpu 3 \
  --rss-mib 2048 --available-mib 4096 --out selfhost/build/phase52/screen-direct01
```

The screen requires 72 samples if all three roles complete all three rounds.
The nominal 60 preset controls warmup/calibration/rounds; incomplete rotations
do not yield valid ratios. For an accepted candidate acquire `--set full` once,
then use the three exact 15-point lists in `profiles.json`, each with the unchanged
600 preset and fresh output. Their 219/225/225 samples total 669; the original
raytrace point retains its three-round exception. A complete 45-point comparison
does not fit a single 600-second run. Other retained presets 20/300 remain available
for explicitly selected smaller/deeper checks, with their original semantics.

## Independent semantic acquisition

The semantic owner maintains `semantic-*` and `fixtures/`; their independent
scenario runner is separate from benchmarking. [acquire-semantics.py](acquire-semantics.py)
emits each catalog case under the same bounds and retains all failures. Catalog
mode `program` maps to driver mode `compile` and upstream `js_book`; library
mode maps to `js_lib(book,true)`. It does not execute the emitted modules.

```sh
python3 selfhost/tools/performance/phase52/acquire-semantics.py \
  --catalog selfhost/tools/performance/phase52/semantic-catalog-v3.json \
  --selection "$P52_ATTEMPT" --role direct \
  --out selfhost/build/phase52/semantic-direct01
```

This requires executable direct emission for the four program fixtures; an
explicit refusal remains a failed acquisition, not a dropped test. The direct
manifest includes its exact checked attempt identity. Merge its `roles.direct`
with the frozen upstream manifest's `roles.typescript`, preserving their catalog
and input receipts, only after both acquisitions pass. The semantic runner then
compares named values, errors, effects and callable behavior; old legacy-descriptor
tests cannot substitute for this new contract's independent controls.
