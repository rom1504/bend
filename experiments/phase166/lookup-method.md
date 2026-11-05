# Same-source complete compiler lookup

This is a bounded transfer test of the selected compiler's actual `lookup`,
`index_hash`, `index_find`, `index_bucket`, `p137q_name_eq` and `p88_string_eq_go`
paths. It reuses the exact Phase163 fixtures and complete-result consumer.
There are 18 complete KDef results per round: ten existing cases cover first
duplicate, Unicode/empty names, missing results, a real FNV collision leaf and
the legacy index; eight additions use actual helper spellings with equal,
early/late mismatch, prefix and Unicode cases. This is a compact diagnostic,
not representative coverage of arbitrary map sizes, internal trie depth or
compiler workloads. No index insertion/zipper optimization is included.

Each round changes record IDs, builds the fixture books, performs the real
lookups, visits every returned scalar/character/nested field with unchanged
`p163r_digest`, mixes all three digest words, and releases the round before the
next one. Held books preserve compiler-like aliasing. Construction, lookup,
ownership adapters, result consumption and teardown all remain charged. The
digest consumer itself allocates work-list cells, so a whole-workload ratio is
not an equality-loop-only ratio. Early complete-value controls export
`p166l_values(i)` and the independently constructed `p166l_expected_values(i)`.
The Python oracle specifies literal expected records and serializes their fields
without calling either compiler or any lookup algorithm; the checksum is a
timing gate, not a substitute for those complete-value controls.

## Complete-value control API

`lookup-expected-values.json` contains all 18 literal records, every KDef/KTerm
field, and all list constructors at i=0,1,7. It is generated from the independent
Python literal results, not either compiler's observed output. `check-lookup.mjs`
strictly compares the raw returned objects against that file, saving any mismatch,
before calling the digest at all. It then checks n=0,1,2,7 against the separately
calculated expected scalars. The extra expected Bend builder is available for
debugging, but this control does not use it as its oracle.

Prepare a fresh API source from the exact qualified Phase152 maintained parent:

```sh
python3 -B experiments/phase163/tools/prepare.py \
  --module selfhost/tests/phase163/direct-workloads.bend \
  --module selfhost/tests/phase163/direct-runtime.bend \
  --module selfhost/tests/phase166/lookup-workload.bend \
  --export p166l_values --export p166l_expected_values --export p166l_run \
  --out selfhost/build/phase166/lookup-api-source01
```

Root executes each following job under its resource/disk guard; these are explicit
commands, not a claim they already ran:

```sh
selfhost/.assets/bin/bun selfhost/tools/build/hosted.mjs acquire \
  --source selfhost/build/phase166/lookup-api-source01/compiler.bend \
  --exports selfhost/build/phase166/lookup-api-source01/exports.json \
  --upstream selfhost/.bootstrap/upstream-phase66 \
  --engine selfhost/.assets/bin/bun \
  --out selfhost/build/phase166/lookup-api01
selfhost/.assets/bin/bun experiments/phase166/check-lookup.mjs \
  selfhost/build/phase166/lookup-api01/report.json \
  selfhost/build/phase166/lookup-controls01
```

This acquires a checked hosted control API from the selected source. It does not
execute any native product or grant native qualification. The existing qualified
compiler image is not silently mutated to add these experimental exports.

Source extraction, no compiler execution (fresh root required):

```sh
python3 -B experiments/phase163/tools/prepare.py \
  --module selfhost/tests/phase163/direct-workloads.bend \
  --module selfhost/tests/phase163/direct-runtime.bend \
  --module selfhost/tests/phase166/lookup-workload.bend \
  --module selfhost/tests/phase166/lookup-main.bend \
  --export main --export p166l_values --export p166l_expected_values \
  --out selfhost/build/phase166/lookup-source01
python3 -B experiments/phase166/lookup-oracle.py --rounds 1000
```

This expected stdout is `2231325349\n`. Use `lookup-10000-main.bend` instead for
the longer point, expected `3279346725\n`; require an observed runtime long
enough to resolve differences before timing multiple pairs. Smaller controls:
0→2166136261, 1→953560951, 2→2065683247, 7→2168612185, 100→1570147109.
`lookup-oracle.py --values I` also writes independently specified complete field
arrays, with no target execution. Full hosted equality at i=0,1,7 and independent
Python digests should precede timings. The source gate and runtime output gate
are separate from proof claims: existing helpers include `@unsafe` declarations.

Use the *same extracted source bytes* for all three products. Reuse the qualified
Phase152 QBE API/image and mature-C API used by Phase165's complete backend replay;
pin the actual executing image, not only its label. Machine assets are
`selfhost/manifests/assets-native.json`: QBE construction uses maintained
`selfhost/tools/build/native.py --target qbe --ir FILE --assets ASSETS --out FRESH`,
while mature C uses the manifest's exact C toolchain recipe. Bendc checked C
emission uses the already acquired bounded-search seed from
`selfhost/build/phase160/capped-seed01/report.json`, with its existing exact
runtime/Clang recipe and explicit Base. Do not blindly invoke the Phase165
`backend-machine-v2.py` fixture whitelist or compiler-source acquisition adapter
on this new program. Root should reuse their authenticated construction steps.
If backend loaders need different source formatting, first prove complete parsed
structure identity and report that bridge; do not silently call it byte-identical.

