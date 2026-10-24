# Phase132: memory, retained representations and a native-first loop

This is an offline source/receipt audit, not a new performance experiment.
Exact costs and artifact identities are in
[the build audit](../../implementation/phase132/build-cost.md) and its JSON.
Source-line references below refer to the frozen Phase131 combined source
`1bc5930…728f9`, available in the
[final source capsule](../../implementation/phase131/final/README.md).

## What native execution actually checks

`p111_compile_source` (line40942) first prepares the authenticated compact Base
carrier or parses Base. `p86_plan` then loads the request. The chain includes
`check_program_diagnostic_world` (38408), `driver_report_data`,
`driver_emit_owned`, entry checks, annotation/reachability and
`jl_checked_error`, before constructing the native request. Runtime-effect
admission is separate. The optimized lowering still invokes its final
independent structured-IR verifier; for example `p126bp_complete` (54641)
checks final functions against the original program/certificate before emission.

The TypeScript-authored upstream checker, executed by Bun, provides a separate
independent source/API gate. `stage0-library.mjs` loads and validates the whole
book, rejects holes, checks selected API exports, and calls `js_lib`; that call
also enforces ownership. Its recorded14.178 seconds includes JS API generation.
This is not a native compiler dependency required for every request: the native
entry already checks source. It remains valuable as an independent oracle for
changed compiler source and for bootstrap/recovery. Removing it from a gate
would change assurance, not prove a faster checker.

A practical native-first loop uses the already-qualified native image for small
source/proxy requests, keeps independent checking where the experiment requires
it, and reserves a complete N1/N2/N3 chain for integration. It should not rebuild
the compiler executable merely to inspect every proposed source transformation:
checked exported Bend helpers and extracted representative workloads can reject
weak changes cheaply. Conversely, JS-hosted exported-function calls are not
measurements of native compiler speed.

## Retention boundaries supported by source

| Boundary | Source fact | What is and is not established |
|---|---|---|
| Parsed and checked book | `p86_plan_loaded` retains `load`, `world`, original definitions while checking; later stages carry checked `book` and source context. | There are overlapping logical views; reference sharing can avoid copies. No heap census proves their peak contribution. |
| Raw and optimized candidates | `p128raw_plan_finish` (56421) returns both lowered result and raw candidates; `p128raw_session_finish` (56517) keeps those through subsequent transformations. | Intentional reuse avoids repeated analysis. Freeing raw data earlier requires proving no late closure/fallback consumes it. |
| Final validation and rendering | `p126bp_complete` builds a direct/assembled view, verifies it, then renders. `p118z_bundle` (51847) carries segments, private functions, IDs, tables and fusion information. | Verified structure and rendered output can overlap during emission; exact simultaneous live bytes remain unmeasured. |
| Rendered output | `P111Emission` holds `List<String>`; `p111_print_chunks` (40948) performs IO after construction. | The whole result is a collection of strings, not a file-backed incremental sink. Function chunks do not by themselves provide streaming production. |
| Private rendering joins | `p112c_chunks` joins private chunks and `p112c_attach` prepends them to the first chunk (44047–44057). | Some paths can create large chunks despite the outer list. Actual selected final chunk-size distribution has not been measured. |
| UTF-8 output | Runtime `io_cbuf` (2498) takes/frees two-field String nodes while filling a growing buffer, then `io_print_run` frees that buffer. | Temporary buffer allocation is per chunk; claiming a second retained whole107 MB buffer would be wrong. |
| Arena reclamation | Runtime `heap_free`/banks recycle slots; corpus reserves and grows address space. | Freed logical nodes can remain in resident reusable pages. Allocation counters and RSS measure different things. |

Source edits that release objects earlier can reduce peak liveness but may not
immediately lower RSS if the arena keeps pages. The current profiler's allocation
counts are cumulative requested events/words, not peak live words. Active owner
attribution identifies execution context, not the original creator of a retained
object. Full-context counters were deliberately disabled, so short-program
allocation totals cannot be extrapolated into a full-compiler heap census.

