# Native facts, calls and foreign runtime IDs

Baseline: checked compiler20 (`45a8ed4` report), pinned upstream0592662.
Goals: improve C program runtime and B1/B2 C-emission latency, close the observed
foreign callback gap, preserve other conformance, and avoid duplicated analyses.
Installed release and unrelated work remain intact. No PR comments.

1. **Conformance first.** Reconcile `FID(Clo~apply)` with the pinned runtime-ID
   contract. Keep namespaced/user resolution and unknown-ID diagnostics intact;
   update native emission and shared foreign parsing deliberately. Exercise the
   tail callback regression, ordinary callbacks, JS/native foreign IDs and lexical
   shields. Do not claim a full-conformance result from this selected gate.
2. **Compilation facts.** Replace repeated use counting in scalar-array ownership
   admission with a reusable per-definition summary, preserving saturated counts
   and maximum across alternative matcher arms. Check equivalence to the old
   queries on adversarial branch/duplicate cases and actual books. Require exact
   C equality on unchanged inputs. Prefer a smaller local memo if it gives the
   same win with less machinery. Measure before claiming improvement.
3. **Program representation/calls.** Inspect current tree/lexer/Map/closure C and
   upstream; identify surviving boxing or dynamic calls. Use a bounded saved-C
   discriminator or actual compiler experiment with independent outputs. Prefer
   extending existing product/worker analysis to a new architecture. Only select
   demonstrated general wins; retain generic fallback for unknown/raw inputs and
   preserve bounded stack and ownership contracts.
4. **Integration.** Freeze selected B1 and genuine B2; compare C bytes and balanced
   runtime/compilation results with20 and upstream. Run the37-case native gate,
   focused new controls and relevant JS/frontend checks for shared changes.
   Report all four goals, rejected attempts, gaps and line/module counts.

Register hypotheses before execution; commit/push design and implementation
milestones. New raw directories under Phase68 only, CPU3 target trees serial,
Node heap1GiB/stack4MiB, tree RSS2GiB, available-memory floor4GiB. Source/data work
on CPU0. Use narrow loops first; do not rebuild/rebenchmark unchanged binaries.
Record usage locally and avoid redundant reviews/large output.
