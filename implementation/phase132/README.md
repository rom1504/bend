# Phase132 — Incremental native development: measured opportunities and limits

Investigation started at `2227ce264dc138d524990e27ef458abbee67a384` on
`selfhost/bootstrap`, 2026-10-24. [Design](../../design/phase132/incremental-native-development.md).
The qualified Phase131 compiler and installed selection remain unchanged.

**The strongest architectural candidate is reusing checked/lowered compiler units before
text generation.** Go provides a useful architecture for this. We demonstrated
machine-object reuse after a real compiler-source edit, and found a large
avoidable text/memory expansion. Neither experiment yet makes a complete edit
cycle ten seconds.

## Direct answers to the order-of-magnitude targets

| Quantity | Evidence | Assessment |
|---|---|---|
| Full QBE text107 MB→1 MB |107,059,385 bytes;2,294,179 instructions;63,239 functions | Not supported by naming/compression experiments. Requires major structural sharing or a different representation; no credible100× full-image reduction demonstrated. |
| QBE text via compact names |57,519,368 bytes preserving exports;52,281,530 bytes if generated exported names also change | About2× is demonstrated as reversible text transformation. Conservative variant preserves machine computation exactly. |
| Compressed retained QBE |gzip8.12 MB;zstd3.93 MB | About13×/27× storage reduction, not IR, resident-memory or compilation-work reduction. |
| Final executable |17.13 MB ELF;10.82 MB `.text` | Different target from107 MB text. Renaming symbols cannot remove machine instructions. |
| Warm machine construction |19.85 s cold partitioned→5.98 s reused,55/65 units hit | Demonstrated for one real source edit, excluding frontend and21 s partitioning. Not an end-to-end speedup. |
| Full source-to-executable 350 s→10 s |Historical arithmetic393.04 s; new edited native request368.98 s before machine work | Plausible goal for sufficiently local warm edits only after skipping over97% of repeated work. Not demonstrated for cold builds, optimizer-wide edits, or full qualification. |
| Peak native request memory |New edited child2.900 GB; outer guard2.930 GB | Strong evidence for emission-memory work: about1.90 GB accumulates late before output. Packed/streamed verified units merit a small experiment. |

All timings here are scoped observations, not a new comparison with upstream or
an update to Phase131's 44-program runtime score. MB/GB are decimal unless marked.
“Orders of magnitude” and literal out-of-memory risk are distinct; this report
addresses both.

## What Go teaches us

[Primary-source research and isolated experiment](../../research/phase132/go-build-reuse.md)
separate installed Go 1.22.2 measurements from current release/development source.
Go reuses **packages**, with a build action keyed by source, dependencies,
toolchain and configuration. Output content identities can stop invalidation
when recompiling a dependency produces unchanged relevant content.

Our tiny experiment makes this concrete: a comment rebuilt only the leaf
package; a private non-inlineable body edit rebuilt leaf and its immediate
consumer, whose unchanged content stopped the wave; an inlineable body change
propagated through callers. The no-op39ms result is not a Bend speed forecast.
Go's inspected development source also separates semantic export identity from
object identity and can publish export information before machine construction.
See the linked report for release-versus-development distinctions and exact pins.

For Bend, the import interface must include every fact actually consumed:
reducible bodies used in dependent checking, inlining/specialization inputs,
constructor layout, ownership/borrowing facts, effects, private-worker admission
and negative dependencies. Unchanged public types alone do not permit reuse.

Keep three identities distinct:

- **Stable unit identity:** which semantic definition/group this is.
- **Action identity:** everything determining its compilation and verification.
- **Result identity:** checked facts, named IR and machine products consumed by
  different downstream actions.

Changing the candidate compiler source under a fixed qualified producer permits
ordinary incremental building. Adopting the newly built compiler changes the
producer identity and conservatively starts a new cache epoch. Sharing artifacts
across compiler epochs requires explicit compatibility/equivalence evidence.
Self-reproduction is not permission to ignore the producer.

## Where the size comes from

[Full census](census.md) and independent token/machine audits establish:

- Local variable names occupy61.19 MB,57.15% of QBE bytes. Global names11.36 MB,
  whitespace11.54 MB. These lexical categories must not be added to overlapping
  semantic categories below.
- Public continuation bodies occupy60.37 MB and 1.482M instructions. Their machine
  code contributes6.285 MB of the10.265 MB attributed QBE function code.
- There are1,713 normalized repeated-body groups, with 19,675 participating
  functions and 13.55 MB candidate repeated text. One15-instruction resume body
  appears7,978 times. Equality is syntactic modulo local identities; it is not
  permission to merge observable function identities.
