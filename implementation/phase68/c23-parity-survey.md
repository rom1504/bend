# Compiler23 C runtime: where the remaining work comes from

Investigation date: 2026-10-11. **The strongest parity path is to stop creating
and transporting values that upstream keeps static or unboxed.** Native CPU
profiles, allocation-site counts, generated C and optimized assembly now agree
on specific missing mechanisms. We also found unreachable parallel calls
changing the runtime mode of sequential programs, and measured that cost.

This is an investigation, with isolated saved-C experiments. Production Bend
compiler source and the installed release are unchanged. There is no newly
qualified compiler runtime ratio, conformance expansion or release promotion.

[Design](../../design/phase68/c23-parity-investigation.md) ·
[Portable evidence](evidence/c23-parity-survey.json) ·
[Methods and commands](../../selfhost/tools/performance/phase68/parity-survey/README.md) ·
[Raw evidence capsule](../../selfhost/tools/performance/phase68/parity-survey/evidence02/README.md).

## What was measured

Source candidate23 is `b2ec0a2`, inspected at repository checkpoint `4e0d8c6`.
The checked B1 image SHA-256 is
`079c0be19a15d707147b4c3f3b381cb7387dd42fdfb6de87c9137b63dedb644b`.
Upstream remains `059266225b77c8ca256ac6b25ee5c21449bab151`.
These are **native programs emitted by B1 and compiled with the recorded
Clang22 recipe**, compared with programs emitted by upstream's TypeScript C
backend and built with that same recipe. They are not timings of a compiler
implemented in C, not JS execution, and not B1/B2 compilation latency.

The preceding qualified six-family campaign remains the baseline:

| Family | Compiler23 kernel ms | Upstream kernel ms | Candidate/upstream |
| --- | ---: | ---: | ---: |
| Numeric | 251 | 253 | 0.992× |
| Array | 169 | 168 | 1.006× |
| Closures | 398 | 223 | 1.785× |
| Tree | 658 | 211 | 3.118× |
| Map | 777 | 435 | 1.786× |
| Lexer | 598 | 226 | 2.646× |

Equal-family geometric mean: **1.724× upstream elapsed time**. This is a small
mechanism-oriented C corpus, not the broader 45-point JS corpus and not full
language coverage. Baseline receipts and exact clock scope are in the
[preceding report](native-facts-and-calls.md). Its separate three-source C
request ratios, 3.389× B1 and 2.284× B2 versus TypeScript, are not remeasured here.

New work comprises all twelve generated C files, 25 optimized native symbols,
forty CPU profiles, eight paired operation-count acquisitions, allocation
classification with no unknown nonzero sites, and clean saved-C interventions.
Four parallel source/research/method lanes supported one root-owned native
execution lane. No Bend compiler rebuild was needed for this investigation.

## 1. Unreachable bangs force unnecessary scheduling

The measured tree and lexer wrappers call `bench`. Their unused imported
original `main` definitions contain `bsort!`/`scan!` and `batch!` respectively.
Compiler23 collects bang references from the whole book before reachable
emission. Consequently its generated tree has `BANGS 39`, lexer `BANGS 16`;
upstream emits zero for both. The relevant source closures contain fourteen
and twenty-four definitions respectively, with no bang references.

This is observable behavior in the native runtime: `corpus_eval` selects the
sequential work loop using `!BANGS && (pool_size == 1 || fid_nofk(...))`.
For the measured one-thread case, nonzero `BANGS` blocks that path. As a result,
our two programs run almost all their CPU work in a pool worker.
The first main-thread-only profiles captured under 1% of process CPU. The
all-thread successor captured essentially all of it. Source reachability and
the runtime branch explain this; the sampling surprise alone would not.

An exact saved-C derivative changes **only** `#define BANGS` to zero, preserving
all function flags, code and runtime helpers. It passes six independent output
controls, including four-thread pure-result controls. Eighteen clean intervals
use three balanced role rotations and the same work within each family:

| Family | Original ms | Mode-only ms | Same-campaign upstream ms | Time removed | Speedup |
| --- | ---: | ---: | ---: | ---: | ---: |
| Tree | 664 | 565 | 273 | 14.91% | 1.175× |
| Lexer | 613 | 540 | 247 | 11.91% | 1.135× |

