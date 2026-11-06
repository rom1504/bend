# Two larger remaining work-elimination routes

Read-only audit of the combined four-overlay candidate. No target execution or
production edit. The clean complete build improved **188.620→180.677s**. The
[paired diagnostic captures](candidate-profile.md) identify the remaining work,
but their clocks are not interchangeable with that clean total.

| Relevant diagnostic region | Original | Combined candidate |
| --- | ---: | ---: |
| Parse/load |28.742s|29.545s|
| Frontend after checking |18.080s|18.281s|
| IDs/tables/index/registry |12.182s|12.271s|
| Render/output/exit |32.451s|30.454s|

The two routes below target substantial complete producer/consumer boundaries.
Their quoted totals are **scope ceilings**, not removable cost or gain
forecasts. The liveness shortcut's actual hosted measurement was neutral;
original-body hygiene sharing has its own experiment. Neither is credited here.

## 1. Materialize frontend terms once at each semantic boundary

The clearest remaining repeated full-tree work is in pattern elaboration.
[`f_hit_row`](../../selfhost/src/front/elaborate.bend) can call
`f_pattern_sub(f_pattern_sub(body, id, value), otherId, constructor)`.
`f_var_rows` also substitutes complete row bodies as columns are removed.
`f_pattern_sub` rebuilds child lists, and its replacement helper recursively
propagates occurrence spans into inserted terms. After elaboration and actual
source validation, [`f_prefix_trace_validated`](../../selfhost/src/load/prefix.bend)
calls `f_fresh_defs` on the complete suffix. The
[`ffw_walk_existing`/`ffw_frame`/`ffw_kids`](../../selfhost/src/front/fresh_work.bend)
chain walks those trees again and reconstructs binders and children.

**Architecture hypothesis:** keep pending, ordered pattern substitutions in a
private row context and apply their composition once when the surviving branch
is materialized. Carry the final freshening environment through that emission,
so the final binder-normalized term is produced once. This is not replacing a
primitive lookup or changing IDs. It removes complete intermediate term trees.

Start with the composed substitutions in `f_hit_row`, then cross the freshening
boundary only if complete real loader results justify it. Simultaneous
substitution is not equivalent: the second substitution must affect inserted
values exactly as today, including occurrence-origin precedence, aliasing,
quantities and removed names. Fresh IDs are assigned after pattern expansion;
simply moving the existing parser counter earlier is incorrect. Keep the actual
validation/checking obligations and their first diagnostic order.

There is a second materialization frontier on the same frontend path:
[`p86_plan_context`](../../selfhost/src/host/native-plan.bend) constructs the
reachable annotated declarations; `jl_checked_error` traverses their annotation
facts for layout; [`p144o_prepare_annotated`](../../selfhost/src/back/common/constructor-facts.bend)
builds an annotation index, merges the source book, traverses that merged book
for its exact maximum ID, constructs an ownership view, and calls `nr_walk` to
produce erased-body facts. A later private producer can emit checked layout and
erased-body facts alongside annotation, preserving the full checked source for
diagnostics instead of materializing and rediscovering those facts. This is a
larger follow-on, not a claim that annotation or layout checking can be deleted.

**Evidence and ceiling:** parse/load plus post-check frontend is **47.826s** in
the current diagnostic. Initial substitution/freshening work is only a subset
of the **29.545s** parse/load interval. The current old-profile active contexts
include `f_pattern_sub` and context materialization, but do not measure their
inclusive removable cost. Improving both complete intervals by 2× would save
23.913 diagnostic seconds; that is arithmetic, not a forecast.

**Cheap decisive gate:** use the retained 39,333-byte actual verifier source and
a pattern-rich compiler module. Compare complete loader graphs/freshened terms,
not only token streams or checksums, including origin spans and exact errors.
Then compile the same source through the unchanged checker/backend and require
exact complete QBE. Charge pending-environment construction and destruction.
If the complete load interval remains neutral, do not acquire a full compiler
merely because a substitution microbenchmark wins. The existing checked API
loop can establish this boundary before any full native acquisition.

## 2. Make region discovery and public emission consume bodies without rebuilding them

**Follow-up:** the bounded public producer/emitter fusion was implemented and
tested ([result](public-emission.md)). All 48 controls and complete actual QBE
matched, but hosted complete time was 28.937→28.843s and render time
2.740→2.820s. This subset is neutral and is not a recommended standalone native
acquisition. The broader registry/retry work below is still unmeasured, not
validated by that result. Prioritize the frontend falsifier next.