- A conservative final symbol/data graph leaves12,048private functions outside
  its roots,9.07 MB of text. All dispatch entries/exports remain roots. This is
  an audited deletion opportunity, not executed dead-code removal.

A naive direct-call graph would incorrectly delete all 48,911 public dispatch
segments: the runtime reaches them through tables and numeric IDs. See the
[source and reachability audit](../../research/phase132/incremental-boundaries.md).
Repeated-body and unreachable-worker savings overlap and cannot be summed
without running a combined transformation.

The ELF contains 11.77 MB of file-backed allocated sections. Removing nonallocated
symbol/debug metadata can reduce disk size, but cannot turn that existing code
and data into a 1 MB executable. Preserve separate symbol/source maps for profiling;
stripping names is not a program-speed optimization. A slim per-edit artifact or
compressed retained cache is a different and more attainable small-size target.

The current instruction inventory alone needs more than2.29 MB even at the
unrealistic one-byte-per-instruction encoding, before operands/data. This is a
conditional lower bound for preserving that inventory, not a universal minimum
for an equivalent optimized compiler or compressed template representation.
A1 MB *changed unit* is a much more plausible objective than a 1 MB *entire image*.

## Compact names: large text gain, small backend gain

[Experiment and archived receipts](../../research/phase132/compact-symbols.md):

| Frozen transformation | QBE bytes | Reduction |
|---|---:|---:|
| Private global names only |104,379,267|2.50%|
| All generated globals, closed-image ABI variant |99,141,429|7.40%|
| Private globals and function-local names |57,519,368|46.27%|
| Closed-image globals and locals |52,281,530|51.16%|

The conservative variant passes exact inverse reconstruction of the original
QBE. Fresh machine builds have identical `.text`, allocated data/layout,
normalized symbols and relocations; only the build-ID note differs. Every export
spelling is retained. No additional program-runtime campaign is required to
establish that this frozen variant performs the same machine computation.

One descriptive pair gives13.9668→13.3154 s QBE/as/link child sums; QBE alone
8.8287→8.2771 s. This is too little to explain a large full-request improvement.
The diagnostic host producers cost43.54 s for globals and115.87 s for locals and
multiple inverse checks, producing both variants. They are not a profitable
production postprocessor. Direct compact generation in Bend may avoid String
construction/allocation, but that benefit is unmeasured and requires a new
checked emitter experiment. Avoid expensive String-key lookup for every token.

## The real edit and reuse experiment

[Detailed methodology, results and gates](incremental.md).
Only the two local spellings in `p111q_main` change from `%result` to `%answer`;
all other source bytes and source length remain equal. This preserves emitted
program semantics while genuinely changing the compiler's code-generation
behavior. Independent full-book checking and minimal one-helper API generation
pass before native acquisition. The fixed qualified Phase131 N2 produces the
changed full compiler's QBE in 368.976 s, with empty stderr.

A single changed declaration changes **476 generated function bodies and two
data declarations**, totaling about 5.79 MB of complete changed declaration text.
No functions are added or removed. Of those 476 functions,377differ only in
recognized decimal `=l copy` operands; all 1,732 such operand changes are+12.
This is a useful warning: locality in Bend source does not currently imply
locality in its fully bound QBE. Static literal pool relocation is implicated;
this bounded syntax audit does not prove decoded-value equality or explain the
remaining 99 function differences. The detailed report preserves that distinction.

The prototype groups emitted functions into 64 contiguous units plus one data
unit. Cross-unit private references are made link-visible explicitly; this is a
closed-image experiment, not an unchanged library ABI. Cache keys bind complete
IR, referenced declarations, runtime, tools and flags. The original qualified
image is not replaced.

| Work | Measured seconds | What it establishes |
|---|---:|---|
| Original partition preparation |21.35| Full host scan/hash/materialization cost; cannot be hidden. |
| Original cold partitioned machine build |19.84| Cache acquisition;65 units compiled. |
| Edited full native source request |368.98| No frontend reuse yet. |
| Edited partition preparation |22.84| Full host scan/hash/materialization still required. |
| Edited reused machine build |5.98|55 hits/10 misses; includes lookup/build/link. |
| Edited independent cold partitioned build |19.85| Reference with no reused objects. |

Cached and independently rebuilt current images have exact allocated-section
agreement. This validates object reuse for the current plan; independent ordinary
compiler-request gates validate the partitioned image against the monolithic
semantic reference: all nine complete-QBE comparisons and six built-program
output checks pass on Lexer, Closures256 and Map128. Exact individual gate receipts and further ELF checks are
recorded in the incremental report. No new full native self-host qualification is
claimed for this experimental spelling edit.

