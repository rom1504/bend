# Phase115: reusable plans and a bounded policy experiment

Started 2026-10-21 at `877911f`, following the user's authorization of the
small optimization-planning experiment. One agent; one CPU3 target lane.
Preserve Phase114 sources, gates, qualified native images and installed selection.

## Question and falsifier

Can retaining legal emission alternatives make a small optimization search
cheaper, without changing any policy's emitted program? This tests research
capacity, not autonomous invention or sustained recursive acceleration.

The current public emitter tries complete direct workers, then H, R, G, H
again, then generic/fused fallback. The second H attempt repeats a pure query
on unchanged inputs. Different legal orders also repeat much of that analysis.
Phase104's design distinguishes cheaper experiments from greater research yield;
the existing MLGO/CompilerGym research motivates separating legality from choice.
No new literature campaign or backend is required.

## Bounded intervention

Add a Bend-only experimental interface around the exact qualified source02:
derive the existing direct/region/fusion alternatives from verified original IR,
retain them in a request-local immutable plan, and choose/render by policy data.
Never use caller-supplied plans as correctness certificates. Preserve original
planners, ownership checks, hygiene, runtime, final verifier and renderers.

Four predeclared policies keep direct workers first:

0. H, R, G, generic: current selected behavior (legacy retries rejected H).
1. R, G, H, generic: earlier legal precedence.
2. H, generic: omit R/G alternatives while retaining the general fallback.
3. Generic/fused only after direct admission.

Compare the original-style engine (plan during every emission) with the retained
plan engine for every policy. Policy0 must also match the untouched Phase114 API.
Require exact complete QBE identity between engines at each policy; policies may
differ from each other. Do not prune definitions or alter semantic optimizations
in this experiment. Stop extending the architecture if preparation, retained
memory or rendering removes the hoped-for benefit.

## Inputs and evaluation

Use existing checked ordinary sources and independent expected outputs. Training:
tree-bitonic, list-pipeline128, expression128. Evaluation: lexer, local-pair,
active-ray256. These are previously seen programs, not blind research holdouts.
Freeze paths/hashes before execution. Initial source checks and emission screens
must succeed before machine builds. If preparation is too expensive, retain that
negative result rather than redesigning the benchmark after observing timings.

Both engines share frontend/lowering, verification, immutable indexes and common
private/data emission. Charge those shared setup costs separately and equally.
Time retained-plan preparation explicitly. Rotate engine and policy order over
three measured rounds after one disclosed warmup; compare the same number of
complete emissions and hashes. Record cold setup and warm replay separately.
Only one copy of byte-identical products needs a machine build. Run ordinary
output checks for every distinct selected policy product, then the existing
bounded runtime method for policies with valid products. No policy is accepted
solely for a favorable static count or in-sample runtime.

Measure fixed-work cost and validated candidates per measured second. A fixed
policy sequence and deterministic output equality should give the same search
outcome under equal work. Equal-wall-budget replay may expose more candidates,
but a simulated budget projection must be labeled as such. Without an actual
budgeted run and better independently validated outcomes, claim only capacity,
not improved research yield or recursive acceleration. Include failed attempts,
API acquisition, build and validation time. Agent/token spend is unavailable;
wall time outside guards is not a token-cost measurement.

## Cheap gates and stopping

1. Exact parent composition and checked API, original verifier unchanged.
2. Ordinary checked IR: policy0 exact old/new complete output; every policy exact
   between engines; plan counts and elapsed time on training inputs.
3. Existing output oracles, selected runtime comparison and evaluation inputs.
4. Only a strong general gain justifies full native-image qualification later.
   No full self-build is needed to report a negative or scoped capacity result.

Disk is constrained. Reclaim only exact duplicate immutable Phase114 QBE,
assembly and object products via verified hard-link deduplication, retaining
both original paths and contents plus a receipt. Never alter source, ELF,
runtime or test data. Use original 2GiB/16GiB/64MiB guard settings for small runs.

The final report answers: current bottleneck, next priority, distance to actual
self-optimization, smallest feedback experiment, useful architecture and work
to stop. Commit the design first; then implementation and honest results.
