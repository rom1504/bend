# Phase136 — What makes a cold native compiler build expensive?

2026-10-24. Investigation of the qualified Phase134 N2, starting from
`286fe9987e7bf79f6de6f7652e988f3148aff41c`. The selected compiler is unchanged.
[Design](../../design/phase136/README.md) · [Metrics](metrics.json) ·
[Query audit](baseline/source-audit.md) · [Native mechanics](profiling/query-mechanics.md).

**The proposed cold-build direction is justified, but a wholesale compact-IR
rewrite is premature.** The strongest immediate opportunity is to compose the
already demonstrated borrowed-query capabilities with the actual hot compiler
computations, and remove the remaining repeated definition scans. QBE machine
construction is a small part of the measured total. Incremental reuse remains
valuable, but the existing late cache cannot accelerate the earlier work.

## Controlled baseline and clock boundaries

One ordinary cold source-to-executable build takes **375.923 seconds**, with
**1.018 GB** sampled peak process-tree RSS. It produces the complete independent
**107,059,385-byte QBE oracle exactly**. All compiler, QBE, assembler and linker
processes succeed. This uses the qualified Phase134 N2 (`9909f18f…`) to compile
the fixed historical Phase131 source (`1bc5930e…`) at its unchanged path.

Cold means a fresh process with no retained source, semantic-edit or object cache.
The immutable prepared Base and prebuilt runtime are explicit common inputs.
OS caches are not flushed; toolchain/Base/runtime acquisition is not charged.
This is one observation, not a new upstream comparison or a speedup claim.
[Baseline identities and recipe](baseline/README.md).

The supervised pipe's inner clock is 374.939s; compiler emission and QBE overlap
inside 369.031s. That interval cannot be called compiler-only time. A separate
replay of the same exact QBE measures **8.727s QBE + 4.874s assembly + 0.266s
linking**, with a 14.948s outer guard. These replay clocks are not added to the
already overlapped baseline. The replay object is byte-identical; the complete
ELF is not. Inspection finds identical executable/read-only/data load segments;
the first load segment differs in section-table offset and build-ID metadata.
No whole-ELF reproducibility claim is made for this ancillary replay.

Even eliminating that approximately 15-second machine step would leave almost
all of the present build cost. Another backend or another late object cache is
not the best immediate cold-build experiment.

## The former “frontend” bucket is now separated

A checked diagnostic entry calls the original computations, with seventeen
explicit timing boundaries. The ordinary entry and original proof/helper bodies
are preserved. It passes complete frontend-plan and independent-QBE comparisons
on three frozen programs, refusal controls, and twelve native output gates.
Two counterbalanced ordinary/staged pairs per small case give ratios 0.9853,
0.9962 and 1.0127. This small screen supports coarse diagnosis, not zero overhead.

The full diagnostic request takes **354.331s wall / 354.306s CPU**, with
**354.248s** inside the stage clocks and 971,984 KiB child peak RSS. It emits the
same full independent QBE oracle. It writes to a file, without a downstream QBE
consumer, and is a different diagnostic executable from the clean baseline.
Do not interpret their difference as an optimization or instrumentation saving.

| Existing computation | Seconds | Share of staged interval |
|---|---:|---:|
| Base preparation | 0.205 | 0.06% |
| Parsing and imports | 44.745 | 12.63% |
| Checking | 53.149 | 15.00% |
| Diagnostic report preparation | 1.812 | 0.51% |
| Ownership checking | 0.144 | 0.04% |
| Compilation eligibility | 0.006 | <0.01% |
| Context preparation | 3.273 | 0.92% |
| Reachability and annotation | 13.546 | 3.82% |
| Annotation validation | 5.110 | 1.44% |
| Erasure/request preparation | 30.326 | 8.56% |
| Runtime admission | 0.027 | 0.01% |
| Initial lowering/preparation | 59.411 | 16.77% |
| Opening verification | 10.983 | 3.10% |
| Inlining and its commit check | 17.073 | 4.82% |
| Ranges and their commit check | 9.013 | 2.54% |
| Final verification/borrowed-helper closure | 40.665 | 11.48% |
| Rendering/writing and associated reclamation | 64.760 | 18.28% |

The frontend, excluding Base acquisition, is **152.111s**, not 175 seconds of
type checking. The dedicated ownership checker is negligible here; ownership
management inside other computations is a separate, substantial issue. The
40.665s closing interval also includes helper closure and reference management,
so it must not be labeled pure independent verification.

The final 64.760s is measured without QBE backpressure. It includes rendering,
conversion, writes and reclamation at that boundary. We have not established
which fraction a byte-buffer emitter could remove. A smaller final file alone
would not establish that saving. Initial file reads and final timing printing
sit outside the stage sum; current continuation closures can affect lifetimes.

## Two interacting causes in actual generated code

The [source audit](baseline/source-audit.md) and
[exact QBE/runtime extracts](profiling/query-mechanics.md) distinguish:

