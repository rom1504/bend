# QBE scalar-array optimization experiments

[Design](../../../../design/phase117/array-facts-and-scalar-code.md) ·
[Report and selection](../../../../implementation/phase117/README.md) ·
[Exact measurements](../../../../implementation/phase117/results.json).

All compiler transformations are Bend. Host scripts compose exact declarations,
authenticate artifacts, invoke checked exports, build/link, and measure. They do
not lower Bend semantics or rewrite generated QBE. The C runtime adapter preserves
its existing layouts/helpers and changes two capability declarations. The selected
runtime stays GCC-O2 with `-ffp-contract=off`. Separate global-O3 and
allocator-only-O3 builds remain unselected after mixed broader measurements. There is no per-program C/cproc step.

## Selected source and runtime

Compose the qualified Phase114 source02 with these four modules, in order:

- `packed-arrays.bend`: coherent packed32 allocation/access/drop capability.
- `array-invariants-packed-v4.bend`: exact entry-origin and invariant metadata.
- `inline-512.bend`: general384→512 inlining admission; other budgets unchanged.
- `array-versioning-v2.bend`: one entry guard and original fallback worker.

The source03 recipe is:

```sh
python3 -B selfhost/tools/performance/phase117/prepare-v2.py \
  --out selfhost/build/phase117/FRESH_SOURCE \
  --module selfhost/tools/performance/phase117/packed-arrays.bend \
  --module selfhost/tools/performance/phase117/array-invariants-packed-v4.bend \
  --module selfhost/tools/performance/phase117/inline-512.bend \
  --module selfhost/tools/performance/phase117/array-versioning-v2.bend \
  --overrides p113a_bundle_chunks p113a_success p113a_raw p113a_template \
    p111q_memory p113ah_function p113i_eligible \
  --module-overrides p117h_finish
```

Acquire a checked API using the unchanged Phase111 guard/check-api tools. Required
exports are `p113a_lower_request p113a_verify p113a_admitted_chunks
p88_cache_prepare p86_plan p111_runtime_admission`. Use a fresh API directory
under `selfhost/build/phase111/`; the checked receipt must bind the newly composed
source. The selected historical API is `p117-version-api03`.

`runtime.py` reproduces the exact selected cached runtime from the
pinned Phase113 runtime assets. It intentionally requires a fresh fixed output
name and never overwrites earlier receipts. On this checkout, reuse the existing
authenticated `phase117/runtime01/report.json`. On a fresh reproduction,
run `runtime.py` under the guard. Old capability1 programs remain
uniform64; capability3 is allowed only through the checked scalar/unshared factory.
The original runtime refuses capability3. Do not mix new packed QBE with it.

## Fast development loop

Run every target command under `phase111/guard.py`, one serial CPU3 lane:
`--rss-mib 2048 --available-mib 16384 --file-mib 64 --cpu 3`.
Keep fresh output/label names. Guard refuses insufficient disk and concurrent jobs.

With authenticated source/API/runtime receipts:

```sh
P117_RUNTIME_REPORT=selfhost/build/phase117/runtime01/report.json \
selfhost/.bootstrap/bun-1.4.3/bun \
  selfhost/tools/performance/phase117/emit-v2.mjs \
  selfhost/build/phase111/p117-version-api03/report.json \
  selfhost/build/phase117/version-source03/manifest.json \
  selfhost/build/phase117/FRESH_EMISSION \
  variation-local-fold-128-0 editdist

python3 -B selfhost/tools/performance/phase117/screen.py \
  --emission selfhost/build/phase117/FRESH_EMISSION/report.json \
  --out selfhost/build/phase117/FRESH_SCREEN --label FRESH_LABEL
```

Wrap these commands separately with the guard; allow~100s each. Typical checked
API acquisition is11s, pair emission20s, pair build/three-role timing6s. `screen.py`
uses the original45 manifest, original50ms counts, unchanged full-output oracle,
three rotated rounds, and the fixed Phase114/upstream binaries. No rescaling or
benchmark source edits hide regressions. The zero-work sentinel remains correctness
coverage but is excluded from timing ratios.

For a runtime-only change, `runtime-binding.py` binds the exact old QBE to the
new runtime receipt; `screen-relink.py` reuses the independently authenticated
`p117-broad01-*` objects. It reruns the original outputs/timings after relinking,
without repeating frontend, lowering, QBE or assembly. A full45 emission took
282s in this phase; reusing it is the useful saving, not the subsecond linker.
The ordinary control path uses `emit-v3.mjs`, `controls02.json` and
`functional-v2.py`; `P117_CASE_MANIFEST` selects the frozen source/oracle manifest.

## Experiments and limits

`compiler-cost.mjs` compares prepared-Base whole requests of the two hosted APIs;
it is not a native N1/N2 compiler benchmark. `recheck.py`/`recheck-v2.py` reuse
machine products for longer timings and the existing unchanged-binary sampler.
`verify-results-v2.py` replays the original oracle independently; `summarize.py`
computes medians/ratios. Evidence and source/toolchain/runtime identities are
retained in the report capsule.

`origin-controls.bend` adds22 finite analysis checks; these are not formal proofs.
`fallback-control.bend` forces the original worker on ordinary valid inputs.
`unroll-two.bend` and `scalar-identities-v2.bend` are separate, unselected experiments.
Global and allocator-only runtime-O3 are also unselected: allocation improves,
but the broader gain does not justify new workload regressions. Earlier versions preserve failed/refined attempts; use the selection
receipt, not the largest numbered file, to identify the candidate.

No installed default or new native compiler image is promoted here. Full native
self-reproduction remains a separate integration gate, with Phase114 source02
retained as the qualified checkpoint. Existing frozen files may be hardlinked;
never modify a pinned artifact in place.