Root owns all guarded builds/runs, balanced serial CPU3 order and the unchanged
5 GiB reserve. With only about 60 MiB above that reserve, admit the complete
emission/object/ELF budget before creating products. Existing source extraction
and the new source/oracle files are small; this preparation acquires no image.
Keep runtime memory policy, worker count, BANGS and compiler provenance explicit.
Do not reuse the historical two-role timing script unchanged for three roles.

Cheapest inspection: inspect emitted workers before profiling. Decode the actual
QBE `p113d_...$direct.p88_string_eq_go`, borrowed-read/owned variants and
`index_hash/index_find/index_bucket/lookup`, then use `nm -S` and focused
`objdump --disassemble=EXACT_SYMBOL` on only those retained symbols. Compare
ordinary C and Bendc's actual `F_/U_` specialized bodies; do not infer work from
source names alone. Count machine instructions, frame bytes and static
keep/sink/borrow-guard/allocation/scheduler call sites separately from dynamic
cost. Existing qualified QBE readers are heap-allocation-free but use alias/RC
adapters and stack scratch; a whole lookup can still allocate/retain/reclaim.
If lookup results dominate with neutral reader code, inspect construction and
the full-result consumer before changing equality again.

Preparation only. No compiler or generated target was run by this source lane.

## Prepared extraction and three-path plan

The source-only extractions now exist, with zero maintained-declaration overrides:
`lookup-api-source01/compiler.bend` is 15,368 bytes, SHA256
`8b989b907d4c2b2a26aa4e55ec954d0472aa01b96259c811643ab9385d8ca488`;
`lookup-source01/compiler.bend` is 15,407 bytes, SHA256
`44865bdac59f2debc541c9cfb39447258c2f3aed858d9c9844f1021a747364ba`.
The first exports complete-value controls and the runtime function; the second
also contains the exact main1000 entry. Both are under `selfhost/build/phase166/`.

`lookup-plan.py` prepared `selfhost/build/phase166/lookup-plan01/plan.json` without
running its five jobs. Its `lookup-products01` execution root remains fresh.
`lookup-emit.mjs` passes one actual checked live request to the selected Phase152
QBE and mature-C backends, using their original complete final gates/renderers;
it explicitly refuses foreign-effect paths for this pure fixture. Bendc emission
uses the same source/Base bytes and the already acquired bounded-search seed.
Machine construction uses maintained `native.py` and the exact retained C
recipes, with separately stated compiler/runtime identities. The plan preserves
default unboxing: `BEND_UNBOX` is absent, and a disabled-unboxing arm requires an
observed failure plus a new treatment. No such fallback is preselected.

Root must verify `lookup-controls01/report.json` has complete raw-value gates
before running native digest/timing jobs; native outputs then must equal the
independent decimal oracle. The plan specifies fresh-process argv, environment
clearing, expected stdout and a bounded adaptive 0–4 cycle policy. It does not
execute those jobs or replace root's resource guard, receipts or retention.

## Consumer counterfactual prepared after the resolved timing point

`lookup-consumer-control.bend` copies the original three loop/fold definitions
under `p166c_*` names and replaces only the round producer with
`p166l_expected_values(i)`. It retains changing IDs, the exact full-field digest,
the same fold and 10,000 rounds. Original fixtures remain pinned and unchanged.
This tests independent expected-record production plus the same consumer;
producer allocation, reachability, inlining and lifetime can change, so differences
are not an exact subtraction of lookup time.

Source-only extraction `lookup-consumer-source01/compiler.bend` has 46 declarations,
zero overrides, 15,589 bytes and SHA256
`bb91456a7223dba7ff19992ba947394c0b0dc50056137f623a069816364bfda3`.
New `lookup-plan-v3.py --role expected-records --rounds 10000` produced
`lookup-consumer-plan01/plan.json`, with fresh run root
`lookup-consumer-products01` and independent expected stdout `3279346725\n`.
It keeps the three original compiler/runtime recipes and default unboxing.
Neither preparation executed a compiler or target; root owns the comparison.

## Executed points and producer control

The 1000-round point was below the timing floor for bendc. Source02 uses
`lookup-10000-main.bend`; its only source-byte change is1000→10000. Create its
plan using `lookup-plan-v2.py --rounds 10000 --preparation SOURCE/manifest.json
--out FRESH_PLAN --run-root FRESH_PRODUCTS`. The `lookup-run.py` adapter runs
that plan inside one declared disk/process guard and requires the checked raw
control report with `--controls`.

For the expected-record producer control, extract the same Phase163 modules plus
`lookup-workload.bend`, `lookup-consumer-control.bend`, and
`lookup-consumer-main.bend`, exporting `main`, `p166l_values` and
`p166l_expected_values`. Plan with `lookup-plan-v3.py --role expected-records
--rounds 10000` and the same preparation/output/run-root arguments. The complete
literal raw control for the expected builder is `check-expected.mjs RECEIPT OUT`,
using the already checked small API. This control changes producer sharing and
reachability; do not subtract it as isolated lookup time.

All native outcomes and the complete results are in the
[Phase166 report](../../implementation/phase166/README.md). The general profiler
uses the pinned all-thread collector,40 captures per binary at alternating8/13ms,
and three separate clean runs. `lookup-profile.py` sets the same explicit runtime
policy as the build/timing adapter. No full compiler acquisition is needed.
