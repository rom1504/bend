# Bounded root-preserving observers

## Decision and evidence

Implement a general analysis experiment before promoting the saved-C rewrite.
The compiler should recognize functions that return their unchanged immutable
inputs alongside scalar observations, then keep those owned roots alive while
a private observer reads borrowed fields. The observer returns only the scalar
information. The public adapter reconstructs the original result *wrapper*,
using the original roots instead of rebuilding their contents.

The completed P69-009 campaign measured:

| Saved-C arm | Median ms | Relative to original | Relative to upstream |
| --- | ---: | ---: | ---: |
| Original compiler23 | 722 | 1.000 | 1.683 |
| Retain bit-traversal root | 488 | 0.676 | 1.138 |
| Retain comparison roots | 620 | 0.859 | 1.445 |
| Both | 390 | 0.540 | 0.909 |
| Pinned upstream | 429 | 0.594 | 1.000 |

Root executed nine output controls and 25 qualified timing intervals. Receipt:
`selfhost/build/phase69/map-borrow-diagnostic01/report.json`, SHA-256
`5e6504f77f96a770b0cf2027da7587e75d94e046da3fef685f38157fe4b9575f`.
The source-only product lane read the receipt; it ran no targets.

This is strong evidence that reconstruction and ownership traffic matter more
than temporary product boxes in this family. It is not a 46% whole-suite claim,
nor proof that a generic implementation will reproduce the whole diagnostic.
The separately measured two-word scheduler island reduced Map time only 6.2%.
The final production comparison must use the then-current combined compiler as
its baseline, because these interventions can overlap other changes.

## First general domain

Admit one or two immutable constructor roots and a small number of immediate
scalar arguments. Initially each root is a nondependent list-like ADT with a
nullary constructor and a constructor containing scalar fields plus one child
of the same instantiated type. Constructor names and function names are not
selection criteria. An unrelated user-defined list must qualify under the same
rules as a prelude list. Broader trees and arbitrary records are later work.

The first representation descriptor requires the recursive constructor to have
at least two live fields and genuine boxed storage. Reject native scalar,
array and Word-list layouts as root layouts, and reject a potentially packed
single-field recursive shell until its read representation is modeled. A
syntactically list-like ADT is insufficient without this storage check.

The result has at most two fixed constructor shells enclosing the unchanged
roots and one immediate scalar observation. The result schema comes from the
original type and actual returned syntax. Types identify candidate fields;
they do not establish that those fields contain the original inputs.

Allow exact saturated calls, sequential lets, constructor matches/builds,
immediate primitive operations and bounded helper unfolding. Every recursive
edge in the residual observer must be a self-tail edge. There can be multiple
recursive branches, but at most one recursive execution on a path. Omit a
recursive call only if it was absent in the original evaluated path; an unused
recursive result is not permission to discard the call.

Decline dependent layouts, arrays, foreign or dynamic calls, bang calls,
parallel lets, escaping closures, escaping borrowed subtrees, boxed observation
results, unsupported helper cycles and residual non-tail recursion. Refusal
keeps the ordinary compiler path. Do not add benchmark, Base-function or
source-path recognition rules.

## Prove return identity before choosing an emitter

Use a bounded symbolic walk over the existing erased/compacted `KTerm` with
explicit origins. It needs four small kinds of symbolic value:

- an original parameter;
- a field of a matched constructor at an existing origin;
- a constructor built from symbolic fields;
- an unknown computed value with a distinct identity.

Matching `C` at origin `p` binds field `i` to `Field(p,C,i)`. Building exactly
`C(Field(p,C,0), ..., Field(p,C,n-1))` simplifies to `p`, only in the branch
where the `C` match established those field facts. A matched nullary literal
similarly equals its input. Reordered, missing or changed fields fail this
rule. Unknown scalar computation does not become equal to its argument merely
because its type agrees.

