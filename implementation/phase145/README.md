# Phase145 — comparative compiler work and architectural findings

The investigation found useful architectural headroom, with no production
compiler changes. The strongest evidence concerns **preserving checked products
and compact identities across phases**, plus the cost of our parser's complete
representation pipeline. It does not establish a new whole-build speedup or a
fresh upstream compilation-speed ratio.

[Design](../../design/phase145/README.md) · [Metrics and cost](metrics.json) ·
[Architecture recommendation](../../research/phase145/architecture-decision.md) ·
[Independent review](../../research/phase145/evidence-review.md) ·
[Evidence inventory](evidence01/inventory.json) ·
[Reproduction](../../selfhost/tools/performance/phase145/README.md).

## What was compared

| Comparison | Controlled property | Important difference or limit |
| --- | --- | --- |
| Same Bend compiler as native QBE and generated JS | Same final04 source, input, prepared Base, ordinary policy and complete emitted QBE | Native process versus checked JS API/Bun observer; startup, JIT, GC and exit behavior differ |
| Our compiler and pinned upstream TypeScript | Same four actual Bend program inputs | Upstream checks Base and emits C; ours decodes prepared Base and emits QBE |
| Upstream full-source parsing and retained native parser result | Exact frozen Phase142 input, 2,946,225 bytes | Different parser implementations, auxiliary work, native producer/runtime and observation dates |
| Native counts, native stages and generated-JS internal events | Exact qualified outputs and pinned diagnostic derivatives | Diagnostic observations, not clean execution times or interchangeable operation counters |

The retained final04 source is `865cff6a…`, checked API `bebacede…`, N2 executable
`e2f6317b…` and serial runtime object `2d078323…`. Complete identities and tools
are in the receipts. All target work uses one CPU3 lane, one Bend heap mutator,
bounded time/RSS and a 16 GiB available-memory floor. OS caches are not flushed.
No compiler self-image is regenerated; existing N2 is relinked only for probes.

## Same-source execution: native is already substantially faster

Fifteen fresh-process pairs produce 30 exact QBE products. The first three cases
have four alternating pairs; the real compiler-index slice has three, with one
extra JS-first pair. Results are exploratory medians, not confidence intervals.

| Request | Native median | Generated-JS median | Native/JS paired geometric ratio |
| --- | ---: | ---: | ---: |
| Lexer | 1.168s | 7.396s | 0.1604× |
| Map churn128 | 1.801s | 11.805s | 0.1528× |
| Closures256 | 0.389s | 2.772s | 0.1407× |
| Actual compiler-index slice | 2.141s | 13.785s | 0.1553× |

This is roughly **6.2–7.1× faster native execution of the same compiler** on
these requests. It is not a comparison with upstream's TypeScript compiler.
The larger slice contains real dependency-closed compiler code and historical
finite checks; it does not substitute for a full self-compilation measurement.

Retaining the JS engine while repeating all request work lowers Lexer to a
5.601s median after warmup. All four iterations produce exact QBE. Startup/JIT
contributes to the cold difference but does not explain all of it. These warm
iteration clocks exclude fresh-process startup and cannot replace the paired
cold ratios. [Detailed scope and results](../../research/phase145/same-source-execution.md).

## Important discoveries

### One static-program judgment is demonstrably repeated

Every counted small request calls `p112s_verify` twice. For Lexer, a stricter
diagnostic establishes that both calls receive the **same actual root object**
with the same complete 27,479-object data content before and after checking.
One call is through `p114s_open`; the other is through
`p113a_verify → p113e_verify`. Complete QBE remains exact.

This supports one private, request-local accepted raw context. It does not
validate a general cache, establish every context is redundant, or permit
removing final independent checking of transformed code. The witness hash
records data content, not all alias/descriptor properties; its completion marker
does not independently capture the returned success value. The accepted complete
request supplies that surrounding gate. Exclusive native time saved by reuse
remains **unmeasured**.

### Names and reconstructed environments are substantive work

The Lexer/Map backend observations count 931,026/856,606 `index_find` entries
and 3.03/3.57 million actual character comparisons in one string predicate.
The source trace shows numeric identities converted to textual names and
repeated schema/flow queries using wide generic records. One real 88-statement
Lexer body has only 21 distinct destination names despite 65 destination
occurrences. Counts are not CPU shares and these lookup totals include more
than locals, but the source and dynamic evidence identify a concrete boundary.

The promising replacement is a complete per-function environment with numeric
local IDs, immutable schema, and separate changing flow state. Charge conversion,
joins, error ordering and reclamation, and inspect generated worker admission.
Phase144 already showed why merely shrinking a record can disappoint: it can
lose existing direct-call optimizations. [Source and machine trace](../../research/phase145/architecture-audit.md).

### Upstream preserves useful products despite multiple passes

