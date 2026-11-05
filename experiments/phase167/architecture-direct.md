# Phase167: direct workers with demand-generated scheduler representations

Source audit and prototype preparation at `022a0f05`; no compiler or generated
program was executed by this lane. Phase152 remains qualified. This describes
an experimental compiler route, not a promotion or a predicted tenfold result. The accompanying
[cost model](cost-and-falsification.md) fixes the complete cold-build boundary.

## What the existing implementation still constructs

The selected backend forks after common static/body preparation:
`back/qbe/prepared-context.bend:p128raw_prepared` constructs both
`p111_compile_defs` and `p113pl_candidates`. The prepared `NativeStaticBody`
already avoids redoing the source compaction; introducing that cache again would
not be new work elimination.

The generic side is not merely an adapter list.
`back/qbe/lower.bend:p111_entry` constructs a source value/factory, and
`p111_extend` additionally constructs the positive-arity worker and its
continuations. `p111_let_cut` implements real suspended non-tail computation.
Those continuations are necessary for the retained scheduler execution model;
counting all of them as dead duplicates would be wrong.

Phase164 already moves candidate admission before generic worker construction.
However, `hybrid-lower.bend:p164l_defs` still visits every requested name, and
`p164l_adapter` constructs the real factory for every admitted positive-arity
owner. It retains original fallback families, raw candidates and the complete
late optimizer. The final renderer still builds the full segment index and
region registry:

- `back/qbe/stream-emission.bend:p134e_prepare` calls `p112f_index` and
  `p112c_index_with` over all retained segments.
- `p134e_registered` creates cursors over private functions, legacy entries and
  public segments; `p134e_next` emits each population.
- `back/qbe/helper-resume.bend:p124r_public` can replace a public generic body
  with a direct adapter. That does not prove its remaining continuation family
  unused: genuine factories, closures, static references and generic callers
  may still require identities in that family.

Phase164's same-source complete acquisition was 201.931→201.271 seconds. Its
2,096 final direct workers were unchanged; factories and ordinary workers were
unchanged, while continuations fell by 10.44%. This is evidence against simply
repeating generic-body omission while preserving all downstream work. It is
not evidence that a demand-based representation has already been tested.

## Smallest coherent new compiler route

Use `P113DFunction` as the canonical ordinary-call body for admitted owners.
Generate an actual `N111Segment` only when a scheduled identity is demanded.
The intended registry-free variant emits remaining generic segments directly.
The first checked emitter does **not** yet achieve that: its reused
`p111q_segment_chunks` delegates to `p112c_segment_chunks` and then
`p112c_emit_indexed`/`p112c_index_with`. The independent audit found this hidden
registry invocation after the first measured snapshot. Preserve that snapshot
as the demand-lowered/inherited-region treatment. A separate direct recursion
over `p111q_segment` is required to test actual registry removal; do not attribute
the first result to elimination of that category.

The prepared lowering interface is:

```
p167l_request(request: NR_Request, mode: U32) -> P167Lowered
P167Lowered{program: P113DProgram, adapters: KDef,
            error: String, stats: List<U32>}
```

The semantic plan carries the real prepared constructor/static catalogue,
private direct functions, actual scheduled segments, exact adapter obligations,
readback/effect metadata, and a diagnostic. A fresh final identity map derives
from the actual scheduled segments. It carries no fake generic body or
producer-supplied verification certificate.

### Algorithm

1. Retain the checked-request precondition and existing common preparation:
   constructor catalogue, `p112s_prepare`, `p113pl_candidates`,
   `p126sc_candidates`, then `p113d_passes`. Retaining all admitted workers is a
   safe initial overapproximation; demand-pruning their dependency graph can be
   a separate refinement. Set their public flag to false, as in
   `p163d_private`: this removes only the claim of a scheduler wrapper, not the
   direct-body verification obligations.
2. Build an authenticated source-identity catalogue from each actual request
   name. Its factory identity is `nc_ref_name(book,name)`; its boxed worker
   identity is `p113d_public(book,name)`; its arity is `nd_arity(book,name)`.
   Do not decode source names by stripping symbol prefixes. Zero-arity entries
   share their representation; distinct source aliases or duplicate identities
   still require the existing uniqueness checks.