The current host splitter already costs more than the old 13.82 s monolithic
machine build. Therefore this prototype is a **successful reuse experiment and
an unsuccessful end-to-end acceleration strategy as currently placed**. A
production design must emit stable units directly and skip earlier work. It
must not rerender the entire107 MB merely to discover what is unchanged.

## Memory and native-first workflow

[Build-stage accounting](build-cost.md) and
[measured memory/output timeline](edited-memory01/README.md):

![Measured compiler RSS and output growth](edited-memory01/memory-output.svg)

The edited request remains near 1 GB around 270–330 s, then gains approximately
1.90 GB before the output file grows. The last zero-output observation is 367.53 s;
first nonempty 368.53 s; complete 107 MB by 369.53 s. One-second sampling cannot isolate
exact print time, but disk transport is plainly not the several-minute cost.

Current output is a list of Bend Strings built before `p111_print_chunks`.
Each independent ASCII `SCon` has two 64-bit field words:107 MB corresponds to
roughly1.71 GB of character payload before other structures, subject to sharing
and exact lifetimes. The source mechanism and observed rise agree, but RSS is
not a live-object census and the final34 seconds are not a measured exclusive
rendering stage. Do not claim that eliminating text will save all34 seconds.

Two falsifiable designs follow:

1. Render compact identifiers into packed output chunks, measuring allocation,
   RSS, total request time and exact emitted semantics.
2. Verify and emit immutable units incrementally, releasing rendered output
   before constructing the next unit. Preserve final cross-unit verification
   obligations and atomic publication; errors must not publish a partial valid
   executable. A temporary output artifact can be discarded on failure.

A~1–1.5 GB peak target is a useful hypothesis if most late String expansion is
removed; it is not measured. Reaching 100 MB requires reducing the earlier~1 GB
retained compiler state as well. Object partitioning itself peaks near169 MB
versus~935 MB for the monolithic machine-build guard, trading more invocations
for smaller per-child working sets. This does not reduce frontend RSS.

Native-first acquisition already works: this experiment used the qualified N2
without generating/executing a full JavaScript compiler image. The independent
check plus minimal helper API took5.48 s child/6.15 s guarded and681 MB outer RSS.
The historical many-export API cost14.18 s and2.29 GB; these are different export
scopes, not a checker speedup. Pure checker-only time remains unmeasured.

Keep source/type checks, BendTT proofs, independent semantic controls, native
reproduction and cross-backend differential checks distinct. Use risk-appropriate
checks on local edits and periodic qualification; retaining an expensive full
campaign after every tiny edit would erase the benefits of reuse. Riskier runtime
or backend changes still warrant independent JS/bootstrap/differential gates.

## Smallest architecture worth testing next

Reuse a definition or dependency SCC together with its generated continuations
and private workers **before numeric FID/CID/static-pool binding**. The existing
named structured representation offers this boundary; a universal SSA rewrite
or a different backend is not required.

```text
CheckedUnit
  stable owner/group identity + source/dependency fingerprints
  checked named terms and consumed semantic interfaces
  ownership/layout/effect/admission summaries and negative dependencies
  verified named lowered functions, continuations and private alternatives
  producer + target + runtime ABI + optimization policy + verifier version

Binding/Link
  current reachability and legal worker selection
  stable symbolic function/constructor/literal references → current bindings
  independently verified cross-unit interfaces
  per-unit QBE/object products + authenticated source/debug maps
```

Global freshness, encounter-order constructor/function IDs, static tagged offsets
and interdependent private-worker admission currently spread invalidation. Begin
conservatively with the full relevant environment fingerprint; narrow it only
when source audits and mutation controls establish what was consumed. Track
absence/refusal as a dependency too. Reusing mathematical proof results does not
remove dependency tracking: proof inputs and checker/kernel identities matter.

A narrow Bend law could establish that resolving the same symbolic references
under equal recorded bindings preserves a lowered unit, or that updating an
unreferenced map key preserves resolution. That is useful only with a tested
bridge to actual resolution and invalidation. It is not whole-compiler
correctness, and cannot authorize skipping an independent verifier by itself.

First implement one **real unchanged lowering-unit hit**, compare the complete
result to a full rebuild, then deliberately change a consumed body, layout,
worker admission, literal and runtime ABI. A stale hit is failure even if one
benchmark output remains correct. Add source insertion/deletion and recursion
before calling the mechanism general incremental compilation.

## Ambition, priorities and estimates

The estimates below concern bounded prototypes, not polished production delivery.
They depend on the first identity/dependency experiments. No measured generated
user-program speedup is claimed; all paths aim to preserve current code quality.

