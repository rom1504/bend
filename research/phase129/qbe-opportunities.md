# QBE after Phase128: opportunities, experiments and ambition levels

This ranking combines the [Bend2 audit](README.md), actual selected code,
Phase120–128 results and [fresh Phase129 profiles](../../implementation/phase129/README.md).
It proposes work; no compiler speedup is claimed by this research phase.

## Metric and estimation discipline

The current qualified N1/N2 **cold source-to-QBE** request time is about 2×
pinned upstream's TypeScript/Bun source-to-C time on lexer, closures and Map.
That excludes the downstream machine builder. Including native QBE/assembly/link
versus upstream C/Clang gives roughly parity under the established
prepared-Base/cached-native-runtime policy. These are separate clocks.

Generated-program runtime is separately 1.65258× upstream geometrically on the
original 44 timed points. Forty remain above 1.1× and 21 above 2×. RLE is 5.66×,
evening 5.42×, tree variants 4.36–5.03×, Map set operations 3.97×, and the main
Mandelbrot case 3.45×. Four spectacularly fast cases still lower the headline
geometric mean. Keep positive log deficit, family means and excess batch time.

Below, **speedup** means old time / new time. Estimated ranges are engineering
priors conditional on a successful discriminator, not measurements or confidence
intervals. A failed hypothesis can yield zero or negative gain. Compilation
ranges refer to the three-request geometric mean unless a different workload
is named. They do not establish full-self-compilation gains. Generated-runtime
ranges refer to the broad corpus, not just the easiest affected kernel.

Times are approximate active implementation plus focused testing for a competent
agent on this codebase; allow **another 30–60 minutes** for one integrated native
qualification/broad gate if no failure or scalability issue appears. They are
not commitments to elapsed time. Do not add overlapping gains.

## Ranked by expected useful compilation gain per implementation cost

| Rank | Opportunity | Estimated compilation speedup | Generated-program speedup | First discriminator → implementation/focused gates | Confidence / complexity |
| --- | --- | --- | --- | --- | --- |
| 1 | Eliminate repeated textual prepared-Base reconstruction | **1.10–1.25×**; closures alone 1.25–1.65×; full compiler likely much smaller | **1.00×** if only carrier changes | 30–60 min → **4–8h** compact carrier; static seed 1–3 days | High fixed-work evidence; medium format/identity risk |
| 2 | Fuse borrowed comparison with its scalar consumer, starting at String ordering | **1.03–1.08×**; lookup-heavy requests benefit most | **1.00–1.06×**, concentrated in text/Map | 30–60 min → **2–5h** | Medium; existing worker and exact projection make a cheap test |
| 3 | Reuse one usage summary instead of recursive per-variable queries | **1.02–1.06×**; **1.06–1.10× on Map** | **1.00×** for exact-QBE cleanup | 45–90 min → **3–6h**; a general proof may take an additional 4–12h | Strong Map exposure; medium scope/branch correctness risk |
| 4 | Resolve names once and carry compact exact identities through one hot pipeline | **1.08–1.25×**; larger inputs may benefit more | **1.00×** for compiler-only representation change | 1–2h → **8–16h** narrow path; pervasive replacement takes days | Medium-low forecast; high identity/invalidation complexity |
| 5 | General private borrowed query regions across recursive calls and scalar returns | **1.10–1.30×** if several hot traversals admit | **1.00–1.15×**; affected kernels could improve 1.5–3× | 1–2h → **8–20h** | Medium-low; broad upside, ownership/stack/escape risk |
| 6 | Remove generic register-bank transitions across whole computations | **1.08–1.20×**, including caller/continuation work | **1.03–1.15×** if transfer spans families | 1–2h → **6–12h** bounded region | Medium exposure; high calling-convention/stack risk |
| 7 | Consolidate a checked immutable plan shared by two real consumers | **1.02–1.12×** if repeated analysis is actually removed | **1.00× initially**; enables rows 5–6 | 1–2h → **6–12h** narrow interface, proof scope extra | High architectural value; low isolated speed certainty |

Rows 4–7 are the more ambitious generalization routes. Rank 1 is a good near-term
compiler-latency target, but **row 5 or 6 is the better bet for improving both
the compiler and unrelated generated programs**. One should not monopolize the
next cycle by optimizing a private Base transport format while ignoring common
code-generation deficiencies.