3. Seed scheduler demand with the real entry identity and every
   `N111FuncId` in retained direct bodies. Traverse every value
   position, nested branch and argument list, not only `rt_jump` statements.
   A function ID passed into closure construction is a dependency even before
   an apply site is known. The current `P112SWord` has only Raw/Packed/Box
   variants; it cannot contain a scheduled function ID. This prototype retains
   all prepared static nodes and their independent constructor/image checking.
4. Pop an unseen scheduled identity. An admitted worker gets the exact real
   Phase164 register-load/direct-call/return adapter. An admitted factory gets
   `p164l_factory` and its actual generated continuations. An unadmitted owner
   gets its unchanged complete `p111_entry` family. Mark all newly emitted
   identities present before scanning their bodies for further demands, so a
   locally generated continuation is not mistaken for a source declaration.
   This intentionally retains the complete generic fallback family at first;
   splitting arbitrary families is unnecessary to test removal of undemanded
   admitted factories and the region registry.
5. Continue until the queue is empty. Unknown demanded identities, conflicting
   source mappings, lowering errors and malformed static references refuse.
   Do not silently synthesize a stub or guess a source owner. Fresh counters
   are threaded through only actual lowering calls; all final numeric IDs are
   assigned after completion, consistently for bodies, static image and tables.
6. Independently validate the complete final representation, then emit direct
   functions, genuine generic segments and actual tables. Existing
   `p113e_private`, `p111q_segment`, `p111q_tables`/`p112s_tables` and table/data
   emission are reusable. Do not call `p134e_prepare`, `p112c_index_with` or the
   old region registry through a convenience wrapper. In particular, avoid
   `p111q_segment_chunks`: despite its name it invokes the registry. The first bounded emitter
   materializes chunks; a full-source pilot needs a small separate cursor to
   avoid materializing a potentially large result. That is an explicit prototype
   limitation, not a claimed improvement over the maintained streaming emitter.

The first lowering is in `selfhost/tests/phase167/demand-{model,lower}.bend`,
reusing existing admission, static preparation and source catalogue operations.
Its statistics are `[sourceNames,directFunctions,fallbackFamilies,
admittedFactories,adapters,finalSegments,queuedUniqueIdentities]`. Mode 0 keeps
raw admitted private workers; mode 1 applies the maintained bounded inliner
and request-derived cold-constructor analysis before demand construction.
The separate verifier/emitter lane owns `demand-{verify,emit,controls}.bend`.
The host only transports requests, chunks and receipts.

The additive `demand-live.bend` exposes `p167live_plan(mode,plan)` and changes
only the checked live-register capability. It intentionally preserves the first
emitter's inherited segment-emission path, including its registry invocation, so
that this control does not conflate live transport with registry removal.
Eligibility is the Phase164 predicate over all actual direct functions and
nonadapter generic bodies; the unchanged final gate first authenticates every
excluded adapter. No eligibility Bool replaces final structural verification.

## The independent final boundary

Reuse the original actual-header and constructor validators, original
`p111v_segment` on every genuine generic body, static-image checking with the
actual identity map, and `p113e_functions` on the ordered final private workers.
Use exact adapter-shape/source-arity/worker-signature obligations for adapters;
the ordinary generic verifier does not authorize their private direct calls.
Require every adapter obligation to have its final worker. Checking only the
functions that happen to remain accepts a missing-worker bug.

`verify-segments.bend:p111v_target` and `p111v_counted_call` already require
actual `N111FuncId` values with appropriate jump/closure/frame arities. This
supports explicit dependency collection and consistent final remapping. It
does not permit replacing an unknown scheduler identity with an arbitrary
integer. Readback, effects and main must come from the same real request.

Private direct flags avoid claiming nonexistent public scheduled originals.
They do not grant permission for direct-to-generic calls. Existing admission
accepts a dependency only after the callee is admitted; the direct whitelist
still excludes scheduler transitions. A direct worker may construct a closure
referring to a genuinely retained factory, provided the final actual-ID check
passes. No private function may call the scheduler and then pretend to return
an ordinary value.