1. **Too many visited definitions.** `f_find` still walks an ordered raw list.
   Constructor ownership also scans definitions and ADT children. Ordinary
   `lookup` already uses its Patricia index when the caller supplies a prepared
   `BookCache`, so simply adding another hash table misses the real boundary.
2. **Too much work per visit.** Reading a name or kind from a retained `KDef`
   can keep the row, take all nine fields, and sink eight unwanted fields. A
   normal raw `lookup` visit does this twice. The retained row forces the shared
   reference-transfer path: this can bump and drop references without destroying
   their underlying graphs. The loops are already local loops/tail SCCs; adding
   another trampoline or tail-call transformation does not remove this work.

The [checked query census](baseline/query-results.md) passes fourteen controls
and thirty observations. Querying each raw prefix name takes 136/2,080/32,896
visits for 16/64/256 definitions. For sixteen actual constructor names, prepared
lookup performs sixteen index delegations rather than 7,247–7,622 raw row visits.
Index work remains nonzero and uncounted internally. The prefix rows are shared
Base definitions across cases, not three independent transfer demonstrations.
These are logical counts under an explicit query schedule, not measured
whole-build call frequency, allocation counts or speed gains.

Blindly replacing parser scans with its existing scope index is incorrect as a
general proposal: scope construction can reverse declaration precedence and
store header payloads instead of the original definition. First-match, law-fill,
missing-name, alias and cached-child behavior must remain exact.

## Reuse the earlier positive experiment

The qualified shallow observer admits at most eight fields; `KDef` has nine.
This is a bounded admission policy, not an eight-slot runtime ABI. Four admission
contracts and a separate late inline limit are involved; changing one number
does not establish legality. The runtime's checked borrowed-field helper and
independent buffer-capacity verifier can already support larger records.

[Phase131 wider-record research](../../research/phase131/wide-records.md) already
demonstrated 32.48% less time for a scalar KDef query, 41.03% for an unrelated
nine-field record, and 50.65%/61.95% for composed scalar-selector extractions.
Those were kernel results with code-growth costs, not full-compiler qualification.
They were not rejected for a demonstrated broad slowdown. They should be reused
as the first ceiling experiment on the current actual query path.

This differs from the rejected [field-mask experiment](../../research/phase131/field-mask.md):
that removed unused loads/stores from an already borrowed reader and was neutral.
The present hypothesis removes owning field transfer and reference-count churn.
Source `+` annotations alone do not promise a borrowed native calling convention.
Keep complete scalar consumers under a live root; do not return an unowned
String or KDef through an owning interface.

## Refreshed physical profile

The exact qualified N2 object was relinked against the existing authenticated
diagnostic runtime, avoiding another compiler build. One ordinary full-source
request sampled every 32ms passes the independent complete output oracle.
There are **11,569 samples**, zero reported loss, approximately **99.68%**
main-thread CPU coverage, and no capture-quality rejection. This is diagnostic
execution: 371.773s wall/371.555s CPU, not a clean timing comparison or an estimate
of profiler overhead. [Profile evidence and limits](profiling/README.md).

| Active source context | Share of all samples | Drop/fade within that context |
|---|---:|---:|
| `nc_ctor_owned` | 7.90% | 53.17% |
| `lookup` | 5.15% | 49.33% |
| `f_find` | 5.11% | 48.22% |
| `p111v_get` | 4.02% | 47.96% |
| `index_remove` | 3.77% | 51.38% |

Across the whole capture, physical `term_drop` is 17.43%, `span_fade` 12.32%,
and borrowed String equality 8.94%. The first two total **29.74%**. The three
main query contexts total **18.16%**, with **9.21% of all samples** in their
drop/fade intersections. Those intersections are subsets, not additional time.
Active contexts include synchronous private calls; they are not full inclusive
call stacks or exact stage labels. Some query invocations can execute under an
outer context. Unknown physical/context samples remain in the denominators.

This supports removing both repeated traversal and reference-transfer work.
It does not establish that all reclamation is redundant, identify original
allocation sites, or justify deleting reference-count operations globally.
`has_name` is a useful contrast: its 2.90% context contains no sampled drop/fade,
and 74.93% of it is String equality. That path needs fewer comparisons, not
another ownership optimization.

## Ranked next experiments

These are conditional engineering estimates of **whole cold-build time saved**,
not measurements or additive gains. They include integration/testing work where
stated. The current investigation implements diagnostics, not these optimizations.

