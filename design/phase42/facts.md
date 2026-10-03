# Request-local compiler facts

Hypothesis: preserve exact Phase41 emission while deleting duplicate planner
walks. The starting point is checked01 / commit `5ec82b3`. Phase41 reports a
9.46% median increase in the normal tree compilation request; attributing that
increase to a particular planner requires fresh compilation profiling.

The [Phase38 architecture](../phase38/architecture.md) favors facts over a new
IR. Start with one bounded source fact, the root's self-reference count. Its
identity is `(original book, original definition, body, name, fuel=1024,
initial count=0)`. Keep it on the ordinary call stack from admission through
selection, and discard it when that plan returns. No persistent cache, runtime
permission, dependency guard, representation or proof boundary changes.

The isolated candidate moves the remaining plan into the existing admission
helper and supplies the self count to selection. It deletes selection's second
identical traversal. All type, prefix, purity, fuel and no-backedge checks remain.
The fact records the existing bounded result, including the conservative value
3 on exhaustion; it does not reinterpret 3 as an exact count.

| Planner consumer | Repeated work today | Safe reuse boundary |
| --- | --- | --- |
| `j_component_plan` admission / selection | Same root self-reference syntax walk twice | One plan invocation; candidate implements this |
| `j_component_wrapper_calls` | Each qualifying callee reruns full component planner / typed graph | Exact callee plan, original book, same bounds |
| `j_component_named` from `finite.bend` | Full callee plan at every saturated emission site | One immutable library emission request |
| `j_l_def` | Callee plan again for worker declaration | Same original book and definition as named call |
| `j_region_has_loop` | Callee plan again for residual profitability | Same original book/definition; only validity is consumed |
| `j_component_declaration` | Self-reference count again for frame choice | Same exact root and 1024 bound |
| `j_tree_scope`, producer planners | Purity graph under different fuel/context | Do not share by name or Boolean purity alone |

The next useful shared result would be the **entire existing JPure plan** plus
the existing bounded self count, scoped to one immutable emission request. Calls
consume its exact ordered definitions for `regionProofCovers`, frames consume
self count and existing structural prefix proof, and layout continues to use
the original tagged representation. This establishes no ownership, demand,
unboxing or mutation permission. Caching both successful and refused exact
plans would avoid fallback sites repeatedly proving failure; implementation
must first identify how to thread the request scope through current emitters
without replacing ordinary source books with rewritten private terms.

Do not substitute a wrapper's full graph for its callee's graph. The wrapper
itself references the callee, so `j_component_closed(callee, wrapperGraph)` can
reject a valid callee. Extra unrelated graph members can also alter guard lists
and emission bytes. A graph subset derived from reachability would need its own
bounded/refusal equivalence proof; this candidate does not attempt it.

Reject any mismatch in admitted or refused module bytes; public alias / partial
call behavior; native-hook and host mutation guards; dependent/open signatures;
capture, mutual backedges, wrapper chains, large bodies or graph exhaustion.
Do not accept a speedup obtained by deleting any owner assertion.

Validation starts with checked candidate build, exact tree/wrapper/control
emissions, then the existing normal-request cost loop using fresh, alternating
baseline/candidate processes. Preserve all samples and memory receipts. The
first candidate removes one syntax walk, not the nested typed graph work, so a
null timing result is plausible and must remain a null result.

## Profile-directed successor

The root's fresh checked-request capture locates about 760ms of visible
component planning, including about 633ms below named-call emission, versus
3.3ms for all visible reference counting. Generated anonymous `kc` frames must
be mapped to enclosing Bend definitions; named-only sampling hides most work.
See the [implementation analysis](../../implementation/phase42/facts.md) for
overlap, verification and timing-boundary limitations. Hold the tiny candidate
and test exact complete-plan reuse first.

The concrete derivative retains exact existing `JPure` results in one emission
request's BookCache metadata. Original logical planners remain callable without
facts. Name-based cached entry points canonicalize through the original source
index; transformed/private same-name KDefs never provide cache keys. Components
and acyclic direct helpers have separate fact tables because their eligibility,
graph fuels and refusal predicates differ. Store failed graphs' exact ordered
defs/fuel/valid rather than collapsing every failure to an empty Boolean.

BookCache child zero remains the source index. Child one is a dedicated
`$js.plans` / `JSPlanContext` containing component/direct indexes. Their private
`JSPlanFact` records encode exactly `JPure{defs,fuel,valid}` in existing KDef
fields. Source names cannot reach these facts through ordinary lookup.
Preparation removes prior fact metadata before running ordinary planners, so
there is no partially constructed cache dependency. A `book_put` source update
already drops metadata; request entry additionally rebuilds fresh facts.

Precompute canonical selected component roots whose declarations already query
the planner; gather direct-helper target names by bounded saturated-call syntax
scan. A scan limit only causes ordinary planner misses. Keep saturation and exact
worker-context subset checks at their original use sites. Producer graphs with
context-dependent remaining fuel are excluded. Do not change ordered runtime
coverage lists or infer representation/demand permission from a plan hit.

This successor adds 116 lines / 15 definitions. That is an explicit structural
cost in return for deleting repeated **execution** of existing proof walkers.
It is not yet a source-size simplification or measured throughput gain. The cheap
falsifier is exact checked emission against calls/context alone, followed by a
fresh request/RSS comparison. Any refusal, order, alias, guard or memory-bound
regression rejects it independently of runtime benchmark gains.

The later closed native-data matched-set exploration is held after an executed
[returning-host callback falsifier](../../selfhost/tools/performance/phase42/facts/map-bst/returning-host-callback-assessment.md).
Its aggregate bounded source facts passed strict controls, but ambient proof
inheritance allowed foreign proxy reentry and skipped dynamically changed G.code
calls. Request-local reuse must continue to cache source facts only; a cached
closed graph cannot authenticate host callbacks or grant ownership to public
reentrant inputs. This stop does not itself falsify the exact plan-reuse cache.

Contract correction: the executed preimport BigInt witness is outside the
already published standard-intrinsics-at-initialization contract
(docs/BEND-IN-BEND-PERFORMANCE.md405–416, pre-Phase42 commit8582de7). Its exact
values/events remain valid boundary evidence, but the earlier blanket stop
and reversal recommendation are superseded. Matched-set exploration resumes
under the existing contract; supported postimport controls remain necessary.
Nat.add candidate02 is an isolated inert metadata proposal preserving original
checkedNat bounds/errors and ordinary G calls, not new preimport trust.