The resulting **same-campaign** ratios are 2.070× and 2.186×. Upstream clocks
changed from the earlier campaign, especially tree. Do not attribute the
historical 3.118× → 2.070× change entirely to this intervention.

Follow-up counts show that mode correction removes only 1,976 tree and 12,254
lexer allocations: 0.31% and 0.77% of their totals. Tree keep/wrapper counts
are unchanged; lexer differs by one formatting wrapper. Thus mode correction
saves real time while leaving almost all representation overhead intact.

**General implementation:** compute bang facts over the semantically reachable
graph, including escaping closure, foreign and device roots. Use the resulting
facts consistently for runtime mode and worker admission. The saved-C test
does not measure additional workers that corrected admission might enable.
Add a metamorphic test: adding an unreachable bang-bearing definition must not
change sequential output/code mode; making it reachable must restore the
parallel behavior. Estimated restricted integration: 1–3 hours plus controls.

Evidence: [P68-023](../../experiments/phase68/P68-023-dead-bang-metadata.md),
[upstream/source mechanism audit](../../research/phase68/c23-upstream-mechanisms.md).

## 2. Closed immutable data is rebuilt repeatedly

The lexer has a 39-character constant template. Upstream puts its constructor
graph in the static image. Compiler23 emits `STAT_LEN 0` and allocates all
39 String nodes every time the template is requested.

The additional sixteen workloads create 6,144 lines. Exactly **239,616 extra
String allocations = 6,144 × 39** occur in the template worker; every other
String-producing application site matches upstream. The excess reference-count
redirect count, **233,472 = 6,144 × 38**, matches the sealed nonempty template
tails. This latter attribution is a strong source/count inference, not a
measured wrapper caller stack.

The runtime already implements static images and distinguishes their locations
from dynamic heap storage. Upstream propagates staticness through all-constant
constructor fields and interns their words in an image. We therefore do not
need a new allocator or benchmark-specific string rule. A general closed,
immutable constructor-graph emitter is the relevant missing feature.

The saved-C experiment uses the existing image ABI: 78 words, root at
`STAT_OFF + 76`, and the template worker returns that root. Its source producer
recognizes every statement in the old constant construction, evaluates the
graph, checks all codepoints against the Bend literal, preserves entry polling,
and reverses the recorded edits to recover the original bytes. Static-only,
mode-only, combined, original and upstream are measured separately.

The five-arm campaign passes six controls and all twenty-five qualified
intervals (five balanced rotations, 448 measured repetitions, 48 warmups):

| Lexer variant | Median ms | Time versus unchanged | Time versus same-campaign upstream |
| --- | ---: | ---: | ---: |
| Unchanged compiler23 output | 614 | 1.000× | 2.486× |
| Static data only | 552 | 0.899× | 2.235× |
| Sequential mode only | 540 | 0.879× | 2.186× |
| Static data + sequential mode | 480 | **0.782×** | **1.943×** |
| Upstream | 247 | 0.402× | 1.000× |

Static data removes **10.10%** of elapsed time by itself; combined with mode
correction the reduction is **21.82%**, or **1.279× faster**. All five combined
intervals are 480 ms. Static-only has one 607 ms outlier among 550–554 ms
otherwise; upstream has 244/245/247/270/271 ms. Report all clocks and use the
medians without suppressing this variation. This is a lexer-only result, not
a newly qualified six-family compiler ratio.

A separate counted static-only derivative confirms the allocation prediction:
1,596,879 → **1,123,791** allocations, exactly **473,088 removed**. RFC redirects
fall from 597,839 to **364,367**, exactly upstream's count. Generic keep and
scheduler entry counts remain unchanged at 4,575,670 and 2,784,494. Thus static
data removes the predicted 39 nodes plus 38 redirects per line while leaving
the loop/transport problem in place. Both instrumented output oracles pass;
these clocks receive no timing credit.

These are diagnostic source edits, not a general emitter. Integration must
prove closed immutable fields, exact representation/layout, deterministic
interning and static-safe matching/dropping. Mutable arrays, foreign-owned
objects and effectful expressions retain ordinary allocation. Check heap/static
mixtures, repeated consuming matches, sharing, image limits and CPU/device
initialization. A restricted constructor-literal implementation is estimated
at 3–8 hours before broader release qualification.

