# Phase185 compiled-program measurement loop

These adapters reuse the maintained native45 catalog, build receipts, benchmark
protocol and profiler. They execute no compiler implicitly. Phase184's frozen
three-role tool is unchanged. No production image is installed by this loop.

## Prepared products and generic runtime roles

The retained baseline manifest is
`selfhost/build/phase184/bend-products01/programs.manifest.json`, with roles
`bend-qbe` and `bend-c` for all45 points. `bend-c` is our C backend.
`selfhost/build/phase183/fast5-acquire01/programs.manifest.json` has
`selfhost-qbe`, `selfhost-x86` and `upstream-c` for exactly `local-pair`,
`local-fold`, `scalar-region-0`, `scalar-region-8192`, `complete-generic-row32`.
Map/tree/ray x86 products require an explicit maintained acquisition first.

Merge arbitrary roles from their retained maintained manifests. This step is
offline and writes another maintained manifest, usable by `bench.py` as well:

```sh
python3 -B selfhost/tests/phase185/runtime-loop.py merge \
  --role old-qbe selfhost/build/phase184/bend-products01/programs.manifest.json bend-qbe \
  --role own-c selfhost/build/phase184/bend-products01/programs.manifest.json bend-c \
  --reference old-qbe \
  --cases coverage-map-churn-128,tree-bitonic,raytrace \
  --out selfhost/build/phase185/three-case-inputs01
```

Add `--role new-qbe CANDIDATE_MANIFEST CANDIDATE_ROLE` and corresponding
`old-x86`/`new-x86` arguments when those products exist. Missing selected products
refuse the merge; a subset never becomes a full45 score. Source, point and oracle
must equal the catalog, and existing manifest/product pins must still match.

For equal-count historical scoring, use maintained `bench.py run` with its
documented `--scale`. For the new adaptive count metric, run:

```sh
python3 -B selfhost/tools/build-retention/guard.py \
  --out selfhost/build/phase185/three-case-runtime01-guard \
  --run-root selfhost/build/phase185/three-case-runtime01 \
  --seconds 90 --disk-mib 128 --rss-mib 2048 --available-mib 16384 \
  --file-mib 128 --cpu 3 -- \
  python3 -B selfhost/tests/phase185/runtime-loop.py run \
    --manifest selfhost/build/phase185/three-case-inputs01/manifest.json \
    --rounds 4 --seconds 75 --target-ms 250 --guarded --cpu 3 \
    --out selfhost/build/phase185/three-case-runtime01
```

Each role calibrates independently, retains every pilot, then runs fixed counts
for serial rotated rounds. The complete output and exact warmup/success counts
must agree; intervals below100ms suppress ratios. Choose rounds divisible by
role count for position balance (two roles:4; three roles:3 or6; five roles:5).
The report records normalized milliseconds per invocation, all selected cases,
dispersion, current denominators and failure/incomplete status. This is a new
adaptive throughput metric, separate from the historical equal-count score.

Close each guarded job using its actual outcome. For the successful example:

```sh
python3 -B selfhost/tools/build-retention/close.py \
  --run selfhost/build/phase185/three-case-runtime01-guard \
  --classification completed --keep-root selfhost/build/phase185/three-case-runtime01 \
  --out selfhost/build-retention/phase185/three-case-runtime01-close
```

Use `failed` for a failed job. Keep the default5GiB disk reserve, never nest
guards, and do not run target work outside the coordinator's CPU3 lane.

## Source-aware CPU sampling and cheap existing runtime counters

For the first unchanged QBE/C sample-only screen, use `execute-profile.py` under
one180s guard, with `--seconds 165 --guarded --cpu 3 --out FRESH_RUN_ROOT`.
It prepares and executes the jobs serially, uses the retained main/thread
samplers, compares/renders each role and attributes every QBE capture to its
conditional lexical owner map. It omits emitter-source pins because current
maintained emitters may be changing. Its `complete` flag establishes completed
diagnostic work; quantitative admission still belongs to each comparison's
sample/loss/coverage gates. It does not relink a runtime or record clean ratios.

`profile-plan.py` writes ordered jobs for the maintained profiler. It prepares
owner maps from retained QBE or assembly, optionally materializes reversible
runtime hooks and relinks each **retained program object**, then freezes exact
independent output contracts. It does not execute any generated job itself.

The existing sampler is
`selfhost/build/phase183/profile-controls01/sampler/sampler.so`; its sibling
`report.json` authenticates the sampler. The qualified runtime source/object
receipt is `selfhost/build/phase182/runtime-build02/report.json`. Its runtime
object matches `selfhost/dist/qbe/runtime.o`, SHA256
`67141c4505a0355901d857c4ba81dfc17559329e536818a843ce68615384d13e`.
The diagnostic build preserves the receipt's GCC flags:
`-O2 -std=gnu11 -ffp-contract=off -DP144_SINGLE_MUTATOR_RFC=1`.
The current runtime passes all14 exact reversible hook anchors offline.

```sh
python3 -B selfhost/tests/phase185/profile-plan.py \
  --manifest selfhost/build/phase184/bend-products01/programs.manifest.json \
  --role bend-qbe --instrument \
  --case coverage-map-churn-128 5000 --case tree-bitonic 7000 --case raytrace 128 \
  --out selfhost/build/phase185/qbe-profile-preview01
```

These counts predict about4s per uninstrumented QBE capture from Phase184's
measurements; they are sizing hints, not fresh timings. At8ms and13ms,
two4s captures deliver about807 samples together. `--periods-us` enumerates
sample captures; `--rounds` controls clean/events repetitions, not sample count.
For a changed faster program, increase repetitions or use
`--periods-us 8000,13000,8000,13000` and pool compatible captures. Never shorten
the fixed input or lower the500-sample admission threshold to fit a budget.