On four complete inputs, upstream checks 374/352/352/396 definition bodies once
each, including Base, and retains the checked runtime body immediately in `Def.e`.
It then needs **two, two, three and five backend fact-discovery/emission rounds**.
The compiler-index case performs 312,900 memo lookups with 196,338 hits.

The transferable lesson is to preserve a useful producer result and its context;
simply reducing pass count would miss how upstream works. Original compiler-action
subtotals range from 0.489s to 2.422s, but are not matched QBE-request clocks:
Base preparation, output target, validation and output volume differ. Diagnostic
instrumentation adds 1.57–1.73× to the clean-transpiled action time, so its clocks
are excluded from production-speed comparisons. All four complete C products
match pristine upstream byte for byte. [Upstream findings](../../research/phase145/upstream-findings.md).

### Full-source parsing reveals another substantial representation gap

Pinned upstream loads/parses the exact frozen 2.95 MB compiler input in **2.583s**,
including source Base, with no typechecking or emission. The counted derivative
retains the same loaded event/name/constructor summary. The historical Phase144
selected native parser takes **31.175s** on this input, excluding its separate
0.208s Base preparation and observation checksum.

The descriptive ratio is about 12.07×. It is **not** a newly paired final04
measurement: our parser also materializes lexical tokens and performs contextual
loading, validation and global freshening; its retained native image uses an
older producer and atomic runtime. Upstream uses indexed native strings, while
our path works over linked String/token structures. This warrants a complete
parser-boundary experiment, not attributing the whole gap to one allocation or
assuming all validation can be dropped. [Boundary audit](../../research/phase145/parser-boundary.md).

### Millions of operations can still be a small fixed cost

Native Lexer/Map/closures perform 16.77/23.68/7.78 million allocation calls.
A selected Base-decoder owner family contributes exactly 4.50 million in each.
Yet exact native stage clocks put Base preparation around **0.23s**; the retained
full-source profile has similarly small Base cost. This is useful for tiny
request latency, not an explanation for a 231-second full compiler execution.

The remaining variable costs differ: Lexer's initial optimizer and first verifier
take 0.328/0.160 diagnostic seconds, while Map raw lowering and render/output
take about 0.452/0.449 seconds. Counted allocations, physical samples, stage time
and active-owner attribution are different overlapping views. The new small
sample captures have fewer than 500 samples; clock intervals are usable, but
sampling percentages remain descriptive. [Native evidence](../../research/phase145/native-accounting.md).

## What to do next

1. Test one request-local accepted raw context against the demonstrated duplicate
   judgment, keeping independent transformed-body verification and exact errors.
   This is the cheapest concrete architecture experiment.
2. Test a complete compact verifier environment with local IDs and immutable
   schema, including all conversion and ownership costs. Require transfer beyond
   Lexer before a broad refactor.
3. Investigate a compact source cursor/token/identifier pipeline on the actual
   full parser workload. Separate lexical work, contextual resolution and
   freshening, then preserve complete parser/error results before replacing a
   representation. This may reveal a shared identity/text primitive useful to
   both frontend and backend, but its speedup is unmeasured.

Use successful results to join lowering, analysis, verification and rendering
around shared semantic products. Keep QBE and the qualified compiler. Avoid
another wholesale backend migration or universal IR rewrite until these tests
demonstrate an advantage. [Detailed reasoning and falsifiers](../../research/phase145/architecture-decision.md).

No measured full-build gain is claimed. The existing final04 cold result remains
247.000s, including 15.318s of machine construction. If the latter stayed fixed,
a 50s build would require compiler execution to fall from 231.682 to 34.682s,
about 6.68×. A single small optimization cannot credibly promise that reduction.

## Negative evidence, cost and preservation

Two failures are retained. The first upstream instrumentation preparation refused
a transpiler-changed textual anchor before executing the compiler. The initial
warm observer was cached by Bun despite unique query suffixes; subsequent
iterations did no work, and the complete-product gate rejected them. Its
successor imports four distinct byte-identical observer files while retaining
the same actual compiler module. All four outputs then pass.

The 32 guarded jobs total **306.58s (5.11 minutes)**, including 8.17s in the two
failures. Peak observed process-tree RSS is **500.09 MB**; the available-memory
floor never trips and no OOM occurs. The target lane is nonoverlapping. Four
bounded agents inspect source, prepare methods and audit results; root alone
runs targets. Analysis, agent effort, metadata preparation, archiving and prior
compiler acquisition are outside that guarded-cost total. It is not quota
accounting or total human-facing elapsed time.

Production compiler/runtime sources, mathematical proof declarations, conformance,
installed selection and qualification are unchanged. No broad self-host campaign
or generated-program runtime campaign is needed for this information-only work.
The evidence capsule retains failed attempts and instrumented methods, with
exact dependency pins; it deliberately excludes compiler images and full SSA
duplicates and is not a hermetic compiler distribution.