Two concrete producers still repeatedly materialize bodies on the backend path:

- [`p168j_registry`](../../selfhost/src/back/qbe/early-emission.bend) feeds the
  same typed candidate list to up to six `p112c_passes`. An already admitted
  owner is skipped, but an unresolved candidate goes through `p112c_scan` again
  in each progressing round. In
  [`closed-regions.bend`](../../selfhost/src/back/qbe/closed-regions.bend), even
  an unsuccessful scan rebuilds the original list through `p112f_prepend` and
  branch reconstruction, then `p112c_fused` creates a transformed segment and
  `p112c_plan` scans it to attempt worker admission.
- On the final public fallback,
  [`p112w_public_segment`](../../selfhost/src/back/qbe/scalar-workers.bend)
  constructs a complete `List<P112WorkerStmt>` with `p112w_public`, immediately
  traverses it with `p112w_stmts`, and turns every ordinary node back into the
  original `N111Stmt` passed to `p111q_stmt`. This is a real producer/consumer
  intermediate, not a retained optimization result needed by another caller.

**Architecture hypothesis:** first fuse that public-worker producer into its
actual emitter, preserving tail-call selection, branch labels, terminal/error
behavior and byte order. Then replace blind failed-candidate retries with
dependency-triggered retries while keeping the same frozen registry per rank,
the same candidate order, and the same six-rank limit. This preserves generated
code quality and can avoid both traversal and lifetime management of intermediate
lists. It differs from caching the final public plan or sharing one hygiene bit.

The dependency condition is strict: skip a previously failed attempt only if
every ready/symbol lookup capable of affecting it is unchanged for the same
candidate body, fusion index and limits. An exact observed lookup-dependency set
is sufficient for a deterministic pure attempt; a conservative static set must
also include continuation bodies reachable through the fusion index. Looking
only at direct calls in the original body is insufficient. Do not immediately
admit newly available workers in the current round: that changes rank/order and
can change exact plans and output. Failed/refused cases stay independently
checked; no cached Boolean becomes verifier authority.

**Evidence and ceiling:** the complete registry-containing interval is
**12.271s**, and complete render/output is **30.454s**, totaling **42.725s**.
Neither is wholly attributable to these two producers. The profile does not yet
record failed-candidate retry counts or public-worker intermediate node counts.
Therefore no seconds saving can honestly be assigned. A 2× improvement of both
whole intervals would save 21.363 diagnostic seconds, again only a scenario.

**Cheap decisive gate:** before implementing a worklist, count candidates tried
at each rank, failures retried with unchanged consulted entries, and intermediate
worker nodes on the same small actual verifier request. If most candidates run
once, abandon the retry project. Prototype public producer/emitter fusion on
complete captured public segments and compare complete emitted strings, including
nonempty recursive workers, malformed tails, branches after terminals, and exact
error markers. The complete request must still match QBE and runtime controls;
an isolated successful plan or string-formatting loop is insufficient.

## Why these remain hypotheses, and what they cannot promise

The [earlier frontend audit](frontend-audit.md) and retained Phase160–170 evidence
exclude tempting substitutes: publication reuse is already selected; the compact
App representation slowed native checking; the prepared-body cache was already
effective; memo/equality transplantation did not explain the whole gap; the
Phase170 lexer win primarily repaired JS memory behavior and did not deliver a
native whole-build speedup. `nt_text_finish` already appends fragments linearly,
and the compiler already streams complete output. Another generic streaming or
lookup-cache proposal would repeat old work.

Likewise, disabling the region registry or bypassing mature composition is not
an acceptable speed route. Phase168–169 established that callable metadata,
registry imports, certified array emission and ordinary composition materially
affect generated runtime quality. The proposed changes preserve those algorithms
and their results while removing intermediate construction/retry work.

Even the optimistic scenario of halving all four named intervals saves only
**45.276 diagnostic seconds**. It does not justify promising a 100s clean build
from 180.677s. Reaching that target additionally needs a substantial reduction in
the execution cost or work of checking/lowering across other stages, such as the
separately investigated borrowed-selector boundary. The next rational decision
is one complete frontend falsifier and one complete backend producer/consumer
falsifier, followed by a full build only for a material measured winner.