Constructor facts are branch-local and include the instantiated owner,
constructor identity and field order. Equal field numbers from different
constructors, roots or type instantiations are not interchangeable facts.

A summary records result projections equal to argument origins. For example,
`result.0 = argument.0` is an equality of language values. It does not claim
that the previous implementation preserved a heap pointer. Small acyclic
helpers can be summarized or unfolded with capture-safe syntax substitution.
All argument computations remain in their original order; only constructor
wrappers and proven reconstruction disappear.

For self recursion, propose the candidate's root-projection summary, analyze
one body unfolding using that assumption for recursive returns, then check the
summary in every returning branch. The recursive transition must target a
matched child origin, and the residual computation must retain the original
recursive call. This proves the property by induction on finite successful
executions; it does not assume termination or discard divergence. Initially
reject mutual recursion rather than implement a general SCC solver.

The summary and the residual observer must be produced together or checked
against the same normalized body. A summary detached from the transform is not
enough: a correct equality proof could accompany an incorrect deletion of a
failing scalar computation.

Use a separate ordered residual statement list for scalar computations,
matches and recursive calls. Every such operation survives unless a specific
existing compiler rule proves it erasable. In particular, a `Nat` increment
can raise the runtime bound error and may not be discarded. Keep calls even
when their returned scalar is dead until a separate total/effect-free rule
exists. Eliminating a constructor allocation must not eliminate the evaluation
of its arguments.

## Normalization and reuse of existing facilities

Run candidate analysis in the native worker planning stage, after ordinary
worker admission has established available scalar callees. Keep scheduler
lowering and public result layouts unchanged. The existing relevant hooks are:

| Existing facility | Reuse |
| --- | --- |
| `nc_definition`, `nc_erase`, `nc_compact` | Obtain the same runtime body that native lowering sees. |
| `nd_head`, `nd_args`, `nd_bindings`, `nd_body` | Read saturated calls and parameter telescopes. |
| `nq_layout_type`, `nq_layout_specialize` | Bounded transparent type/layout queries. |
| `nq_layout_subst`, `nq_layout_subst_small` | Syntax-only substitution and pre-expansion size limits. |
| `nc_sequence`, `nd_beta` | Preserve ordered argument binding; substitute only evaluated variables directly. |
| `NF_Worker`, `NC_Code`, `nf_name`, `nf_bodies` | Existing private C worker envelope and polling/tail-loop conventions. |
| `nc_condition`, `nc_field_word`, `nd_scalar_word` | Existing representation tests, read expressions and scalar primitive semantics. |
| `nc_lower_to`, `nc_constructor_value` | Build the ordinary boxed public result from retained roots plus observation. |

An explicit plan carries the owner, actual parameter IDs, result-wrapper
template, preserved-root map, residual body and refusal reason. It can use
existing `KTerm` syntax for symbolic origins and residual syntax, with one
small plan record; it does not require a parallel general-purpose IR.

Representation helpers are not uniformly read-only. In particular,
`nc_field_word` calls allocating `native_word` for the U32/F32 Word-view match;
array patterns have their own storage rules, and a one-field user constructor
may use `TAG_PAK`. The observer must dispatch through its validated descriptor,
not call `nc_field_word` indiscriminately. Decline native Word-view matches and
unsupported packed fields initially. Scalar primitive calls and known immediate
Char/Nat/enum patterns can retain their existing nonallocating expressions.

Fresh IDs must be checked against all parameter/body IDs, following the
existing combinator pass's collision checks. Bound helper depth, total visits,
expanded nodes and emitted candidate count separately. Suggested first caps:
eight helper levels, 4,096 expanded nodes, two roots, two result shells and
eight live observer words. These are engineering limits, not semantic facts.
Alpha-rename every binder in each unfolded helper invocation, including nested
match/let/lambda binders. Renaming only outer parameters is insufficient: two
expansions of the same helper would otherwise conflate origins and locals.

