# Phase 4: structural compiler speed, with a six-hour feedback loop

Date: 2026-09-22. Authorized work window: approximately 14:16–20:16 UTC.
Starting revision: `89e2c83` on `selfhost/bootstrap`.

## Objective and scope

Improve successful compilation by the compiler written in Bend, and shorten the
time between an edit and trustworthy feedback. Preserve language semantics,
diagnostics, ownership checking, emitted-program behavior, and the existing
public JavaScript library ABI. A useful result is a measured improvement in a
real workload with a reproducible correctness argument, not a synthetic speedup
extrapolated to the whole compiler.

The initial expectation is another 1.3–2x improvement on affected compiler
workloads; 2–3x is a stretch outcome if a structural bottleneck yields. These are
planning estimates, not promised results. We will retain negative experiments
and revise the expectation as evidence arrives. A complete representation
rewrite is not required to produce a useful result within six hours.

The pinned TypeScript compiler remains revision
`6018e28ecc67cf1fffc0c20c64b11023474c2df8`. Do not modify the reference checkout or
the human-written `bend2/bend.ts`. Compiler algorithms remain in Bend; JavaScript
host tooling manages files, processes, provenance, and measurements.

## What is established before changing compiler code

The Phase 3 report distinguishes these implementations:

| Compiler/workflow | Established full-source observation | Meaning |
| --- | ---: | --- |
| Pinned TypeScript | about 50 seconds | Three same-source/root-policy observations; median process wall |
| Bend compiler, native O2 | about 250 seconds | One checked native compilation, emitting identical H bytes |
| B1, compiled by TypeScript | about 704 seconds | First full checked self-emission stage |
| H, emitted by Bend | about 1,980 seconds | Second full checked stage, byte-identical fixed point |
| Fresh checked B1 plus 21 focused cases | 36.35 seconds | Inside the workflow tool, excluding assembly and Node startup |

These full-source observations are not an alternating cross-version benchmark.
The existing controlled small comparison found H successful compilation largely
unchanged in Phase 3: tree 3.14 seconds, list sort 5.88 seconds, versus TypeScript
0.392 and 0.417 seconds of request work. The exact rejected bytes example improved
11.54x, which does not establish a corresponding successful-compilation gain.

The final H self-emission phase intervals attribute approximately 62% of wall
time to checking/post-check work and annotation, and 18% to emission. These are
adjacent host trace intervals, not sampled exclusive function CPU time. Doubling
emission alone would reduce total time by only about 9%, so we must investigate
shared runtime overhead and repeated analysis as well as code generation.

Freeze the current assembled source and 59 modules, manifest, B1 and H APIs,
runtime, host helpers, native build reports, completed fixed-point proof, and
comparison configurations. Record SHA-256 and canonical paths before and after
each run. The canonical Base path is part of the input: it affects foreign-source
metadata and exact output bytes. Keep the baseline available while source edits
proceed in parallel.

## Measurement before implementation

Use successful tree and list-sort programs for second-scale experiments. Add
compiler-source or representative extracted-module workloads when a mechanism
depends on long telescopes, large books, or compiler-specific terms. Obtain
exclusive CPU samples and top-level API timings from the frozen H and B1 APIs.
Separate discovery/parsing, checking, specialization, annotation, layout, and
emission; report gaps and profiler overhead instead of attributing every second
to a convenient function. An instrumented run is diagnostic, not a benchmark.

For timing claims, alternate baseline/candidate order on a fixed CPU, repeat at
least three times when practical, use fresh processes, consume outputs, and
check exact outcomes first. Record compiler/input/runtime/host identities, Node
arguments, CPU affinity, cache policy, failures, and process wall. Keep Base
caches separate per compiler identity and prime them explicitly where the
comparison calls for warm compiler caches. Do not call warm OS caches cold.

Measure separately: compiler request latency, end-to-end process/workflow wall,
generated-program execution, and compiler rebuild cost. A smaller export set or
different checking policy is a different workload and must be labeled.

## Parallel investigation A: private compiler calls

H pays for generic function objects, argument arrays, saturation/partial
application handling, tail-jump objects, and field projection. B1 has a different
emission strategy, which is evidence that the gap is not solely checker theory.
Explore a compiler executable with a narrow public boundary and statically known
private functions. A private worker may use positional arguments or direct calls
only when its identity and nonescape are established. Preserve recursion stack
behavior: a faster recursive call that overflows an existing accepted workload
is not an optimization we can ship.

