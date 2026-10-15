# Phase90 final compilation-speed screen

The admitted native07 compiler wins five of these six fresh-process cases
against pinned upstream TypeScript on Bun; Map remains slower. Across the six
selected cases, native uses **0.678× TS process time** and JS B2 uses **1.367×**.
Native uses **0.496× JS B2 process time**. These are measurements of the guarded
workflows below, not general compiler parity: Base preparation and validation
boundaries differ. All **36/36** outputs match the correct role-specific C oracle.

## Versions, clocks and scope

The screen uses upstream TypeScript on Bun 1.4.3, genuine compiler07 JS B2 on
Node 24.18.0, and admitted native07 (`d7c7a479…`), built at Clang O2 from our own
C backend's output. Six selected compilation inputs run once in each of two
fresh-process rounds. Role order rotates by case and reverses in round two;
all targets run serially on CPU3 under 30-second / 2-GiB guards. Every table entry
is the median of two observations (the midpoint for two samples). Ratios are
time divided by TS time; lower is better. Each case receives equal geometric
weight; this is not a workload-frequency-weighted estimate.

The request clocks have different boundaries:

- **TS / Bun:** ordinary `book_load`, `book_valid` and `compile_book`, including
  loading/preparing Base and source. Module import and output-file writing are
  outside the request clock.
- **JS B2 / Node:** one ordinary `D.inspect` call. Its API-specific prepared Base
  is decoded inside the request. Initial cache creation is a separate setup job;
  the setup reported 4,004.3 ms Base preparation and is not amortized into these
  request or process medians. Module import and worker verification are outside
  the request clock.
- **Native07:** the input text, authenticated Base carrier and runtime parts are
  loaded/prepared before the request. The request compiles and traverses the
  resulting source/error/verdict lengths. Writing output is afterward. Base
  preparation and runtime preparation are outside this request clock but inside
  its process clock. Native request clocks have whole-millisecond resolution.

The process clock covers each guarded worker's startup, imports, preparation,
request, output writing and in-process verification/cleanup. Outer Python
admission checks and orchestration are excluded. Workers differ: JS B2's extra
input/output/final verification costs 63.8–92.7 ms per run (median 77.1 ms), while
native output comparison occurs in the outer coordinator. No adjusted or
subtracted process result is substituted for the observed clocks. These are
not public CLI startup timings, Clang timings, or generated-program execution
measurements. File-system caches were not flushed; “fresh” means process state.

## Request milliseconds

| Source | TS / Bun | JS B2 / Node | Native07 | JS B2 / TS | Native / TS |
| --- | ---: | ---: | ---: | ---: | ---: |
| Small | 439.8 | 260.7 | 70.5 | 0.593× | 0.160× |
| Numeric | 503.7 | 391.3 | 118.5 | 0.777× | 0.235× |
| Lexer | 718.6 | 912.6 | 462.0 | 1.270× | 0.643× |
| Map | 1,050.4 | 1,382.5 | 1,724.5 | 1.316× | 1.642× |
| Functions65 | 580.8 | 603.0 | 272.5 | 1.038× | 0.469× |
| Unicode | 449.7 | 280.7 | 72.5 | 0.624× | 0.161× |
| Equal-case geometric mean | 593.4 | 528.5 | 225.5 | 0.891× | 0.380× |

The request geometric means favor native partly because it already has its
prepared Base. They must not be presented as equivalent-work backend or language
speedups. Map is still 1.642× TS and 1.247× JS B2 request time. The two native
Map requests are 1,676 and 1,773 ms; native Lexer is 440 and 484 ms. Two samples
are enough for this bounded screen, not confidence intervals or steady-state
throughput claims.

## Guarded process milliseconds

