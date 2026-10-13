# Phase83: compare work, not just pass names

Investigation on 2026-10-13 against Phase82 `8042809` and pinned upstream
`059266225b77c8ca256ac6b25ee5c21449bab151`. This note changes no production
compiler or benchmark. It uses source inspection, existing Phase81/82 profiles,
and primary-source Go/LLVM research. No compiler target was run by this analysis
agent. The root investigation owns new measurements and final decisions.

## Findings that change the next experiment

1. **Frontend cold-execution overhead deserves a separate experiment from native IR.** The
   definition-heavy held-out program spends 140.8 ms in source completion and
   83.4 ms in checking, versus only 6.4 ms in annotation. Its native preparation
   is 43.3 ms. Annotation fusion cannot account for its remaining gap. The new
   root-run size/warmth diagnostic below finds that parsing and checking fall
   sharply within three requests; it does not establish quadratic work. B2's
   complete check-only request is already slightly faster than TS at N=65,
   because TS also parses/checks Base. Native preparation/planning remains the
   direct absolute gap; cheaper cold frontend execution could create headroom.
2. **There is a concrete algorithmic difference in proof reporting.** Upstream
   builds reverse dependency edges once and propagates unsafe roots. Ours walks
   from each root and only memoizes fully safe traversals. It also reconstructs
   a final book/index for that query. This is general, simpler-to-test work
   elimination, although its whole-request ceiling is single-digit percent on
   the current IO screen.
3. **Native representation replacement remains plausible, but its previous
   15–25% forecast is not established by pass timings.** Our final native stage
   has already received an annotated and erased program; upstream's emission
   includes preparation. Comparisons must account for those different inputs.
4. **One request context should own facts at their natural granularity.**
   Constructor ownership, final declarations, binder bounds, dependency edges,
   and function-local runtime facts need different invalidation boundaries.
   A giant cache attached to generic syntax repeats earlier failed experiments.

The qualified metric remains fresh Bend-to-C requests, reports enabled, imports
and explicit prepared Base excluded, with no Clang or program execution. B2 is
1.328× upstream and needs 24.7% less time for aggregate parity. B1 is 1.673× and
needs 40.2%. These five diagnostic sources do not establish universal parity.

## Existing evidence, with limits

Sources: [Phase82 public profiles](../../../implementation/phase82/profiles.json),
[Phase81 CPU/heap summaries](../../../implementation/phase81/profiles.json), and
[offline stack attribution](pipeline-stack-attribution.json). The last file
binds both input CPU profiles by SHA256, states the attribution algorithm, and
contains stage-restricted self and inclusive samples. It is derived data,
not a new run. Detached GC cannot be attributed to a caller. Inclusive rows
overlap and cannot be added as savings.

| Phase82 B2 diagnostic region | Numeric ms | Functions65 ms |
|---|---:|---:|
| Source completion |114.8|140.8|
| Check prepared world |48.0|83.4|
| Report declarations |58.6|37.0|
| Annotation |75.2|6.4|
| Merge/index/closure preparation |104.2|43.3|
| Final native compilation |386.5|183.8|
| Complete instrumented request |969.0|617.4|

These are instrumented intervals, not the clean medians used for performance
claims. The absolute time to remove cannot be inferred by comparing a sample
from one phase with a clean median from another.

The prior Phase81 small/functions comparison is especially useful as a
**hypothesis**, not as a causal scaling measurement:

| Diagnostic operation | Small ms | Functions65 ms | Difference ms |
|---|---:|---:|---:|
| TS loading + checking, Base included |301.9|308.7|6.8|
| B2 source completion |18.6|146.2|127.6|
| B2 checking |23.2|84.2|61.0|

The fixtures differ, samples are single instrumented runs, and TS parses Base
before user code whereas B2 decodes prepared Base. Upstream may enter user
parsing with V8 already warmed; ours may first exercise parser paths on those
user definitions. Consequently the difference could contain JIT startup as
well as excess logical work. Do not call this quadratic behavior without a
definition-count sweep and logical counters.