The existing public runtime permits observable function-object mutation and
accessors. Phase 3's scalar guard changed the number of `.code` getter reads and
therefore changed an exception. Freezing existing public values or treating a
runtime identity guard as proof of purity would change the contract. Either
prove a value private behind an unchanged wrapper, or preserve the full generic
path. Partial application, overapplication, argument ownership, retained arrays,
tail calls, imported functions, and arbitrary public callbacks need explicit
coverage.

Initial estimate: medium-to-high complexity; 1.5–3x on H if it removes a dominant
cost, potentially much less. Bound the first feasibility experiment to 60–90
minutes. Start with disposable, hashed artifacts; integrate into the Bend emitter
only after real-workload gains and adversarial ABI checks justify it. Any private
image must carry its own provenance and must not be presented as the old public
full-library fixed-point workload.

## Parallel investigation B: repeated checking and annotation

Identify redundant normalization, substitution, type reconstruction, and book
lookup within a single checked compilation. Prefer structural reductions in
work over a cache that changes evaluation order or retains arbitrary contexts.
Candidate ideas include reusing an already-computed telescope/type, maintaining
small exact term facts, and avoiding repeated reconstruction of unchanged
subtrees when the normalization contract permits it.

The existing substitution routine rebuilds and can beta-reduce applications.
Absence of the substituted variable alone is insufficient to return the original
term. A safe shortcut needs the additional invariants that make rebuilding a
no-op. Cache identity must include every relevant environment/context component;
fresh compilation requests must not accidentally share mutable analysis state.
Preserve first error, shadowing, malformed-input handling, and BookCache sentinel
fallbacks. Existing annotations, diagnostics, and generated bytes provide exact
oracles where the optimization is intended to be representation-preserving.

The Phase 3 suffix-signature index gave about 8% on one full-book check and had
small-book/early-error costs. Do not repeat it without a stronger incremental
design. Annotation spine sharing already removed one synthetic quadratic type
reconstruction; remaining substitution costs require new evidence.

Initial estimate: medium complexity; 1.2–1.7x total if it improves the measured
dominant phases. First profile/prototype decision in 60–90 minutes. Verify exact
component results on real source, adversarial binders/shadowing, and source-level
fixtures before broad conformance.

## Parallel investigation C: representation and projection

`KTerm` currently stores a string tag, name, binder ID, quantity, a linked list of
children, and removed names. Repeated `tg`, `kid`, and other accessors can combine
generic calls, list walks, and allocation. Establish whether dispatch, projection
copies, tag comparisons, or term rebuilding dominates before changing the term
schema. First try local emitter/runtime improvements that preserve the public
representation. An explicit numeric/tagged variant or fixed child-slot design is
a larger alternative if measurements show representation itself is limiting.

Any changed internal representation needs a documented boundary and must preserve
sharing, normalization, malformed public values, and existing FFI behavior.
Avoid converting entire books eagerly at each host call. A term migration affects
most modules and the compiler ABI, so within this window its initial deliverable
may be a bounded prototype plus quantified evidence rather than a full migration.

Initial estimate: medium complexity for projection improvements; high for a term
schema migration. A successful local projection fix may help many phases; a
redesign's total gain is unknown until measured. Budget 60–90 minutes for a
decisive prototype rather than spending the entire window on an unproven rewrite.

## Integration and correctness gates

Each agent owns separate experiment files and reports; the coordinator owns
production integration, design updates, commits, and pushes. Reserve separate
CPUs for timed experiments, avoid overlapping tests on the same CPU, and record
contention that cannot be excluded. No agent edits another experiment's frozen
inputs. Coordinate production file ownership before integration.

Progress through increasingly expensive gates:

1. Checked pinned-TypeScript build of the assembled Bend compiler; ownership and
   completeness checks remain mandatory. No fabricated bootstrap provenance.
2. Exact component/ABI tests for the changed mechanism, including known Phase 3
   counterexamples. Run focused live paired source cases and execute outputs.
3. Controlled successful compile samples with baseline/candidate output checks.
   Reject complexity that produces no credible workload gain.
