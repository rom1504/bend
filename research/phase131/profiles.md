# Phase131: refresh the remaining native compilation cost

The Phase130 compact prepared-Base carrier changed the cost distribution. The
Phase129 profiles remain useful historical evidence, but their percentages do
not describe the current compiler. This experiment profiles the **qualified
Phase130 N1 executable**, without rebuilding its Bend source or changing any
frozen request, semantic oracle, production selection or generated-code policy.

## Exact scope and identity

The selected [candidate](../../implementation/phase130/candidate.json) binds:

- Compiler source `995d6b4bf14963debb9a810de2ed941c3cd30a71fc34a156d96b1adbd1b06bdd`.
- N1 executable `a25e4c7f55a6a48829bf9d148498d6392b98fe1ab66b9664d99ce1987715c2c5`.
- Runtime object `9b3f57afb46b4db8c63f6f3c5f1af1194e0854a7329de28f25d2e11aef887749`.
- Compact carrier `984fad041a0ba855ea0aaedd384485afa2153da644655c00882eb50ace33817f`.

The preparation script checks those current receipt identities, the native
qualification, original linked object and full QBE, and the complete carrier
lineage through the existing Phase130 verifier. It authenticates the original
Phase88 producer, Base and serializer inputs, the compact inverse receipt and
explicit routing stamp. Every run independently checks whole QBE stdout against
the unchanged Phase128 qualification oracle and requires empty stderr.

The three cold requests are `lexer`, `coverage-closures-256` and
`coverage-map-churn-128`. These reveal text/index work, fixed preparation and
Map/use-query work respectively. They are a screen for hypotheses, not a new
benchmark definition or a substitute for full compiler self-emission.

## Three separate views

1. **Original executable:** three clean rounds for wall/CPU time and RSS, plus
   physical samples at alternating 8ms/13ms. Small captures are pooled only
   within the identical source, arguments, compiler and instrumentation identity.
2. **Diagnostic runtime relink:** the identical compiler object is linked with
   the existing reversible diagnostic runtime. Context-only unsampled timing
   measures perturbation separately from its sampled active-dispatch contexts.
   The latter are not a source call tree: private synchronous calls retain the
   outer dispatch context.
3. **Counter execution:** one separate event run measures dispatch, allocation,
   reclamation, ownership, register-copy and continuation counts. Its elapsed
   time is never used as a clean compiler result. Counters may miss operations
   inlined by existing generated helpers.

The existing authenticated libc CFI sidecar recovers one physical caller where
its rule applies. This distinguishes register-bank copies from unrelated libc
time without guessing from unresolved PCs. Unsupported callers stay in the
denominator. Each capture must pass loss/lifecycle gates; fewer than 500 pooled
samples remain explicitly inadequate for quantitative interpretation. Absolute
CPU attribution additionally needs the captured process-CPU window to cover at
least 95% of whole-child CPU. Period-weighted and raw fractions remain available.

Closures gets eight sample pairs; lexer and Map get two. These are sample
budgets, not quality waivers. If OS coalescing loses samples, retain the negative
evidence and repeat only the deficient workload under the same guard.

## Reproduction

Run from the repository root. Preparation and analysis execute no compiler or
benchmark target. Root owns the sole guarded CPU3 target lane.