| Source | TS / Bun | JS B2 / Node | Native07 | JS B2 / TS | Native / TS |
| --- | ---: | ---: | ---: | ---: | ---: |
| Small | 523.7 | 574.5 | 227.4 | 1.097× | 0.434× |
| Numeric | 564.6 | 727.8 | 288.3 | 1.289× | 0.511× |
| Lexer | 789.1 | 1,300.3 | 643.9 | 1.648× | 0.816× |
| Map | 1,115.6 | 1,759.6 | 1,903.5 | 1.577× | 1.706× |
| Functions65 | 646.2 | 972.6 | 440.4 | 1.505× | 0.682× |
| Unicode | 513.4 | 604.8 | 237.5 | 1.178× | 0.463× |
| Equal-case geometric mean | 664.8 | 908.6 | 450.9 | 1.367× | 0.678× |

JS B2 is slower than TS in all six process comparisons even where its request
clock is lower. Native Map is 1.706× TS and 1.082× JS B2 process time. This is the
remaining unfavorable case; the geometric mean does not hide it. The timed
36-job campaign occupied 39.290 s; setup and final verification bring the
reported elapsed method time to 46.958 s. The small screen is not a substitute
for the separate 45-case output-preservation controls.

## Prepared Base remains a material native cost

Native Base preparation is **135 ms median**, with all twelve observations
between 134 and 147 ms. Per-case medians are 135 / 135 / 141 / 141 / 135 / 136.5
ms in table order. Runtime preparation adds 1–2 ms. Base preparation alone is
about 59% of the Small process median and 57% of Unicode's. It is excluded from
the attractive native request ratios and included in the process results above.

The historical Phase89 qualified native screen recorded Base preparation mostly
at 58–59 ms (range 58–63 ms, median 58 ms). The current 135 ms cost is a clear
remaining gap relative to that evidence, roughly 77 ms above its historical
median. **This is not a same-campaign regression measurement.** Phase89 used an
upstream-C-built native image (`8bacae26…`), older compiler source/runtime and
measurement workers; Phase90 uses an own-backend native image. Source shape,
backend, runtime and worker boundaries changed together. The old process
geomean 0.492× TS and the new 0.678× must not be subtracted to assign a causal
backend regression. The historical record is retained in
[qualified-screen.md](../phase89/qualified-screen.md) and its raw cold report.

## Full compiler self-emission is a separate, harder case

| Frozen D04 source, new runtime | Request seconds | Complete C |
| --- | ---: | --- |
| Genuine compiler06 JS B2 / Node, `js-new-runtime02` | 51.672 | `dae071f0…`, 38,614,882 bytes |
| Native07, `native07-self01` | 164.322 | Exactly the same bytes |

The native observation takes **3.180×** the JS B2 request time for this much
larger input. These are separate single jobs, not a paired repeated campaign;
the JS producer is compiler06 with an authenticated explicit runtime derivative,
whereas the six-case screen uses refreshed compiler07. Both clocks exclude their
initial Base preparation; the source-loading and result-consumption boundaries
remain those of their respective workers. This establishes a substantial
observed large-input gap and successful exact native self-emission, not a
statistically estimated regression or an upstream-TS ratio. Clang image build
cost is separate: native07 O2 construction took 308.201 s.

## Evidence and offline review

[Raw final screen](../../selfhost/build/phase90/final-screen01/report.json),
SHA `c282819b5be9902c9816951615ede36d5fd26d7679d98316be7334187c94c5ff`, binds all methods, versions, inputs, per-job guard records and
complete timing arrays. The offline report review recomputed every median and
equal-case geometric ratio from the 36 raw rows and checked all pass/exact flags;
no new compiler targets were run. The summary reports 574 unchanged input pins.

TS outputs are compared with the historical pinned TS oracle. JS B2 outputs
match the fresh preparation oracle, and every native output matches that same
JS B2 C exactly. TS C differs from ours, so “36 exact outputs” does **not** mean
our generated C equals upstream C. It also does not measure generated-program
speed or prove full-language conformance.

Additional records: [historical native89 cold screen](../../selfhost/build/phase89/qualified-cold01/report.json),
[JS full-self emission](../../selfhost/build/phase90/js-new-runtime02/report.json),
[native full-self emission](../../selfhost/build/phase90/native07-self01/report.json),
and [native build and correctness report](native-build.md). No optimization or
additional experiment is implemented by this reporting task.
