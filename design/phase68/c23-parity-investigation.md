# Compiler23 native runtime parity investigation

The user requested more evidence before selecting the next C-target optimization:
native profiles, generated-code analysis, a comparison with pinned upstream, and
research grounded in other compilers. This investigation changes diagnostic
tools and documentation only. It does not promote a compiler or claim a speedup.

## Frozen question

Checked source `b2ec0a2` (compiler23) takes 1.724 times upstream C runtime on the
six-family set. Numeric and arrays are approximately at parity; tree, lexer,
Map and closures remain 3.118, 2.646, 1.786 and 1.785 times upstream respectively.
These are the preceding balanced campaign's results, not fresh measurements.
Upstream stays at `059266225b77c8ca256ac6b25ee5c21449bab151`.

Can we attribute most of the remaining gap to a few general mechanisms, and
specify short experiments that establish their attainable benefit before a
large compiler refactor? Reaching parity and beating upstream by 2x are distinct
questions. Operation counts alone cannot establish either outcome.

## Work lanes

1. Root: frozen input manifest, fresh native CPU profiles and dynamic allocation,
   ownership and call counters; quantitative synthesis and report.
2. Generated-code lane: all six paired C programs, structural counts and exact
   hot-body comparisons, separating runtime support from emitted user code.
3. Upstream lane: source-level mechanisms, existing selfhost equivalents, gaps
   and correctness constraints; challenge the assumed value of direct calls.
4. Research lane: reuse prior work and expand primary-source research on
   ownership, unboxing, closure specialization and control-flow lowering.
5. Profiling-method lane: bounded main-thread statistical sampling fallback
   if Linux perf is unavailable; source/data work only until root executes it.

## Measurements

Use actual saved compiler23 acquisitions and their pinned upstream counterparts,
with identical workload and Clang recipe. Bind C, receipts, executable, toolchain,
oracle and diagnostic tools by hash. Every new target gets a fresh directory
under `selfhost/build/phase68/parity-survey23*`; historical evidence is immutable.
One root-owned guarded CPU3 target tree runs at a time, with a 2 GiB process-tree
RSS threshold and 4 GiB available-memory floor. Source/data work uses CPU0.
No compiler rebuild or full conformance rerun is required for unchanged code.

Collect fresh counts on all four slow families with independent output oracles.
Compare one versus seventeen repetitions to isolate a sixteen-input cycle.
Extend allocation counts to source call sites where useful. Instrumented clocks
are diagnostic, never clean timing evidence. Obtain native CPU samples for both
roles; preserve perf failures and state any sampling blind spots. Prefer sampled
instruction/source localization over assigning whole inlined functions a cause.
Inspect optimized assembly/IR for the paths implicated by both samples and counts.

User-space sampling must be separately qualified: fixed bounded storage, no
allocation in the handler, explicit thread and signal selection, correct oracle,
attributed/unattributed sample totals, and comparison of generated executable
text when debug information is added. A failed method is retained and replaced
by a clearly identified fallback, never silently counted as a successful profile.

## Decision product

The report will distinguish observations, causal evidence and hypotheses. Rank
mechanisms by affected runtime, potential gain, implementation cost, semantic
risk and the cheapest falsifying experiment. Do not multiply overlapping gain
estimates. For each substantial refactor, specify a saved-C proof experiment,
counterexamples and a generalization gate on additional programs. Include the
coverage limits and a path to a broader C corpus before a general parity claim.

Hypothesis record: [P68-022](../../experiments/phase68/P68-022-native-parity-survey.md).
Report: [native parity survey](../../implementation/phase68/c23-parity-survey.md).