## Why these are the best current bets

### 1. The fixed Base cost is real and now counted

All three requests execute exactly 1,087,899 `p88_digits`, 762,943 `p88_digit`,
324,069 `p88_number` and 228,745 `p88_field` entry segments. The source decodes a
canonical decimal/string carrier into checked preparation structures. It already
has a cache; the opportunity is **decoding/materialization**, not adding a cache
that already exists. See selected source 37936–38032 and the exact frozen
`selfhost/build/phase88/cache-js01/entry.bend` decoder.

The three decimal-related active contexts cover 38.84% of closures, 10.47% of
lexer and 8.74% of Map. The complete explicitly identified decoder definitions
cover 53.53%, 16.04% and 11.90% respectively in the diagnostic context profile.
These are not exclusive clean CPU percentages: instrumentation affects the
image, and separately dispatched library helpers escape those owner buckets.

**Fast discriminator:** run the existing decode request alone on unchanged
carrier bytes and an independently serialized word-oriented candidate. Compare
the entire reconstructed data/ordinary request QBE, not a few chosen fields.
First test whether a checked compiler-produced static seed removes more cost
than changing decimal arithmetic. Preserve authentication, node bounds, quantity
roles, Unicode, duplicate behavior, format/version/runtime identity and failure
semantics. A routing stamp alone is not cryptographic authentication.

**Reject early** if materialization dominates both representations or new
index/heap initialization eats the savings. A warm daemon is a separate service
metric and cannot be presented as faster cold compilation. Host tooling must
not become a second compiler or forge unchecked native terms.

### 2. Comparison still returns data only to discard it

`String.order` is `Pair.snd(String.cmp(...))`. The selected native compiler has
a borrowed comparison reader but retains product transport and immediate
projection. Active contexts account for 7.25% of lexer and 9.29% of Map, versus
2.45% of closures. Preserve equality/order/Unicode and root lifetimes while
returning just the required scalar. This is a general known-projection rule,
not a recognizer for a benchmark function.

**First test:** an exact wrapper change provides a source-level ceiling on the
existing name/index proxy. If the ceiling is small, stop. If useful, represent
the observed result field in the existing reader summary and verify a second
list/tree query. The original owning fallback and float/error distinctions must
remain. Deleting a product allocation without lower clean time is insufficient.

### 3. One usage summary can replace many ownership-sensitive walks

