# Phase128 native acquisition: reuse the existing tools

Read-only preparation; no campaign or compiler target was executed for this
note. Freeze the selected Bend source, checked API and runtime before starting.
Keep installed selection and the qualified Phase126/125 artifacts unchanged.

## Two prerequisites before paying for a full image

1. **Wire the actual native entry.** An API export of `p128raw_emit_admitted`
   does not change native execution. `main` still reaches
   `p111_compile_source → p111_emit_admitted`. If raw reuse is selected, its
   tested Bend entry must be connected there in the final frozen source.
   Otherwise hosted prototype emission can produce a compiler that still runs
   the old request path. Preserve runtime admission, source-bound checking,
   original verification and final merged-program verification.
2. **Create a narrow new source/runtime admission receipt.** Phase126's
   `native/rebind-abi-v5.py`, `layered-contract-v5.py` and `plan-v2.py` admit only
   their exact frozen source endpoints through source33. They correctly reject
   Phase128. Do not alter those old authorities or reuse `native32-abi01.json`
   as if it admitted another source. Replay the new overlays from the known
   parent, enumerate exact entry changes and unchanged verifier declarations,
   bind the checked API, and bind the selected runtime/import implementations.
   The scalar-borrow runtime requires its explicit additional import contract;
   successful linking is insufficient. Reuse existing jobs and runners, with
   a small frozen Phase128 plan/receipt rather than another generic framework.

The checked API needs `p88_cache_prepare p86_prepare p86_plan
p111_runtime_admission p111_emit_admitted p111_compile_source`. Acquire it using
`phase111/check-api.py` under the existing root guard. Check its receipt names
the exact frozen source and its command checked that source. Prototype-only
export lists are insufficient for the hosted acquisition helper.

## Existing commands to put in the serial root plan

The placeholders below are exact pinned absolute paths in the final plan.
`TAG` is fresh; every output directory must be absent. Run from the repository
root, under `phase111/guard.py` with CPU3, RSS6144MiB, available16384MiB and
file128MiB. These are commands to schedule, not commands run for this note.

```text
BUN selfhost/tools/performance/phase118/native-hosted-v2.mjs API SOURCE
  selfhost/build/phase111/TAG-full-emit cache array

python3 -B selfhost/tools/performance/phase123/build-aligned.py
  --source selfhost/build/phase111/TAG-full-emit/program.ssa
  --runtime RUNTIME --out selfhost/build/phase111/TAG-n1 --seconds 120

python3 -B selfhost/tools/performance/phase125/native/coverage.py
  --image selfhost/build/phase111/TAG-n1/program --runtime RUNTIME
  --suite focused --seconds 30 --build-seconds 30
  --out selfhost/build/phase111/TAG-n1-focused

python3 -B selfhost/tools/performance/phase125/native/native-emit.py
  --image selfhost/build/phase111/TAG-n1/program --source SOURCE
  --out selfhost/build/phase111/TAG-self --mode cache --seconds 1200
```

The last command omits `--runtime` deliberately: emit first, authenticate the
same source/Base/carrier/stamp/runtime lineage and compare complete hosted/native
QBE bytes **before** N2 building. Its `--reference` option does not admit every
newer hosted receipt kind; do not casually pass the Phase118 integrated receipt
there. Reuse the staged comparison obligations instead. Neither normalize QBE
nor change the native stdout LF convention. Once equality is authenticated,
the completed equal SSA may be hardlinked with an explicit receipt.

```text
python3 -B selfhost/tools/performance/phase123/build-aligned.py
  --source selfhost/build/phase111/TAG-self/program.ssa --runtime RUNTIME
  --out selfhost/build/phase111/TAG-self/build --seconds 120

python3 -B selfhost/tools/performance/phase125/native/coverage.py
  --image selfhost/build/phase111/TAG-self/build/program --runtime RUNTIME
  --suite focused --seconds 30 --build-seconds 30
  --out selfhost/build/phase111/TAG-n2-focused

python3 -B selfhost/tools/performance/phase125/native/full45.py
  --partition all45 --image selfhost/build/phase111/TAG-self/build/program
  --runtime RUNTIME --seconds 120 --build-seconds 10
  --out selfhost/build/phase111/TAG-n2-full45
```