4. Full frontend comparison against the frozen Phase 3 candidate and live pinned
   TypeScript. Existing differences are recorded; acceptance parity alone is not
   exact diagnostic conformance. Persistent-worker results are fresh requests.
5. Checked full-source self-emission and self-reproduction of the final combined
   source/runtime. Both stages must consume the same frozen inputs, complete
   normally, and produce byte-identical libraries. If output deliberately
   changes, compare baseline behavior separately from the new fixed point.
6. Native and generated-program tests appropriate to affected code. A JS-only
   optimization does not imply a native gain; report unsupported hardware gates.

Preserve subprocess failures and incomplete reports. File-backed asynchronous
supervision is available when the environment rejects synchronous child-process
handling. Do not accept an `EPERM` result just because its status also says zero.
Once relevant gates pass, do not repeatedly rerun them without a new reason.

## Time allocation and decision points

The initial 45 minutes establish frozen baselines, profiles, and three bounded
alternatives in parallel. Over approximately the next three hours, pursue the
best measured mechanism(s), integrate independently reviewed changes, and run
focused gates after each coherent step. Stop broadening the production change
early enough to leave roughly two hours for full frontend validation, controlled
comparisons, checked self-reproduction, documentation, and push. Keep about 15
minutes for final evidence review and failures. Reallocate when measured costs
justify it, while preserving time for a truthful final result.

A full self-build is an integration gate, not the edit loop. Use checked B1
rebuilds and small capsules while developing. Retain native O2 as the existing
fast full-source lane; upgrading the convenient developer path is useful even if
the strongest H optimization needs more time.

## Deliverables

Commit this design before production changes. Maintain
`implementation/phase4/report.md` and linked evidence as results arrive, including
rejected hypotheses and limits. Add a compiler development document linked from
the repository README describing the validated workflow and any new switches,
artifact contracts, or ABI constraints. Make coherent commits and push them to
the already-authorized `selfhost/bootstrap` branch throughout the pass.

The final report will identify what shipped, what remained experimental, the
exact tested compiler identities, performance versus both Phase 3 and pinned
TypeScript, the fastest measured edit loop, and remaining conformance limits.
Do not silently promote a new distributed default API: promotion requires the
documented checks and explicit provenance for the selected artifact.

## Decisions during implementation

The measured private-image gains justify a separate build/run package rather
than changing the public generated runtime. Its production builder must consume
a real completed checked self-reproduction proof, verify the exact reviewed
runtime and generated-worker patterns, preserve all consumed identities, and
produce a distinct immutable image. An explicitly experimental checked-stage
mode may exist, but it must retain its pending-proof status everywhere.

Initial CLI measurements exposed significant launch/verification overhead,
including hashing the Node executable. The next supported interface is therefore
a finite batch of at most 256 data requests. It reuses a private worker for at
most 32 requests, while constructing fresh source graphs for each one. The
supervisor owns per-request deadlines, output bounds and process-group cleanup;
after a timeout or crash it preserves that failed row and starts a new worker
for later requests. Compiler rejection is an ordinary completed observation.

Node/image identities are checked before and after each worker lifetime; consumed
source bytes and path resolutions are audited per request. Successful emitted
files remain pending until the supervisor verifies that lifetime and rechecks
the consumed inputs. Inputs must remain stable through the chunk. A separate
fresh-source regression verifies that the reused compiler does not retain stale
graphs when a file is deliberately edited between requests. There is no daemon,
incoming function/graph transport, interpreter, native execution or user-code
execution in this private interface.

For source optimization, the promising fact is stronger than “no applications”:
substitution-invariant children allow a canonical neutral application to remain
unchanged. Exclude every variable, beta-reducible application, noncanonical
application metadata and wrong child count. Compute the fact once and carry it
only down literal `All` suffixes. Restart ordinary normalization/fact analysis at
other heads, including references and annotations that may expose dependent
types. Preserve head checking/annotation before the fact scan and preserve
substitution's child traversal order. Exact malformed-text and error-order
controls are required alongside real compiler-source timings.

Native `-O3`, ThinLTO and profile-guided optimization are bounded comparisons of
the identical checked C. Profiles are tied to that C, the compiler version and
training input identities. Charge instrumented build/training time explicitly;
a small steady-state win that costs minutes after each compiler edit may be a
poor choice for the development loop. The existing O2 path remains the control.
