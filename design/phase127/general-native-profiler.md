# Phase127: reusable native Bend profiling

Start: 2026-10-23 09:44 UTC. Working window: three hours, through 12:44 UTC.
Parent: `6fe4f29` on `selfhost/bootstrap`. Installed and qualified compiler
selections remain unchanged. This phase builds profiling capability and uses it
to explain native N1 compilation cost; compiler optimization is a follow-up only
if a small causal experiment is necessary to validate attribution.

## Objective and acceptance

Build a reusable profiler for sequential native Bend programs, with N1 as its
first substantial workload and unrelated ordinary programs as transfer controls.
The first useful result is an explanation of Phase126 versus Phase125 native
request cost, backed by exact outputs, independent timing and retained captures.
Generic means the runner, capture format and symbol/semantic attribution do not
encode compiler phase names or benchmark names. Workload manifests may supply
ordinary commands, frozen output oracles, source identities and optional scopes.

The primary metric is complete fresh-process source-to-QBE request wall/CPU time
on fixed inputs, including preparation, output and exit. QBE machine build,
compiler acquisition and generated-program runtime are separate metrics. The
native prepared-Base policy is explicit. Upstream emits C, so its historical
ratio is a workflow comparison, not identical-output throughput.

## Iterative implementation

1. Generalize the existing unchanged-ELF sampler into a small reusable command
   runner and offline analyzer. Record exact ELF/tool/source/oracle identities,
   clean wall/CPU/RSS, sampled PCs, executable/library mappings, decoded Bend
   function names, unknowns, loss and CPU coverage. Infer unsized QBE symbol
   ranges conservatively. Require exact complete output for every capture.
2. Run paired Phase125/126 N1 lexer, closures and map requests. Rotate roles;
   keep profiled times out of clean timing statistics. Use two sampling periods
   to detect aliasing and require adequate sample counts. Examine absolute
   estimated CPU cost as well as fractions. Add ordinary-program controls.
3. Use the actual blind spots to add generic attribution. Evaluate explicit
   logical scope IDs carried through runtime continuations or diagnostic
   generated-code markers. First establish feasible semantics and overhead;
   do not pretend physical native callers reconstruct erased logical ancestry.
   Optional runtime event counts must distinguish attempts, allocations,
   reclamation and dispatch, and never masquerade as time percentages.
4. Iterate on the profiler and measurements: source/group attribution, selected
   physical caller recovery, phase timing or work counters as justified. Reuse
   existing objects and diagnostic links where possible. A diagnostic compiler
   build is allowed only when smaller controls show the instrument adds useful
   information and disk/memory permit it.
5. Publish reproducible CLI documentation, raw bounded evidence, limitations,
   profiler overhead, a compiler bottleneck ranking and next causal experiments.
   Validate the analyzer against deliberately malformed/ambiguous synthetic data
   and the runtime against ordinary deterministic source controls.

## Architecture

`workload manifest -> clean/sample runner -> capture -> symbol/source analysis
-> optional semantic scopes/counters -> comparable report`.

Keep collection separate from interpretation. OS signal sampling and ELF tools
remain host instrumentation, not a second compiler. Reuse the existing C sampler
and Python measurement/ELF machinery; any compiler semantic changes belong in
checked Bend or an explicitly reversible diagnostic artifact transformation.
Logical source identities and metadata should be reusable by later backends;
this phase only qualifies sequential native Linux x86-64.

An optional scope is a profiling annotation, not permission to weaken ownership,
effects, stack safety or final verification. Its context must restore across
continuations; recording all recursive ancestors unboundedly is unacceptable.
Physical self costs, logical inclusive costs, estimated allocations and retained
memory are distinct. Deferred reclamation attribution must state whether it
names the executor, creator or logical scope. Unknown attribution stays visible.

## Resource and cost discipline

Root owns the one serial CPU3 target lane with existing guards, ordinary 2GiB
RSS limit and 16GiB available-memory floor. Agents perform bounded independent
analysis and disjoint tooling edits; no duplicate target campaigns. Initial disk
headroom is only147MiB, so recover exact immutable duplicates before captures;
preserve paths/content and document metadata consequences. No broad self-host
qualification just to test profiler plumbing. Preserve failures and partial data.

Indicative allocation: first30min reusable capture/baselines; next60min diagnosis
and focused attribution; next60min deeper repeated profiles and generality
controls; final30min independent review, evidence, documentation and push.
Adapt to evidence rather than fill a feature list. Commit completed milestones.

## Failure and success criteria

Reject sample captures with unaccounted loss or inadequate thread coverage for
quantitative claims. Label small sample groups low precision. Instrumented runs
are diagnostic only; check output equivalence and compare overhead to clean
runs. Rejected scopes, malformed maps and failed controls remain evidence.

Success is a usable general profiler, measured on compiler and ordinary Bend
programs, that resolves at least one attribution question the old leaf-only
profiles could not. No promised speedup, complete logical stacks, GPU support,
whole-compiler proof or recursive acceleration claim.
