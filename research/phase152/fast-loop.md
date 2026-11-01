# Checked hosted emission before a full native compiler build

The existing maintained tools can check a changed complete compiler, emit an
executable QBE witness using that changed compiler, and run the witness without
first constructing another native compiler. Use a checked upstream-built B1 JS
API for this screen. This tests the compiler change and generated native program;
it does not measure the candidate compiler's eventual native request speed.

No target was run for this investigation. Costs below are retained observations,
not a new Phase152 measurement.

## Smallest complete compiler API

`selfhost/tools/build/hosted.mjs acquire` calls the maintained
`selfhost/tools/stage0-library.mjs`. The latter loads and checks the **entire**
source, rejects unresolved holes, then asks upstream `js_lib` to emit the
requested export roots and their dependencies. A six-root export manifest is
sufficient for the unchanged maintained QBE request adapter:

```json
{
  "kind": "bend-hosted-api-exports",
  "version": 1,
  "protocol": "qbe-api-v1",
  "targets": ["qbe"],
  "preparationModes": ["cache", "live"],
  "exports": [
    "p88_cache_prepare", "p86_prepare", "p86_plan",
    "p134e_plan", "p134e_begin", "p134e_next"
  ]
}
```

For a cache-only API, omit `p86_prepare` and advertise only `cache`. Additional
finite-control roots can be included in this acquisition. Do not use the default
union export manifest unless JS/C targets are needed: it roots both other
backends and their public drivers.

The adapter calls `p86_plan`, `p134e_plan`, and the cursor directly. It does not
invoke `p149_native_args` or select a Phase149 policy code. A general compiler
edit must reach these ordinary Bend entries to be exercised here. Merely
exporting a different compiler entry does not redirect `hosted.mjs` to it.

`selfhost/build/phase149/check03/api.mjs` exports **only `p149p_valid`**. Its
receipt proves complete-source checking, but it cannot emit QBE. The permissive
target label on that receipt must not be mistaken for the six required exports.
Likewise, `selfhost/.assets/native/qbe-api.mjs` is a retained Phase146 source API,
not an API of current edits; its explicit binding supports cache mode only.

## Assemble an isolated candidate with existing source transport

`selfhost/tools/build/source.py` has no overlay flag or implicit patch-chain
loader. Its existing editable recipe already supports an explicit candidate:

1. Copy the canonical manifest to a fresh candidate recipe. For each changed
   module, copy its complete bytes to a fresh path under `selfhost/build/phase152`
   and replace that module's filename at the same manifest index. Keep ordinary
   module paths pointing at `src/...`, with `--root selfhost`. This preserves
   declaration identities, order, protected bodies, and source mapping.
2. Edit the copied Bend module. Body-only edits require no inventory refresh.
   If declarations are added or removed, use the explicit `source.py refresh`
   step on the candidate recipe and review its `inventoryChange` before assembly.
   A new module must first be named in the candidate recipe.
3. Assemble the `qbe` profile to check the same complete source, including main,
   that a later native build would consume. `js-api` is also supported but omits
   main, so it produces a different source identity and excludes that declaration
   from checking. A QBE-profile source can supply a JS API: requested pure roots
   determine API emission, while the full book is checked first.

```sh
python3 -B selfhost/tools/build/source.py assemble \
  --manifest selfhost/build/phase152/candidate01/compiler.json \
  --root selfhost --profile qbe \
  --out selfhost/build/phase152/source01/compiler.bend \
  --map selfhost/build/phase152/source01/compiler.map.json
```

This uses the maintained assembler unchanged. Do not edit retained generated
source or a hardlinked retained module in place. `source.py verify` compares the
frozen extraction identity; it is not a source check after an intentional edit.

## Acquisition and complete native witness

The following are command templates, not executed jobs. Create the explicit
candidate recipe/export manifest and independent witness/output files first.
Every run path must be fresh. Each target command has one outer guard.

```sh
python3 -B selfhost/tools/build-retention/guard.py \
  --out selfhost/build/phase152/api01-guard \
  --run-root selfhost/build/phase152/api01 \
  --disk-mib 128 --seconds 60 --rss-mib 4096 \
  --available-mib 16384 --file-mib 128 --cpu 3 -- \
  selfhost/.assets/bin/bun selfhost/tools/build/hosted.mjs acquire \
    --source selfhost/build/phase152/source01/compiler.bend \
    --exports selfhost/build/phase152/candidate01/exports.json \
    --upstream selfhost/.bootstrap/upstream-phase66 \
    --engine selfhost/.assets/bin/bun \
    --out selfhost/build/phase152/api01

python3 -B selfhost/tools/build/native.py \
  --assets selfhost/manifests/assets-native.json \
  --host js --stage B1 --target qbe --mode cache \
  --image selfhost/build/phase152/api01/api.mjs \
  --image-receipt selfhost/build/phase152/api01/report.json \
  --source selfhost/build/phase152/fixture01/witness.bend \
  --expected-stdout selfhost/build/phase152/fixture01/expected.stdout \
  --retain-ir --seconds 60 \
  --out selfhost/build/phase152/witness01 --plan

python3 -B selfhost/tools/build-retention/guard.py \
  --out selfhost/build/phase152/witness01-guard \
  --run-root selfhost/build/phase152/witness01 \
  --disk-mib 256 --seconds 75 --rss-mib 4096 \
  --available-mib 16384 --file-mib 128 --cpu 3 -- \
  python3 -B selfhost/tools/build/native.py \
    --assets selfhost/manifests/assets-native.json \
    --host js --stage B1 --target qbe --mode cache \
    --image selfhost/build/phase152/api01/api.mjs \
    --image-receipt selfhost/build/phase152/api01/report.json \
    --source selfhost/build/phase152/fixture01/witness.bend \
    --expected-stdout selfhost/build/phase152/fixture01/expected.stdout \
    --retain-ir --seconds 60 \
    --out selfhost/build/phase152/witness01
```

