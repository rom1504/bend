# Phase56: qualify direct self-hosting and retire proven dead code

The installed Phase55 host02 compiler remains the reference. Its direct image
successfully handles eight ordinary-driver probes, but has not freshly checked
the full compiler source or reproduced its own complete module. The user asks
for easy legacy removal, then self-hosting conformance and compiler speed without
regressing compiled programs. This phase prioritizes those concrete obligations.

## Sequence and decision gates

1. Audit remaining legacy consumers. Delete only demonstrably dead code or
   superseded active paths whose replacement is already qualified. Preserve the
   public legacy backend, native boundaries, historical experiments and required
   seed/image transforms. Coordinate edits against frozen source identities.
   A small justified deletion is preferable to another architecture rewrite.
2. Reuse Phase55's exact own-source direct image (B2). Run it through an isolated
   byte-identical ordinary driver, with private Base caches. Admission requires
   the checked host02 subject, successful B1 emission, successful driver controls,
   exact source/runtime/roots and original receipt identities. An emitted image
   must never receive a fabricated checked-attempt or bootstrap sidecar.
3. Make B2 emit the same source through the unsplit library entry to B3. Require
   whole-module B2/B3 equality, including runtime, all exports and wrappers.
   This establishes an emission fixed point only, not fresh checking or soundness.
4. Separately make B2 freshly check the entire compiler source. Expand semantic
   execution beyond the eight driver controls using existing source, numeric,
   composition and overapplication fixtures. Retain exact differences and
   compare emitted bytes where existing checked-B1 evidence permits it.
5. Record timings for these real compiler operations. If a bounded attempt
   fails or is unexpectedly slow, preserve it, profile the actual blocking
   operation, and test the smallest general fix. Never replace a failing check
   with an inherited proof while calling it fresh checking.
6. Consolidate tools, evidence, documentation and next steps; commit and push.
   Promotion of a different installed image additionally requires release and
   relocation validation. Successful experimental qualification alone does not
   silently replace the installed default.

## Performance and correctness boundary

The last clean generated-program campaign covers 45 points / 23 sources and
measures 1.069599 times pinned TypeScript execution time. That dated result
remains applicable to identical executable modules. Compare the entire retained
benchmark modules when compiler/backend changes occur; time changed workloads
with their output checks before any performance claim or promotion. Do not rerun
669 samples simply because unrelated tooling changed. Source-check success,
emission equality, ordinary-driver behavior, language conformance, compiler
latency and generated-program speed remain distinct claims.

Fresh comparisons must state source, API, runtime, Base, Node, cache state and
timing boundaries. Stage timings with provenance checks are diagnostic costs,
not warmed throughput or a general compiler/TypeScript ratio. Use ordinary
small and compiler-sized requests before selecting new performance work.

## Parallel work and limits

Independent agents audit cleanup, prepare reproduction, prepare semantic/self-check
gates and challenge the result. The root reviews and serializes target execution,
integrates and publishes. Reuse maintained runners rather than constructing a
new framework. Initial full operations receive explicit bounded deadlines;
timeouts remain evidence. Use CPU3, Node 24.18.0, 1 GiB heap, 2 GiB process-tree
RSS and a 4 GiB available-memory floor. No concurrent heavy compiler jobs.

Use fresh Phase56 outputs. Phase54 and Phase55 archives stay closed, including
their caches and attempts. Preserve all 103 inherited unrelated files. Do not
edit pinned upstream sources or post PR comments. Report concrete removals,
passed/failed gates, measured compiler costs, unchanged program output and any
remaining qualification gaps without claiming universal conformance.
