# Why these read-like queries still pay ownership costs

This is a static inspection of the **qualified Phase134 N2**, not a proposed
compiler change or a dynamic event count. The retained QBE is 107,316,480 bytes,
SHA256 `2c25748d8a0eae711a7dd641d372bbce9f1fb4827dbe95e781b9f1cd11668aec`;
its source is `a00019246b5181b288ab4d3e09e616bd41415fe6381e89a96185c05efa19fb57`.
[The extraction receipt](queries01/report.json) pins both, the exact runtime and
the extraction method. [Small verbatim extracts](queries01/extracts.md) retain
parent QBE line numbers and complete-function hashes. No target was run.

The important distinction is **reference transfer versus destroying a graph**.
The source makes repeated uses of a definition, but the generated code frequently
implements a read by making an owned reference, taking the entire record, and
discarding the fields the reader did not request. Source `+` quantities permit
multiple uses; they do not promise a zero-reference-count borrowed native ABI.

## Exact loop mechanics

| Private computation | Exact ordinary-record path | Control already eliminated |
|---|---|---|
| `f_find` | Each visited `Con` takes the two-field list cell, keeps the query and row, calls owned `dn(row)`, then compares the returned name. `dn` takes all nine KDef fields, loads nine, and calls `sink` on the other eight. A miss subsequently sinks the retained row; a hit sinks the query and remaining list and returns the retained row. | The `f_find`/`f_find_next` recursion already runs as one local tail-SCC loop. |
| `lookup` on an ordinary **non-BookCache** row | One list take; one kept-row `dk` projection to decide BookCache, then one kept-row `dn` projection to compare the requested name. These two projections perform two take9 calls, 18 loads, and 16 unused-field sink calls per such visit. The actual equality and terminal/miss cleanup add work. | The miss backedge is already a local loop. A BookCache head takes a different indexed branch; these per-visit counts must not be applied to that branch. |
| `nc_ctor_owned` on a non-ADT row | One list take; one kept-row `dk` projection: take9, nine loads, eight unused-field sinks, comparison with `ADT`, then cleanup and a local backedge. | Both continuing branches are local loops; no scheduler/frame operations occur in this direct worker body. |

An ADT visit in `nc_ctor_owned` additionally reads `dc(d)`, calls `lookup` on the
children, reads `dk(child)`, and on success returns `db(d)`. There are four static
take9 sites in this worker, not four executions on every visited definition.
The returned child's kind projection and final `db(d)` consume their inputs
without the immediately preceding retained-row keep pattern. Whether those takes
are unique or shared depends on the actual incoming ownership; the guaranteed
shared argument below does **not** apply indiscriminately to them.

Relevant parent positions are:

| Body or event | Parent QBE line |
|---|---:|
| `dn` ordinary take9 → nine loads → eight sinks | 43156 |
| `f_find` SCC begins | 229166 |
| SCC list take / row keep / `dn` / equality | 229286 / 229293 / 229302 / 229305 |
| Ordinary `lookup` kind / name takes | 277443 / 277756 |
| `lookup` indexed branch's separate take9 | 277582 |
| `nc_ctor_owned` kind / child-list / child-kind / native-flag takes | 336838 / 336972 / 337076 / 337210 |

The complete static bodies contain 16 call sites for the combined `f_find` SCC,
85 for `lookup`, and 94 for `nc_ctor_owned`. These include mutually exclusive
constructor variants, error paths and terminal cases. They are inventory counts,
**not hot-loop instruction counts or forecasts of removable time**. These three
worker bodies call no generic scheduler/dispatch/frame API. Other helpers and
caller entry boundaries remain outside that assertion.

## What the runtime actually does

The pinned Phase128 runtime is SHA256
`6eb24c8d4a5d6358a9b8b4107a75af777a8dbdd06fe5fdce18d73b9f85f4824a`.

1. `term_keep` at runtime lines 886–895 increments an existing RFC counter, or
   wraps a nontrivial unshared value with count two. The explicit kept row is
   still retained by the query while a second owned reference goes to `dk`/`dn`.
2. `p111_rt_take` at 3908–3920 calls `ctr_take`. For a unique constructor,
   `ctr_take` at 1033–1053 transfers fields and permits reclamation of its storage.
   For a shared RFC constructor, it copies all fields and calls `span_fade`.
3. `span_fade` at 1021–1031 visits all nine fields, bumps each RFC field's count,
   and drops the consumed reference to the parent. The generated projection then
   sinks the eight unwanted field references.

Thus a normal, valid, nontrivial KDef with an immediate keep and still-live
original row necessarily takes the shared path. The original parent continues
to own those fields. The new references to unwanted nontrivial fields are
incremented and decremented without recursively destroying their contents.
Trivial fields are cheaper and need no RFC bump; eight sink calls are **not**
eight necessarily atomic decrements. KDef includes scalar fields as well as
strings, terms and children. Counts must distinguish actual field types/sharing.

Later cleanup of a discarded row or remaining list can still reclaim a large
graph. A unique input take also has different behavior. Therefore samples in
`term_drop` or `span_fade` cannot reveal allocation sites, graph sizes, or the
fraction of this particular churn without additional evidence. The static path
does establish a plausible recurring cost that is absent from a true borrowed
scalar observation; it does not attribute all destruction samples to that cost.

## A different hypothesis from the rejected field-mask pass