Existing Phase82 functions65 samples attribute 39.0 ms inclusively to the lexer,
87.6 ms to the parser's top-level SCC, and 14.7 ms to checker `book_put`.
Those are nested, not independent costs. Of the 32.4 ms of report samples,
15.2 ms fall under final-book selection and 9.8 ms under constructor-parent
resolution. The latter is a linear book scan after a definition lookup miss.

## Exact pipeline differences

Local paths below are repository-relative. Upstream paths are under
`selfhost/.bootstrap/upstream-phase66/bend2/`; production paths are under
`selfhost/src/` unless indicated otherwise.

| Concern | Upstream implementation | Current self-hosted implementation | Consequence / experiment |
|---|---|---|---|
| Name resolution while parsing | `bend.ts:1653–1684`: bound environment and book symbol tables; contextual resolution directly produces terms | `front/contextual.bend:4–30`; `front/declarations.bend:681–701`: `FParseScope` has declaration and constructor indexes, but alias/namespace resolution still calls `f_declared` over the prior list; `f_decl_prior` computes near and far lookups eagerly, even when names coincide | Count exact resolution requests, prior-list cells, hash characters and duplicate near/far queries before replacing anything. Preserve namespace, alias and chronological declaration rules. |
| Syntax materialization | Parser produces lower terms; higher representation is introduced for checking/compilation | `front/literals_arrays.bend:234–265`: `f_context_higher/lower` traverse and materialize parser placeholders; `front/contextual.bend:468` lowers definition types; module completion reconstructs headers and attaches paths | A complete frontend replacement may eliminate intermediate forms, but a local pass fusion needs counters proving enough repeated node visits. Raw term and diagnostic APIs remain boundaries. |
| Source publication | Book has ordered names and direct definition/constructor tables | `front/contextual.bend:258–275` constructs declaration headers and updates scope; `load/graph.bend:201` also validates freshness, qualifies fragment headers and paths | Some repetition enforces different contracts. Distinguish first declaration, self-visible header, completed source and checked publication; they cannot simply be deduplicated by name. |
| Checker world update | Checked definition products remain in the book | `core/index.bend:282`: updating an existing cached definition also calls `index_remove` on the declaration list; checking uses immutable `KWorld` snapshots | Measure removed-list cells versus definition count. An event list plus final index might replace per-update filtering, but only if chronological consumers continue to see the right world. |
| Constructor ownership | `book.ctrs` and `book_fam` provide direct constructor-family facts | `core/reach.bend:94–105` resolves a missing top-level reference by scanning ADTs; `check/prefix-state.bend:132` scans constructor membership for each suffix definition | Carry an exact-world constructor-owner table shared by reports, admission and reachability. This is a more specific experiment than replacing all symbol storage. |
| Reports | `main.ts:747 book_promises`: empty-unsafe early exit, dependency graph once, reverse unsafe propagation, source-order output | `driver/report.bend:108–158`: final book/index rebuild, per-root DFS, safe-only result cache; unsafe closures may be rediscovered | Replace the query algorithm and reuse a source-world index. Compare exact unsafe-name ordering, cycles, nested constructor fields, laws and foreign definitions. |
| Runtime function preparation | `comp.ts:1169 fun_of`: one memoized function record with higher body, live parameters, layouts and return shape | `back/native/request.bend:63`: merge annotated replacements into full context, recompute exact bound/index, walk runtime closure, erase bodies and attach private facts | A function product can replace generic typed/erased reconstruction; adding another retained graph has already failed. |
| Repeated function analyses | `comp.ts:645/665/768/824`: identity-keyed opened bodies, application spines, usage maps, telescopes; `memo_gc` bounds lifetime | Existing erased/static bodies and worker plans are retained, but dependency lists, binder queries, arities, product signatures and routing consume generic KTerm forms | Measure tuples `(function, world, fact kind)` plus actual inputs, not just helper names. Different-binder queries are not identical cache hits. |
| Global optimization feedback | `comp.ts:2768 compile_book` re-emits until ownership/hot/static facts stabilize, then prunes segment reachability | `back/native/flat.bend:312–325`: optimistic signatures, worker admission, selective retry; observer routing later | Upstream is not single-pass. Count actual retry and rejection rates before proposing pass removal or disabling optimization. |