The measured full-source workload spends substantial physical samples in
reference management/destruction (about29.4%) and string equality (about10%).
Active-owner attribution points to `nc_ctor_owned`, `lookup` and `f_find`.
Those are opportunities to remove repeated semantic work and intermediate
traversals, not proof that the textual emitter dominates379seconds.

## Smallest decisive memory experiments

1. **Packed or streaming final output, same bytes.** First inventory final chunk
   lengths and expanded String payload. Compare a verified-unit renderer with
   current output, retaining exact QBE and source identities. Preserve global
   tables, IDs, final-verifier obligations, error behavior and deterministic
   ordering. Never stream unverified executable output as a successful result.
   A temporary file may hold speculative output until final success, but it must
   not silently weaken verification. Byte-identical products make this a clean
   representation experiment. Expected memory benefit is plausible; speed is
   unmeasured.
2. **Reuse immutable checked-book facts.** Constructor-ownership lookup is a
   whole-book scan at source31097 and7.48% of full active contexts. Compute an
   exact summary once per immutable book, preserving first-match, missing-name,
   duplicate and fallback behavior. It may reduce allocations/traversals in
   both checking/lowering; full7.48% elimination is only a local context ceiling,
   not an expected speedup. This alone cannot deliver a39× rebuild.
3. **Tighten representation lifetimes only after use audit.** Carry a small
   semantic certificate instead of retaining a raw AST/candidate catalogue where
   a later stage requires only a few facts. This is more intrusive than dropping
   an unused variable: shared fallbacks, late worker closure and the independent
   verifier may rely on the original representation. Measure retained bytes and
   compilation cost before expanding the change.

## One honest incremental source-edit witness

A cheap, controlled first edit changes only `p111q_main` (40886): rename the
emitted local SSA variable `%result` to `%answer` at its definition and return.
The strings have equal length. This preserves emitted program semantics,
exported ABI and runtime contracts while requiring changed compiler output.
It tests a real compiler helper and static-string dependency handling. It is a
small **text-generation** edit, not evidence about arbitrary optimizer/CFG edits.

Freeze the exact patch and check the edited source independently. Use the
qualified native N2 to compile that source once, yielding the full changed-source
QBE reference. Build full and reused machine products from this same new
reference, compare their semantics and linked interfaces, and count changed
function/data units, source-dependent IDs and rebuilt bytes. Existing original
QBE cannot be the edited-source oracle. A complete additional self-hosting chain
is unnecessary merely to compare machine-unit reuse, provided this remains an
experimental product and does not replace the qualified compiler.

There are6,529 declared source names, so one leaf is about0.0153% of names, but
that number predicts neither invalidated IR nor elapsed cost. A local literal
may change shared data ordering, generated IDs or reachability-dependent
summaries. Report measured dirty units and transitive dependencies rather than
assuming one-source-function/one-machine-function locality. A second witness
should change a pure helper's computation/CFG, followed by an interface/layout
change that intentionally invalidates its dependents.

For a10-second warm loop with1–2seconds spent in incremental machine building,
remaining frontend work must stay below2.1–2.4% of today's379-second full request.
The required semantic reuse is therefore much more demanding than a useful
machine-object cache. Stable content-addressed semantic units need checked
source bodies, elaborated interfaces, ownership/layout/effect assumptions,
policy/runtime/tool identities and transitive dependencies. Stable local IDs
must be distinguished from stable cache identities; a compact numeric renaming
alone establishes neither.

## Bounds and missing measurements

A1MB per-unit representation cache and10MB extra working heap may be useful
long-term budgets. A1MB entire compiler IR or10MB total native RSS is not an
experiment supported by the present57,842-line compiler and10.82MB instruction
text. Disk compression also does not alter in-memory String representation.
RSS samples, virtual reservation, resident mapped text, live heap bytes,
cumulative requested allocation and retained disk bytes should remain separate
metrics.

Next required evidence is limited: actual emitted-unit locality after one source
edit; selected chunk-size/lifetime information during an already-needed run;
and correctly scoped stage clocks. Do not pay for another full unchanged image
build just to restate the baseline, or build a broad incremental framework before
the locality witness shows which boundaries are reusable.
