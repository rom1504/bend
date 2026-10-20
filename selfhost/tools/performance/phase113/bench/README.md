# Phase113 current-six fast loop

This is a new, explicitly named development screen. It preserves the exact
Phase93 batch sources, workload arguments and independent complete expected
outputs for scalar-region8192, local-pair, edit-distance, active ray256, lexer
and closures256. It does not rewrite the Phase112 six-case screen or the
original45 corpus. The unchanged broad45 manifest/profile remain the integration
reference; this screen contains no zero-work point.

`manifest01.json` pins the selected Phase112 facts source, checked hosted API,
native N1, native N2, unchanged runtime, tools and upstream products. All six
native N2 baseline products are already available and authenticated in
`baseline-binding01.json`; runtime comparison requires no baseline acquisition.
Its role is `facts-n2`, never renamed as production B1/B2 or old Phase111.

| Exact case name | Repetitions | Warmups | Workload arguments |
|---|---:|---:|---|
| scalar-region-8192 |419|1|8192, 524800|
| local-pair |72|1|0, 0|
| editdist |18|1|2, 0|
| variation-ray-active-256-2240 |114|1|256, 2240|
| lexer |39|1|8, 0|
| coverage-closures-256 |1470|1|256, 123|

Counts are frozen in `upstream-15ms-profile01.json`, using only the historical
upstream medians: `max(1, ceil(original repetitions * 15 / upstream median ms))`.
Every role uses the same counts. The 15-ms target and 5-ms qualification floor
make this a short development screen; a 1-ms clock cannot resolve small gains.
Counts are never tuned from candidate timings. Workload arguments and outputs
remain exact. At the previous facts rates, one baseline role costs about5.8s;
a baseline/candidate/upstream round is roughly12s, and three rounds roughly35s,
before process/setup overhead. These are estimates, not guaranteed deadlines.

## Measurements and grade

The adapter imports the original frozen `phase112/benchmark/run.py`. It supplies
the new manifest location and calls its unchanged binder/measurement functions.
The original timing loop, full-output parser, role rotation, timeouts, raw logs
and method source are preserved. The old supervisor requires output beneath
`selfhost/build/phase112`; use a fresh `p113-` prefix there. This compatibility
path does not turn the new screen into Phase112 evidence.

Root runs all following target commands serially under its CPU3 process-tree
guard. A candidate binding must cover all six exact sources. Bind its completed
emission/build map, without executing targets:

```sh
python3 -B selfhost/tools/performance/phase113/bench/run.py bind \
  --label candidate01 --reports CANDIDATE_REPORT_MAP.json \
  --out selfhost/build/phase112/p113-candidate-binding01.json
```

For a single-round diagnostic:

```sh
python3 -B selfhost/tools/performance/phase113/bench/run.py measure \
  --bindings selfhost/tools/performance/phase113/bench/baseline-binding01.json \
    selfhost/build/phase112/p113-candidate-binding01.json \
  --grade diagnostic1 --budget-seconds 20 \
  --out selfhost/build/phase112/p113-diagnostic01
```

For paired evidence, use `--grade paired3 --budget-seconds 60` and a fresh output.
Omit the candidate binding for a baseline/upstream check. Both grades check the
complete initial value and every successful warmup/repetition count. The
`phase113-report.json` is the authoritative grade: diagnostic1 publishes no
qualified aggregate; paired3 requires all six points in all three rounds.
Its candidate/facts ratios use directly paired current observations, not ratios
multiplied across campaigns. The raw inherited `report.json` is retained but its
single-round aggregates must not be presented as paired qualification. Compiler
requests, builds and counter instrumentation remain outside runtime ratios.

## Hosted API and build plans

Three matching hosted facts products already exist: ray256, lexer and
closures256, listed in `baseline-hosted-existing01.json`. The prepared
`baseline-hosted-plan01.json` contains only the missing scalar8192, local-pair
and edit-distance emissions/builds; the companion reports map combines them
with the three existing actual receipts. Planned destinations are
`selfhost/build/phase111/p113-hosted-facts01-NAME-{emit,build}`. They remain
pending until root executes the plan; the native baseline needs none of this.