The driver uses the *loaded source book* for proof reporting and the *checked
book* for emission (`selfhost/tools/typed-driver.mjs:855,881,897,926`). A shared
context must distinguish those worlds explicitly. Reusing the checked graph
for source proof-trust reporting without proving equivalence would be wrong.

## Directly applicable lessons from Go and LLVM

### Go: references can stay encoded until a body is demanded

Current Go source has lazy package/type tables, indexed object readers,
separate body-reader locations, and direct indexed local-variable references.
These mechanisms permit locating a declaration or body without eagerly
constructing every imported IR object. See
[reader.go](https://go.dev/src/cmd/compile/internal/noder/reader.go), especially
`pkgReader`, `objReader`, `bodyReaderFor`, `funcBody`, and `useLocal`.

Transfer hypothesis: if we revisit Base products, put small name/layout records
in a stable index and decode a body only when reached. The consumer must use the
decoded representation directly. Do not rebuild both an ordinary Base graph
and an extra full typed backend graph. Phase79's eager 2.94 MB product and
Phase80's retained typed syntax did exactly the expensive work we must avoid.
This is a transport/consumer redesign, not merely a different cache switch.

Go also separates frontend preparation that cannot safely run concurrently from
function backend compilation; it schedules larger functions first and passes a
worker identity into code generation. See
[compile.go](https://go.dev/src/cmd/compile/internal/gc/compile.go),
`prepareFunc` and `compileFunctions`.

Transfer hypothesis: finish shared semantic facts once, then give each function
an owned workspace. This helps locality and later permits bounded parallelism.
It does **not** establish a gain for our single-CPU metric. Running more Node
compiler processes would duplicate preparation and memory, not implement this
architecture.

### LLVM: prevent whole-world analyses from leaking into function work

LLVM's pass-manager contract restricts inner passes from triggering arbitrary
outer analyses because doing a module scan inside each function can introduce
quadratic work. It separately recommends grouping related function passes for
locality and makes preserved analyses explicit.
[New pass-manager documentation](https://llvm.org/docs/NewPassManager.html).

For Bend this yields a testable rule: an owned function consumer receives an
already-valid request context; it must not reconstruct a book, rehash all
declarations or scan all constructors. Each representation transition states
which facts it preserves. A static-body rewrite might preserve source names,
arity and type layout while invalidating runtime dependencies or node-use facts.
Our selective `nf_retry` already embodies part of this principle: only workers
depending on withdrawn product signatures are rebuilt.

Implement the rule with ordinary typed products and explicit arguments first.
Introducing a generic LLVM-style pass-manager framework would add complexity
without evidence that framework dispatch is the missing capability.

These are source-level mechanisms observed on the research date, not measured
speedups transferable from Go or LLVM. External live-source pages are not a
replacement for the immutable upstream Bend pin used in our benchmarks.

## Ranked experiments

Ranges are hypotheses about complete request time, not promises. They overlap;
do not add them. Prototype times assume one focused implementation worker and
exclude a shared integration/qualification gate.

| Priority | Experiment | Conditional gain hypothesis | Prototype / broader implementation | Main risk |
|---|---|---|---|---|
|1, fastest discriminator|Use the completed size/warmth sweep to focus parser/checker code-shape or logical-work counters, then replace measured overhead|No gain from measurement itself. A successful frontend change might remove 3–8% on the IO screen and 10–25% on definition-heavy inputs; current evidence cannot narrow this.|30–60 min focused diagnostics; 2–4 h prototype; larger representation change 1–2 days|Mistaking cold JIT for algorithmic work; changing declaration visibility or parse diagnostics.|
|2, bounded implementation|Source-world report graph and constructor-owner facts, with one final index|2–5% IO request, perhaps 3–7% definition-heavy/small; bounded by current report cost, and graph construction may consume the gain|1–2 h prototype / 3–5 h integration|Unsafe propagation through cycles, source ordering, type-only dependencies and foreign rules.|
|3, main architectural bet|Per-function runtime product that replaces annotation/erasure and supplies multiple native consumers|Earlier 15–25% remains a target to falsify, not a supported forecast; annotation-only cannot deliver it on all classes|2–3 h first admitted slice / 12–24 h full implementation|Extra representation survives alongside old forms; consumer incompatibility; product/observer/bang behavior.|
|4, only with hit-rate evidence|Resolved request-local declaration handles and invalidation-aware summaries|3–8% current screen plausible, potentially more on larger definition sets; overlaps all rows above|1–2 h focused discriminator / 6–12 h integration|Handle stability across worlds, eager construction, persistent trie overhead merely moves elsewhere.|
|Separate future metric|Lazy Base/function products or per-function parallel backend|Unquantified; existing eager product failed, single-CPU parity cannot be claimed from parallel runs|2–4 h demand/transport prototype / at least 1–3 days production work|Decode/GC costs, ABI and demand correctness, memory, scheduler overhead.|

For the large IR bet, require a disjoint time budget. Numeric annotation plus
preparation is 179.4 ms of a 969.0 ms instrumented request: even removing every
millisecond there would be 18.5%, and real lowering still must do essential
work. Functions65's corresponding ceiling is only 49.7/617.4 = 8.1%. A proposal
claiming 25% must also demonstrate replacement of downstream planning or other
work. The 386.5/183.8 ms native stage cannot be treated as wholly removable: it
contains the actual code generation that upstream must perform too.

## Cheap diagnostic recipe

Use the existing `selfhost/tools/performance/phase77/fixtures/functions65.bend`
(SHA256 `301e07212360ee4741b08271cb1eacbb5b92494e0372eae9eb3a6a716888e9db`)
as the generator specification: `f0(x)=U32.add(x,1)`, then
`fi(x)=U32.add(f(i-1)(x),i+1)`, ending in `main()=f(N-1)(0)`.
Generate N=8,32,65,128; expected result is N*(N+1)/2. Retain one constant-main
control with the same unused declarations, and one same-size single-body case
if the first sweep exposes a definition-count slope. This separates total
syntax, checked declarations, and runtime-reachable functions.

Run parse/check-only and full native compilation as **separate contracts**.
The check-only API must preserve ordinary reporting or label it disabled;
do not subtract independent noisy medians as if they were exact phase clocks.
Count source completion, checker and reports in the same request. Compare fresh
processes with an explicitly separate repeated-process lane to distinguish JIT
startup from work growth. B1/B2/TS receive identical files and report settings.

For a count-only generated-B2 derivative, target:

- Parser: `f_context_definition`, `f_context_publish`, `f_context_declare`,
  `f_context_higher`, `f_context_lower`, `f_context_material_children`, `f_grow`,
  `f_lex_scanned`, `f_declared`, `f_find`, `f_decl_prior`.
- Checker/world: `book_put`, `index_put_rest`, `index_remove`,
  `base_prefix_ctor_disjoint`, `constructor_exists`.
- Index: API-level `index_lookup`, `index_set`, `index_build`; separately
  recursive `index_find`/`index_insert` visits and `index_hash` character steps.
- Report: `dr_walk`, `kr_resolve`, `kr_parent`, `kr_dependencies` and
  `book_final_scan`, with a separate source-world label.

Count physical helper entries and semantic tail states separately. Our generated
`f_context_publish$scc` contains many parser functions in one switch loop;
wrapping its exported function misses internal tail transitions. Parse a named
wrapper's `return ...$scc(CONSTANT,...)`, verify its unique switch case, and add
one counter at that case entry. Ordinary direct functions get entry counters;
self-recursive loops need an iteration counter. Do not infer semantic calls
from CPU sample names, or compare the derivative's timings with clean runs.
Keep assertions on image SHA, match count, parameter positions and final
C/report equality. A failed insertion must stop rather than silently miscount.

Counters only store integers and bounded call-site buckets. Do not retain every
term object or log per-call JSON; those changes can dominate memory and runtime.
No parameter hashing inside counters: computing a structural key can cost more
than the operation under investigation.

### Prepared diagnostic implementation

The root requested a narrower first discriminator before the internal counters:
[prepare-frontend.py](../../../selfhost/tools/performance/phase83/prepare-frontend.py)
and [frontend-sweep.mjs](../../../selfhost/tools/performance/phase83/frontend-sweep.mjs).
They freeze the existing Phase83 survey plan, all parent inputs and B2's already
prepared Base, then create 8/32/65/128-definition files. The 65-definition file
matches the historical fixture byte-for-byte. Every role/source gets a fresh
process that issues three ordinary checking requests, with reports enabled.
There is no persistent inspector, CPU profiler or semantic result cache.

B2 calls its existing public driver and records source/check/report boundaries.
TS creates a new book each time, loads/checks Base and user code, and calls the
exact upstream `book_promises`/`term_refs` functions extracted into a diagnostic
module. The extraction changes no function body and records the source hash,
character range and extracted-body hash. Importing the CLI itself would register
a Node loader, so that unrelated side effect is avoided. Each request must
accept the program and return an empty unsafe-definition list. These check-only
results do not constitute an emitted-C equality or execution check.

Public wrappers make the clocks diagnostic. A faster third call demonstrates
reuse of process/JIT/filesystem state, not incremental compilation or a gain
eligible for the fresh-request headline. The root runs this method serially
through the existing ExecutionGuard. This agent checked Python syntax, Node
syntax and fixture identity; it did not launch any compiler request.

### Root-run result: cold execution matters substantially

All eight jobs and all 24 check/report requests pass; their source and method
inputs and prepared cache remain exact. See the SHA-bound
[summary](frontend-sweep-summary.json). Each cell lists the first, second and
third request in **one** process. These are not medians or independent repeats.

| Chained functions | B2 check + report ms | TS load + check + report ms |
|---|---|---|
|8|171.0 / 143.4 / 92.9|331.1 / 197.0 / 295.8|
|32|283.1 / 199.1 / 85.8|332.7 / 194.9 / 261.4|
|65|351.4 / 223.3 / 136.4|370.8 / 225.6 / 313.0|
|128|452.8 / 339.0 / 175.5|344.4 / 216.5 / 278.3|

For N=65, B2's source-completion stage drops 144.3→44.8 ms, checking
82.5→23.8 ms and reporting 39.2→11.6 ms. For N=128, source completion drops
216.9→54.8 ms. This is strong evidence that much of the first-request cost is
sensitive to process reuse. It does not isolate JIT compilation from inline
caches, GC, filesystem warmth or module state; no internal work counters were
installed in this initial discriminator. The nonmonotone TS timings also warn
against treating the third request as a stabilized warm benchmark.

The first-request source-completion progression, 28.7/99.9/144.3/216.9 ms,
does not show an obvious quadratic explosion. Its corresponding third requests
are 10.5/30.9/44.8/54.8 ms. The next frontend test should distinguish logical
node/lookup counts from generated-code cold execution cost, rather than begin
by assuming a new parser representation is required.

At N=65 B2 checking/reporting is already 351.4 ms versus upstream's 370.8 ms
with Base work included. Thus the slow total C request cannot be blamed simply
on an absolutely slower frontend contract. The new full-request profiles still
show roughly 7 ms annotation + 46 ms preparation + 203 ms final native stage
versus TS's 80 ms emission. Those profiles are separate runs and boundaries;
they locate the backend preparation/planning problem without providing an
additive speedup budget.

## Decisions to carry forward

- Use the observed cold/warm sensitivity to distinguish logical frontend work
  from generated-code startup before proposing a frontend rewrite. Broaden
  program classes before another backend rewrite.
- Test the report/context replacement as a small general improvement, with a
  lower expected gain than parity. It is useful only if it remains simpler.
- Pursue native IR only with an explicit list of old traversals and fields it
  deletes. Erasure-head shortcuts from Phase82 were a different, 1.4% experiment.
- Preserve raw API behavior, exact error ordering and typed layout checks;
  optimization may use a private owned request path with a safe fallback.
- Keep compilation latency, emitted-program execution, warm sessions and
  multi-core throughput as separate metrics.
