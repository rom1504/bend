# Phase173 — reduce the work and the cost of executing it

Status: implementation and experiments. Parent `5a2d9c0`; qualified reference
remains Phase170. The user authorized the complete investigation, implementation,
and qualification of the proposed successor architecture. This document records
selection gates, not an assertion that any speculative design will be promoted.

## Objective and evidence

Target cold self-builds below 100 seconds, with 20–30 seconds the architectural
ambition. These are targets, not measured results or forecasts. Preserve the Bend
implementation, JS/C/QBE behavior, ownership, stack safety, independent final
verification, and generated-program quality.

The qualified canonical build took 189.329 seconds. Phase171's experimental
combination measured 180.677 seconds in one controlled pair. Phase172's static
publication shortcut changed a full build by only 0.59%, so it was not promoted.
The current diagnostic split assigns about 68 seconds to frontend work and 112
seconds to backend work; these instrumented intervals are not a clean cold score.
Halving only the backend cannot deliver the desired architectural result.

Important negative evidence: compact App nodes previously regressed checking;
removing some generic continuations did not remove downstream work; most helpers
already have useful direct lowering; borrowed selectors alone barely helped;
static-wrapper and constructor-field shortcuts did not transfer to the complete
compiler. Bendc also uses linked codepoint strings and intermediate passes. Its
small self-build is not an equivalent source/toolchain/output comparison.

## Competing execution and representation changes

### A. Borrowed computations over existing semantic objects

Preserve an immutable input/context through a complete allocating computation.
Return an owned result, retain only escaping fields, and reuse a unique record
when the complete verified update makes that legal. Compare unique, shared, and
static inputs. Admission must identify aliases, effect boundaries, ownership
transfer, field order, and publication. Unknown cases retain the existing route.

The initial experiment is a general record-update region, exercised by real
`k_with_children`/`k_with_span` consumers and an unrelated record/tree operation.
It must remove reconstruction or ownership work across the region, rather than
repeating the already-neutral borrowed-getter experiment. Semantic legality and
the backend emission template remain separate. No source-name recognizer.

### B. Durable indexed semantics with explicit lifetimes

Use stable numeric nodes/definitions, interned identity, preserved source spans,
immutable checked definitions, and side tables for established semantic facts.
Major consumers operate on IDs without reconstructing KTerm in inner loops.
Separate request-lifetime semantic data from bounded scratch allocations. Preserve
snapshots using append-only versions/deltas where necessary; never suppress all
reclamation for an unbounded request.

The first storage implementation is in checked Bend with exact import/export,
an independently checkable postorder graph invariant, and full KTerm/KLambda/
KLiteral metadata. Ordinary Bend Array is a persistent tree, not a mutable native
arena. Its access/update and ownership costs must be charged; this implementation
can falsify an assumed storage advantage. A native storage interface would need
an explicit lifetime/alias contract and measured justification, not silent host
compiler logic.

The initial complete consumers are `nc_compact` and ordered `nc_refs` on actual
erased bodies. Import, both operations, export, and cleanup are measured together.
This bounded test does not claim to eliminate erasure or the frontend. If useful,
migrate substitution, normalization, annotated erasure and closure discovery to
the durable store so the representation survives a substantial pipeline region.
Do not broaden an implementation that only wins by hiding conversion costs.

### C. One control-flow representation with demanded fallback

After selecting execution/storage primitives, keep one body representation and
verified function interface through lowering. Produce direct calls/loops where
legal and resumable frames for actual stack-safety, dynamic-call, or effect needs.
Construct generic bodies only for demanded fallbacks. Preserve indirect runtime
references and independent final verification. Phase169 already does early direct
admission: the next implementation must remove repeated body construction and
analysis, not merely omit another set of final continuations.

## Implementation and validation sequence

1. Freeze canonical source, qualified executable, runtime, Base, toolchain,
   outputs and current profile evidence. Record every candidate source identity.
2. Build A and B as bounded alternatives. Run independent full-value controls,
   including sharing, metadata, literals, boundaries and valid deep structures.
   Source checking, finite controls, and mathematical proof are distinct gates.
3. Compare complete real compiler computations and unrelated transfer workloads.
   Require dynamic work removal and clean runtime results. Charge conversion,
   acquisition, failed attempts and validation separately. Aim for 2–3× on a
   substantial computation; a tiny isolated win does not justify migration.
4. Select or combine only supported mechanisms. Migrate producers and consumers
   together, retain immutable facts, and remove superseded intermediate work.
   Estimate the whole-build ceiling before each expansion.
5. Run a larger real compiler request with the unchanged final verifier and
   complete QBE equality when promised. Otherwise compare independent semantic
   outputs, structural/ownership checks and generated-program performance.
6. Once substantial transfer is demonstrated, build the experimental full native
   compiler and run identical canonical source-to-executable requests. Separate
   frontend/compiler work, QBE construction, assembly/linking, memory, disk and
   qualification. Do not equate smaller text with faster compilation.
7. Qualify selected implementation through native N1/N2 reproduction, ordinary
   correctness/ownership/ABI gates and representative generated programs. Use
   independent JS/C routes where relevant; native agreement alone is insufficient.
   Promote only the independently qualified selection, retaining recovery assets.
8. Consolidate the selected route, docs, laws/contracts, reproducible receipts and
   failures. Commit and push checkpoints and the final report.

If an alternative fails, preserve the failure and use it to choose the next
architecture. Do not present an unsuccessful pilot as completion of the promised
successor architecture. Conversely, do not migrate the whole compiler solely to
satisfy an ambition after its premise is falsified.

## Laws and correctness boundaries

Useful small obligations: exact store round trip; child-ID bounds and acyclicity;
stable identities under append; complete ordered dependency preservation; record
update preserves all unmodified fields; retained shared/static roots remain valid;
escaping fields have owned lifetimes. Executable checkers and differential tests
will cover these first. Any independently checked BendTT theorem is reported with
its precise scope; `law` declarations and `@unsafe` implementations are not proofs.
The existing 112 protected verifier/proof declarations remain intact.

## Research cost and promotion discipline

One coordinating agent and one guarded CPU3 execution lane. Bounded agents may
implement independent alternatives and audit semantics without target execution.
Use fresh immutable source snapshots, explicit disk/RSS/time budgets, the 5 GiB
disk reserve, and close every run. Archive only reviewed completed artifacts with
verified retention evidence. Never remove qualified binaries or profiling assets
to make room for an unproven experiment.

Report clean medians/ranges, full output identity and per-workload regressions.
Keep generated-code quality, compiler throughput and research throughput separate.
Report remaining unknowns honestly. Ambition is a reason to test a different cost
model, not a license to weaken evaluation or predict an unsupported speedup.