The second guarded command performs actual changed-compiler QBE emission,
streams it through QBE, assembles, links, and executes the witness against its
independent complete stdout. `program.ssa`, `program.s`, `program.o`, `program`,
request pins, child diagnostics, output digest, and timing are retained. It does
not build a new compiler executable. When the expected QBE is unchanged, add
`--expected` with the independent complete reference. A code-generation change
normally needs the output oracle and structural inspection instead of asserting
old QBE equality.

For separate emission clocks or IR inspection before construction, use
`request.py` with the same authenticated request arguments, then
`native.py --assets ... --ir .../program.ssa --expected-stdout ...` in a separate
guard. The combined `native.py` route avoids a second orchestration step.
Close both jobs through the existing retention workflow after evaluating them.

## Explicit inputs

Acquisition pins the supplied compiler source, export JSON, Bun, `hosted.mjs`,
`stage0-library.mjs`, the current compiler manifest, and upstream
`bend2/{bend.ts,comp.ts,base.bend}`. The upstream checkout must be clean at
`059266225b77c8ca256ac6b25ee5c21449bab151`. Its explicit path is
`selfhost/.bootstrap/upstream-phase66`.

The unchanged `assets-native.json` authenticates the request and machine assets:

| Asset | Path / identity |
| --- | --- |
| Bun | `selfhost/.assets/bin/bun`, SHA256 `7ce7d6b654eddeec20afddf2396317fba6dc19ab52788a27e894e1806bf8f24b` |
| Base | Absolute pinned upstream `bend2/base.bend`, SHA256 `99ac43f2b2bb3e3f39acdcedcecbbd3cb44749ce13969c827d6973fa66f7facf` |
| Prepared carrier | `selfhost/.assets/base/base.p130`, SHA256 `984fad041a0ba855ea0aaedd384485afa2153da644655c00882eb50ace33817f` |
| QBE | `selfhost/.assets/bin/qbe`, SHA256 `1eca24288f9574ad57032ac88f11c3f74ced605838749226d77a9acd4443e5f4` |
| Runtime | `selfhost/.assets/native/qbe-runtime.o`, SHA256 `2d07832382a11d7e993124ecc70452e4e1a3b7f753cf429343e1183cd8e493a3` |
| Assembler/linker | `/usr/bin/x86_64-linux-gnu-as`, `/usr/bin/x86_64-linux-gnu-gcc-10`, identities and flags in the asset manifest |

The prepared carrier stamp includes the absolute Base path. Let the maintained
request planner derive/authenticate it; do not relocate Base or invent a stamp.
The supplied API and its fresh acquisition receipt override the old image key.

## Retained cost evidence and limits

| Observation | Acquisition seconds | Guard seconds | Peak tree RSS | Evidence |
| --- | ---: | ---: | ---: | --- |
| Phase149 complete 3.07 MB source, predicate export only | 6.837 | 7.242 | 789,741,568 B | `selfhost/build/phase149/check03/report.json`, `check03-guard/process.json` |
| Phase147 complete source, predicate export only | 6.906 | 7.297 | 801,595,392 B | `selfhost/build/phase147/integrated-plan05/source-check/report.json`, `source-check-guard/process.json` |
| Phase146 full QBE API plus controls | 15.136 | 15.851 | 2,325,843,968 B | `selfhost/build/phase111/p146-api03/report.json`, `selfhost/build/phase146/source03/checked-api-guard/process.json` |
| Consolidated full JS/C/QBE union API | 17.276 | 17.729 | 2,810,552,320 B | `selfhost/build/consolidation/hosted-current03/report.json`, `guards/hosted-current03/process.json` |
| Phase131 selector full-compiler QBE API | 14.067 | 14.735 | 2,251,493,376 B | `selfhost/build/phase111/p131-selector-api02/report.json`, `selfhost/build/phase131/selector-api02-guard/process.json` |

These support budgeting roughly 15–20 seconds and several GiB for a focused
complete-compiler API acquisition; they do not guarantee the new candidate's
cost. The Phase131 selector then emitted the unchanged safe witness in a
23.673-second guarded job, with 450,170,880 B peak RSS, before native construction
and paired execution (`selector-emit02-guard/process.json`). Its historical
emit/check scripts are provenance only; use the maintained commands above.

