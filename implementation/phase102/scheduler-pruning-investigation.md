# Scheduler reachability after native direct-call lowering

The final bounded-inline compiler retains a substantial scheduler implementation
that has no path in the emitted host literal-FID graph. This is a promising
compiler-image build-cost opportunity. It is not yet a validated deletion pass.
No compiler, native target or rewritten C was executed during this investigation.

The reusable offline census is
`selfhost/tools/performance/phase102/typed/scheduler-reachability.py`, with exact
source hashes and results in `selfhost/build/phase102/scheduler-reachability02.json`.
It selects literal `DEVICE` conditions for CPU, keeps both sides of unknown
conditions, removes quoted strings/comments, and collects all literal FID
references from every remaining scheduler body. Every literal reference in NF
workers and the runtime outside scheduler bodies is treated conservatively as
a root. The dispatch table and numeric ID declarations are excluded as
execution roots. Runtime footer references are conservatively attached to the
always-retained exit segment.

| Exact emitted C | Scheduler cases | No literal-root path | Continuations among these | Approximate host segment text |
| --- | ---: | ---: | ---: | ---: |
| Final compiler B1 self output | 20,991 | 11,629 | 8,613 | 4,159,742 characters |
| Source-index | 553 | 428 | 278 | 160,114 characters |
| Image-render | 513 | 325 | 215 | 104,355 characters |
| Dependency-plan | 560 | 383 | 253 | 143,610 characters |

For the compiler this is 55.4% of scheduler functions and 21.3% of the inspected
host scheduler text. It is not 55.4% of compiler runtime or C compilation cost.
The method uses textual segment boundaries and a conservative partial
preprocessor, so byte estimates are approximate. It does not model arbitrary
numeric construction of callable terms. The ordinary roots are main, entry,
exit and closure application; IO emission becomes reachable through runtime
references. All NF code is conservatively retained.

## Why ordinary C dead-code elimination cannot finish the job

The host runtime emits `static const WlFn wl_tab[] = { WL_TABLE };`. Every
`WL_X(FID)` expands to the corresponding scheduler function address. Dynamic
closure, continuation and task dispatch indexes that table. Consequently every
listed scheduler function is address-taken, even when no runtime value can
carry its ID after direct-call lowering.

NF wrappers replace a scheduler entry's host body with a direct NF call but
retain the original scheduler fallback inside its device branch. The original
curried closure factories and continuations remain in the segment list and
dispatch table. Local NF composition similarly avoids scheduler cuts while
earlier reachable-definition collection can still retain the old definitions.
This is broader than removing just a few duplicate direct-entry wrappers.

The existing `N_Segment.refs` field is not yet an exact post-lowering host edge
set. `nf_wrap_segments_rev` preserves its original refs when replacing the body,
and marking functions can attach the whole original definition's call set to
segments. Reusing that field unchanged would conservatively retain much of the
redundancy. A precise pass should collect host execution/value-construction
edges during final lowering, and preserve separate fallback/device edges.

## Conservative implementation boundary

The useful invariant is that every callable FID is created by a known lowering
operation or a certified runtime constructor. Track both direct jumps and
**address-producing** operations: `term_clo`, `term_tsk`, task-node creation,
saved continuation IDs and static closure/task words. A function-valued use is
an edge even when there is no direct call. Dynamic application then consumes
those reachable values; it does not justify pruning their factories.

Start with a CPU-only specialization for the existing checked native runtime
permission, preserving the original device program. Treat unknown FID producers
as escaping all applicable scheduler entries, or decline pruning for that
request. Raw/provider programs must retain the original path until their
producer contract is established. Existing no-bang permission alone establishes
the device boundary, not the complete FID-producer invariant.

For a first experiment, keep all numeric IDs, arity/result-width/flag arrays and
static data unchanged. Replace dead CPU table slots with one shared explicitly
failing unreachable-dispatch stub while omitting their host definitions. Keep
the original device table and bodies. Simply deleting `WL_X` entries would
shift the positional table and dispatch live IDs to the wrong functions.
Renumbering would also require updating encoded static words and could change
the `FID_ENTER >= 4096` dispatch specialization, confounding the experiment.
An instrumented failure stub is useful for finding an incomplete reachability
model; passing executions alone cannot establish that the model is complete.

The principal unresolved hazards are:

- Closures and partially applied functions retain IDs through heap fields and
  may be called much later, including from another worker.
- Continuation stacks and task queues retain numeric IDs independently of
  current lexical calls.
- Foreign effects, raw runtime providers or unchecked word-to-function paths
  can manufacture IDs not spelled as literal FID macros in a reachable body.
- Static image data can encode tagged callable words numerically; those values
  need decoder-aware roots rather than text matching.
- Device and CPU fallback paths need separate graphs. Discarding the device
  fallback while building a CPU graph does not authorize deleting device code.
- Metadata is also used for readback, ownership and scheduling. Execution-body
  pruning does not authorize removing those tables or changing their indices.

## Next decisive experiment

First establish the producer invariant for the exact trusted native/runtime
route and add generated-code controls covering escaped closures, partial
applications, callback fields, dynamic dispatch, task continuations, static
data and raw-provider refusal. Then prepare one saved-C host-only ablation on
the exact final image, with stable IDs and a complete table-slot manifest.
Measure a bounded matched Clang build, and execute the already frozen app and
compiler request oracles before integrating a Bend pass.

The current census suggests enough function-count reduction to justify this
experiment; it does not support a numerical build-time gain estimate. Because
the FID-producer and static-data boundary was not proved within this short
investigation, no supposedly sound C-pruning prototype was produced. The exact
candidate and qualification chain remain unchanged.
