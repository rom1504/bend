# Phase118 request-bound integration

## Scope and status

`integrated-entry.bend` is an isolated overlay for the combined Phase118 source.
It overrides only `p111_emit_admitted`; it changes no existing diagnostic API,
runtime, verifier or installed selection. This audit is source inspection, not a
claim of successful checking, performance improvement or native qualification.
The root owns compiler acquisition and execution.

Inspection base: `selfhost/build/phase118/combined-source01/compiler.bend`,
SHA256 `c27f33103b97971fee08e2706459582b78ff50fb8960985d8b2f780a792f61e3`.
Its manifest identifies the borrowed v3/v2 modules, cold modules, TRMC v4, sized
calls and capability-table hook. Those files remain unchanged.

## Dataflow and authority

The production-shaped flow is:

1. Existing `p111_emit_plan` performs runtime admission. An incoming admission
   error still produces `compile: ...` and does not invoke lowering.
2. `p113a_lower_request(request)` runs once. Its ordinary source/bound check and
   all selected lowering passes remain intact. It derives `P113ACertificate`
   from this same request; a lowering failure keeps the original error prefix.
3. `p113a_verify(program)` runs once before either new transformation. Its
   selected TRMC contracts and all original structural checks remain intact.
4. Only `certificate.scalar` enables the cold and borrowed derivations. This is
   exactly the `ns_definitions(book,names)` permission used by both diagnostic
   plans. `unshared` is not substituted for it or broadened; the existing array
   renderer continues to use both fields according to its original policy.
5. `nh_definitions(book,names,[])` runs once. `*` retains the original program;
   otherwise `p118c_candidates` derives the existing conservative ordinary
   constructor set and `p118c_apply_verified` changes only its hot metadata.
6. The original `no_candidate_names` definition/bang/effect filter runs. Each
   candidate gets one `no_observer_plan`. Existing `p118b_eligible` checks the
   complete residual with mature `no_emit`, owning-root preservation and exact
   wrapper restrictions. The admitted plan is passed directly to
   `p118b_functions`; it is never discarded and rederived from a name.
7. Nonempty worker additions pass through unchanged `p118b_compose`, including
   the independent structural projection/check of the borrowed runtime import,
   exact constructor arity and merged function signatures. Only an empty added
   function list skips that additional index/check: there is no new body to
   verify and the original program already passed step 3.
8. The existing `p113a_admitted_chunks` routes and combined `p111q_data_chunks`
   hook emit the selected functions, tables and capability 8 as before.

The external entry accepts the same request and admission-result interface as
before, not arbitrary derived IR, cold lists, saved certificates or workers.
All internal continuations receive objects constructed from that same request
in this invocation. Do not export the internal `p118e_*` continuations as trusted
serialized-plan interfaces. The existing compiler assumes its checked request
comes from the ordinary planning boundary; this patch does not create a new
untrusted request format or a persistent cache.

## Work removed, by inspection

For the successful scalar-enabled cold+borrow path in `emit-v4.mjs`, excluding
its separate independent parent oracle, the diagnostic composition invokes:

| Work | Diagnostic composition | Integrated entry |
| --- | ---: | ---: |
| Candidate lowering | 1 | 1 |
| Candidate full original verifier | 4 | 1 |
| Source/bound validation at these entry boundaries | 5 | 1 |
| `ns_definitions` at these entry boundaries | 5 | 1 |
| Whole-program `nh_definitions` | 2 | 1 |
| NO plan derivations for an accepted observer | 2 | 1 |
| NO plan derivations for a rejected observer | 1 | 1 |
| Added borrowed-worker structural check | 1 | 1 when nonempty |

These are source-level call counts for the enabled diagnostic route, not timing
measurements. Existing lowering may itself contain other analyses or repeated
bang/signature construction; the table does not claim those are eliminated.
Independent reference lowering/checking remains valuable in the qualification
harness, but does not belong inside every production compilation request.

The candidate scan accumulates functions in reverse and reverses once, preserving
the previous candidate order and each reader-before-adapter pair. Mutual tail
calls avoid adding a pending append frame per source name. The generated backend
must still establish whether it lowers those calls without native stack growth.
The first derived-worker lowering error aborts emission; it never silently
selects an unchecked worker or masks a failure with baseline output.

## Remaining gates and risks

First check the composed Bend source. Then compare complete QBE bytes from the
integrated entry against the defensive combined diagnostic route on the existing
map/tree/list/lexer controls. Identical bytes would isolate the preparation
change from generated-code quality. If bytes differ, account for function order,
metadata or template changes before interpreting any timing.

Keep the ordinary controls for shared aliases, equal/unequal observer roots,
constructor counts, effects and unknown-sharing refusal. The source-bound
derivation does not itself prove the semantic soundness of borrowed execution
or cold sealing. Those remain the previously documented NO/nh assumptions,
runtime contracts and external correctness gates.

Measure the complete admitted request, separating frontend/prepared-Base cost
and one-time API acquisition. Do not infer a native compiler speedup from fewer
hosted diagnostic calls. Existing broad qualification and actual native N1/N2
evidence are still required before promotion. No additional cache, backend or
search infrastructure is introduced.