```sh
python3 -B selfhost/tools/performance/phase112/run-jobs.py \
  --plan selfhost/tools/performance/phase113/bench/baseline-hosted-plan01.json \
  --out selfhost/build/phase112/p113-hosted-facts-jobs01
```

Prepare an all-six plan for a completed checked candidate API offline:

```sh
python3 -B selfhost/tools/performance/phase113/bench/prepare-hosted-plan.py \
  --api CANDIDATE_API_DIRECTORY --pipeline direct --tag p113-candidate01 \
  --runtime CANDIDATE_RUNTIME_OBJECT \
  --out selfhost/tools/performance/phase113/bench/candidate-plan01.json
```

Execute it through the same root-run job supervisor and bind its generated
`candidate-plan01-reports.json`. The default `--pipeline static` preserves the
existing `phase111/emit.mjs` transport and requires `p111_compile_source`.
`--pipeline direct` calls `phase113/staged-emit.mjs API SOURCE OUT cache direct`
and requires the checked exports `p88_cache_prepare`, `p86_prepare`, `p86_plan`,
`p111_runtime_admission`, `p113d_lower_request`, `p113d_verify` and `p113d_chunks`.
It does not substitute the old `p111_compile_source` fallback for direct lowering.
Both paths use unchanged `phase111/build.py`; no host code lowers algorithms.
Emission and build paths remain under Phase111 to preserve output guards.

`--runtime` accepts an object or a directory containing `runtime.o`. Omit it to
use the exact frozen facts runtime. The chosen object is hashed into the plan
and passed explicitly to every build. Build commands use pinned QBE amd64_sysv,
assembler and `gcc -no-pie`. `--reuse-baseline-hosted` requires the static path
and exact frozen API/runtime; candidate products never reuse those receipts.
API/source/receipt pins and complete output/build checks remain separate from
the existence of a plan.

The unchanged legacy binder additionally requires `p111_compile_source` in a
hosted API's export receipt. A direct API may expose that fallback alongside
the seven direct exports; the direct plan still calls only its staged path.
A direct-only API can be planned and built, but needs a separately qualified
producer adapter before the current binder will accept it.

`method-history/hosted-plan-v1/` preserves the original preparer and README
bytes referenced by `freeze01.json`, with a restoration map. The version2
preparer adds pipeline/runtime selection. Existing manifests, profile and
prepared version1 plans are unchanged.

## Runtime counters

`baseline-counter-plan01.json` binds the exact six baseline objects and QBE
products to the existing diagnostic runtime runner. Root can run:

```sh
python3 -B selfhost/tools/performance/phase112/profile/run.py \
  --plan selfhost/tools/performance/phase113/bench/baseline-counter-plan01.json \
  --runtime-source selfhost/build/phase112/profile-runtime01 \
  --out selfhost/build/phase112/p113-facts-counters01 --budget-seconds 60
```

It qualifies the independent counter control, compiles one diagnostic runtime,
relinks existing program objects and checks all full outputs. No compiler/API
acquisition is needed. Instrumented timings are never benchmark samples.
Counters use one repetition and zero warmups, so the wrapper evaluates each
workload twice: once for initial output and once in the loop. Counts include
setup/readback and overlapping helper calls; they are not CPU-time shares.

For a candidate, run `prepare-counter-plan.py --binding CANDIDATE_BINDING.json
--out FRESH_PLAN.json` offline, then pass that plan to the same runner. The
existing counter parser identifies frames, dispatches, allocations, RC helpers
and register transport by the actual linked QBE/runtime identities.

Only source/receipt/hash preparation and synthetic parser/accounting checks were
performed here. No compiler, API, assembler, linked product or timing target
was executed by the preparer. Original methods and corpus files stay unchanged.
