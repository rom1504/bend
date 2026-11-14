# Phase194 — x86 value identity and diagnostic discovery

Compiler transformations are Bend. Python/JavaScript files transport checked APIs,
execute independent observers, authenticate products and measure/retain evidence.
They do not implement source optimization or select machine instructions.

## Current methods

Use the existing maintained source/build workflow with explicit assets and a
fresh output path. `job.py` wraps actual work in the repository process-tree and
disk guard on CPU3, preserving5GiB reserve and closing retained runs. Never nest
it inside another guard. Root owns one target lane. Metadata preparation is
separate from execution; `qualification-plan-v2.py` does not run its commands.

The frozen final source is `selfhost/build/phase194/selected-source02/compiler.bend`.
The final report, not this method description, establishes which gates passed and
whether an image is qualified. Installed Phase189 and qualified Phase193 remain
independent references.

## Fast experiment ladder

1. Prepare a checked API from an explicit frozen parent with Phase190
   `prepare-api.py`; source check/acquire using maintained `hosted.mjs`.
2. Run finite machine controls through shared typed-instruction object and GNU-as
   consumers. Current fixtures: float-value-controls-v2, predicate-controls-v3,
   predicate-stress-v3, commutative-controls. Corresponding drivers are
   float-value-driver-v2, predicate-driver-v3, predicate-stress-driver-v3 and
   commutative-driver. See exact captured argv for their export lists.
3. Use Phase192 checked emission and Phase190 construction on six development
   programs. Runtime comparison reuses Phase185 adaptive calibration and rotated
   role order. Five roles require five rounds, four roles four rounds.
4. Only after machine evidence and useful actual runtime results, freeze maintained
   source and execute the larger native qualification plan. `compare-hosted-subset.py`
   requires a fresh same-parent seven-root API with no experimental overrides.
5. Run the immutable full native45 against fresh C/QBE/Phase193 references.
   `summarize.py` retains failures, dispersion, per-case regressions, family and
   positive-log/excess diagnostics; ten development and35 heldout cases are frozen
   in `cases.json`. A heldout case here means not used to tune this campaign;
   historical programs were already known.

Full native reproduction and finite gates do not prove whole-compiler correctness.
Source type acceptance is not independent BendTT proof. No new kernel theorem is
claimed. Runtime and compiler latency are separate objectives.

## Separate twelve-program diagnostics

The active catalog is **`diagnostics/catalog-v3.json`**. Use
`diagnostics/emit-programs-v2.mjs`, `build-programs-v3.py`, and
`runtime-loop-v3.py`. Earlier versions are retained failed experiments, not active
alternatives. `oracle-v3.py` checks the24 mathematical outputs and source pins.

Six paired families cover value identities, register pressure, F32 representation,
predicates, ownership/products and cache-resident dependent memory. They remain
outside native45 and its score. The emitted sources preserve independent literal
outputs at `(32,17)` and `(1024,17)`. Calibration changes repetitions only.
The runtime adapter checks both points across all four roles (96 observations)
then runs four balanced timing rounds on all12 cases.

For a fast source/semantic check, emission accepts an explicit unique CSV subset,
for example `--cases memory-dependence-sequential,memory-dependence-dependent`.
The builder accepts that ordered memory pair or the existing first3/full12 sets.
For C/QBE reference acquisition use the ordinary benchmark acquisition tool with
`--set full`; the catalog declares that exact set. Avoid an overlong CSV argument
because the retained guard treats command words as possible paths.

The [diagnostic execution recipe](diagnostics/RUN-v3.md) gives four-role merge/run
commands. Run timing within `job.py` with270s/32MiB outer budget and240s internal
limit. This is prepared-program runtime, not source-to-executable build time.
Each point includes the same result-validation/timing wrapper. Inspect actual
machine code before interpreting a source pair: the memory pair retains nested
state operations, and source sharing does not itself prove heap allocation.

## Failure preservation and cost

Initial float/predicate/stress fixture annotation/order failures, memory fixture
versions1/2, stale-parent API provenance refusal and overlong-argument guard
predispatch failure remain recorded. No validator was weakened to make them pass.
Versioned sources and fresh API preparation fix the corresponding boundaries.
The first compiler-cost command rejected an invalid set/missing guarded flag
before executing requests; planner v2 fixes it. The first final-runtime command
started before manifest preparation finished and failed before execution.
`runtime02` waits for the completed immutable manifest; `runtime01` remains a
failed orchestration receipt, not a timing result.

`campaign-cost.py` counts terminal outer guards once; it excludes agent/billing
cost and unguarded preparation. `pack-evidence.py` captures bounded original
receipts, observations, failed attempts and argv; binary/source/IR artifacts stay
at their pinned paths. See [evidence-method.md](evidence-method.md).

[Design](../../../design/phase194/README.md) ·
[Report](../../../implementation/phase194/README.md) ·
[Machine findings](../../../research/phase194/diagnostic-machine.md) ·
[Independent semantic audit](../../../research/phase194/combined-audit.md).
