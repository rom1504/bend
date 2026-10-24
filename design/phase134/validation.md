# Phase134 validation contract

[Main design](README.md) · [Execution budget](execution.md).
These are planned gates. No new runtime, performance or conformance result is
claimed by this document. Thresholds below are investigation triggers, not
permission to knowingly regress performance or proof of statistical equivalence.

## Reference identities and fair comparisons

Freeze the exact selected source, producer binary, prepared Base, runtime object,
QBE/assembler/linker, flags, target, source fixtures, repetition counts and output
oracles into each attempt. Reuse [Phase131's final capsule](../../implementation/phase131/final/README.md).
Its source is `1bc5930edcf80cda6c3572645df3c846fa631a83c2b936f20c83b05e0a6728f9`;
N2 was measured and N3 separately qualified. Do not attach N2 timings to N3.

Use two references for every meaningful incremental edit:

1. **Candidate clean rebuild of the new revision:** detects stale incremental
   results and wrong invalidation. Use an independent empty cache/process.
2. **Qualified reference compiler or independent semantic oracle:** detects bugs
   shared by the candidate's incremental and clean paths. Preserve exact output,
   refusal, ownership and stack-safety expectations.

Fresh versus cached agreement alone cannot establish compiler correctness.
Likewise, N1/N2 agreement is a reproduction check, not an independent theorem.
Keep the historical 45 ordinary fixtures distinct from the 45 repetition wrappers;
their output/count oracles are not interchangeable.

## Measured clocks and work

| Metric | Required scope |
|---|---|
| Cold compiler request | New process: input reads, Base/preparation, analysis, verification, emission and exit. State explicitly whether an on-disk cache is empty. |
| Cached edit request | Detect revision, invalidate/recompute, verify and emit required products; include cache lookup, loading and maintenance. State fresh-process or resident-process separately. |
| Ready executable | Checking/request plus QBE, assembly, linking and required transport/bookkeeping, with overlap accounted for. |
| Validated edit | Ready executable plus the specified independent checks and output gates. Identify exactly which gates are included. |
| Native acquisition | Building a candidate compiler executable, separately from running it. |
| Qualification | Extra generations, focused/ordinary conformance, proof and cross-backend gates. |
| Program runtime | Frozen ready executables, arguments, input/repetition counts and independent output oracle. |
| Resource cost | Target CPU, wall, peak process-tree RSS, logical live buffers, cache bytes, temporary disk and retained evidence. |

Process lifetime and cache state are independent axes: new process/empty cache,
new process/warm artifact cache, and resident process/warm state. Phase D first
uses a bounded two-revision batch, E can additionally reuse on-disk objects, and
F adds the long-lived service. A warm object cache does not imply restored named
IR or checked state. Attribute avoided lowering separately from avoided process
startup/Base initialization.

Track source bytes parsed/checked; queries visited/recomputed/hit; owner units
prepared/lowered/verified/reused; instructions rendered; objects built/reused;
binding changes; and reasons for invalidation. Hashing and validation scans count
as work. Report byte-weighted reuse alongside counts so many trivial hits cannot
hide recompiling one expensive owner.

Diagnostic counters and profiler sampling use separate runs. Clean timing
disables them. CPU samples are attribution evidence, not exclusive stage time;
allocator events are not live heap. Measure counter overhead on a small frozen
request before choosing which counters stay in development receipts.

Memory comparisons include current and previous revision state during updates,
not just steady state after eviction. Record high-water encoded buffer bytes and
physical representation estimates separately from RSS. A renderer that writes
early but retains all old chunks fails the memory goal.

## Tiered validation and escalation

Times are budget targets on reused artifacts, not guarantees or hidden build costs.

| Tier | Trigger and contents | Planning budget |
|---|---|---|
| V0: structural | Each edit: source/module checking as applicable, exact source bridges, descriptor/buffer tests and deterministic metadata. | Seconds to about 30 s after harness acquisition. |
| V1: focused | Each candidate boundary: emission/refusal controls, finite ownership/ABI witnesses, edit invalidation controls, bounded scaling extraction. | 20–60 s target; compiler acquisition separate. |
| V2: representative | Passing V1: three existing native compiler requests, transfer cases, paired clean timing and product classification. | About 1–3 min with ready images; measure actual cost. |
| V3: broad programs | Integration or machine/semantic change: ordinary45 correctness, wrapper products, changed-code runtime screen. | Existing full runtime screen about 178 s, plus emission/build/controls. Budget 5–15 min total when needed. |
| V4: full compiler | A promising scalable checkpoint: full-source emission, memory and cold time; then native qualification before selection. | Each self-request historically about 6–8 min; allow 30–60 min for a qualification block before failures. |

Use the inherited 19-case focused native gate and the new boundary controls.
The performance screen retains lexer, coverage-closures-256 and
coverage-map-churn-128. Add held-out request coverage for static data, recursive
workers and compiler-owner scale. Extractions may reject an idea; only actual
complete requests support compiler-speed claims.

Phase B warrants one early full-size emission because memory scaling is the
central hypothesis. Other small edits do not trigger automatic full reproduction.
After the emission and unit boundaries stabilize, qualify one combined useful
checkpoint, then another after semantic reuse/binding stabilizes. Do not batch
unrelated risky changes solely to save one validation run.

## Output and generated-program preservation

For streaming and representation-only changes, require complete QBE byte identity
with the legacy renderer, including order, whitespace/LF and data. Differential
tests cover empty/single/many functions, private helpers, data-only sections,
large strings/tables, errors, nested workers, and boundaries on either side of
the buffer size. Preserve error category/order and no successful partial artifact.

For deliberate symbol changes, require a lossless mapping or independent
structured comparison, plus machine inspection. Never normalize arbitrary
integers in the Phase132 changed-literal pattern as if equality were established.

Exact existing QBE plus runtime/tool/flags identifies the same build input; a
measured executable may be reused by its authenticated binary identity. A newly
built executable needs comparison of allocated sections, addresses, relocation/
symbol metadata, entry information and NOBITS extents under the existing method.
Identical instruction counts or `.text` bytes alone are not sufficient.
Only the already documented nonsemantic build-ID exception is automatic.

If products are established identical, do not repeat unchanged runtime timing
merely because the compiler's source changed. Record the evidence join and its
scope. A few representative output executions still exercise the changed driver.

If machine products change, use the existing Phase131 rule: fewer than 23 changed
wrappers get a changed-only screen; otherwise run the frozen complete45 block.
Changed-only measurements do not create a new whole-corpus geometric score.
Link partitioning, addresses, indirect dispatch, literal loading or calling
convention changes all require runtime checks even if source semantics agree.

For a full comparable block retain:

- Historical geometric ratio over 44 timed points; preserve the zero-work control.
- Mean positive log slowdown `mean(max(0, log(candidate/upstream)))`.
- Equal-weighted family score, fixed-batch sum and positive excess time.
- Counts over 1.1× and 2× upstream, worst regressions and per-case samples.
- Same-block candidate/qualified-baseline comparisons, not historical cross-window ratios.

## Performance decisions under noise

Use one controlled measurement lane, matching CPU affinity, runtime, build flags,
inputs and cache/process state. Avoid heavy parallel work during timings. Begin
with three alternating or rotated paired rounds; retain all observations and
the predefined warmup policy. Tiny cases need the frozen repetition wrapper,
not a newly selected loop count that favors the candidate.

Desired regression is **zero**. Investigate these screening triggers:

| Quantity | Trigger for focused investigation |
|---|---|
| Cold native request geometric ratio | Candidate/baseline > 1.02. |
| Any representative native request | > 1.05 or consistently slower beyond observed noise. |
| Generated-program geometric or family score | > 1.01 in a complete matched block. |
| Any generated workload | > 1.03, or a consistent smaller regression in a formerly sensitive case. |
| Peak memory / retained cache | Growth where the phase promises reduction, unbounded edit-history growth, or breach of the explicit run budget. |

Thresholds are triage rules; being below one does not prove non-regression. For a
flagged case run a separate five-pair confirmation using the same products and
predeclared method. Report it separately; do not replace the original block with
the more favorable result. A confirmed regression blocks default promotion while
it is explained/corrected. Do not offset a bad family by improving an already-fast
one. Stop with an inconclusive result if noise remains; do not keep sampling until
it passes. Report effect ranges and raw ratios; three samples are not a formal
noninferiority test.

A larger cold overhead may be worth a large warm benefit, but it is an explicit
tradeoff requiring a revised decision—not a hidden exception to this plan.
Compute break-even edits including acquisition and qualification before proposing it.

## Invalidation and persistent-state challenge matrix

Freeze each source pair/edit sequence, expected affected facts and independent
output/error oracle. No-op and comment-only cases are overhead controls, not
the headline evidence for useful incrementality.

| Edit or fault | Obligation |
|---|---|
| No-op; comment/spacing | No spurious semantic changes; preserve source maps/diagnostics. |
| Real `p111q_main` spelling edit; unrelated private body edit | Skip unaffected lowering; update changed compiler behavior correctly. |
| Same type, changed reducible body | Invalidate consumers that evaluate the body during checking/specialization. |
| Inlineable body, erased argument, quantity change | Recompute every consumed optimization/ownership fact. |
| Constructor field/order/layout/hotness change | Invalidate layouts, bound references and consumers. |
| Missing name becomes present; deletion/rename/duplicate | Record negative lookup, namespace and first-match/order dependencies. |
| New recursive edge or changed helper admission/refusal | Reclose affected groups and preserve bounded-pass/fallback semantics. |
| Literal content/graph change, pool reordering or capacity boundary | Rebind and reanalyze static-versus-dynamic admission where required. |
| Base/import/provenance or parser-context change | Invalidate exact consumed source/checking context. |
| Producer, policy, verifier/kernel, schema, runtime ABI or target change | Reject the old epoch unless a separately justified compatibility contract exists. |
| Truncated/corrupt artifact; wrong dependency fingerprint | Reject/fall back, never publish a hit or a complete result. |
| Error/cancellation then valid edit; edit/revert | Previous committed state remains valid; no stale partial updates. |
| Many alternating edits and evictions | Bound memory; result independent of cache eviction and valid update history. |

Mutate the recorder to omit a known dependency and require the challenge to
detect stale output. Also exercise an irrelevant edit that **should not** cause
invalidation. A system that recompiles everything is safe but fails the reuse goal.
Start with small programs, then replay the covered cases against real compiler
owners. Do not acquire a new full compiler image per mutation.

## Native qualification and independent boundaries

Independently check candidate Bend source and changed laws. Use the qualified
native producer to acquire N1; use N1 to build N2; require the appropriate output
fixed point. If parent and candidate code generation differ, continue to N3
as Phase131 did rather than demanding Q1=Q2 incorrectly. Bind each generation,
source, emitted QBE, runtime and machine-build receipt separately.

Concretely, parent(S) emits Q1 and builds N1; N1(S) emits Q2 and builds N2;
N2(S) emits Q3, with **Q2 = Q3** as the changed-codegen reproduction condition.
Build/qualify N3 where the established protocol requires it. N2 timing remains
N2 timing even when N3 is separately qualified.

Run focused19 on relevant native generations and ordinary45 on the final
qualified image. Bridge native-emitted benchmark wrappers to the measured
products by exact identity where possible. Measure N1 and N2 compiler execution
separately; self-build acquisition time and generated-program runtime remain
different metrics. Reusing a qualified producer's artifacts across adoption of
a new producer requires a new epoch or explicit evidence.

JS-hosted execution remains an independent differential/recovery path. Use a
small checked API for ordinary controls and appropriate cross-backend witnesses
for runtime, storage, ownership or semantic changes. Do not automatically emit
and execute the complete compiler via JS at every checkpoint. Full BendTT proof
checking, source typing, finite gates and reproduction establish different claims.

## Existing tools to reuse

- [Native request capture](../../selfhost/tools/performance/phase130/native-request.py):
  exact byte capture/expected QBE, source/image/carrier receipts. Current output
  root is `selfhost/build/phase130`; do not invent unsupported CLI flags/paths.
- [Aligned machine builder](../../selfhost/tools/performance/phase123/build-aligned.py):
  frozen runtime and alignment; current output root `selfhost/build/phase111`.
- [Phase131 wrapper screen and native bridge](../../selfhost/tools/performance/phase131/programs/README.md).
- [Phase132 object reuse and ELF audits](../../selfhost/tools/performance/phase132/incremental/README.md).
- [Native profiler](../../docs/self_hosted/PROFILING.md) and existing process-tree guard.
- [Phase131 qualification capsule](../../implementation/phase131/final/README.md)
  and [source-connected proof boundaries](../../docs/self_hosted/analysis-and-proof-boundaries.md).

First inspect/extend these interfaces narrowly and preserve their oracles. New
phase commands must be documented only after they exist. Every attempt uses a
fresh evidence directory. Harness changes and compiler changes receive separate
receipts so a faster measurement cannot silently be a weaker measurement.
