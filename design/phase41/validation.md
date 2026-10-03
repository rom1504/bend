# Phase41 validation efficiency proposal

Use the maintained conformance runner with exactly two candidate persistent
workers for untimed frontend correctness. The Phase40 main acquisition took
784.390 seconds; broader took 37.354 seconds. No speedup is established before
root runs a fresh candidate. Scheduling changes do not alter observations:
3026 main and 196 broader, preserving 2525 pass / 497 observed / 4 shared main
failures. Reference acquisition remains the attested four-worker pinned reference.

The narrow generator `selfhost/tools/performance/phase41/validation/derive-frontend.py`
pins frozen Phase40 final-plan02/tools/frontend-gate.mjs SHA
`8e118b47b8652425be8f7583c0b9a80721e4c000e2cd2e27bb3e2e716b59b666`.
It produces a versioned successor plus exact replacements and parent/derived
hashes. Only scheduling, kind, initial memory headroom and refusal of historical
failed-candidate reuse change. The fixture selection, strict path/layout
comparator, unknown-field refusal, behavioral values, source hashes, compiler /
runtime / base identity and all worker timeout/failure assertions stay intact.
The historical tools, plans and reports remain unchanged. New final integration
must pin the successor and explicit report paths in a reviewed derived plan /
auditor input; an old hash-pinned auditor cannot silently consume this new gate.

Root serializes main and broader runs. Give both worker processes two approved
CPUs via PHASE41_FRONTEND_CPU=3,4 and outer taskset -c 3,4; validate those CPUs are
allowed first. Builds and timing remain CPU3 and serial. Each worker keeps
heap1024 MiB, stack4096 KiB, recycle64 and RSS-recycle1024 MiB; the parent also
keeps heap1024. Recycling checks RSS after completed probes, so it is not a hard
instantaneous bound. Require 5120 MiB MemAvailable before launch and the existing
outer bounded-run supervisor with aggregate tree RSS3072 MiB, free-memory floor
2048 MiB, 1200-second ceiling and fresh output. Its 100ms sampling gives a
practical aggregate stop, not an instantaneous kernel memory guarantee. RSS
summing conservatively double-counts shared pages. Do not launch another heavy
job alongside it. If two workers cannot close under those bounds, preserve the
failure and return to the unchanged one-worker gate; do not silently increase
heap, relax health or discard cases.

## Root integration recipe

Derive once to a fresh path, inspect derivation.json, run Node --check. Bind
ATTEMPT to the final checked image, LAYOUT to its reviewed frontend module layout,
OUT to a fresh Phase41 prefix and NODE to pinned Node24.18. The historical
reference gates still require all input/artifact rehashes, performed by the gate.

```
python3 selfhost/tools/performance/phase41/validation/derive-frontend.py "$OUT/frontend-tool"
python3 selfhost/tools/performance/phase32/bounded-run.py --seconds 1200 \
  --rss-mib 3072 --available-mib 2048 "$OUT/run-frontend-main" -- \
  env PHASE41_FRONTEND_CPU=3,4 taskset -c 3,4 "$NODE" \
  --stack-size=4096 --max-old-space-size=1024 \
  "$OUT/frontend-tool/frontend-gate-v1.mjs" "$ATTEMPT" "$OUT/frontend-main" \
  main selfhost/build/phase23/frontend-main-01 '' "$LAYOUT"
```

After main closes, repeat in a fresh run/output with scope broader, reference
selfhost/build/phase23/frontend-broader-01 and selection
selfhost/build/phase22/context-group196-05/selection.json. Preserve full candidate
reports and consumed successor, accept exactly two healthy candidate workers,
exact3026/196 agreement and zero differences. The workers array records two
logical slots; recycle telemetry can record more child process starts and must
remain healthy. Do not require selectedComplete
true: the four shared main failures remain explicitly represented and exact
agreement is the gate's established policy. Record total enclosing wall, peak
aggregate RSS and both workers' health; elapsed observations are workflow
measurements, not generated-program timing.

## Early compatibility preflight, bounded at 120 seconds

Before building broad integration plumbing or acquiring45 prepared points,
inspect the selected API and run the reviewed current controls serially with
fresh report directories. The fast admission stage should use focused checked
cohorts for counters, recursive-folds and unary; component and its tail supplement
are required before final owner closure. Current control execution receipts are
0.604s counter, 0.705s foldV3, 0.202s fold recognizers, 1.308s unary, 1.611s
component and 0.404s tail. These establish small execution cost on existing
cohorts, not a two-minute fresh acquisition guarantee.

Use Phase35 vector-acquire.py --cases counters only; run reviewed Phase39
vector-counter-fixture-controls-v1.mjs directly (35 oracles /5 structures /5
boundaries). Avoid obsolete owner-counters and do not invoke the historical
rebind requiring a failed launch. For fold acquisition, separate the maintained
fold-final-controls.py's checked acquisition from its old diagnostic stage in
one narrow reviewed successor: its old wrapper has no override and would replay
a known failure. Run Phase40 fold-controls-v3.mjs (27 oracles /57 boundaries /3
structures /4 admissions) plus unchanged Phase35 fold-guards.mjs with a fresh
config bound to the selected attempt/API (24 observations). Run Phase40
unary-compiled-controls-v1.mjs after selected-image unary acquisition; keep83
oracles /56 structures /32 boundaries /3 admissions /3 order /3 refusals.
Never substitute the obsolete suffix decoder.

For component closure use Phase40 component-inherited-derive-v1.mjs,
unchanged Phase39 component-actual-controls.mjs (159 oracles /113 boundaries /3
admissions), and mandatory Phase40 component-inherited-tail-controls-v2.mjs
(13 oracles /19 boundaries /1 admission). The active ordinary-entry boundary
must be exercised; inactive descriptor tests do not discharge error order.

For an early baseline-only compatibility check, the current checked06 cohorts
can be rehashed and controls rerun into fresh outputs under one120-second
outer supervisor with their exact stored source/module identities. Mark this
as baseline diagnostic compatibility only. After any compiler change, every
candidate-bearing cohort must be freshly emitted by that checked API, and the
120-second envelope must include acquisition plus derivation plus controls. Use
an absolute deadline/shared-lock owner, never nest lock-owning supervisors. If
that budget ends, retain partial evidence and stop the screen; do not assert
compatibility or reuse old candidate evidence. No new acquisition runner is
proposed until root reviews the focused extraction above.

Preflight validates catalog/path bindings before any source acquisition:
Phase35 vector/region cohort preparation uses programs/catalog.json's fixed15
points; prepare only local-pair/local-fold/raytrace when those owners need it.
The45-point Phase37 catalog is separate for broad preparation, Phase36/37 owners
and measurements. Both must identify the exact same selected API. Manifest
arguments are used for final --prepared and Phase36; Phase37 owner planner
requires the preparation directory. Never rename or relabel catalogs or paths.