[Phase131's field-mask ceiling](../../../research/phase131/field-mask.md) removed
seven unused heap-load/stack-store pairs from an **already borrowed** KTerm
reader. It changed real machine instructions but yielded approximately neutral
runtime on both tested families, so that extra pass was rejected.

Here the target is an **owning** take9 plus reference transfer and sinks. Merely
deleting unused field loads would leave that work. The existing runtime
`p118_rt_borrow_fields` at 4624–4637 already reads fields without transferring
ownership while a certified root stays live. That does not by itself justify
returning a borrowed `String`/KDef through an owning public API, weakening shape
checks, or extending the compiler's currently admitted layouts. The selected
shallow-record observer admits up to eight fields; KDef has nine. Phase131's
separate wider-layout/selector experiments are prior experimental evidence, not
an already-qualified general KDef borrowed-return capability.

### The exact width boundary is bounded admission, not a runtime ABI ceiling

All following positions refer to the selected source hash above:

| Admission point | Current restriction |
|---|---|
| `nol_fields`, line 36606 | Telescope remainder `left <= 8`, together with nonzero quantity and existing dependent-type restrictions. |
| `nol_ctor_fields`, line 36627 | Known constructor, matching owner, zero templates and `arity <= 8`. |
| `p131rg_width`, line 57640; `p131rg_case`, 57675 | Shallow-record width zero or 2–8, matching the independently read declaration. |
| `p118b_project_borrow`, line 51396 | Derived import has exact argument/result types, state argument, known constructor and matching count in 2–8. |

The projected import is checked as a `p111_rt_take` contract for the independent
verifier; this projection is not the emitted operation. `p118b_verify_functions`
at 51441 verifies the projected workers against the original program. The actual
reader still calls `p118_rt_borrow_fields`.

Physical capacity is wider: `p113e_seed` at 44916 declares 2,048 bytes of scratch;
the existing direct emitter also allocates 2,048 bytes. Protected `p111v_buffer`
at 40332 checks `count <= 255` and actual buffer capacity at least `8 * count`.
Sixteen fields need 128 bytes. The runtime helper checks actual constructor
arity, output pointer and constructor tag, without an eight-field ABI bound.
Separately, the late inline read template `p128bf_match` at 56678 admits only
2–8 fields. Leaving that bound unchanged lets wider admitted reads use the
generic runtime helper, preserving its checks; widening it is another decision.

The existing [Phase131 wider-record experiment](../../../research/phase131/wide-records.md)
already changed exactly the four admission declarations above while retaining
the runtime, late template and all protected verifier declarations. It passed
width, unknown/mismatched constructor, state/type and insufficient-buffer
controls. Actual KDef name queries became 32.48% faster and an unrelated
nine-field query 41.03% faster in that bounded screen. Its composed scalar
selector improved 50.65% on a one-entry leaf and 61.95% on forced 64-entry
collisions. These overlapping kernel results are **not multiplied** or converted
into a whole-compiler gain. The experiment remained outside the qualified source.
Reuse this evidence and frozen candidate before constructing a new width pass.

The exact experimental source was `wide-source02/compiler.bend`, SHA256
`5b889d04628d9fb9b5a53a8486b1c5bec169d941933ce8c4365f9b0f53c2a5da`.
Its [published kernel summary](../../phase131/diagnostics/wide-records.json) and
[selector addendum](../../phase131/diagnostics/addendum02-wide-selector.json)
are backed by the Phase131 diagnostic capsules. It was excluded because no
whole-compiler benefit or native self-hosting qualification was measured, **not**
because these kernel tests failed or demonstrated a whole-compiler regression.

The cheapest next falsifier on the actual current hot path is a **complete scalar consumer**, such as
`name_equal(held_row, query)` or `kind_equal(held_row, literal)`, retaining the
original row until the Bool result is known. Reuse the prior wider-reader
candidate for this source-level ceiling against the exact owning composition
on the same query proxy. Then,
only if native timing and ownership events improve, consider a reusable checked
projection-observer composition which preserves that scalar computation through
lowering. Keep the existing owning path for unknown/escaping cases.

Admission must cover valid constructor variants, held-root lifetime, aliases,
first-match/missing and BookCache behavior, evaluation order, no pointer escape,
and native stack safety. Passing `+` annotations or enabling a wider field count
alone is insufficient. If the source-level ceiling still becomes take9/sink in
generated code, the experiment has not tested native borrowing: inspect the
actual admitted worker before timing it.

This separates two independent hypotheses: reducing the number of visited rows
through indexing, and reducing ownership work **per visited row** through scalar
observation. The query proxy's visit/comparison counts can normalize the latter,
but are not themselves allocation or RFC counts. Preserve both factors and
negative outcomes rather than combining them into an unexplained speedup.

## Refreshed dynamic context, without over-attribution

The completed [exact-object sample](refreshed.json) has 11,569 observations and
no quality rejection. `f_find`, `lookup` and `nc_ctor_owned` account for 5.11%,
5.15% and 7.90% of active contexts. Drop/fade leaves cover respectively 48.22%,
49.33% and 53.17% **within** those contexts (2.46%, 2.54%, 4.20% of all samples).
This confirms that the inspected computations are consequential on the current
full compiler request. It still does not identify which individual projection
caused each runtime sample or how many decrement operations actually freed a
graph. The existing borrowed `has_name` context has zero sampled drop/fade but
different inputs and algorithms, so it is supporting evidence rather than the
missing controlled intervention.