Current `nq_uses` has 565,251 observed direct entries on the Map request and
`nq_uses_list` another 750,375; their combined active contexts are 10.97%.
The actual [algorithm](../../selfhost/src/back/native/product.bend#L101) saturates
counts at two, takes **maximum** across exactly two-armed `Mat`, and has a
special `NWPattern` case. A standard syntactic occurrence count is wrong.

Compute a per-immutable-body summary for variables actually queried, with
zero/one/many upper bounds and any separately needed minimum-use facts. Preserve
scope/renaming and the exact existing branch algebra. A summary for every
possible ID, or a deep-string key for every query, can cost more than rescanning.
Borrowed query traversal and summary reuse are competing/overlapping designs;
compare both on the same extracted Map/compiler ASTs.

**Reject early** if few identical or compatible queries recur, retained summaries
inflate live memory, or metadata preparation exceeds removed traversal work.
For a cleanup, require byte-identical whole QBE, not only matching execution.
Transfer through a different tree/closure workload before broadening it.

### 4. Resolve identity before optimizing equality forever

Lexer active contexts spend about 17.73% in index find/bucket/insert/hash and
another 7.25% in String ordering. The compiler already has an exact-name Patricia
index. Replacing it with “a hash table” is not an insight. A resolved identifier
can eliminate repeated hashing/string ordering **after** one exact lookup.

Prototype a request-local `DefId`/`LocalId` table at one backend catalogue boundary.
Preserve first-event/full-payload lookup, duplicate declaration precedence,
instantiation/quantity identity, constructor-parent provenance and source names
for diagnostics. Hash collision controls alone do not establish those properties.
Use a theorem analogous to the upstream kernel's `Book.ok`/`get_find` connection.

**Reject early** on total request time or allocation regression; small inputs may
not amortize preparation. Do not build a global interning service before this
local experiment demonstrates value.

### 5–6. Preserve a complete private computation

Physical copies called by `p111_set_regs` plus that helper's own sampled body
consume 9.25–12.78% of original-image CPU exposure. Counts show 21.0–66.9 million
requested register words copied per short request, and **zero words cleared**.
Dispatch counts are 9.94–35.14 million. This is real transport and scheduling,
not the already-fixed blanket clearing bug.

Do not merely hand-inline `memcpy`: that cannot remove calls, state packing,
ownership movement or reconstruction. Preserve scalar/product lanes, held roots,
known helper contracts and local continuation state across a complete recursive
query. Prove/check where control may leave, which values escape, and how the
generic fallback resumes. Keep native stack bounded; a direct recursive C-like
call is not a valid replacement for a stack-safe loop.

The next useful profiler extension is a small sidecar recording exact emitted
worker/FID origin, transition widths, borrowed/effect facts and local-resume
eligibility. It should reuse already-computed lowering data and leave QBE bytes
identical. Join existing counters first. If needed, add a **bounded diagnostic**
width or selected-edge histogram; no dense 48,251² transition matrix.

**Fast discriminator:** pick one decoder/AST/query computation and give its
entire local state a private ABI. Measure register-copy/dispatch/drop changes,
actual hot instructions and clean time. Require unrelated list/text/tree transfer.
The source-level ceiling plus mature C machine code helps reject a bad QBE plan
before a full compiler acquisition.

## Two small experiments that test the Bend-native opportunity

### Experiment A: a proved reusable use-analysis island

**New capability:** one safe analysis implementation has a theorem relating its
reusable result to the previous query semantics. Two optimizer consumers reuse
its answers. This is more valuable than labelling a Bool field a certificate.

1. Extract the measured `nq_uses` subset and its branch/saturation algebra into
   a small safe datatype, leaving unsupported `KTerm`/`NWPattern` cases on the
   existing fallback. Preserve an exact source-to-subset bridge.
2. State a law: for every admitted body and queried variable, lookup in the
   batched summary equals the original saturated query. Prove the actual safe
   analyzer, not an unrelated model. Independently check the translated body
   and require no excluded roots or assumed proof definitions.
3. Pass the executable summary with an erased correctness witness to one
   transformation that currently recomputes the query. The theorem is proved
   once at compiler-development time; the summary is computed at runtime.
4. Challenge branch join, repeated alias, ID renaming, empty scope and unsupported
   pattern cases; mutate the sum/max rule and ensure the proof/gate rejects it.
5. Require identical emitted QBE, lower extracted and total request cost, and
   bounded retained memory. Inspect emitted proof-erasure behavior directly.

**Cost / stop:** 45–90 minutes for query-repetition and subset feasibility;
roughly 4–12h for a credible small proof/integration if the existing proof
workflow accepts its recursion. Stop if adapters remain most of the trusted
work, proof elaboration grows badly, or only one negligible query benefits.

**Transfer:** product substitution, borrowing, continuation lane use and future
backends can consume the same use facts. It helps self-research only if fewer
repeated analyses or proof failures actually reduce the cost of experiments;
measure that, do not infer recursive acceleration from the existence of a law.

### Experiment B: a private borrowed scalar computation with a checked boundary

**New capability:** verified helpers remain composable through their immediate
return consumer and local continuation, without reboxing or runtime-bank moves.
Use String ordering or a measured AST observer, plus an unrelated tree/list
query. This extends the successful Phase128 technique rather than inventing
another backend.

Start with a safe *admission theorem*: accepted argument/result/layout/callee
descriptors satisfy the exact private interface. Reuse existing ownership and
fallback checks. Then separately state the heap/model simulation assumptions
for the generated implementation. The admission theorem alone does not prove
that a raw RFC load or final drop is correct.

**First implementation:** a tiny plan containing origin identity, root-hold set,
non-escaping scalar result, permitted calls/effects and return-consumer fields.
Do not encode all existing IR nodes dependently. Preserve this contract only
across the two boundaries the experiment actually needs.

**Cost / stop:** 1–2h for a source/machine ceiling and controls, 6–12h for a
bounded compositional implementation. Reject if boxed transport merely moves
elsewhere, native stack grows with input, caller analysis becomes quadratic,
or no unrelated workload improves. Preserve final independent verification.

## Ambition ladder

### 1× scope: a profitable next iteration

Use the frozen proxies to test Base decoding/materialization and scalar
comparison composition in parallel read-only investigations; execute one target
lane. Take the better discriminator, then test usage-query reuse. Integrate one
useful combination and qualify once. Keep exact-QBE cleanup separate from
code-quality transformations.

**Conditional objective:** 1.15–1.35× compilation speedup (13–26% less time),
bringing about 2× upstream to roughly **1.48–1.74×**. Generated runtime should
stay flat or improve modestly. Estimated 6–12h plus qualification if experiments
succeed; no promise that this package reaches parity.

### 10× scope: a compiler over persistent semantic facts

Build one narrow `PreparedPrivateUnit` pipeline spanning analysis, legality,
private calling convention and QBE emission. Give it stable resolved IDs,
batched use/layout/borrow summaries, explicit effects/escapes, and local scalar
continuations. Prove the small analyzers and keep raw runtime bridges audited.
Stage the authenticated Base state so cold requests stop reconstructing it.

Extend across compiler AST queries, text and one unrelated tree computation.
Delete superseded analysis paths only after exact equivalence/qualification.
Use the origin/cost sidecar to explain work removed, not just code-size changes.

**Ambitious scenario, low confidence:** 35–55% less compilation time, about
**0.9–1.3× upstream**, and 10–25% less broad generated runtime if the private
computation work transfers. This requires removing work across categories,
not adding the table's estimates. First useful slice: 1–2 days; a genuinely
integrated result could take several days and failed attempts. Proceed only
after Experiment A or B proves the shared boundary pays for itself.

### 100× scope: staged, proof-constrained compilation units

Move from repeated ownership-sensitive graph interpretation to immutable,
compact, resolved units with compiler-produced static preparation and explicit
dependencies. Transformations operate on local units and return checked
replacement certificates; stable interfaces make unchanged analyses reusable.
Sequential deterministic assembly precedes any parallel implementation.

Then use affine ownership to split private output regions, retain read-only
input owners at joins, and schedule balanced independent units on CPU cores.
Requalify all single-worker assumptions before QBE multicore. Try GPU only if
a measured large regular analysis beats the C/CPU proxy after transfer and
conversion costs. The compiler/optimizer itself becomes a first-class workload.

**Research target, not forecast:** single-core 50–70% less work could put the
current 2× ratio near **0.6–1.0×**. Reaching **0.5× upstream requires 75% less
current time** and is not supported by today's profiles alone. Multicore may
reduce latency further but consumes more CPU and must be reported separately.
With parallel fraction `p`, four-core speedup is at most `1/((1-p)+p/4)` before
overhead: 1.6× at p=0.5, 2.5× at p=0.8. No GPU multiplier is estimated.

For generated programs, the present 1.65× geometric ratio needs about **39.5%
less runtime for parity**, or about 69.7% less for 0.5× upstream. The most
ambitious private-representation/producer-consumer campaign can target that
first number, but today's evidence does not support a forecast that it will
deliver it across the corpus. Keep this separate from compiler latency.

Budget a 1–3 week vertical research slice, not a promised complete rewrite;
full semantics, proof bridges, runtime support and broad qualification can take
substantially longer. First falsifier: one real immutable compiler unit must
reduce sequential cost, preserve exact outputs and exhibit balanced C-backend
scaling. If it fails, retain the small wins and stop the architecture campaign.

## What I would do next

Start with **Base decoder ceiling versus complete scalar-query composition**,
using today's fixed counts and existing kernels. Favor the latter if its gain
is comparable, because it can improve compiler execution and user programs.
In parallel, make the use-summary law/bridge small and concrete enough to test.

Keep QBE. Borrow Lean's call contracts and theorem/specification bridges, Zig's
stable identities and phase boundaries, and Go's dense per-function work reuse.
The [Phase128 compiler survey](../compilers_architecture_and_techniques/phase128-fast-compilers.md)
already supplies primary sources for those principles. Bend's specific
opportunity is to connect them to quantities, erasure and source-level proofs,
not to discard the working backend for architectural elegance.
