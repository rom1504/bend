# Private finite-prefix source review

This review inspected the new `finite.bend` admission/emission, its dispatch
from `emit.bend` and `u32.bend`, the `Bool.xor` addition to `JPure`, compiler module
ordering and runtime native capture. It ran no compiler, test or benchmark.
The reviewer did not author this optimizer patch. Checked controls and measured
compilation cost remain promotion requirements.

The first inspected finite source had SHA-256
`4f86cd2a6e76c93acb6c7575c24928c37d0aaa2e4a9ca39ef4146e2b5766cf8d`.
Two findings were sent to root and the implementation owner before a build.
The owner preserved that unbuilt proposal and produced a successor with SHA-256
`695df2e03228e0ac49d3118c57a5d98ce4ca8c4debd4ca9e99084fed19bbbb0c`.
The corrections described below were inspected in that successor. The final
follow-up below additionally binds the review to the frozen checked02 source;
the intermediate findings remain visible with their original scope.

## Blocking concern corrected in the successor: nested forcing

The first root wrapper called `force(generic_tail_result)` on every admitted
exact entry, even when a proof was already active. `JPure` permits recursive
graphs. A scalar lambda root can return a tail call to a Nat matcher helper,
which returns to the root; a finite selector elsewhere in that graph makes the
root useful. Reentering the wrapper would nest JavaScript `force` invocations
instead of returning the tail message to the existing trampoline. This could
turn a bounded-stack tail cycle into a stack overflow.

The successor requires **`regionProof===null`** before opening this new root
scope and forcing its complete result. Nested calls use the original generic
return path, while the existing outer force loop keeps the proof active.
Private finite calls can still use that active proof. This addresses the
structural cause without adding an SCC analysis or a second continuation system.

The implementation owner added self/mutual root→matcher→root fixtures and plans
30,000-step controls with nonzero terminal finite-selector entry counts. Those
actual emitted controls must pass; the source review alone is not an executed
counterexample or proof of stack safety for every program.

## Demand and representation argument

The new call branch evaluates every original actual argument, left to right,
as IIFE arguments before introducing callee-local bindings. This differs from
generic staged application, which can match an earlier argument before
evaluating a later one. The justification is stronger than purity alone:

1. Entry requires an active complete scalar-root proof covering the callee.
   Caller-provided trees and function values cannot enter through that scalar
   boundary. The complete reachable source graph excludes foreign functions,
   arrays, IO and function-valued fields/results.
2. Ordinary non-tail argument emission forces calls and constructor fields;
   values passed onward through variables and matched fields therefore come
   from fully materialized private values. Constructor generation retains the
   original tagged representation, and direct field reads do not mutate it.
3. The finite selector's prefix contains only original typed lambdas and
   matches. Its separate `JPure` prefix validation checks constructor coverage,
   variable types and full branch telescopes. The additional finite check
   refuses helper calls, recursive calls, lets and effectful/native constructor
   work in leaves. Native Bool construction is a deliberate inert exception.
4. Thus work crossed by evaluating a later argument earlier consists of total
   private tag/field inspection and transient generic descriptor construction.
   It cannot perform a user callback or an observable error. A later actual
   argument may itself fail; prefix totality is why moving it across the prefix
   does not reorder two observable failures.
5. Captured `$pN` arguments are outside the callee's IIFE binding scope. Field
   expressions refer back to those captured values, and the trusted core's
   globally unique binder IDs prevent caller/callee capture. Aliased child
   references remain the same references.

This is broader than the design's suggested initial restriction to syntactically
inert actual arguments. The implementation has no such argument-shape filter;
its acceptance depends on the ownership/materialization argument above.
Actual checked controls should include throwing later arguments, multiple
input matches, nested fields, aliases and live dependency mutations, rather
than treating the earlier saved-JavaScript prototype as that evidence.

`j_finite_prefix` alone accepts `Efq` and is not a completeness proof. The
mandatory independent `j_pure_prefix` check is what permits absurd elimination
only after all constructors are removed. It also permits a total default lambda;
the current code is not limited to explicit constructor permutations ending in
`Efq`. That broader safe shape should be described accurately in final docs.

## Host reentry and public boundaries

The new root uses the existing exact-entry token, scalar input predicates,
complete dependency snapshots, host protocol guard and `finally` restoration.
The finite call checks active coverage before skipping the public descriptor;
outside the scope it emits the original generic expression, retaining partial,
oversaturated and raw public stages.