Do not recursively inline every scalar implementation. A call with only
immediate scalar arguments may reuse an admitted scalar worker and preserve
its success/error return. A small reconstructing helper receiving borrowed
boxes must be unfolded and proved; otherwise decline. Helpers returning
products may use an existing admitted product result only when its fields are
all immediate and its result mapping is known. This avoids requiring recursive
product layouts or a scheduler result-ABI extension for the first feature.
Scalar arguments alone do not qualify a helper: its checked immediate result
mapping and full transitive admitted dependency closure must also satisfy the
observer's effect/lifetime boundary, and its success/error result is retained.

## The ownership integration choice

The current `NC_Binding` contains only `{id, word}`. `nc_prepare_env` emits
`term_sink` for dead bindings, and `nc_keep_uses` emits `term_keep` when a value
is used across a binding. `nc_destructure` consumes a constructor with
`ctr_take`. Passing borrowed words through this ordinary environment unchanged
would be incorrect. A string prefix on a C variable, fake static tag or
user-controlled book marker is not a safe ownership capability.

There are two legitimate approaches:

1. Add explicit ownership provenance to native bindings and thread it through
   every sharing, match, call, return and cleanup operation. This is the more
   general long-term borrowing pass, but it expands the integration surface.
2. For the first bounded feature, emit a read-only local worker whose entire
   environment contains borrowed cursors and immediate scalars. Admission
   forbids owned boxes, allocation and escapes inside that worker. Reuse the
   existing worker envelope, scalar operations, constructor predicates and
   result adapter. Its small emitter needs only scalar binding, borrowed match,
   branch, scalar call/return and self-tail jump.

Choose option 2 for the prototype. Its explicit narrow ownership domain makes
omitting keep/drop valid without weakening ordinary lowering. It is one
compiler mode for all qualifying observers, not an emitter per source function.
If it starts accumulating general boxed operations or many special nodes,
stop and switch to explicit binding provenance instead of duplicating the
whole backend.

The adapter retains each original owned root throughout the call. Matching a
cursor uses `term_peek`, reading through RFC and immutable static storage;
borrowed children are never consumed or dropped. Only scalar values may be
passed to unrelated worker calls. At success, original roots move into the
ordinary public wrapper exactly once each. Two aliased roots require the two
ownership references originally supplied by the caller; the pass invents none.
The wrapper root map must use every retained input exactly once. Repeated or
missing roots initially decline; any later multiplicity support needs explicit
keep/drop rules. Adapter-owned root slots are separate from the worker's
mutable cursor parameters, so a tail update never overwrites the retained root.

Residual tail recursion uses simultaneous parameter moves and the existing
`nf_again` loop; there is no new native C recursion. Keep the regular worker
entry, loop and return error policy. The diagnostic's entry check was too weak
to qualify asynchronous behavior, so it must not be copied verbatim.

## Checked boundary and fallback

Initially activate the observer only through the checked host compilation
boundary and an explicit compiler-owned permission. This can follow the
existing `nc_compile_checked` mechanism, whose trusted effect-source proof is
already separate from raw `nc_compile`. Do not infer permission from a `KDef`
name, an annotation alone, or a user-supplied boolean in the book.

The permission must establish immutable source layouts and rule out foreign
code observing or mutating these roots. Trusted effect wrappers must be
reviewed for this stronger representation-identity condition; the fact that
another optimization accepts a wrapper is not automatically sufficient.
Either extend that certificate explicitly or conservatively disable observers
when an unsupported foreign definition is reachable.

Raw compilation and the device route retain the ordinary bodies. A checked
host adapter can be selected with a compiler-generated macro, similarly to the
existing typed scalar ABI, while raw/device compilation takes the old route.
No speculative runtime scan of an arbitrary raw graph is required for this
first production boundary. The saved-C shape guards remain diagnostic evidence,
not the production raw-API theorem.

## Sequential implementation phases and stop rules