| Priority | Concrete experiment | Plausible saving | Decisive experiment / integration estimate |
|---|---|---:|---|
| 1 | Reuse wider borrowed layouts plus complete scalar name/kind consumers on actual compiler queries; inspect that take/sink work disappears | **5–12%** if prior local gains transfer across the measured query contexts | **30–90min** ceiling; **2–4h** integration and focused/native gates |
| 2 | Eliminate remaining ordered scans: exact parser-prior query interface, early immutable constructor-ownership summary, and avoid repeated list removal where equivalent | **5–15%**, overlapping priority1 | **1–2h** measured caller experiment; **3–6h** integration with ordering/absence/ownership controls |
| 3 | Separate emitter construction from final cleanup; test bounded byte-oriented rendering on one owner unit using the existing structured IR | **5–10%** if a substantial part of the64.8s interval is removed | **1–2h** profile/ceiling; **4–8h** implementation and output/IO gates |
| 4 | Carry one immutable prepared definition and its semantic facts through checking/annotation/erasure/lowering, avoiding repeated construction | **10–25%** only if cross-stage duplicate work is demonstrated; lower confidence | **2–4h** first falsifier; **1–3 working days** for a useful broader boundary |
| 5 | Move incremental reuse before semantic preparation, then connect it to existing machine units | Potentially large **warm-edit** gain; no cold gain assigned | **4–8h** one-owner edit prototype; broader invalidation remains additional work |

Priority1 is deliberately bounded. Applying a 30–60% reduction only to the
18.16% classified query samples suggests approximately5–11% request savings,
before acquisition, code growth and other costs. It does not predict2× overall.
Scalar-consumer composition may reach other contexts, but that is unmeasured.
Priority2 can eliminate both traversal and its ownership work, so multiplying
its forecast by priority1 would double-count likely savings.

For the next cycle, first use the existing Phase131 wider-record fixture and
current query extraction, with a small two-factor comparison: ordinary versus
borrowed observation, and raw versus correctly indexed lookup. Keep all four
legal variants, independent outputs and actual emitted-call inspection. Record
visits and ownership events separately from wall time. Require a second unrelated
record/tree query before broadening. A new analysis pass is unnecessary if the
existing verified plans can express the winning composition.

Then measure one full same-source native compiler request. Distinguish source
algorithm changes from a better-built compiler executable: a code-generation
improvement may first become visible in the successor generation. Measure N1
and N2 explicitly. Preserve the qualified tool until native self-reproduction,
ordinary semantic gates and relevant generated-program performance gates pass.
Do not run those expensive campaigns for a failed local ceiling.

Useful narrow laws are exact scalar-query fusion and first-match preservation
for a prepared prior index. Reuse the existing independently checked bucket
fusion theorem where its actual definitions match. Such laws do not prove
native ownership/ABI correctness or whole-compiler equivalence; retain those
independent checks and the final verifier.

## What this says about the larger ambition

Going from 375.9s to 60s needs about **6.3×** acceleration; reaching 25s needs
about **15×**. Neither one query optimization nor elimination of the entire
frontend establishes those outcomes. Even halving all 152.1s of frontend work
would save only about a fifth of the clean full build, assuming unchanged other
costs. The 60s target requires changes spanning preparation, lowering and output.

The useful lessons from the existing pinned Zig/Go research remain: compact
identities, explicit immutable semantic facts, short-lived lowering state and
reuse before expensive work. Their warm incremental results are not cold Bend
comparators. Start with a small held compiler-context/query interface, then one
prepared owner unit. Build wider indexed storage or a persistent cache only when
that boundary demonstrates a measured benefit and correct invalidation.

No selected source, runtime, optimization policy, mathematical proof or installed
selection changed. No fresh broad45 speed ratio, N1/N2 qualification, upstream
parity result or recursive acceleration is claimed. Existing qualified metrics
remain those of Phase134; diagnostics and methods are separate research code.

## Cost, failures and reproduction

[Cost receipts](costs.json) retain **23 guarded jobs totaling26.56 minutes**, with
no overlap between their recorded intervals. The large costs were the clean
baseline375.92s, one diagnostic image acquisition380.08s, the full staged
request355.83s guarded, and exact-object profiling375.37s guarded. The last clock
includes capture analysis. Source/API gates, twelve small native controls and
the machine replay account for the remainder. Three bounded agents audited
source/proxies, stages/evidence, and physical/generated-code mechanics; the
coordinator alone ran target workloads. Agent tokens/quota and unguarded reasoning
are not measured by process receipts.

Two failed attempts remain visible: the first bridge launch used an unavailable
bare `bun` command, then used the pinned executable; the first appended query
counter was rejected for duplicated scalar arguments without sharing annotations.
Source02 fixes six annotations and passes checking and all controls. Frozen
failed source01 is retained. Neither failure required changing compiler semantics
or weakening a gate. The native profiler reused an existing program object and
diagnostic runtime; another full compiler acquisition was unnecessary.

The [compact evidence archive](evidence01/receipt.json) preserves sources,
commands, successful/failed receipts, diagnostic output, raw samples, contexts,
caller sidecars, exact owner map and analysis methods. Full QBE/ELF/API products
are excluded and remain pinned by receipts. Re-symbolization also requires the
separately identified binary/shared libraries; the archive is not a standalone
binary capsule. [Stage tools](../../selfhost/tools/performance/phase136/stages/README.md)
and [profiler recipe](../../selfhost/tools/performance/phase136/profiling/README.md)
document fresh-path reproduction. No PR comment was posted.
