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

## Current checkpoint and retained history

Selected frozen `checked-direct06` implements callable libraries, CLI pure/IO programs,
CPS foreign effects, and byte-exact vendored Base JS providers. Its maintained
validation passed, and its 26-row JS census agreed on all observations (22 fixture
passes and four unchanged not-applicable rows). Independent semantic controls
completed **95/96** scenarios across 29 fixtures: the retained NaN-table bit
witness still failed. Pinned TypeScript returns 1, direct returns 39, and the
independent source oracle expects 40. This prevents a blanket semantic or full
conformance claim; it is not waived by benchmark success. The separate eight-point
intrinsic smoke and timing screen completed and passed. The subsequent selected
06 final corpus completed all 45 points/669 samples. Installation and verification
also passed, with all 42 legacy and 18 direct ordinary/relocated checks. These
release/interface gates do not change the failed semantic aggregate.

Receipts are `selfhost/build/phase52/{maintained06,direct-conformance06,
semantic-direct06-controls01,smoke-direct06-intrinsics,
screen-direct06-intrinsics}/report.json`. Selected 06 is installed; the default
legacy compatibility interface remains unchanged and direct remains opt-in. Candidate 07 was rejected: its
ordered-argument eight-point screen was 25.75% slower than 06, and exact 06 source
was restored. The [07 report](../../../build/phase52/screen-direct07-ordered/report.json)
and [rejection notes](../../../../implementation/phase52/remaining-work.md) remain
retained. The [release qualification receipt](../../../build/phase52/release-qualification06-final01/report.json)
joins selected identities, successful gates, and preserved failed attempts. Final
portable publication and numerical summaries belong to the root report.
See [full-plan.md](full-plan.md) for fresh selected-image acquisition, smoke, three
15-point rotations and aggregation, and [release-qualification.md](release-qualification.md)
for the later install/verify/42-CLI/18-direct qualification bundle. Those plans
authorize no targets by themselves.

Historical upstream acquisition of frozen catalog v3 completed 18 checked
emissions (14 libraries/four programs), following a preserved environment-only
failure in `semantic-upstream03`. That acquisition did not execute its 59
scenarios. Later independent catalogs and runners extend this scope; old attempts
and catalog/tool bytes remain retained. The first full direct05 campaign completed
30/45 points and 444 samples before its final batch was held for a successor;
those partial timings are not mixed into a new final-image aggregate.

The data-only [reference freezer](freeze-reference.py) copied the saved Phase51
and TypeScript modules without compiling or executing them. All 45 points remain
at `selfhost/build/phase52/reference01/manifest.json`, SHA256
`b64c2be861da1a69dc51cfddae6d90c64942d1e9a106ae240cb18752b6117930`.
Phase51 API is `c15718cbf3e744e47c0795d7d78db6351a61c21983f53ec9c722272782dba061`;
its runtime is `3158f543b3fb67d2319a83e18485c116708bc8f17998e602f29ee95e83c05e46`.
Both original portable bundles remain untouched.

## Checked acquisition interface

[prepare-v2.py](prepare-v2.py), with [emit-worker-v2.mjs](emit-worker-v2.mjs), is the current versioned successor of the maintained program
acquirer. Its candidate backend is explicit: `--backend direct` calls
`inspect(source,{mode:'library',backend:'direct'})`. A successful checked result
must explicitly report `backend:'direct'`; unsupported emission never silently
uses the legacy backend. The actual direct runtime is required in the driver's
`result.files`, separately pinned as `compiler.directRuntime`, and checked
against the emitted prefix, allowing only the reviewed ESM `createRequire`
prologue before the exact runtime bytes. The original consumed prototype tools
remain preserved. The old `attempt.runtime` is labelled identity-only
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
This is a regression corpus, not an untouched holdout or a universal parity claim.

Root alone authorizes and serializes checked builds and target jobs. Example
commands below are recipes; choose an actual checked attempt and fresh outputs.
Do not rerun an acquisition already bound to the same checked source and image.
Do not pin the launcher parent to CPU0: target launchers must see CPU3 in their
inherited affinity. Each tool owns one existing ExecutionGuard; do not nest guards.

```sh
P52_NODE=/home/ai/.nvm/versions/node/v24.18.0/bin/node
P52_IMAGE=direct06  # Selected frozen image; every execution output must be fresh.
P52_ATTEMPT="selfhost/build/phase52/checked-$P52_IMAGE"
P52_CASES=test-rle-roundtrip,test-morning-program,coverage-expression-128,lexer,coverage-numeric-recurrence-1024,complete-generic-row32,coverage-closures-64,tree-bitonic
python3 selfhost/tools/performance/phase52/prepare-v2.py \
  --attempt "$P52_ATTEMPT" --backend direct --role candidate \
  --catalog selfhost/tools/performance/phase37/catalog.json --cases "$P52_CASES" \
  --node "$P52_NODE" --cpu 3 --heap-mib 1024 --rss-mib 2048 \
  --available-mib 4096 --timeout 180 --out "selfhost/build/phase52/prepared-$P52_IMAGE-screen"
python3 selfhost/tools/performance/phase52/compare.py \
  --catalog selfhost/tools/performance/phase37/catalog.json \
  --baseline selfhost/build/phase52/reference01/manifest.json \
  --candidate "selfhost/build/phase52/prepared-$P52_IMAGE-screen/manifest.json" \
  --budget 60 --cases "$P52_CASES" --node "$P52_NODE" --cpu 3 \
  --rss-mib 2048 --available-mib 4096 --out "selfhost/build/phase52/screen-$P52_IMAGE"
```

The screen requires 72 samples if all three roles complete all three rounds.
The nominal 60 preset controls warmup/calibration/rounds; incomplete rotations
do not yield valid ratios. For a root-admitted scoped comparison, acquire
`--set full` once for the final image, then use the three exact 15-point lists in `profiles.json`, each with the unchanged
600 preset and fresh output. Their 219/225/225 samples total 669; the original
raytrace point retains its three-round exception. A complete 45-point comparison
does not fit a single 600-second run. Other retained presets 20/300 remain available
for explicitly selected smaller/deeper checks, with their original semantics.

## Independent semantic acquisition

The semantic owner maintains `semantic-*` and `fixtures/`; their independent
scenario runner is separate from benchmarking. [acquire-semantics-v2.py](acquire-semantics-v2.py)
emits each catalog case under the same bounds and retains all failures. Catalog
mode `program` maps to driver mode `compile` and upstream `js_book`; library
mode maps to `js_lib(book,true)`. It does not execute the emitted modules.

```sh
python3 selfhost/tools/performance/phase52/acquire-semantics-v2.py \
  --catalog selfhost/tools/performance/phase52/semantic-catalog-v8.json \
  --selection "$P52_ATTEMPT" --role direct \
  --out "selfhost/build/phase52/semantic-$P52_IMAGE-fresh"
```

Catalog v8 has 20 libraries and nine programs. This requires executable direct
emission for every program fixture; an explicit refusal remains a failed acquisition, not a dropped test. The direct
manifest includes its exact checked attempt identity. Use
[semantic-full-join-v4.py](semantic-full-join-v4.py) to join the exact direct and pinned reference acquisition receipts required by that catalog, preserving
all source/tool/catalog identities. Do not hand-edit roles or drop a failing case.
The versioned semantic runner compares named values, errors, effects and callable
behavior; old legacy-descriptor tests cannot substitute for this new contract's independent controls.
