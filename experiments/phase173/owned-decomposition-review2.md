# Early owned decomposition: independent source review

Scope: bounded source review by `ambitious_challenge`; no compiler executions,
production changes, or new performance measurements. Reviewed at repository
HEAD `5a6baaa00895b1a6be054e0715245f44aad99883`. Relevant source identities:

| File under `selfhost/tests/phase173/` | SHA-256 |
| --- | --- |
| `owned-decomposition.bend` | `24d038215c1f521e2ed1dd82259f5b1287029d73702af6b7c67b89b7bfb6e5fb` |
| `owned-decomposition-summary.bend` | `090b6afa4b9bbe1a1b62cb02e27f774e28cec41952168f839f03155ccb94b4cc` |
| `owned-decomposition-entry.bend` | `a07b116272feb56059e53980c662345be9ca76f6826cf7776fe9cb55b4a0c40a` |

This supplements `owned-decomposition-audit.md`; it does not supersede its
admission obligations or turn its prepared controls into passing tests.

## Decision

No additional semantic blocker was found within the explicitly checked,
bounded, pure-request scope. The prototype is appropriate for a cheap native
experiment on the actual pattern-substitution workload and unrelated packet
workload. It is **not yet a candidate for a full compiler rebuild**.

The decisive scope limitation is `p173oa_pure_names`: any reachable Foreign,
Absent, or unknown definition refuses the entire request. The real File/IO
compiler image therefore receives no rewrites. The current transformation's
direct full-self-build improvement ceiling is **0%**, before charging its gate
cost. A pure-kernel win cannot establish a positive whole-compiler prediction.
This restriction is deliberate and documented, not a newly discovered defect.

## Semantic boundaries checked

- **Eager fallback:** unchanged or identity variants retain the complete original
  expression, renamed to the fresh fallback-root binder. They still execute the
  original getter, worker, and setter. No ignored worker is silently deleted.
  `nq_layout_subst` performs structural variable substitution here; it does not
  beta-reduce unrelated applications during renaming.
- **Constructor coverage:** the selected branches need not cover every possible
  constructor, because all other variants enter that original-expression
  fallback. Getter/setter summaries must nevertheless agree on ordered branch
  identity, field count and mask. The bounded summary checker is an admission
  algorithm, not a theorem that arbitrary unsafe helpers are exhaustive.
- **Root occurrences:** the root is a variable; the worker is a saturated static
  reference; other arguments are already evaluated variables or prepared closed
  literals. The same root ID in another argument is refused. An alias under a
  different ID is permitted and must retain normal shared ownership. A root used
  after this region remains live because ordinary ownership/liveness lowering
  runs after the shared prepared-body rewrite. No uniqueness claim is made.
- **Reconstruction:** changed branches retain the exact constructor, unchanged
  field order, and a single strict worker result binding. Field lambdas use
  quantity 2, allowing a field to be both passed to the worker and retained in
  another result field. This may require sharing and limit the gain, but it is
  preferable to an unsound forced-unique fast path. Identity branches remain
  untouched fallback computations.
- **Freshness:** global fresh IDs are threaded across bodies; candidate and
  helper IDs must precede the fresh range. Sequential substitution therefore
  cannot accidentally rewrite a newly introduced field variable. At most eight
  rows of sixteen fields plus one result per row fit the local reserved margin.
  The existing `<4e9` convention does not prove separation from arbitrarily many
  later descending native temporaries. Keep the existing bounded qualification
  claim; do not advertise a general fresh-allocator proof.
- **Preparation and trust:** both direct and generic paths read changed
  `NativeStaticBody` facts. Checked definitions, cached erased bodies, static
  image and constructor facts are retained. The unchanged final verifier checks
  the resulting backend representation; it does not establish source-semantic
  equivalence of this new rewrite. That remains a new optimizer trust boundary.

The argument that `NStatic` and `NWord` are already evaluated depends on their
normal checked/prepared producer contract. The syntactic atom recognizer is not
a validator for arbitrary fabricated malformed KTerm payloads.

## Performance traps

1. **The first rewrite starts too late to equal the manual ceiling.** It remains
   inside the existing branch and does not consume the record before preceding
   predicate/getter calls. The manually consuming `f_pattern_sub` result cannot
   be assigned to this automatic transformation without measurement.
2. **No-hit traversal still allocates.** `p173oa_walk` traverses prepared bodies,
   creates result records and new child lists, and then returns the original
   term when the hit count is zero. Its `4096` fuel is a depth bound, not a total
   node/work budget. A broad input can be expensive while staying well within
   that bound.
3. **Original preparation is still fully paid.** The entry hook executes the
   existing static-preparation algorithm first. This experiment changes execution
   ownership lifetimes; it does not by itself eliminate original preparation,
   the helper definitions, or whole stages of compilation.
4. **Repeated summaries are bounded work, not repeated erasure.** On the actual
   prepared request, `nc_definition` reads cached `NativeErasedBody` facts. It
   does not erase and compact each helper again. Remaining repeated work includes
   indexed lookups, structural summaries and constructor checks. Measure before
   adding a cache; no existing elapsed attribution makes it the main bottleneck.
5. **Nested application scans may repeat.** Recomputing head/arguments while
   visiting each application node can revisit portions of long application
   spines. This is a compile-cost risk, not evidence of a measured regression.

## Cheapest decisive checks

The root's planned source checks and 16 structural controls remain prerequisites.
Then inspect actual checked/prepared bodies to confirm selected owners and rows,
and compare one complete-value oracle plus bounded native timing on each of the
two workloads. Inspect ownership traffic as well as time: a positive case should
remove root retention across the child call, not merely move reconstruction.
Include a retained-root alias and an ignored-result variant in the complete-value
control; unchanged final output alone does not test eager worker retention.