The closer Phase145 same-source comparison recorded a complete hosted Lexer
request at 7.391 seconds / 251,334,656 B child RSS, and compiler-index-slice at
13.721 seconds / 315,686,912 B (`execution-clean01/report.json` and
`execution-index01/report.json`). Those instruments were different adapters and
earlier source, so these are sizing observations, not Phase152 predictions.

Phase147's 74 KB renderer and 91 KB verifier slices acquired in 2.985 / 1.810
seconds (`render-fragments01/api/report.json`, `verifier-candidate04/api/report.json`).
They are extracted kernels, not general compiler images. No maintained tool was
found that produces a smaller general native compiler slice automatically.
For a new general optimization, the complete checked hosted API plus a small
native witness is the existing inexpensive semantic/structural screen. Reserve
full native compiler acquisition for changes that pass it and warrant actual
native compiler-performance measurement.

## Addendum: nullary prepared facts in the actual Phase147 compiler

A bounded read-only scan authenticated
`selfhost/build/phase147/integrated-plan05/image/program.ssa` against its retained
build receipt: 119,544,406 bytes, SHA256
`76eb1a7c500b19c86cbeaa523f4e0066cafa2588b02f729e1909ef35902c2a2f`.
This is the final N1 compiler's own QBE, not the different frozen-request QBE
used as its profiling output oracle. No compiler, generated program, or machine
disassembler was executed for this addendum.

The scan finds **13,438 nullary constructor-to-sink sequences across 4,447
generated functions**, among 13,445 nullary `p111_rt_ctor` sites and 56,598 total
`p111_rt_sink` sites. Each counted sequence is one `p111_rt_ctor` call with final
argument `w 0`, followed exclusively by zero or more `=l copy` instructions
carrying its result, then a sink of that same result. Any other instruction,
label or function boundary ends recognition. All counted constructor IDs are
0; the same file's `p111_cid_names_0` spells `Unit`. These are static sites,
including duplicated generated entry/worker variants, not execution counts or
proof that every site satisfies the candidate's prepared-fact admission.

Examples occur in workers whose source owners are visible in the final profile:

| Generated worker after decoding `FID_` | Static pairs | Example SSA line | Existing active-owner observation |
| --- | ---: | ---: | --- |
| `p113d_FID_$direct.p111_op_id` | 170 | 379355 | 32 samples during raw lowering |
| `p113d_FID_$direct.p111v_contract` | 22 | 385558 | 31 during initial optimizer |
| `p113d_FID_$direct.p111q_memory` | 10 | 433151 | 37 during rendering |
| `p113d_FID_$direct.ns_body` | 4 | 296002 | 29 during raw lowering |
| `p113d_FID_$direct.lookup` | 4 | 297521 | 70 during raw lowering |
| `p113d_FID_$direct.p144e_body_tail` | 4 | 410228 | 150 during rendering |
| `p111_FID_$direct.nc_uses_term` | 2 | 1755532 | 99 during raw lowering |
| `p111_FID_$direct.p134e_next` | 2 | 2934190 | 17 during rendering |

The owner observations come from
`selfhost/build/phase147/profile-final-analysis01/summary.json`. They locate
live compiler work, but neither assign its samples to these particular pairs
nor establish which generated variant executed a pair. For example,
`p111_op_id` contains a long ordinary `nt_choose` chain, while
`p144e_body_tail` contains nested choices around real fragment rendering.
The pattern is therefore not confined to the isolated text-dispatch witness.

The runtime limits the likely mechanism. In
`selfhost/src/runtime/qbe/runtime.c:3936`, `p111_rt_ctor` validates arity and
returns `term_pak(cid,0)` immediately when count is zero: **no heap allocation**.
`p111_rt_sink` calls `term_sink`, whose trivial-value check skips `term_drop`
for that packed Unit. The removable work is calls, checks, argument transport
and related generated-code overhead. These particular pairs do not justify
claiming the profile's 17.06% `term_drop` plus `span_fade` reclamation cost.

The final authenticated physical-leaf analysis
(`selfhost/build/phase147/profile-final-full01/capture/000-sample-full-current-candidate-n1-diagnostic/analysis.json`)
contains 178 samples in **all** `p111_rt_ctor` calls and 266 in **all**
`p111_rt_sink` calls: 444 / 7,302 = **6.08%**. Including all 88 `p111_rt_keep`
samples raises this broad helper-only envelope to **7.29%**. The eligible
nullary subset is unknown and must be smaller than or equal to those sampled
helper totals. This is an intentionally loose ceiling on directly eliminated
helper work, not a statistical bound or forecast of whole-build speedup:
caller simplification, layout effects, new authentication work and sampling
uncertainty are outside it. Static site proportions cannot allocate this CPU
budget. Retain the small native witness and an actual changed-compiler build
comparison before assigning a whole-compiler gain.
