# Phase85: how V8 executes the self-hosted compiler

User authorizes deep investigation of V8 execution, reusing older designs. This
phase investigates the installed Phase82 B2 compiler itself; it does not rerun
legacy generated-program guard experiments or promise an optimization release.
Starting commit d2ea7f3. Source/installed images remain unchanged. Design, evidence
and report are committed/pushed; no PR comments.

## Questions and falsifiers

1. Do large generated SCC functions fail to reach useful tiers or prevent
   profitable inlining? Match generated-source locations to actual bytecode
   lengths and trace events, then inspect filtered optimized code when relevant.
   Source size or absence of deopts alone cannot establish the explanation.
2. How much first-request cost is sensitive to tiering versus repeated semantic
   work, GC and process state? Compare five ordinary requests per fresh process,
   clean clocks separately from instrumented traces/profiles. No persistent
   inspector/result cache or warmup is hidden in the fresh-request headline.
3. Does one shared code shape explain multiple sources? Use Numeric, Map,
   Functions65 and Lexer. Smaller Functions65 is useful because it admits its
   ordinary workers; a Map-only answer cannot explain its gap.
4. Can a bounded exact-output diagnostic ablation demonstrate causality? A saved
   compiler-image derivative remains unchecked and needs its own API-keyed Base
   preparation. Engine-flag interventions have altered runtime contracts and
   are diagnostics, not new qualified production speed claims.

## Evidence sequence

Read Phase49/50/51 V8 methods, Phase30 warmth cautions and current Phase83/84
profiles. Record the exact Node/V8 executable/options. Three bounded agents
inspect historical methods, generated source shape and official V8 sources;
root alone runs target processes. Agent offline processing uses CPU0 if it
coincides with timing. No additional agents or target builds are required.

Freeze current B2 and upstream roles from the Phase83 plan, with original Base
cache preparation and C oracles retained by exact hashes. First run three
rotated fresh-process rounds, five ordinary full native requests per process.
Validate complete C on every call and preserve ordinary Bend observations.
Record imports separately. Upstream's existing comparator loads/checks Base
but omits its CLI proof-report helper; retain that explicit contract distinction.
Repeated calls are a process-reuse diagnostic, not a claim of steady state.

Then collect separate opt/deopt/inlining/GC traces with import, request and
post-validation markers. Separate CPU profiles of the first and fifth calls
on two contrasting inputs. Do not treat profiling intervals as clean speed.
Inspect actual bytecode of a few hot/large functions; cap output and preserve
flags that can change feedback allocation. Use supported tier ceilings to
separate interpreter/baseline/optimizing behavior only when evidence warrants.
Do not equate --no-opt with disabling every optimizing tier.

Select the strongest observed mechanism for one bounded ablation. If a higher
bytecode cap, different code shape or tier policy helps, test its memory,
first-request, imports-plus-request and later-request tradeoffs. Preserve all
failures. A null result narrows the next architectural decision. No compiler
build/release gates until a separate authorized implementation merits them.

## Resources and decision

One target process tree, CPU3, Node24 heap1GiB/stack4MiB, aggregate RSS2GiB and
4GiB available-memory floor. Per-job time and64MiB file-size limits. Disk starts
below1GiB free: reuse frozen images, avoid unfiltered graph/assembly dumps and
full heap snapshots; archive only new evidence without deleting old seals.
No concurrent benchmark, compression, compiler build or agent target job.

Keep correctness, causal evidence, measurement and promotion separate. Explain
which functions are hot, which tiers run them, where optimization fails, and
how first/later costs compare with upstream. Rank next implementation options
with measured scope, conditional gain estimates and effort. Parity needs24.7%
less qualified B2 time; no single trace or pass-name budget proves that gain.

## Evidence-driven extension (before execution)

The first thread CPU trace observes substantial background optimization work
competing with the JavaScript thread on CPU3. Add a small, paired two-CPU
diagnostic: unchanged images, first request only, two rounds, same four sources
and both roles. Interleave CPU3 control with CPU2,3 affinity. Retain every output,
RSS and preparation boundary. This tests hardware contention with matched
upstream conditions; it is not a new one-core compiler optimization or release.

The original timeline01 captures V8 events but Node does not emit the requested
performance.mark events. Preserve it as incomplete for request attribution.
Timeline02 adds explicit PID/job and process.hrtime microsecond records; Node's
tracing documentation identifies this as the same time source as trace events.
An exact lexer-only generated-image experiment lowers four simple expression
choices to ternaries. It owns a newly validated Base cache under its new API
hash, stays unchecked/unreleased, and tests closure/context overhead only.