`Bool.xor` remains the ordinary native ABI. Its proof admission checks native
definition metadata and the complete Bool→Bool→Bool telescope; the runtime now
captures that descriptor so replacement/accessor mutation can reject the root.
Its implementation uses strict inequality on canonical private booleans and
does not introduce a host coercion callback. Other prototype and arithmetic
hooks remain guarded. Existing `bad` suspends the proof before invoking mutable
Error hooks; exceptions then unwind through the root's `finally`.

No additional host-reentry blocker was found in this source inspection. This
depends on the existing host guard and whole-graph proof; it does not justify
generalizing the direct branch to arbitrary public trees or foreign callbacks.
Actual controls must visibly execute their mutation/reentry hooks and refuse
private entry; zero-count witnesses would be vacuous.

## Compilation-cost risks still requiring measurement

The first patch eagerly looked up `nm(spine)` even for an absent/non-name call
spine. The successor moves that lookup inside a `kc` Call-tag gate, avoiding an
extra failed linear book lookup for ordinary higher-order applications.

Additional repeated work remains in the inspected successor:

- Each known call site reruns finite readiness: body bounds/match discovery,
  closed type/signature checks, finite-prefix analysis and independent typed
  prefix validation. The result and emitted plan are not memoized per definition.
- Each candidate scalar fallback root computes a complete pure graph before
  looking for a useful selector. That search can repeat the same readiness work
  on many reachable definitions.
- Both the generic fallback and private inline prefix are emitted at each
  admitted call. Local AST/depth budgets do not bound aggregate generated size
  or repeated work across the whole book.
- **Bend `&&` is not a short-circuit control construct here.** The existing
  checked compiler API emits ordinary eager `$Bool$and$(left,right)` calls.
  Therefore the conjunction of cheap shape/arity/budget predicates with expensive
  readiness checks does not skip the latter when an earlier predicate is false.
  Arity mismatch combined with readiness has the same issue. Use nested `kc`
  gates if cheap-to-expensive screening is intended.
- `j_finite_match` recursively visits all children without its own fuel,
  including annotation types. The preceding executable-node bound deliberately
  ignores annotation-type children, so those two traversals do not currently
  share the advertised bound. Stripping annotations in the match probe would
  align the traversals; an explicit bounded probe is another option.

The eager-conjunction and annotation-traversal observations were sent to root
and the implementation owner. They are iteration-cost/resource concerns, not
measured regressions. Final normal checked-request timings and generated-module
sizes must decide admission. A later cached plan should retain identity and
budget/refusal behavior rather than adding a global cross-book cache.

No canonical optimizer source or consumed experimental tool was edited by this
reviewer. The root must bind final checked controls and performance evidence to
the ultimately selected source hash.

## Follow-up: frozen checked02 source

The reviewer subsequently inspected
`selfhost/build/phase37/checked02/snapshot/src/back/js/finite.bend`, SHA-256
`d79d569471ef48816f700b23c6d662eda3c53d3992fe1c4b785fefeb145f0dbb`, and confirmed
the canonical finite source has those same bytes. The attempt manifest hash is
`1aaa83399ba7a61e1ff0526f88062289d0dda556ff905d0c3ae72035a991aed4`.
This is a source review of that snapshot, not an execution by the reviewer.

The earlier compilation-screening findings are corrected in this version:

- `j_finite_ready` separates cheap definition/arity screening, executable-node
  bounds, match discovery, type eligibility, finite-prefix checks and independent
  typed-prefix validation with nested `kc` branches. A failed earlier screen
  therefore avoids the later work. `j_finite_named` similarly tests exact arity
  before readiness, and root bounds now precede whole-graph analysis.
- Match discovery strips annotations before traversing executable children. The
  earlier `j_u32_bounded` check already counts each annotation but does not visit
  its type child; the new match traversal no longer escapes that bound by
  visiting annotation-type subtrees. Its sibling search also stops at a found
  match instead of evaluating both sides of a Bool conjunction.
- `j_finite_emit` matches its argument list before defining branch-local
  `body`/`head` values. The empty-argument branch uses its own stripped term and
  normalized type; the nonempty branch establishes them once where required.
  This addresses the consumed-binder source-check failure without changing the
  emitted argument order, prefix semantics or active-proof condition.

