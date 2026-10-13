# Phase83: explain work before replacing representations

User authorization: investigate with agents and research other compilers. This
phase does not optimize production or promote a compiler. Phase82 remains the
installed baseline at commit `8042809` (B1 `8a400725`, B2 `098320e8`).

## Questions and division of work

Three bounded research agents own separate documents under
`research/compilers_architecture_and_techniques/phase83/`:

1. Compare upstream and selfhost pipeline work, using Go/LLVM implementation
   mechanisms to identify redundant traversals, metadata and contexts.
2. Audit representation replacement, using Zig/Cranelift. Specify old passes and
   objects removed, consumers served, and invariants; challenge the IR hypothesis.
3. Explain B1/B2 generated-code and allocation differences, using V8 and a
   functional compiler. Separate historical samples from new evidence.

Root owns serial diagnostics, evidence integration, review, documentation and
commits. Agents do not build compilers or independently run validation. Their
initial investigation budget is 20–30 minutes, with early findings requested.
The prior no-agent preference is superseded for this explicitly authorized
investigation. No PR comments are authorized.

## Measurements and decision rules

The qualified three-source Phase82 ratios are 1.673× B1 and 1.328× B2 upstream.
Parity needs approximately 40.2% and 24.7% less request time respectively. These
are Bend-to-C compilation requests, not C execution or Clang compilation.

Use a varied subset of previously validated C inputs and established small and
many-function held-outs. Record source selection, exact compiler/driver/runtime
and oracle hashes. Measure fresh Node processes, explicit prepared Bend Base
outside the request clock, source/check/report/C emission inside, and preserve
imports separately. Rotate role order. Diagnostic clocks and profiler samples
remain separate from clean samples. Upstream output and each selfhost output
are checked against their own previous exact C oracle.

Reuse existing profiles first. Collect new diagnostic data only to resolve a
specific gap. One CPU3 target tree, Node 1 GiB heap/4 MiB stack, aggregate RSS
2 GiB and available-memory floor 4 GiB. Keep new artifacts small given low disk
space. No builds, broad conformance campaign or generated-program execution is
needed because production does not change.

Prior failed typed-graph and eager-product experiments (Phases79/80), and the
small Phase82 owned erasure gain, are required counterevidence. An agent must
report a cost bound, exact code paths, a replacement mechanism, a cheap falsifier,
correctness risks, and implementation effort. Literature speedups do not predict
Bend gains. Overlapping stage costs cannot be added.

Recommend a subsequent substantial prototype only if evidence supports a route
to at least 15% complete-request savings. Retain weaker findings as incremental
options. No promise of parity or 0.5× follows from an architectural analogy.

## Deliverables

Keep research source links and read dates, a file per investigation hypothesis,
reproducible diagnostic methods and compact raw evidence, and an integrated
report in `implementation/phase83/`. Rank opportunities separately for B1/B2,
including program-class limits, simplicity and runtime-preservation boundaries.
Commit and push the investigation without changing the installed compiler.