Evidence: [P68-024](../../experiments/phase68/P68-024-static-constructor-data.md),
[allocation classification](../../research/phase68/c23-allocation-categories.md).

## 3. Products need to remain unboxed across scheduler boundaries

The previous worker/product changes do not implement a general native value
layout. Private product workers flatten one constructor shell, leaving its
fields as opaque `Term` words; transfer back to `NC_Scheduler` reconstructs the
box. Ordinary generic arguments are also 64-bit terms. Upstream retains
recursively flattened nonrecursive product/sum layouts in locals, joins, calls and returns.

Concrete surviving costs:

- Lexer `lex` is now an ordinary C loop, yet it allocates a Tuple for every
  state transition and consumes that Tuple at the next iteration. Upstream
  carries String plus three scalar words. The Mode itself is already packed
  on valid inputs; it is incorrect to count it as a second compulsory heap box.
- `Map.bit.go` returns two words upstream but one boxed Tuple in compiler23.
  Its character/recursive helpers also reconstruct products. `Map.seek.go`
  uses four upstream result words; ours transports nested boxed products.
- Tree's upstream `scan` returns four Stat words; ours allocates Stat shells.
  That is a useful ABI witness, but only 3% of tree's extra allocation calls.

Map makes the case especially clear. Of **591,818 extra allocations**, 391,290
(66.12%) are Tuples and 190,568 (32.20%) are reference-count redirects. Together
they account for **98.32% of net extra allocation calls, not 98.32% of time**.
The top six bit/string/character helper owners produce 88.74% of our Tuples.
Unboxing only the public Map lookup result would miss most of this work.

Optimized assembly confirms that the cost survives Clang: our recursive bit
reconstruction helper has 203 instructions, twenty conditional branches and
four wrapper-call sites; the corresponding upstream continuation has 44,
two and one. The boundaries differ, so this is not a 4.6× runtime prediction.
It does show that generic heap representation was not optimized away.

**Experiment before refactoring:** preserve the generic/raw entry, then add a
constructor-proven internal loop or multiword return for one hot nested
product. Carry the fields through its actual caller/continuation rather than
flattening and immediately reboxing. Require fewer dynamic allocations and
faster clean execution. Use a second unrelated product program, a shared field,
a wrong-tag/raw path, competing errors and an escaping result as controls.

GHC's constructor specialization and worker/wrapper separation are the useful
precedents. Generic demand checks stay at the boundary; proven internal
transitions can use a more precise representation. Details and primary sources:
[compiler research](../../research/phase68/c23-external-techniques.md).

## 4. Known closure construction can remove an entire stage

The closure benchmark makes **16,432 generic apply entries versus 8,224**
upstream in the added input cycle. It allocates 12,312 closure environments
versus 8,208: one extra intermediate environment per chain step.

The dispatch code itself is almost identical after optimization: 75 versus
76 instructions and nine conditional branches each. The captured scalar-add
worker is seven instructions in both. Candidate CPU samples spend 70–75% at
the dispatcher. Changing arithmetic or rewriting that helper is a poor first
move; simplify the generated factory/application sequence.

Upstream's partial-application emission constructs an environment containing
the already-evaluated captures directly. Our exact-saturation fast path leaves
some underapplication to curried stages. First recover that general factory
case. Then carry a known target plus capture values through local bindings:
call a private worker when saturated, allocate a closure when it escapes.