Initially keep array/live capabilities conservative and explicit. Reusing
a capability table transform requires its corresponding final body checks,
not merely copying a bit from an old certificate. Compiler source checking,
structural backend verification and finite runtime equivalence remain distinct
from a kernel proof of the compiler.

## Biggest obstruction and honest limits

The immediate implementation risk is distinguishing source factories, boxed
workers and generated continuations. Source reachability is not representation
demand. An owner needed as an ordinary direct callee may need no scheduled
identity; the same owner captured as a value may need a real factory and its
closure entries. Keeping fallback families intact bounds this problem.

The larger architectural obstruction is still non-tail recursion and calls to
unadmitted dependencies. `direct-lower.bend:p113d_call` rejects non-tail self
calls; `p113d_deps` and the bounded ordered passes require an admitted closure.
Existing tail-SCC handling does not supply general native recursion or explicit
resumable frames. Compiler owners such as `p111_lower`, `p113k_function`,
`p113k_put`, `p111v_assign`, `index_set` and `p111q_stmt` therefore still expose
generic work. The new route must retain real fallback rather than weaken the
admission rule. A single control graph with explicit resumable frames is the
next larger design, described in [architecture alternatives](architecture-alternatives.md).

Bypassing late borrowed/product/region transforms may make the produced compiler
slower even if acquisition is cheaper. Both prototype modes are boxed-worker
policies; mode 1 applies the independently checked bounded inlining/scalar and
source-derived cold transforms before demand collection, but those do not
recreate all current borrowed optimizations. Do not identify a
policy change's speedup solely with removal of generic construction.

## Complete workload and falsification order

Use the existing closed reverse/lookup sources only to prove the zero-fallback
case and reproduce the already successful Phase163 boundary. They cannot prove
the new mixed architecture. The real Map workload with its original IO main is
a useful complete mixed request, including closures and generic fallback.
For an actual compiler-owner slice, retain `p113k_function` operating on the
captured real compiler bodies from Phase154/148, with the complete transformed
body and original verifier/output consumed. It combines generic fact writes
and recursive reconstruction with already admitted lookup/equality reads.
Restore authenticated archived inputs when needed rather than substitute a
synthetic tiny fact table.

Before timing, mutate a demanded factory, a continuation target, a static box offset,
an adapter signature and a required direct worker to demonstrate refusal.
Compare complete values/diagnostics, including an escaping closure and a
non-tail-recursive fallback. Count produced direct bodies, factories, generic
segments/continuations and emitted bytes, and verify the old registry is never
called on the explicit plain-emission variant. Charge demand scanning, all verification, rendering,
teardown and machine construction in their proper clocks.

Then measure both acquisition and execution of the generated compiler on the
same real input. Source-to-QBE savings alone cannot establish the cold-build
goal. The current frontend and required candidate work leave a substantial
floor under an unchanged executor; tenfold improvement would also require the
generated compiler to execute the remaining work much faster. Stop or change
architecture if the prototype merely shifts construction into slower generic
runtime execution.

## Final admission-reason diagnostic

`selfhost/tests/phase167/demand-reasons.bend:p167why_plan` returns structured
`P167WhyRow` records after the exact raw-mode constructor/static preparation,
candidate production and bounded dependency admission. `source` rows preserve
every requested name and its exact worker identity; `candidate` rows preserve
every original raw error and dependency list; `admitted` rows preserve the final
selected worker set, including synthesized SCC workers. The `missing` field is
the subset of raw callees absent from that selected set. An absent callee is a
reported fact, not a proof that it is the only reason for refusal. Raw errors,
unsupported recursion and the 32-round policy remain distinct causes.

Here `admitted` describes candidate dependency selection, not success of the
independent final-program verifier. Public flags are captured before Phase167
marks all workers private. The diagnostic creates no executable, changes no
body policy, and must run outside clean timing because it retains original raw
candidate evidence alongside the admitted set.