Retain the final staged comparison receipt binding the actual N1/N2 binaries,
checked source/API, common runtime, hosted/native SSA and separate N2 build.
Focused19 means16 successful exact outputs plus3 original refusals on **each**
image; full45 means45 ordinary exact-output observations on N2. These gates do
not establish timed45 performance, ELF identity or N2→N3 reproduction.

Use the Phase123 builder throughout: GNU as must receive
`-mbranches-within-32B-boundaries`. Older Phase111/118 builders silently differ
on this important machine-layout policy. The cached runtime links with
`gcc -no-pie ... -pthread -lm`; there is no per-program C/cproc step.

## ABI and numeric identities

There are two different contracts, which should not be conflated:

- The **runtime admission receipt is source-specific**. Its source pin, checked
  import gates, runtime source/object and implementation/header pins must match
  the final composition, even when the numeric primitive catalogue is unchanged.
- Primitive operation IDs and special-constructor selector IDs are fixed by
  `phase111/runtime/primitives.h`, `catalogue.json`, and Bend's `p111_op_id` /
  `p111_special`. They do **not** shift when compiler declarations are added.
  The current primitives are1–85 and special selectors1–9.
- Ordinary program constructor IDs and segment FIDs **are program-specific**.
  `p111q_ids` derives them from the actual `P111Program` constructor/segment
  lists via `p111q_constructor_ids` and `p111q_function_ids`, starting at0.
  Emit those tables normally. The runtime binds core constructor names from
  the actual program descriptor (`p111_lookup_cid`), rather than importing old
  compiler-image numbers. Profile FID/constructor mappings must likewise come
  from the new authenticated ELF/descriptor. Never copy source32 numeric IDs.

I found no separate currently used tool literally named `primitive-abi`; the
source-specific receipt above is `native32-abi01.json`. Derive a new receipt
from checked declarations and runtime contracts, not by changing its source hash.

## Fixed-request timing after qualification

Reuse `phase125/native/timing-run.py` and the frozen lexer/closures/Map inputs,
independent outputs, upstream revision, tools, clocks, Base/carrier and limits
from the Phase126 timing manifest. Produce a fresh data manifest with the
actual Phase128 N1/N2 images, selected runtime and new qualification lineage.
Keep `assemblerOption` explicit. The frozen Phase126 timing-plan CLI rejects
unrelated plans; do not relabel its old successful receipt.

Run three rotated rounds with `--modes cache --rounds 3`, writing beneath
`selfhost/build/phase112/`. The ordinary runner supports three role keys:
`phase111`, `phase112`, `upstream`. First bind those honestly to Phase128N1,
Phase128N2 and pinned upstream. A second contemporaneous comparison may bind
the two native role keys to Phase127's repaired image and Phase128N1, with the
mapping explicitly relabeled in its lineage/report. Do not call the repaired
source32 image a qualified Phase127N2; it is the same-source causal repair.

Report request latency and request+machine-build stage sums separately. Native
uses prepared Base and a cached runtime; upstream checks source Base, emits C
and rebuilds its runtime with Clang. Generated execution in this screen checks
correctness; it is not the compiled-program speed benchmark.

## Resource checkpoint and stopping conditions

Phase126's completed chain took26.27 guarded minutes, peak5.502GiB. Hosted
emission845.57s and N1 self-emission511.06s dominate acquisition; machine
builds were about14s each. These are historical sizing observations, not an
estimate of Phase128 gains. Its SSA/assembly/object/N1 sizes were approximately
99.5/72.7/21.5/16.1MB. Existing 1.5GiB free space should accommodate that scale
and short timing, subject to actual source growth and repeated disk checks.

Retained raw candidates may raise hosted/native peak memory. Do not infer
full-image safety from small request equality. Keep the6GiB and128MiB bounds;
stop and diagnose the first scale failure rather than silently lifting them.
The generic guard needs416MiB at startup; timing retains256MiB free before
every request. Use one resource lane and preserve successful prefixes on failure.
Reuse the existing staged/resume principle, but the old resume guard is pinned
to source32 and cannot authorize a Phase128 run. Hardlink only completed,
authenticated equal outputs; never a file still being written.
