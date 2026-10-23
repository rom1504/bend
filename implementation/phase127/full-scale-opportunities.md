# Full-source profiling: ownership-preserving search is the next useful target

The strongest new lead is a capability already demonstrated in the mature C
backend but absent from selected QBE: a **scalar-result borrowed observer** for
the compiler's string equality loop. Combine its first experiment with a
compiler-shaped name-search proxy. This can distinguish expensive traversal
from expensive ownership handling before paying for another compiler image.
The evidence does not call for a new IR or backend.

This was an offline source/QBE/machine-code investigation. No target execution,
build, production edit, new optimization or speedup occurred in this audit.
Exact input identities and bounded function evidence are in
[full-scale-source-evidence.json](full-scale-source-evidence.json).

## What the full request actually sampled

The [full-source capture](../../selfhost/build/phase127/full-profile01/report.json)
compiled unchanged Phase126 source32 using the diagnostic executable whose
producer restored live-bank admission. Its algorithm/source remains Phase126.
The request emitted the expected99,526,466 bytes with empty stderr. Its471.33s
wall time is diagnostic time, not a clean compilation benchmark.

The [attribution](../../selfhost/build/phase127/full-profile01-attribution/report.json)
contains36,220 samples,35,300 known active dispatch contexts, no recorded loss,
and near-complete main-thread CPU coverage. Physical `term_drop` and `span_fade`
leaves account for8,205 +5,754 samples, or38.54%. They are distinct sampled PCs;
this does not mean two independent source-level passes take38.54% of the time.

| Active lowered owner, including its continuation FIDs | Samples | All samples | `term_drop` | `span_fade` | Those two leaves within this context |
|---|---:|---:|---:|---:|---:|
| `p88_string_eq` | 2,725 | 7.52% | 662 | 403 | 39.08% |
| `has_name` | 2,651 | 7.32% | 995 | 614 | 60.69% |
| `String.order` | 1,921 | 5.30% | 493 | 0 | 25.66% |
| `f_find` | 1,765 | 4.87% | 523 | 616 | 64.53% |
| `nc_ctor_owned` | 1,561 | 4.31% | 390 | 424 | 52.15% |
| `index_find` | 1,361 | 3.76% | 271 | 298 | 41.81% |
| `nb_contains` | 1,258 | 3.47% | 400 | 309 | 56.36% |

These are owner×physical-leaf measurements. Private calls retain the outer
dispatch context, and a generic transition can change it. Consequently, the
whole `has_name` context is neither its exclusive string-comparison cost nor
the inclusive cost of all its callers. The `p88_string_eq` context includes
its two root keeps, consuming walker, final root drops and other private
work. The seven contexts sum to36.56% of samples; they are disjoint dispatch
observations, not additive independent optimization speedups.

## Trace1: held string equality still consumes every inspected node

Actual [source32](../../selfhost/build/phase126/observer-divmod-source32/compiler.bend)
lines6–19 define a consuming `p88_string_eq_go(a,b,same)` and this public wrapper:

```bend
def p98_eq_finish(same: Bool, left: String, right: String) -> Bool:
  same

def p88_string_eq(+a: String, +b: String) -> Bool:
  p98_eq_finish(p88_string_eq_go(a, b, True{}), a, b)
```

The wrapper deliberately retains both roots during the consuming traversal.
The retained full QBE at lines107002–107030 has two `p111_rt_keep` calls, a
direct walker call and two root sinks. The walker at106814 has a local loop,
two `take2` operations on the two-nonempty-strings path, character extraction,
comparison and a backedge. Its154 machine instructions include16 textual call
sites across all branches, including failure paths; these are not dynamic
call counts. There is no borrowed-reader worker for this equality in source32.

On shared strings, taking a node can call `span_fade`, adjust child ownership,
and drop the traversed wrapper. This is consistent with the physical profile;
the evidence establishes ownership work in the comparison, not the fraction
that a borrowed version will eliminate. Early mismatch must still dispose
owned roots according to the original semantics.

