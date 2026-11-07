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

## Native source08 certificate and cost-recovery review

The acquired `owned-native-n1-08` receipt binds checked source
`8536e598ee618e401fafed82e9e75f0d32e13c697a13ddbd5f2de23639e6c3c6`
to native image
`a634d2405acee15369b050f9b931201d0662d3bae085a32989e825b29791e85a`.
Acquisition took 201.615 s using the installed Phase170 producer. This review
read existing artifacts only; it did not execute the image or qualify it.

**The ordinary File/IO compiler is admitted by the new extra certificate.** The
important argument is the actual control flow, rather than trusting a source
name whitelist:

1. The sole maintained caller of `p168_catalogued` is `p168_request_mode` in
   `back/qbe/early-observers.bend`. Frozen source08 retains that call structure
   at lines 67157–67179. It first requires `p167ob_permission(request)`.
2. `p167ob_permission` tries `ns_definitions`, otherwise calls
   `p118i_permission`, which is exactly
   `p118ns_effect_definitions(True{}, book, names)`.
3. `ns_definitions` permits only three foreign names: IO.args, IO.print, IO.now.
   The real compiler has reachable File operations, so that first branch is
   false. Reaching the new catalogue hook therefore means the exact second
   certificate already returned true for the same immutable book and names.
4. The existing source08 emitted QBE effect table contains exactly File.write,
   IO.print, File.close, File.read, File.size, File.open, IO.now and IO.args.
   No byte-file or NativeHost provider is used by this executable. The acquired
   QBE also contains 132 private `$p118borrow.*` worker definitions, corroborating
   actual permission-enabled lowering. A lexical source check found no rewrite
   syntax outside comments/quoted strings; this is supporting evidence, not a
   substitute for the actual admission control flow.

Thus `p173op_prepared` repeats a guaranteed-successful whole-body certificate scan
on this full compiler request. It cannot silently reject this particular request
unless the existing internal contract is violated. Constructor-summary refusal
or zero useful site coverage remains a different possibility; this argument does
not establish the number of rewritten owners.

### Do not generalize the implication to every admitted request

`ns_definitions => p118ns_effect_definitions` is not an established invariant.
In particular, `ns_term` strips `Ann` and does not traverse its type, whereas
`no_effect_terms` traverses all children and refuses any `Rwt`. A rewrite inside
an erased annotation can distinguish the two syntactic predicates. The scalar
foreign check also lacks the second predicate's explicit filled-Foreign check.
Checked request/Base assumptions may eliminate some examples, but no general
implication proof was found. A fabricated-book control alone would not prove a
counterexample is reachable through the public checked path either.

Consequently deleting the second predicate solely because
`p167ob_permission=True` would silently widen the experiment's existing scope.

### Minimal exact certificate reuse

If the additional scan has material measured cost, change the optional
experiment's permission plumbing, not the predicate or foreign allowlist:

| Original scalar predicate A | Existing observer predicate B | Existing route | Rewrite permission |
| --- | --- | --- | --- |
| false | false | Existing permission error | Not reached |
| false | true | Catalogue | Pass this already-computed true certificate |
| true | false | Catalogue | Retain original prepared bodies |
| true | true | Catalogue | Apply optional rewrite |

At `p168_request_mode`, compute the exact observer result once when needed and
pass it immediately to a private catalogue/preparation continuation. The
continuation must receive the same source, book and names, call original
`p112s_prepare` exactly once, and retain every existing error/context/freshness
check. For A=true, B must still be computed once for this optional rewrite; for
A=false the preceding route check already computed B, so reuse it. Keep the
legacy catalogue signature as a conservative wrapper if raw internal callers
remain; never synthesize permission from a source marker or mode bit.

The maintained public route is `p169np_plan` → runtime admission →
`p168_request_mode` → catalogue. A direct internal test call that bypasses it
must supply the same documented checked/runtime preconditions. No frozen08 file
or production gate was changed during this review.

Required bounded checks for a cost-only revision: all four truth-table paths
with unchanged errors/fallback; identical source08 prepared outputs/QBE; ordinary
IO/File acceptance; unknown/unfilled foreign and active rewrite refusal; an
annotation distinction control so A alone cannot grant B; unchanged static
preparation invocation and exact field/ownership controls. Use counters for
certificate invocation only in a diagnostic build, then clean timing. Do not
spend another full image merely to test this plumbing.

### Integration merit and stage distinction

The extracted automatic pass is 54,350 bytes/2,035 lines, with 104 definitions,
103 forward laws and nine data types. Source assembly adds 217 declarations in
total including the external prelude contract; these laws are callable type
contracts, not 103 mathematical equivalence proofs. The complete source grows
from 3,150,535 to 3,205,249 bytes (54,714 bytes, about 1.74%). The two manual
consuming modules plus the layout helper contract are 1,873 bytes/37 lines and
mostly replace existing functions.

The automatic result has real generality evidence: retained paired measurements
show runtime ratios 0.88948 for pattern traversal, 0.81148 for layout traversal,
and 0.50051 for the unrelated wider packet computation. The manual pattern
ratio is 0.79861 and the earlier manual layout screen is about 0.7922. These
are individual workload results, not additive full-compiler speedups. The
automatic rule starts later than the manual pattern rewrite and pays whole-body
analysis overhead on every compiled program.

N1-08 was generated by the installed producer **without this new optimization**.
Its compiler executable contains the new pass but has not itself acquired the
pass's generated-code benefits. N1 request timing first measures added analysis
and resulting product construction; compiler execution improvements appear only
when a generated successor is run. Conversely, an acquired successor cannot
justify installation without matched complete-request and correctness gates.

For the immediate cold-build objective, the manual changes have the smaller
complexity and analysis-cost burden. Keep the automatic implementation
experimental until its net successor execution benefit and general workload
coverage justify the new persistent compiler work. The packet transfer makes it
a useful optimization capability; it does not by itself justify adding two
thousand lines to the default research compiler or predict progress to 100 s.