```sh
python3 -B selfhost/tools/performance/phase131/profile/prepare.py physical \
  --out selfhost/build/phase131/profile01
python3 -B selfhost/tools/performance/phase111/guard.py \
  --out selfhost/build/phase131/profile01-guard --seconds 240 \
  --rss-mib 2048 --available-mib 16384 --file-mib 64 --cpu 3 -- \
  python3 -B selfhost/tools/performance/phase113/run-jobs.py \
  --plan selfhost/build/phase131/profile01/jobs.json \
  --out selfhost/build/phase113/p131-profile01

python3 -B selfhost/tools/performance/phase131/profile/prepare.py runtime \
  --physical selfhost/build/phase131/profile01 \
  --out selfhost/build/phase131/context01
python3 -B selfhost/tools/performance/phase111/guard.py \
  --out selfhost/build/phase131/context01-build-guard --seconds 120 \
  --rss-mib 2048 --available-mib 16384 --file-mib 128 --cpu 3 -- \
  python3 -B selfhost/tools/profiler/build-runtime.py \
  --plan selfhost/build/phase131/context01/runtime/plan.json \
  --out selfhost/build/phase131/context01/build
python3 -B selfhost/tools/performance/phase131/profile/prepare.py seal \
  --physical selfhost/build/phase131/profile01 \
  --out selfhost/build/phase131/context01
python3 -B selfhost/tools/performance/phase111/guard.py \
  --out selfhost/build/phase131/context01-run-guard --seconds 240 \
  --rss-mib 2048 --available-mib 16384 --file-mib 64 --cpu 3 -- \
  python3 -B selfhost/tools/performance/phase113/run-jobs.py \
  --plan selfhost/build/phase131/context01/jobs.json \
  --out selfhost/build/phase113/p131-context01

python3 -B selfhost/tools/performance/phase131/profile/analyze.py \
  --physical selfhost/build/phase131/profile01 \
  --context selfhost/build/phase131/context01 \
  --out selfhost/build/phase131/profile-analysis01
```

Use fresh paths for repeated campaigns. The analysis records exact evidence
pins, generic pooled profiles, selected direct-entry counts, active-owner/leaf
tables, counter totals and original-image recovered callers. It reports the
historical Phase129 categories alongside current ones; it does **not** pool
samples across carrier versions or treat historical wall differences as a new
controlled speedup measurement.

## Deciding whether an ambitious change is justified

The historical use-query context was 10.97% of Map, String.order was 7.25% of
lexer and 9.29% of Map, and lexer index contexts occupied 17.73%. These views
overlap physical ownership/reclamation work and may include synchronous callees.
Their current exposure must be measured before selecting an optimization.

For a nonoverlapping cost fraction `f` accelerated by `s`, the time reduction is
`f × (1 − 1/s)`, and the request speedup is `1 / (1 − f + f/s)`. A 20% reduction
requires at least 20% completely removable cost, or 25% of cost made 5× faster.
Parity from 1.80× requires approximately 44.4% of current request time to
disappear. One 10% context cannot establish such a route on its own.

The most informative outcomes are:

- **Repeated use/name analysis still dominates:** inspect shared scalar facts
  or one prepared use-summary traversal before adding a cache. Existing
  `nq_uses`/`nq_uses_list` counters count observed direct entries, not distinct
  queries. A high count does not prove recomputation on the same AST.
- **Materialization dominates several contexts:** look for one representation
  or ownership transformation removing both construction and destruction across
  unrelated computations, rather than accelerating only the allocator.
- **Register-copy/dispatch remains broad:** combine its original-image physical
  exposure with exact copy/dispatch counts; changing call boundaries could
  remove a whole category of work. Do not count copy callees twice.
- **Compact decoding remains mostly fixed overhead:** isolate decoding from
  retained Base materialization. A faster transport has already been adopted;
  renaming that gain as future headroom would be double counting.

The current generic profiler has bounded per-dispatch-owner counters, not
per-query AST identity or result-key histograms. A follow-up repeated-query
diagnostic, if justified, should instrument only selected use-query entry
points, cap storage, record overflow and distinguish exact live object identity
from structural equality and allocator address reuse. No dense FID×FID graph
or unbounded trace is needed for this decision. Correctness requires the
original compiler/oracle runs remain independent of that diagnostic.

## Initial physical screen

Root executed `profile01`; an offline pass through the generic comparison API
found all three pools adequate, with no rejected captures and full-child CPU
estimates available. This is an observation of current execution, not a newly
measured optimization speedup.

| Request | Clean median wall | Accepted samples | Reclamation | Ownership/products | Allocation |
|---|---:|---:|---:|---:|---:|
| lexer | 1.944s | 796 | 22.58% | 20.54% | 0.94% |
| closures | 0.522s | 769 | 15.77% | 22.84% | 1.35% |
| Map | 2.863s | 1,129 | 24.82% | 18.85% | 1.60% |

These are disjoint **physical categories** from the generic period-weighted
profile. Reclamation plus ownership/products occupies 38.61–43.67%; halving
that work would correspond to about 19–22% lower total request CPU time if the
category remains representative and no replacement overhead appears. This is
a conditional performance ceiling, not evidence that a legal transformation
can halve it. Allocation-helper tuning alone has a much smaller measured
ceiling. The pending active-context and event results should identify which
semantic computations create this work.

