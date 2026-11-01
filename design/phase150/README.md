# Phase150 — cheaper optimized compilation and independent validation

Start at `267ae45`, on `selfhost/bootstrap`. The ordinary qualified native
compiler remains Phase147. Phase149's reduced optimizer is diagnostic only:
its faster acquisition produced a substantially slower research compiler.
The user authorizes the proposed upstream assessment, complete parser experiment
and bounded process-parallel validation investigation. New algorithm/tool logic
is Bend; reuse existing host source transport and resource/measurement tools.

## Questions and decisions

1. What upstream changes must a later migration preserve, and what performance
   ideas can transfer without mixing migration with an optimization comparison?
   Assess the exact `0592662..e9d269b` delta, including actual source changes.
   Do not silently change the pin, runtime, CLI contract or independent oracle.
2. Can a producer-side parser change reduce complete native parsing cost while
   retaining exact tokens, parse graphs, source positions and first diagnostics?
   Begin with fused lexer classification and quote metadata, eliminating repeated
   head/tail/lookahead constructions and rescans. Do not assume lexing dominates
   the full parse stage. Preserve the current FToken/FInput boundary initially.
3. Can independent correctness jobs finish sooner in separate processes, without
   changing compiler heap ownership or contaminating serial performance evidence?
   The QBE runtime remains one mutator, one CPU worker, GPU off. An outer aggregate
   guard owns all independent children, their fresh roots and memory/disk budget.

## Efficient experiment ladder

- Freeze current source, qualified producer, Base/carrier/runtime/toolchain and
  actual compiler-source and unrelated inputs. Preserve baseline and negative
  outputs. Existing historical parser slices are provenance/oracle aids; a new
  timing baseline must use current maintained declarations and current runtime.
- Build a small Bend lexer/parser workload, including input transport, consumer
  work and teardown. Compare complete token fields on finite/Unicode/error controls
  and complete parse graphs on real inputs before timing. A checksum alone is
  not a semantic oracle. Typecheck every new source independently.
- Start with lexical and complete parser clocks on one frozen compiler input.
  Include conversion/reclamation. If the changed work is a small fraction or the
  complete native boundary is flat/slower, record rejection and stop that variant.
  A substantial complete-region win, ideally2×, warrants a larger experiment;
  smaller gains need a correspondingly small/clean implementation to justify
  integration. No full-image acquisition just to test a weak early idea.
- Transfer to unrelated source/diagnostic shapes. Keep source law and protected
  verifier bodies intact; no generated-program optimization may be disabled.
  Require exact emitted QBE for successful compilation before claiming unchanged
  generated-program quality. Native self-reproduction/full qualification is
  reserved for a justified production integration, not every diagnostic variant.
- Separately compare identical independent qualification tasks in serial and
  two-process modes. Charge coordinator startup/output and all child work;
  verify each child report and expected products independently. Keep fixed CPU
  allocation, aggregate RSS/disk ceilings and fresh nonoverlapping roots. Report
  wall time and CPU separately. This does not make a single compiler request
  parallel or qualify a multi-mutator QBE runtime.

## Ambition without unsupported claims

The bounded outcome is a useful measured parser change or a decisive rejection,
plus an upstream migration assessment and real process-parallel feasibility
evidence. The larger direction carries stable semantic identities through
parse/check/publication, or directly produces compact lowering units consumed
without pack/unpack adapters. Phase148 showed why a late conversion layer can
erase the expected benefit. A reusable checked unit could eventually enable
independent verification, parallelism and incremental reuse; one successful
unit must establish that benefit before a framework or universal IR rewrite.

Keep proof work tied to actual invariants. Finite exact-token controls and source
checking are not a BendTT equivalence theorem. No new whole-compiler proof, GPU
backend, policy-search framework or upstream speed ratio is an implicit goal.

## Execution and reporting

One coordinating agent owns all target executions. Bounded agents independently
review upstream, parser semantics and the separate-process driver. CPU3 is the
serial measurement lane. Parallel correctness pilots use an explicit disjoint
CPU mask; no other target runs concurrently. Use fresh disk-guarded roots, keep
5GiB free reserve and16GiB available-memory floor, and close/archive completed
or failed runs. Preserve the installed and qualified images.

Commit design, validated implementation milestones and the final report/evidence.
Report prediction versus outcome, native complete cost, generated-code identity,
source/complexity growth, failures and acquisition/validation cost separately.