| Priority | Next experiment | Potential benefit | Estimated effort / main risk |
|---|---|---|---|
|1| Stable symbolic literals/owner-local identities; reuse one checked/lowered owner under a fixed producer | Enables skipping the dominant repeated work; strongest route to10–40× warm local-edit speedups |4–8h first falsifier; dependent checking and admission invalidation may dominate. Broad safe implementation needs further cycles. |
|2| Compact names produced directly in Bend, packed/streamed verified output | About2× text reduction established; potentially large late-heap reduction, unknown whole-request gain |2–4h isolated prototype; extra lookups or retaining old IR could erase savings. |
|3| Conservative final private reachability, then one shared continuation template |9.07 MB unrooted-private and 13.55 MB normalized-duplicate opportunities, overlapping; code/build savings need measurement |2–6h first bounded experiments; indirect roots, identity, code layout and fallback correctness. |
|4| Stable semantic interfaces with separate checked/export/object fingerprints and SCC dependency graph | Extend fast edits across real optimizer development; stop invalidation waves, preserve deterministic linking |Several staged campaigns after a successful unit hit; avoid a large cache framework before evidence. |

**1× ambition:** stop materializing long local names, test one reusable owner,
keep a fixed qualified producer and clear independent gates.

**10× ambition:** obtain a genuinely warm10–30 s local-edit cycle by reusing
checked/lowered units and objects; measure a representative edit suite, not only
a comment or this spelling edit. This is a latency target, not a prediction.

**100× ambition:** rebuild only a sub-megabyte delta with work proportional to
changed semantics, share continuation templates, and run many cheap verified
experiments per compiler epoch. Near-second local changes would require the
fixed check/link/verification floor to shrink too. Full compiler adoption and
qualification costs remain separately amortized. There is no evidence for a
100× faster cold compiler build or a 1 MB complete compiler image today.

For a 350 s baseline,10 s requires97.14% avoided work. More usefully:

```text
T_edit = fixed lookup/check/link/selected-validation cost
       + invalidated fraction × reusable compilation work
```

This experiment's~6 s object path leaves only~4 s for the whole remaining frontend
and checking if targeting10 s. Finer stable units can reduce backend misses,
but hashing full files, checking the whole book and recomputing global admission
must also become bounded/reusable. A full350 s qualification every 20 experiments
adds17.5 s amortized per experiment, before any fast work. Report development
latency, integration cost and validated improvements per research budget
separately.

## Research cost and validation boundary

Six bounded investigations ran in parallel for source research, census, ABI/
cache review, memory attribution, compact symbols and the object prototype.
The coordinator owned one serial target lane. Only **one full compiler-source
request** was needed; other compiler executions were short frozen requests.
[Guard accounting](cost.json) records10 guarded jobs,483.34summed/occupied seconds,
one retained initial harness failure and2.93 GB maximum process-tree RSS.
Unguarded metadata scans, report writing and agent effort are excluded from that
number; it is not total research time or a quota measurement.

Five actual cache-admission corruption controls pass with zero child launches:
modified object, receipt key, current IR, binding digest and runtime identity are
refused. [Receipt](../../research/phase132/cache-admission.json). These test
artifact integrity, not completeness of future semantic dependency tracking.
The full investigation deliberately avoids another native self-reproduction or
405-observation runtime campaign: production source is unchanged; compaction
has machine-equivalence evidence and object reuse has a fresh-machine reference
plus independent ordinary behavior checks.

## Evidence, exclusions and recommendation

- [Census and independent audits](census.md).
- [Go primary sources and cache experiment](../../research/phase132/go-build-reuse.md).
- [Compact-name machine equivalence](../../research/phase132/compact-symbols.md).
- [Real-edit object reuse and independent gates](incremental.md).
- [Build costs](build-cost.md), [RSS/output timeline](edited-memory01/README.md).
- [Source-level invalidation/reachability audit](../../research/phase132/incremental-boundaries.md).
- Hypotheses: [size/names](../../experiments/phase132/P132-001-size-and-names.md),
  [real edit](../../experiments/phase132/P132-002-incremental-native-edit.md),
  [Go/memory](../../experiments/phase132/P132-003-go-and-memory-boundaries.md).

Retain the initial Go executable-permission harness failure and the readelf
hex-size parser failure; neither is a compiler fault. No dead-function removal,
continuation merging, production cache, compiler-law theorem or backend migration
was implemented. The Python programs here measure/transform frozen experimental
artifacts; the compiler remains Bend, and a future semantic incremental
implementation belongs in its checked Bend path.

**Recommendation:** pursue stable, reusable named lowering units and packed
emission together, beginning with one actual compiler edit and a full-reference
falsifier. Do not optimize final ELF size as the main objective, add a Python
postprocessor to production, or mistake a 6 s object build for a 6 s complete rebuild.
The evidence supports a much faster development architecture; it does not yet
establish the requested order-of-magnitude end-to-end gains.