Charge the additional pass on the same workload with zero admitted sites. This
cheap negative case bounds the practical cost of the whole-body walk. Preserve
the already known negative transfer: `nq_layout_subst` uses an eight-argument
setter, outside the initial two-argument setter rule.

If pure cases pass and improve, the next enabling experiment is a **local,
transitively authenticated effect scope** allowing a pure owned computation
inside an otherwise File/IO request. Do not simply remove the whole-request gate.
First show the same rewrite and oracle inside an enclosing request with unrelated
effects, retaining the original fallback and exact effect order. Only then does
counting real compiler sites become relevant to whole-build benefit.

Existing Phase171 stage evidence supplies upper envelopes, not attribution to
these sites. For example, the 29.545 s parse/load interval is about 17.1% of its
172.745 s diagnostic request. Even deleting that entire interval would not imply
a comparable gain on the separate clean build measurement, and the proposed
rewrite only touches some computations within and beyond those stages. Do not
multiply sampled context counts by stage time or apply a 20% extracted-kernel
win to the complete compiler. The current zero-coverage gate is already a
sufficient cheap falsifier against a premature full-image campaign.

## Follow-up: is whole-request purity actually necessary?

The preceding ceiling describes the implementation above, not a fundamental
requirement of the transformation. After checking the actual fixed-QBE ABI,
the answer is **no, within that existing admitted runtime contract**. This is a
source argument and an experimental admission recommendation, not a passing
effect-control result. No gate was edited by this reviewer.

The relevant pre-existing boundaries are:

- `selfhost/src/check/kernel.bend:1212` requires foreign definitions to return
  Base IO directly. Ordinary evaluation constructs an IO request; handler
  execution belongs to the IO interpreter. Upstream enforces the same condition
  in `bend2/bend.ts:3871`.
- `selfhost/src/back/qbe/lower.bend:699` defines the fixed effect catalogue.
  `stream-emission.bend:p134e_plan` and
  `prepared-context.bend:p128raw_emit_request` call
  `p111_runtime_admission` before the ordinary lowering route. Unknown foreign
  providers are refused. Keep these gates and source/runtime authentication.
- `selfhost/src/runtime/qbe/README.md` specifies one Bend heap mutator and no
  arbitrary foreign embedding. Supported providers are compiled into this
  runtime; the code does not load an arbitrary source-supplied C handler into
  the admitted QBE executable.
- `runtime/qbe/runtime.c:970` implements recursive reclamation in `term_drop`;
  it has no user destructor/finalizer callback. The owned root is a checked
  ordinary Data constructor. The native host providers around lines 3625–3785
  read String contents into host buffers and perform file/path operations;
  their results do not expose immutable constructor addresses or refcounts.

For a selected constructor `C(fields)`, the original evaluation obtains
`getter(C(fields))`, runs the worker exactly once with that value and the same
already evaluated other arguments, then applies the setter. The rewrite binds
the fields with an ordinary match, runs that identical worker application in a
strict let, and constructs the same `C` with exactly the prescribed field
replacement. The only work moved across the worker consists of opening the
immutable parent and ownership bookkeeping for the parent/fields. No supported
IO action is removed, duplicated, or reordered by those structural operations.

An old replaced field not used by the getter may now be reclaimed before the
worker. A selected field passed to the worker may no longer need an otherwise
artificial retain. Unchanged fields remain live until reconstruction. These
changes are precisely the optimization and are not hidden assumptions of equal
allocation, wrapper identity, or refcount histories. As with existing ownership
optimizations, exact heap exhaustion/refcount-overflow thresholds and timestamps
are not invariant performance observations.

If an external alias owns the parent, an ordinary shared take preserves its
contents and transfers additional field ownership correctly. If another
argument aliases a field or the parent under a distinct variable ID, its ordinary
owned reference stays live; the pass does not create a raw borrow. The worker
can return or publish an allowed alias without the rewrite freeing that live
value. A subsequent ordinary observer receives equal values, with the same
source-level alias/handle semantics. Identity/no-replacement/unrecognized cases
run the exact original expression, so even a diverging or failing ignored worker
is retained. A worker failure in a changed branch still occurs before final
reconstruction.

Consequently a transitive worker-purity analysis is unnecessary for this bounded
rule under the qualified QBE runtime. Removing only the whole-request pure gate
can admit pure computations inside the File/IO compiler without changing the
allowed effect set. Source checking, exact helper summaries, atom restrictions,
fallback, ownership lowering, and final verification must remain.

There are two limits to this conclusion:

1. **Internal API scope:** `p112s_prepare` itself does not carry an authenticated
   runtime certificate. A raw caller may bypass the public emission gate. Scope
   the experimental rewrite to already-admitted QBE requests, or explicitly
   require that precondition at this internal entry. Do not silently reuse this
   argument for the mature C backend with arbitrary imported C.
2. **Custom foreign identity:** C handlers receive `Env` and `Term` and can
   inspect runtime representation. A general claim covering arbitrary custom
   handlers would need a representation-parametric foreign contract or an
   appropriate permission gate. The existing fixed-QBE restriction is what makes
   that unnecessary here. The older `no_effect_definitions` observer permission
   is an alternative conservative certificate, but its whitelist is narrower
   than QBE's current NativeHost/byte-file catalogue and should not be conflated
   with the actual QBE runtime gate.

The cheapest new qualification is a small supported IO request enclosing the
same admitted record composition: compare ordered output, complete final record,
retained alias, and unchanged fallback. Also preserve unknown-provider refusal
at the public emission boundary. This is a sharper experiment than building a
per-function/higher-order purity framework or acquiring the complete compiler
before any generated-code coverage is known.