| Phase | Deliverable and gate | Estimate |
| --- | --- | --- |
| 0: completed discriminator | Independent bit/compare/both interventions, typed controls and balanced timings. | Completed. |
| 1: analysis only | Name-independent plan/refusal report for selected definitions; accept unrelated reconstructing list observers, reject changed fields, side effects and non-tail residuals. No generated-C changes. | 1–2 focused hours; roughly 150–250 Bend lines for a first bounded recognizer. |
| 2: one-root observer | Private read-only worker and boxed adapter for generic indexed/list observations; checked host only, raw/device fallback. Qualify ownership and scalar errors before timing. | 1.5–3 hours; roughly 100–200 additional core lines including hooks. |
| 3: two-root comparison | Extend the same analysis/environment to two roots and nested result wrappers. Unrelated user ADT comparison qualifies without name rules. | 1–2 hours; roughly 50–120 additional lines. |
| 4: integration | Current compiler comparison, mixed family smoke, B1/B2 compile-time checks, focused raw/device fallback and shared-error controls; then justify broad gates. | 1–2 hours, mostly serial validation. |

These are estimates, not delivery guarantees. A complete reviewed feature is
more plausibly **350–600 added Bend lines and 4.5–9 focused hours** than a
150-line patch. Documentation and controls are additional. Some steps overlap
and may run in parallel, but target execution stays serialized in the guarded
lane. If phase 1 cannot certify both witnessed shapes within its bounds, report
the refusal and reconsider before building another lowering mode.

Stop promotion if the candidate changes raw emitted behavior, admits a changed
root, removes a failing/diverging computation, increases native stack depth,
or needs source-name exceptions. Stop expanding the emitter when its grammar
ceases to be the declared read-only scalar observer subset. A failed optional
candidate must never remove an existing ordinary worker or poison its admission.

## Fast validation and measurements

Start with tiny functions over renamed user ADTs: one-root indexed observer,
two-root lexicographic observer, early exit, empty/unequal inputs and an acyclic
reconstructing helper. Add negative cases for modified/reordered fields,
computed dead results that still fail, nontermination, mutual recursion,
escaping child values, arrays, foreign calls, bang calls and dependent layout.
Admission/refusal reports make a parser or normalization failure distinguishable
from an intentional unsupported case.

Ownership controls include fresh roots, static roots, RFC roots, roots sharing
tails, identical roots supplied under two owned references, and discarded
public results. Check scalar boundaries (unsigned high characters, Nat limit),
one/four-thread output, pre-existing shared error, error from a scalar helper,
and long traversal cancellation. Raw controls must demonstrate that optimization
permission cannot be forged through ordinary books and that old entry bodies
remain active. Device code must build through its old route when that lane is
available.

Only after these controls pass, run the short Map discriminator against the
current compiler. The target is the removed reconstruction pattern: allocation,
keep/seal and continuation counts should fall, without merely moving them to
another wrapper. Then measure a few independent list programs and the mixed
family set. Record compiler source/line growth and compile-time cost; analysis
that makes B1/B2 materially slower is not free. Reserve the broad suite and
self-reproduction for a candidate with demonstrated local correctness and gain.

## Work allocation

One source agent owns the bounded origin/identity analysis and refusal report.
One owns the read-only worker/adaptor proposal once its input plan is fixed.
An independent reviewer owns changed-field, demand, ownership and raw-capability
counterexamples. Root alone schedules compiler/native runs and records the
comparison. Separate files and explicit plan schema allow useful parallel work
without concurrent production edits or competing benchmark processes.

Related evidence: [P69-009](../../experiments/phase69/P69-009-root-preserving-traversal.md),
[independent diagnostic review](../../selfhost/tools/performance/phase69/product-transport/independent-root-preserve-review.md),
and [earlier proof notes](../../selfhost/tools/performance/phase69/product-transport/return-identity.md).