Upstream still allocates a known local add closure and immediately applies it
on this path. Eliminating such work is a concrete potential advantage beyond
upstream, though we have not timed that transformation here. Flambda's explicit
capture arguments and direct-call surrogate offer a bounded implementation
model while retaining indirect fallback.
[OCaml 5.5 Flambda](https://ocaml.org/manual/5.5/flambda.html).

Preserve partial-call demand/error order, capture ownership, overapplication,
foreign/bang behavior and stack safety. Start with one known target, limit
specialization variants, and reject ambiguous joins initially. A saved-C proof
is estimated at 1–3 hours; a narrow factory optimization at 4–12 hours;
interprocedural closure specialization can take 1–2 days.

## 5. Tree reconstruction needs ownership facts and compatible-node reuse

Tree adds 190,432 node allocations and 204,800 reference-count redirects.
Together these are 96.52% of net extra allocation calls. Upstream's hot
`warp_zip` consumes two Nodes, reuses both storage blocks and allocates one
outer Node. Our version takes/frees the parents and allocates three Nodes,
sealing the transported fields. The two additional nodes across 81,904 calls
already explain 163,808 allocation calls.

The missing facts are specific: field representation, whether a root is owned
or borrowed, whether a constructor can contain shared values, and whether a
dead unique parent's storage remains available. Upstream carries these across
projections and calls. Our generic `NC_Binding` retains binder ID and C word,
so many transfers fall back to generic keep/seal/take behavior.

Simply omitting seals is not a new solution: the earlier controlled experiment
gave a modest tree gain and no lexer win. Nor is lexical spare reuse alone a
new idea. The stronger experiment combines a proven unique/cold reconstruction
with compatible storage reuse and unchanged-field preservation. Keep separate
arms for each mechanism; measure allocations, redirects, memory retention and
time. Shared inputs must retain the allocating fallback.

Lean's borrow inference and Koka/Perceus ownership-guided reuse are directly
relevant. In particular, unchanged fields can avoid the extract/retain/store/
drop round trip. Retaining arbitrary dead roots is unsafe for space usage;
reuse tokens should be bounded by the local evaluation frame.
[Perceus](https://www.microsoft.com/en-us/research/publication/perceus-garbage-free-reference-counting-with-reuse/),
[expanded source/research comparison](../../research/phase68/c23-external-techniques.md).

## Dynamic counts and profiles: what they do and do not establish

All counters below are seventeen repetitions minus one, i.e. sixteen added
inputs plus changed digest/formatting work. All outputs pass independent
oracles. Allocation-site totals exactly match the aggregate counter.

| Family/role | Heap allocation calls | Generic keep entries | RFC wrappers | Scheduler entries | Closure applies |
| --- | ---: | ---: | ---: | ---: | ---: |
| Tree / selfhost | 640,908 | 477,216 | 204,801 | 833,341 | 0 |
| Tree / upstream | 231,426 | 0 | 1 | 714,755 | 0 |
| Lexer / selfhost | 1,596,879 | 4,575,670 | 597,839 | 2,784,494 | 0 |
| Lexer / upstream | 734,878 | 0 | 364,367 | 913,038 | 0 |
| Closures / selfhost | 12,318 | 4,156 | 3 | 65,783 | 16,432 |
| Closures / upstream | 8,214 | 0 | 3 | 28,845 | 8,224 |
| Map / selfhost | 1,220,422 | 211,849 | 399,130 | 1,223,720 | 0 |
| Map / upstream | 628,604 | 5,456 | 208,562 | 741,028 | 0 |

These are instrumented source-operation counts, not machine instruction counts
or costs. Instrumentation can inhibit optimization. Local allocator misses
are zero and alloc/free deltas match: there is no evidence here that repeatedly
asking the operating system for memory is the main issue. Scalar and unique-value fast paths are visible in the generated helpers,
but the aggregate counters do not classify every keep by its resulting path.
Actual RC increments are only 2 versus 1 in
tree/lexer/closures; Map has 27,874 versus 23,721. Millions of keeps must not be
described as millions of atomic increments.

The all-thread sample campaign covers the four slower families, both roles,
and two timer periods. All sixteen observations pass outputs and coverage;
26,198 samples are retained, with 819–3,811 per observation and minimum sampled
thread/process CPU coverage 99.9994%. Candidate leaf-function shares:

| Family | Stable hot locations across the two samples |
| --- | --- |
| Tree | warp 14.7–14.9%; zip 14.2–14.3%; leaf helper 9.9–11.4%; RFC wrapper 7.4–7.7%; pool loop 7.1–7.2% |
| Lexer | lex 21.8–22.4%; step.at 15.0–15.9%; expand 9.4–11.0%; RFC wrapper 8.5–9.7%; template 4.7–5.1%; pool loop 4.0–4.5% |
| Closures | apply dispatcher 70.4–74.6% |
| Map | bit.go.rec 13.0–14.2%; RFC wrapper 11.2–13.1%; bit.go 9.2–10.5%; drop 7.0–7.4%; seek 5.7–7.0% |

Profiles localize surviving instructions, including lexical inline frames;
they are not reconstructed dynamic stacks. Allocation inside an inline caller
is not necessarily charged to a separately named allocator. Different roles'
percentages have different denominators. Removing Map's separately sampled
11–13% wrapper helper alone cannot explain a 1.8× improvement.

Numeric and arrays spend essentially all sampled CPU in their tight scalar
loops, consistent with their existing parity. The smaller initial main-thread
campaign has 24 observations; four tree/lexer candidate observations are
explicitly inadequate and superseded, not counted as complete profiles.

The Linux perf capability probes failed; a bounded user-space CPU-timer sampler
was used. Debug binaries have **identical complete `.text` sections** to all
twelve original optimized executables. The all-thread sampler handles persistent
pool workers, uses bounded buffers, and records overruns and coverage failures.
Sampling intervals are coarser than requested on this kernel. Nine bracketed
clean/sampled/clean overhead controls show negligible movement in two screens
and about 5.7% overhead for upstream closures. Profile timings are never used
for speedup claims. Full method, failed attempts and limitations:
[sampling report](../../research/phase68/c23-sampling-method.md).

## Ranked implementation opportunities

These ranges are **hypotheses for affected programs**, except the explicitly
measured saved-C results. They are not additive, do not predict every program,
and exclude full release qualification. A good diagnostic can reject a proposal
well before its estimated integration time is spent.

| Priority | Mechanism | Evidence / possible affected-program gain | Proof experiment | Restricted integration | Main risk |
| --- | --- | --- | --- | --- | --- |
| 1 | Reachable bang facts | Measured 1.175× tree, 1.135× lexer from runtime mode alone | Already measured | 1–3 h | Missing live indirect/foreign/device roots |
| 2 | Static immutable constructor image | Measured 1.112× lexer alone; 1.279× with corrected mode | Already tested in saved C | 3–8 h | Static lifetime/layout and taking semantics |
| 3 | Direct known partial-closure construction, then known calls | 2× apply frequency; 1.2–1.8× faster is plausible on this HOF family, unmeasured | 1–3 h | 4–12 h factory case; 1–2 days interprocedural | Capture demand/ownership and code growth |
| 4 | Native value layouts through workers **and scheduler ABI** | Map/lexer product costs are large; 1.3–2.5× on strongly affected paths is a hypothesis | 2–4 h for one proven loop/result | 1–3 days in slices | Raw demand, nested sums, transfer ownership |
| 5 | Unique/cold reconstruction plus reuse | Most tree excess allocations; 1.2–2× on affected reconstruction paths, unmeasured | 2–4 h, separate arms | 1–3 days | Sharing, lifetime, retained memory |
| 6 | Scheduler callers directly invoke admitted workers | Frames remain around ordinary helpers; 1.1–1.5× on boundary-heavy paths, overlaps above | 1–2 h | 4–12 h | Errors, polling, device path, bounded C stack |
| 7 | Borrow provenance across calls/projections | Strong upstream/Lean mechanism; 1.3–2.2× only if ownership dominates | 2–4 h separate scalar/box probes | 1–3 days | Escaping borrows, root lifetime, space retention |
| Stretch | Eliminate an intermediate that **upstream also creates** | Known closures or producer/consumer fusion; 1.5–3× on an eligible pipeline, no corpus guarantee | 3–6 h with second witness | Several days | Evaluation order, coverage and code expansion |

Static-data timing comes from the five-arm campaign in section 2; its
implementation estimate is separate from the already completed experiment.
Priorities 4–7 should share facts rather than grow independent analyses.

The source review supports three cooperating additions to existing lowering:
an early admitted-worker plan, native values with layout/ownership provenance,
and bounded specialization on proven constructor/closure facts. Each fact
should replace repeated queries and serve multiple consumers. A new general
IR, switching to LLVM, or a whole-runtime rewrite is not justified by this
evidence. Clang already optimizes equivalent scalar code well; it cannot be
assumed to recover a high-level value layout after we encode it as generic
heap words and scheduler transfers.

## What would justify 1×, and what would justify 0.5×?

Parity is a credible engineering target because the remaining overhead has
specific source counterparts in upstream, while two families already match.
This is not yet a forecast that combining all ideas will yield 1×: ownership,
layout and call changes overlap, and fresh combined measurements are required.

Reaching 0.5× needs an advantage over upstream, not just removing our excess
work. Known nonescaping closures are the first concrete lead. Fusion is a
second research direction: prove that both compilers materialize a substantial
single-use intermediate, then eliminate it while preserving demand and errors.
With two of six families left at 1×, a six-family geometric mean of 0.5× would
require the other four to average approximately **0.354× upstream**. Current
evidence does not support promising that outcome.

## A fast execution plan for the next optimization phase

1. Integrate the two small measured mechanisms separately, with fresh compiler
   snapshots and new experiments. Avoid coupling the reachability fix to an ABI
   refactor. Protect live bangs and immutable-data semantics with independent
   witnesses beyond these benchmark names.
2. In parallel source lanes, prepare saved-C closure, loop/product and tree
   reuse experiments. Root serializes builds/timing; agents inspect sources,
   prepare exact derivatives, reason about legality and independently review.
   Use short fixed-input oracles first, then repeated kernel intervals above
   100 ms and balanced role order. Preserve wrong-output/timeout attempts.
3. Choose the strongest complementary broad mechanism from clean time, dynamic
   counts and assembly together. Require a second unrelated source to benefit
   before turning a fixture-specific diagnostic into a compiler rule. Integrate
   one slice at a time; keep generic/raw fallback and bounded specialization.
4. Recheck the six-family C set, selected native/raw conformance, generated JS
   protection, B1/B2 emission latency and C size/Clang cost. Expand the native
   corpus with unrelated programs before making a general parity claim. A
   saved-C witness and 37 selected native cases do not establish full conformance.
5. Run slower B2/self-host/release gates only on a selected combined candidate.
   A compilation-only change with exact generated C can reuse qualified native
   bytes; a changed ABI cannot. Keep generated-program time and compiler time
   as separate objectives throughout.

There is also a distinct simplicity/compilation lead: every candidate C file
contains an 11,659-line `Nat.read.trim` worker used by the command-line wrapper,
outside the repeatedly timed kernel. Total C is 33–56k lines versus upstream's
4.5–11k. Numeric/array parity despite that bloat demonstrates why source length
alone is not an execution profile. Reduce cold duplication for C size, Clang
time and simplicity; do not count it as the cause of all runtime gaps.

## Preservation and limits

The investigation adds diagnostic tools and documents, **zero production Bend
lines and zero compiler modules**. Installed Phase67 and all historical raw
remain unchanged. New raw uses `parity-survey23*` directories, one guarded CPU3
target tree, 2 GiB process-tree RSS and a 4 GiB available-memory floor. Source
analysis is separate from native timing. Tool versions, failed profile builds,
the main-thread blind spot and a lock-rejected attempt are preserved. The first
packaging attempt rejected equal member sets because it compared different
path sort orders; its archive/manifest/failure remain preserved, and a versioned
successor verifies both sorted member names and each member content. All twelve
original product acquisitions and their 98 input pins were reverified unchanged.

Time accounting from 238 unique guarded process receipts totals **448.94 s
(7 min 29 s)**: native compilation 152.21 s, target execution/probes 291.21 s,
sample analysis 4.96 s and binary utility work 0.56 s. This includes failed
attempts and is process wall time, not session duration or agent CPU/token
usage. The largest observed guarded process-tree RSS was **347.52 MiB**.
Source inspection, literature research, report writing and evidence packaging
are outside these receipt clocks. Parallel source lanes allowed those tasks
to proceed while the serial target lane ran; no multi-hour self-host validation
was necessary for unchanged compiler source.

The phase does not requalify full conformance, B2 reproduction, C compilation
speed or JS performance because production code has not changed. It provides
diagnostic evidence and qualified finite saved-C comparisons for selecting that
next work. No PR comment was posted.

Further detail:

- [Generated C syntax and hot bodies](../../research/phase68/c23-code-shapes.md)
- [Optimized native machine code](../../research/phase68/c23-machine-code.md)
- [Allocation categories and source-site attribution](../../research/phase68/c23-allocation-categories.md)
- [Exact upstream mechanisms and current missing facts](../../research/phase68/c23-upstream-mechanisms.md)
- [Expanded Lean/GHC/Flambda/Koka/LLVM research](../../research/phase68/c23-external-techniques.md)
- [Sampling implementation and limitations](../../research/phase68/c23-sampling-method.md)