The nested-force correction remains: only a root reached with
`regionProof===null` opens this wrapper's proof and owns its force loop. The
semantic ownership/prefix argument and remaining repeated-readiness/aggregate
code-size risks above still apply. Nested screening makes those costs more
selective; it does not memoize analyses or establish a compilation speedup.

The separately authored actual finite fixture/control pair was also inspected.
Its independent arithmetic expectations, complete aliased tree, actual branch
counters, public dependency/refusal observations,30,000-step self/mutual cycles
and argument-overflow Error/reentry checks match the intended obligations. No
source-level blocker was found. Several prototype/array-hook comparisons do
not require a nonzero count; those comparisons alone cannot claim that a
particular hook ran. The final closure must bind raw control modules through
their checked emission receipts, because the control's own inputs identify
module hashes rather than directly certifying their acquisition. All actual
outcomes remain the responsibility of the root's bounded runs.

## Actual-emission fixture corrections

The root's first three fixture acquisitions exposed source issues before any
finite owner controls could run: an unannotated local constructor, an ineffective
RHS annotation, then live forward calls between safe definitions. V3's typed
local binder resolved the constructor inference. V4 retains the intended
recursive graph using explicit laws and `@unsafe` bodies, as in pinned
`tests/run/unsafe_mutual.bend`; all accumulator quantities are unchanged.
The reviewer confirmed `du(d)` records that unsafe flag independently of
`db(d)` (native) and `dx(d)` (templates). Finite/JPure admission still checks
those complete bodies rather than rejecting their unsafe flag. The root
reported all three v4 checked emissions passing.

The first actual control then failed its structural expectation for
`choice_check`. Inspection of the emitted candidate showed both `choice_check`
and `leaf_check` select the earlier scalar fold optimization. Neither opens a
finite proof on direct public calls, even though its generic expression contains
conditional finite-selector branches. This is a fixture nonvacuity failure,
not evidence that a finite branch ran or a semantic failure in either compiler.

V5 adds `leaf_scoped`: it creates a private shared tree with `finite.leaf`, passes
that tree through the same multi-tree `finite.zip` shape already admitted by
`alias_check`, and folds the result. Its independent scalar oracle is
`4 * (x + y)` modulo2^32. No generated proof scope or alternate implementation is
injected. The v2 control retains the older roots' differential/public cases,
requires real alias/argument/leaf/cycle roots and nonzero entries for all five
finite selectors, and moves mutation boundaries to those actually eligible
roots. These successor files were authored without execution by the reviewer;
their eventual passing/failing receipts must decide whether the intended paths
were exercised.

## Follow-up: checked03 profitability and host boundary

The selected successor inspected here is
`selfhost/build/phase37/checked03/snapshot/src/back/js/finite.bend`, SHA-256
`8998f43394e465ab9d3add60ca2dd432b633faca57249dc0063d4222cb4a1cf6`.
Its attempt manifest has SHA-256
`7ae878dda1b75dce1655c62d8e7238e184319da1fa04a8a12a189f37badc8f85`.
This supersedes the earlier reviewed source identity, while checked02's failed
profitability result and all its controls remain historical evidence.

The sole finite-source change from checked02 rejects a scalar-only helper
signature as sufficient justification to open a new root scope.
`j_region_signature` recognizes canonical scalar parameters and result; the
remaining helper must still pass the unchanged finite readiness and complete
pure-graph conditions. This narrows root admission without widening any type,
ownership or call-shape acceptance. It does not prevent scalar finite calls
inside an already active proof. The implementation owner traced checked02's
ray regression to repeated small scopes; the signature filter is a conservative
profitability heuristic, not a general cost model or a measured guarantee.
Clean final execution and compilation results must establish its effect.

The checked03 runtime review also inspected the shared `regionF32ToU32` body
and the minimal DataView guard. The helper body is unchanged from the final
public native implementation, and both public registration and private emission
use that same function. Existing signature/dependency/host checks gate the private
call. The additional host checks use already captured descriptor/prototype
intrinsics: they require the existing private view's original prototype, refuse
own overrides of its four conversion methods, and require those methods to
remain original data properties on the captured DataView prototype. Checking
the retained instance is necessary because a previous generic method hook may
have saved its receiver. The checks themselves do not invoke an overridden
method or getter. Replacing the global DataView constructor is not a reason to
refuse use of an already created unchanged private instance.

No source-level semantic blocker was found in these narrowed changes. Actual
mutation, retained-view, error and reentry controls must still be rebound to
checked03; passing controls from checked02 are not final-image closure.