That command only previews a plan. The guard requires fresh artifact roots, so
actual execution must create its plan inside the guarded root. The sample-only
QBE/C wrapper does this directly:

```sh
python3 -B selfhost/tools/build-retention/guard.py \
  --out selfhost/build/phase185/qbe-c-profile01-guard \
  --run-root selfhost/build/phase185/qbe-c-profile01 \
  --seconds 180 --disk-mib 512 --rss-mib 2048 --available-mib 16384 \
  --file-mib 128 --cpu 3 -- \
  python3 -B selfhost/tests/phase185/execute-profile.py \
    --out selfhost/build/phase185/qbe-c-profile01 --seconds 165 --guarded --cpu 3
```

`execute-array-profile.py` is the corresponding fresh-root wrapper for the
array-x86 local-fold screen; it creates a plan then calls the generic
`execute-profile-jobs.py` dispatcher. Future instrumented wrappers can use this
same pattern, creating `profile-plan.py --instrument` output inside their fresh
guarded root before dispatch. Never declare an already prepared plan directory
as a fresh guard root or write its target outputs outside declared roots.

Close with the same lifecycle command as above, substituting profile paths and
the actual classification. All preparation, relink, capture, comparison and
render commands are retained in `jobs.json`. `--instrument` adds three separate
observations: uninstrumented clean+sample, diagnostic clean+sample with counters
disabled, and diagnostic events with counters enabled. Counter and context
timings never enter the runtime speed comparison.

Counters cover executed dispatch, allocation calls/words/refills, frees,
keep/sink/drop, constructor takes, continuation frames/returns, primitive calls
and register transport. They describe event volumes and active dispatch owners;
private calls/inlining can bypass entries. They do not measure live heap size
or universal source-function invocation counts. For cheap event comparisons,
prepare a separate explicit small-count recipe rather than weakening outputs.

The planner emits `ownerMaps` for offline attribution. For each sample row in
`capture/report.json`, use its exact `analysis.file`, optional `contexts.file`
and corresponding owner map:

```sh
python3 -B selfhost/tools/profiler/attribute.py \
  --analysis CAPTURE/analysis.json --contexts CAPTURE/contexts.txt \
  --owners OWNERS.json --summary-only --out FRESH_ATTRIBUTION
python3 -B selfhost/tools/profiler/attribute.py \
  --events CAPTURE/events.json --binary DIAGNOSTIC_PROGRAM \
  --owners OWNERS.json --out FRESH_EVENT_ATTRIBUTION
```

Omit `--contexts` for a clean binary. QBE maps group lowering segments by Bend
definition and authenticate linked FID addresses. x86 clean maps additionally
bind the completed native build receipt. An x86 diagnostic ELF differs from
the original receipt's ELF, so its owner map omits that receipt and preserves
the retained-object/runtime provenance through the diagnostic build receipts.
Benchmark fixtures are ordinary files, not assembled compiler-source manifests;
no fabricated instruction line/source map is supplied. These are conditional
definition owners, not full logical stacks or recovered inlining origins.

`compare.py` admits quantitative attribution only after at least500 accepted
pooled samples, zero loss, plausible delivery and adequate sampled-thread CPU
coverage. At least95% process-CPU coverage is required for absolute CPU cost
estimates. Retain rejected captures. The Phase183199-sample control established
the source mapping capability only and is not a quantitative hotspot baseline.

For the C backend use a separately built `build-sampler.py --all-threads`
collector under its own guard and pass it with `--sampler`, without
`--instrument`. A single Bend mutator may execute on a child pthread; main-only
coverage can fail correctly. Starting counts for about4s of C work are map18000,
tree24000 and ray144. The thread sampler supplies physical leaves only, with no
dispatch contexts or caller unwind. It must pass lifecycle/overflow/CPU coverage
gates. Its grouped thread stream cannot establish chronological stages.

## Native perf and static machine evidence

This environment has `/usr/bin/perf`, `perf_event_paranoid=3` and zero effective
capabilities (neither `CAP_PERFMON` nor `CAP_SYS_ADMIN`). Treat hardware/software
perf events as unavailable unless a guarded permission probe proves otherwise;
no privileged settings change is required by this plan. If allowed elsewhere,
`perf record -e cycles:u -F 99 -g --call-graph dwarf -o FRESH/perf.data -- PROGRAM ARGS`
can inspect an unchanged ELF, and `perf stat -e instructions:u,cycles:u,branches:u,branch-misses:u`
can supply event counts. Those hardware events are distinct from runtime hooks.
Retain exact outputs, argv, ELF and perf/tool identities, run under the same
outer guard, and keep diagnostic clocks out of speed ratios.

The maintained signal sampler works without perf-event access. `owners.py`,
`attribute.py`, `compare.py`, `render.py`, ELF symbol/disassembly inspection and
the retained lexical C/QBE/x86 inspection need no target execution. Use them to
localize a candidate, then measure changed prepared products with the clean
runtime loop. Exact unchanged emitted products should reuse their qualified
machine products instead of manufacturing a new timing ratio.

## Adapter validation

`python3 -B -m unittest discover -s selfhost/tests/phase185 -p test_runtime_loop.py -v`
passes four offline controls: five-role rotation/calibration, output refusal,
catalog-point refusal and count limits. Actual QBE three-case profile planning
and14 reversible runtime anchors were checked offline in a temporary directory;
no native target, compiler, profiler capture or instrumented build ran during
adapter preparation. Real campaign results remain the coordinator's next gate.