This exact distinction already appeared in
[Phase98's mature C evidence](../phase98/own-backend-mechanism.md): its generated
observer used borrowed pointer reads and a local loop, with no per-node
take/keep/sink/allocation operations. Reuse that semantic argument and controls;
do not transfer its historical speed ratios to current QBE.

## Trace2: name membership and declaration lookup are already local loops

[`has_name`](../../selfhost/src/core/term.bend) scans a `List<String>` and compares
each head. Its callers in [reach.bend](../../selfhost/src/core/reach.bend) include
the seen set, duplicate dependency suppression, stop membership and final
book filtering. Repeated linear membership can therefore become quadratic as
the number of names grows. This is algorithmic work independent of RC costs.

The final QBE public `has_name` and `has_name_next` wrappers already call the
joined `$p126scc.3009` worker at148390. It has108 QBE lines, local backedges,
one list-take site, one keep site, and a direct equality call. There is no
generic jump/return helper inside that worker. Replacing per-element scheduler
transitions is therefore not the right explanation for this particular hot
loop; local control flow is already present.

[`f_find`](../../selfhost/src/front/declarations.bend) similarly scans a
`List<KDef>`, projects `dn(d)` and returns the first matching declaration.
Its joined `$p126scc.1000` at205542 has158 QBE lines, local backedges, list take,
definition/name projection and equality calls. It returns an owning `KDef`,
so it cannot simply use a Bool-result borrowing transformation.

Use two independent interventions: fewer comparisons through an amortized
index, and less ownership traffic per comparison. Merely adding a hash table
can move work into the already-hot `index_find`, especially for small lists.
Likewise, borrowing comparison leaves linear/quadratic search complexity.

## Trace3: Base ordering already borrows, but retains product transport

Pinned [Base](../../selfhost/.bootstrap/upstream-phase66/bend2/base.bend):1952
defines `String.order` as `Pair.snd(String.cmp(a,b))`. `String.cmp` returns both
roots plus a comparison. QBE has an actual `$p118borrow.read.String.cmp` worker
at the beginning of the retained full SSA. Its127 machine instructions include
borrowed field reads; its QBE has five constructor call sites across branches.
The `String.order` local region then calls the product worker and `Pair.snd`.

Thus this path has already obtained borrowed traversal but still materializes
and consumes result structure. A checked scalar-result observer or composition
of the immediate projection could remove that category of work. It is a
different capability from blindly extending the current root-returning reader.

## Trace4: constructor ownership rescans information already prepared elsewhere

[`nc_ctor_owned`](../../selfhost/src/back/native/identity.bend):44 scans the book,
tests each definition's `ADT` kind, searches that definition's constructor list,
and returns the **parent ADT's** Base provenance `db(d)` when a constructor
matches. It is used by constructor-name encoding. Its generic QBE still has
continuation/jump edges, unlike the two joined lookup loops above.

[`nc_find_ctor`](../../selfhost/src/back/native/bridge.bend):373 already has a
prepared constructor index. This suggests enriching existing request-local
constructor metadata with the owning ADT's provenance rather than adding a
separate cache or repeatedly scanning the book. This is a hypothesis: the
index lookup must preserve the original traversal/duplicate precedence and
must not substitute the constructor's own `db` flag for its parent's flag.
Cached book nodes and nested constructor traversal also need explicit checks.

`index_find` itself uses a hash/Patricia representation
([index.bend](../../selfhost/src/core/index.bend):71); it is not another ordinary
linear scan. Its generic full QBE at2433749 contains takes, sinks, constructor
reconstruction and generic edges. Treating it as a borrowed lookup returning
an owned child would require an escape/retain proof, not a scalar-word shortcut.

## Archived scalar observer: implemented and checked, not selected

The selected `p118b_eligible` in source32:51252 explicitly excludes a `Var`
wrapper, the representation of a scalar-only observation. No `p118s_*`
definitions occur in source32. The archived
[scalar-observer-v2.bend](../../selfhost/tools/performance/phase118/scalar-observer-v2.bend)
implements that missing path with a borrowed reader, owning fallback and adapter.

The retained status is more precise than either “unimplemented” or “rejected”:

- V1 checked as source but failed ordinary emission with `direct condition must
  be a definitely assigned U32`; its runtime guard result was U64. V2 normalizes
  the branch condition using an explicit comparison.
- [V2 ordinary emission](../../selfhost/build/phase118/scalar-controls-emit02/report.json)
  succeeds and includes an actual scalar-guard call. Its
  [independent ordinary execution](../../selfhost/build/phase118/scalar-controls-run02/scalar-observer-observe/report.json)
  passes all12 output lines, covering shared/distinct, mixed, aliased, static and
  Unicode cases. This is bounded semantic qualification, not a general proof.
- [The four-program screen](../../selfhost/build/phase118/scalar-screen01/report.json)
  completed, but compares against Phase117 and includes other Phase118 changes.
  Only map-churn's emitted QBE has a scalar-guard site; lexer, Unicode and list
  pipeline have none. Those historical ratios do not isolate this capability.
- No inspected receipt demonstrates admission of the real compiler's
  `p88_string_eq_go`, a full compiler built with this observer, or an isolated
  compiler speedup. The selected report calls it a separate alternative. A
  demonstrated performance rejection was not found; the honest status is an
  unselected, bounded checked prototype with its compiler value unmeasured.

The old scalar-source02 already admits `p118_rt_borrow_scalar_safe` in its
transport whitelist. Current source32 does not. Porting only the observer
without that independently audited contract could recreate the global
live-bank regression just diagnosed.

## Smallest high-information experiment

Start with a source-frozen kernel containing the actual equality walker,
`has_name`/`has_name_next`, and repeated membership over retained compiler-like
names. Include a separate declaration lookup transfer using small `KDef`
records. Use existing small-program emission/runtime/oracle machinery; no
whole compiler image is necessary.

Use a two-factor comparison: original consuming equality versus checked
borrowed equality; list membership versus a prepared existing compiler index.
Measure preparation+queries as well as query-only time. Vary list size, number
of queries, shared/distinct roots, early/late hits, misses, long common prefixes,
Unicode and aliases. Freeze names/queries and expected answers before runs.
An actual declaration-name slice from source32 is useful, but retain an
unrelated list/text workload to test transfer. Never select by workload name.

The first decisive questions are whether the NO analysis admits the renamed
actual walker, whether its fallback satisfies the archived ready/dependency
restriction, and whether final machine code removes per-character owning
takes. Record destructor/take/allocation events and clean timings separately.
If the comparator improves but the lookup does not, residual list projection or
algorithmic cost is important. If the index improves only query-only time,
establish its reuse threshold before applying it to a compiler request.

Correctness obligations:

1. The result must be proven nonowning by its checked type/NO schema. Bool and
   checked zero-field enums qualify; an arbitrary U64 word might be a borrowed
   pointer. `nol_scalar` at36666 normalizes and checks permitted scalar/enum
   types. Do not replace this with “the machine result is one word.”
2. Borrowed nodes cannot escape or be mutated; owning roots stay live until
   observation finishes and are discharged exactly once. Preserve alias,
   unique, static, shared and mixed-root fallbacks, character representation,
   evaluation/error behavior and bounded native stack use.
3. `f_find` must return the first matching full declaration, preserve its
   Missing sentinel and handle duplicate names/hash collisions correctly.
   Returning an owned subobject needs a retain/transfer proof.
4. `has_name` Boolean membership permits duplicate-insensitive indexing, but
   its callers' output order and the construction of `seen`/`live` lists must
   remain unchanged unless separately proved irrelevant.
5. Constructor identity must preserve parent provenance, traversal precedence
   and exact encoded spelling for non-Base constructors.
6. Preserve original verification and runtime import contracts, including
   transport capability admission. Unknown forms retain the current fallback.

## Conditional bounds and ranking

For an affected measured fraction `f` accelerated by `s`, the idealized cost is
`T'/T = 1-f+f/s+h`, where `h` is new preparation, checking and guard overhead.
These diagnostic shares are envelopes, not forecasts or clean CPU timings.

| Experiment | Conditional opportunity | Small decisive test effort |
|---|---|---|
| Scalar borrowed equality on the actual compiler-shaped kernel | The equality context alone is7.52%; halving its whole cost would save3.76%. Drop/fade within equality+membership+declaration-search contexts occupy12.49% of all samples, but only an unknown subset belongs to replaceable equality work. Removing half of that subset cannot be assumed in advance. | About30–60min to establish current admission, reuse controls and inspect one small emitted kernel; extend only after a positive result. |
| Reuse an index for reachability membership | `has_name`+`nb_contains` contexts are10.79%. A4× improvement of all that work would save8.09% before setup costs; this is an optimistic envelope, since these contexts contain unrelated ownership work too. | About30–60min for a list/index crossover proxy; integrate only where enough repeated lookups amortize preparation. |
| Prepared constructor provenance | `nc_ctor_owned` contexts are4.31%; eliminating90% would save3.88% before preparation. The existing constructor index may make the implementation smaller than a new cache. | About20–40min for an indexed-vs-original source-level ceiling with duplicate/provenance controls. |
| Scalar projection through the existing borrowed `String.cmp` result | `String.order` context is5.30%; its whole elimination is impossible, and borrowed reads/comparison remain. Measure allocation and root-disposal removal rather than claiming the full share. | About30–60min for an immediate-consumer kernel and machine inspection. |

The effort ranges describe bounded experiments, not full compiler integration
or qualification. Reducing the global38.54% drop/fade bucket to zero would
still leave61.46% of this diagnostic CPU profile; even that impossible extreme
is only1.63×. Compiler parity therefore cannot be justified by a destructor
micro-optimization alone. Composable borrowed computation and fewer repeated
searches address different parts of the deficit and should be tested separately.

Prioritize the scalar-observer admission/proxy because there is existing source,
an independent semantic control, a mature C precedent, a concrete absent QBE
capability, and a newly measured hot compiler use. Then choose between an
amortized membership index and constructor-provenance reuse using the proxy
results. Defer a wholesale representation rewrite and another full self-hosting
campaign until a small experiment removes the expected dynamic work.