The raw receipts are under `selfhost/build/phase131/profile01/{lexer,
coverage-closures-256,coverage-map-churn-128}/report.json`. Complete analysis
belongs in `profile-analysis01/report.json` and the Phase131 implementation
record. The diagnostic runtime source and copied headers were separately
checked against the authenticated linked-runtime receipt; the analyzer repeats
that check before accepting its results.

## Complete context refresh and next priorities

`selfhost/build/phase131/profile-analysis01/report.json` is complete. The context
pools contain 831 lexer, 856 closures and 1,219 Map samples, with no rejected
captures. Context-only unsampled runtime was 1.060×, 1.079× and 1.150× clean
respectively; counter runtime was 1.728×, 1.674× and 1.615×. These overheads make
context percentages diagnostic estimates, not exact attribution of original
executable wall time.

| Active context group | Lexer | Closures | Map |
|---|---:|---:|---:|
| Prepared-Base decoder definitions | 11.17% | 44.33% | 7.63% |
| `String.order` + `String.eq` | 10.08% | 2.59% | 12.56% |
| `index_find` + `index_bucket` | 13.70% | 3.14% | 6.70% |
| `index_set` + `index_tip` | 2.90% | 1.03% | 0.81% |
| Index insertion/update family¹ | 8.65% | 3.49% | 3.05% |
| `nq_uses` + `nq_uses_list` | 0.45% | 0.09% | 11.22% |
| Both `nq_uses` and `nc_uses` families | 0.80% | 0.28% | 13.09% |

¹ `index_set`, `index_tip`, `index_leaf`, `index_insert`, `index_join`,
`index_remove`, `index_remove_step`. This row contains the preceding update row;
the final query row contains the preceding `nq_uses` row. Do not sum nested
rows. Physical ownership/reclamation percentages overlap all these contexts.

The analyzer's historical compatibility field `oldDecimal` includes
`p88_number`. It **does not measure remaining decimal arithmetic**: current
`p88_digits` and `p88_digit` direct-entry counts are both zero. `p88_number`
now wraps compact word decoding and associated products/continuations.

Ranked by concrete evidence and potential transfer:

1. **Fuse scalar comparison with its retained-string consumer.**
   [Base `String.eq`](../../selfhost/.bootstrap/upstream-phase66/bend2/base.bend#L1925)
   computes `Cmp.is_eq(String.order(a,b))`; `String.order` projects `Pair.snd`
   from the `(String & String) & Cmp` result of `String.cmp`. In this compiler,
   the comparison's borrowed helper is already visible physically, yet the
   enclosing order context still allocates 3,312,667 times for 815,101 lexer
   calls and 6,632,503 times for 1,614,589 Map calls. This is about four hooked
   allocations per call. The order context also contributes 2.43% lexer and
   3.04% Map samples specifically at `term_drop`. Preserve the scalar answer
   while eliminating reconstruction and consumption of unused string products.
   The whole comparison pipeline is a 10–13% large-request context ceiling;
   it is not all removable. This transformation should generalize to retained
   input/result APIs, rather than recognizing a benchmark function.

2. **Keep record/tag projections borrowed through scalar consumers.**
   The current private `p98_tag_eq` machine helper contains 179 instructions.
   Its ordinary `KTerm` path performs two keeps, an owning eight-field take,
   three discarded-field sinks, calls the ordinary `$direct.p88_string_eq_go`,
   and then performs two more sinks. The `nq_uses` entry calls its private
   wrapper twice. This gives a precise target for avoiding owning record
   destructuring and keeping the projected tag borrowed through comparison.
   The private `nm` and `tg` helpers also take their input record on each of
   the three constructor branches, and reserve 0x800 bytes of scratch stack.
   Their source contracts are in [term.bend](../../selfhost/src/core/term.bend#L52).
   A retained owned result still needs its own correct ownership transfer;
   replacing every owning accessor with a raw load would be incorrect.

   Small direct-dispatch counts do not falsify this direction. Map records
   only 22,576 direct `p98_tag_eq` entries and 0.17% active p98 context, but
   synchronous private calls retain the caller's active context. The same
   limitation applies to `tg` (8,025 direct Map entries) and `nm` (3,502).
   Their costs can appear under `nq_uses`, tree lookup, shape checks and other
   consumers. Dynamic cost of the complete proposed transformation remains
   unmeasured; 39–44% total ownership/reclamation is a broad upper bound,
   not its achievable gain.

3. **Optimize read-side Patricia queries before assuming insertion dominates.**
   Lexer performs 1,630,841 direct `index_find` entries and 163,166
   `index_bucket` entries; their contexts cause 6,273,069 takes and 8,579,207
   drops. `index_bucket` alone causes 4,642,228 takes and 5,427,567 drops,
   with no hooked allocation. This is ownership traffic while searching an
   existing structure, rather than allocation that a better allocator fixes.
   Map has 1,507,119 find and 125,442 bucket entries, with 2,820,081 takes
   and 4,959,718 drops across these two contexts. The bucket source repeatedly
   projects `dn(h)` and compares the name before retaining or discarding the
   candidate; shallow borrowing plus scalar comparison can therefore compose.

   One-pass insertion remains a useful cheap experiment, but its measured
   ceiling is narrower: lexer has 102,830 set and 101,379 tip entries, with
   748,569 takes and 1,396,687 drops across just those contexts. Their sampled
   share is 2.90% lexer and 0.81% Map. The larger insertion family is 8.65%
   and 3.05%, some of which necessarily remains to construct the final tree.
   [index_set](../../selfhost/src/core/index.bend#L239) explicitly obtains the
   tip before a separate insertion traversal, while
   [index_bucket](../../selfhost/src/core/index.bend#L126) is a distinct
   read-side target. Do not forecast a 20% whole-request gain from deleting
   only the tip traversal.

4. **Reuse verified use facts instead of repeating owning AST traversal.**
   Map has 565,251 direct `nq_uses` entries and 750,375 `nq_uses_list` entries.
   The former alone causes 2,419,161 takes, 8,116,922 drops, 4,444,747 keeps
   and 13,736,276 sinks, without any hooked allocation. Its active context
   is 9.24%, with 2.21% specifically at `term_drop` and 1.17% at `span_fade`;
   the list helper raises the combined context to 11.22%. The analogous
   `nc_uses` family adds 1.87% Map context. The explicit semantic constraints
   in [product.bend](../../selfhost/src/back/native/product.bend#L101) remain:
   saturate at two, take the maximum for a two-arm match, and preserve the
   special pattern rule. Count reuse and borrowed traversal overlap: they
   remove some of the same work and their projected gains cannot be added.
   Direct entry counts establish traversal volume, not repeated identical
   `(AST,id)` keys. The agent's bounded reuse experiment should supply that
   missing causal evidence. This target has almost no measured exposure on
   lexer/closures, so transfer beyond Map needs another workload.

5. **Eliminate intermediate decoder products, rather than another encoding.**
   Every request performs 324,069 `p88_number`, 324,956 `p130m_word` and
   228,745 `p88_field` direct entries. Their event counts are also identical
   across requests. Number and word contexts alone cause 2,595,213 hooked
   allocations; their combined active share is 20.49% closures, 5.03% lexer
   and 4.09% Map. The complete decoder is 44.33% of closures but only
   7.63–11.17% of the larger requests. Flattening transient cursor/result
   products across these calls could remove materialization and scheduler
   work while preserving the already-qualified compact transport. This is
   potentially a large tiny-request win, not evidence of proportional gains
   on full-compiler self-emission.

Original-image CFI attribution independently recovers `p111_set_regs` as the
caller for 6.10% lexer, 7.45% closures and 5.67% Map physical samples. Requested
register-copy words are 42,104,527 / 11,461,678 / 57,311,383 respectively, with
zero requested clearing. This cross-cutting cost supports eliminating calls
and intermediate state in the transformations above. It is already included
in their active contexts and must not be added as an independent promised win.

The strongest conclusion is that **the decisive next experiment should remove
ownership work across complete scalar observations**, especially comparison
and record projection boundaries. It can affect several measured families.
The reuse and one-pass insertion experiments are still valuable, but their
current measured exposure does not independently justify a broad 20% claim.
