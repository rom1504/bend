# Phase62: eliminate repeated dependent-term work

Investigated 2026-10-07 against Phase61 state08, source
`268b3cf2e1f1c2810c372925ccd1ad7eb91225853d432ca9517f05f2ecefd42e`.
This is source research and an experiment proposal. No compiler, benchmark or
candidate implementation ran for this investigation. Existing measurements below
remain Phase61 evidence, not fresh Phase62 profiles.

**The useful question is which term traversals can disappear, not whether to add
sharing in general.** Our compiler already has graph reduction, bounded delayed
substitution and immutable leaf reuse. The next investigation should distinguish
unchanged reconstruction, repeated visits to shared syntax and substitution of
large bodies at each beta step.

## Current implementation and the missing evidence

- [`subst` / `subst_node`](../../selfhost/src/core/term.bend) replace globally
  unique variable IDs, preserve literals and childless non-App terms, but rebuild
  composite child lists and parents. `core_rebuild` also beta-reduces Apps and
  canonicalizes their metadata. Substitution is therefore more than variable
  replacement.
- [`env_subst_apply`](../../selfhost/src/check/env-substitution.bend) already
  fuses multiple substitutions in an admitted beta-stable term. Bindings are
  applied oldest first; a replacement receives only later bindings.
  [`env_tele_safe`](../../selfhost/src/check/env-telescope.bend) excludes unsafe
  Apps and materializes at unsupported boundaries or 64 pending bindings. The
  count is a cursor bound, not a universal normalization fuel limit.
- [`graph.bend`](../../selfhost/src/core/graph.bend) already shares argument
  thunks through `GCell` and a persistent `GHeap`. `g_args` nevertheless invokes
  `subst` over each lambda body. `g_let_sub` substitutes repeatedly. Sharing an
  argument avoids copying that argument's payload; it does not eliminate visits
  to every node of the receiving body.
- [`norm_convert`](../../selfhost/src/core/normalize.bend) starts separate graph
  heaps for its symbolic empty-book pass and full-book pass. `norm_cmp_quick`
  uses structural `norm_exact`, and strong normalization uses graph reduction.
  A proposal to add graph reduction or a general reflexivity shortcut would
  overlook existing machinery.

In [state06 profiles](../../implementation/phase61/frontend-next.md), MapSet
substitution accounted for about 25.7% of sampled allocated bytes, across
checking, annotation and backend callers. The corresponding CPU union was much
smaller; these allocation bytes cannot be converted into a 25.7% latency gain.
State08 subsequently selected leaf reuse, so its residual opportunity requires
fresh counting. Numeric already allocated less than TS while remaining slower.

Record the following in separate diagnostic processes, attributed to the nearest
semantic caller rather than a shared generated SCC name:

| Counter | Purpose |
|---|---|
| `subst` entries, visited Var/literal/composite nodes, rebuilt parents and list cells | Establish actual work after leaf reuse |
| Composite results structurally equal to their input, classified by tag | Upper-bound change-aware reuse; include App canonicalization and beta work |
| Distinct input-object identities versus visits within one exact substitution binding/environment | Find redundant DAG traversals, distinct from unchanged output |
| `env_tele_safe` visits, admissions, rejection reasons, binding counts and materializations | Test whether safety scans or fallback dominate the admitted cursor's savings |
| Beta steps in `norm_args` and `g_args`, body nodes visited, fresh thunks, repeated forces | Distinguish body substitution from argument evaluation and memo-heap overhead |
| `norm_exact` nodes visited, successes and failures, comparison mode | Test whether structural reflexivity is itself expensive |

Diagnostic JavaScript identity maps may count observations without changing
compiler results. They are measurement tools, not permission to move compiler
semantics into the host. Timing instrumented workers is not a speed result.

## 1. Preserve unchanged subtrees; add summaries only where they amortize

Lean's `instantiate` uses cached loose-bound-variable ranges to avoid irrelevant
subtrees. Its expression update helpers return the original node when child
identities do not change. These are complementary: one avoids visits, the other
avoids allocation after visits. [Instantiation source](https://github.com/leanprover/lean4/blob/d024af099ca4bf2c86f649261ebf59565dc8c622/src/kernel/instantiate.cpp),
[update helpers](https://github.com/leanprover/lean4/blob/d024af099ca4bf2c86f649261ebf59565dc8c622/src/kernel/expr.cpp).

**Transfer to Bend:** first measure the larger change-aware substitution already
proposed but not implemented in [Phase61](../../implementation/phase61/frontend-next.md).
Rebuild only changed children and their ancestors, retaining immutable list
tails where possible. A result flag or wrapper has a cost; do not replace every
saved KTerm with another allocated wrapper and assume a win.

For frequently reused compiler-owned terms, investigate a small conservative
summary of variable occurrence and substitution stability. A min/max variable-ID
range can reject IDs outside the range; a tiny occurrence mask can reject a
missing bit, with collisions falling back. Neither needs to claim exact
membership. An ID is a variable occurrence only where existing `subst` treats it
as one: a Var's payload is not traversed by that operation, while binder IDs
are not themselves replaced. Recompute summaries when children change.

**Semantic obstacle:** absence of the target variable is insufficient. For
example, substituting an unrelated ID into an App with a Lambda head still
performs beta reduction today. A skip needs both a sound absence fact and a
proof that the existing rebuild leaves the whole subtree unchanged. An App can
also be changed solely by canonicalization of name, ID, quantity, child arity or
removed-name metadata. Keep quantities, source intervals, constructor variants,
literal identity and explicit Lambda quantity presence exact. Initially retain
ordinary substitution for every unproved case.

Lean4Lean's paper describes a soundness bug involving overflow in compact
bound-variable metadata. The lesson for our proposed summaries is concrete:
overflow or an unavailable fact must produce an unknown/conservative answer,
never a wrapped value meaning no variables. Its reported 20–50% slowdown versus
Lean's C++ checker concerns another workload and runtime; it is not a forecast
for Bend. [Lean4Lean, v3, sections 4.1 and 7](https://arxiv.org/html/2403.14064v3).

**Cheapest falsifier:** count no-op composite results and sizes on Numeric,
MapSet and Lexer. Reject a summary representation if a one-time construction
scan plus lookups exceeds the visits it could remove. Test exact results on
no-match beta Apps, malformed App metadata, later bindings occurring inside
inserted replacements, Var payloads, source spans and 63/64/65 bindings. This is
a small-to-medium experiment without summaries, a larger representation change
with them. No speed percentage is justified yet.

## 2. Memoize a traversal's repeated shared nodes, not every constructed term

Lean's replacement walker has an optional cache keyed by expression identity
and binder offset. It preferentially caches shared nodes; offset is part of the
key because replacement under different binders is not the same operation.
This differs from global hash-consing of every new term.
[Replacement walker](https://github.com/leanprover/lean4/blob/d024af099ca4bf2c86f649261ebf59565dc8c622/src/kernel/replace_fn.cpp).

**Transfer to Bend:** measure repeated input identity within one `subst` call
and one admitted environment realization. If those repeats are material,
request-local caching of successful immutable results could avoid both repeat
traversal and rebuilding. Bend uses global binder IDs rather than de Bruijn
offsets, but replacement ID/value and ordered environment still define the
operation. For general evaluation, book context and evaluation policy also
matter. A memo for syntactic substitution is a narrower proposal than a cache
for context-dependent normalization.

There is no assumption that Bend source currently exposes a constant-time
object-identity map. A production design would need compiler-owned stable node
IDs, another proved representation, or an explicitly justified primitive.
Structural hashing on every lookup may cost as much as the avoided walk;
hash equality alone must never admit a result. Generating IDs for every term
could make this more expensive and complex than change-aware reconstruction.

**Cheapest falsifier:** collect repeated visits using host identity solely in a
diagnostic, grouping by the complete operation key. If distinct nodes are almost
as numerous as visits, defer this idea immediately. Record peak retained nodes
and limit a possible memo to one operation. Preserve original error/evaluation
order on uncached paths. This is medium-to-large implementation scope because
identity support, not the table algorithm, is the principal open question.

## 3. Evaluate body syntax through environments instead of substituting it

Smalltt separates syntax from semantic values. Its `Closure` stores an
environment and a term; function application extends that environment. Its
values can retain a named unfolding head and a deferred evaluated alternative,
and quotation can preserve the named form. This avoids equating efficient
evaluation with eagerly constructing a fully unfolded output term.
[Core types](https://github.com/AndrasKovacs/smalltt/blob/ea99b0f478e50dcb81ea19e40bfb4262339b22aa/src/CoreTypes.hs),
[evaluator and quotation](https://github.com/AndrasKovacs/smalltt/blob/ea99b0f478e50dcb81ea19e40bfb4262339b22aa/src/Evaluation.hs).

**Transfer to Bend:** the substantial architectural hypothesis is a private
closure representation for the residual `g_args`/conversion path, extending the
existing GCell machine rather than adding a competing whole compiler. Binding
an argument would extend an environment and retain the original body. Only
observed variable occurrences would consult the environment. Preserve a compact
reference/original-term form where a public result must be reconstructed.

This goes beyond the selected bounded telescope cursor: it addresses beta
application to arbitrary admitted bodies, including normalization and
conversion. It also has substantially greater semantic risk. Existing stuck
match behavior, native opacity, quantity ordering, `pending`/`fallback`, source
locations, fresh IDs, ordered inserted-value substitution and resource refusals
remain part of the contract. A conventional lazy evaluator cannot simply replace
our eager-rebuilding substitution. Start with an explicit admitted grammar and
materialize into the old path at every unproved boundary.

Smalltt deliberately balances lazy and strict evaluation and warns that plain
hash-consing cannot prevent beta-driven size expansion. Its benchmark corpus is
not evidence of gains on our programs. [Author's design discussion](https://github.com/AndrasKovacs/smalltt/tree/ea99b0f478e50dcb81ea19e40bfb4262339b22aa#design).

**Cheapest falsifier:** measure body nodes visited per beta step, then construct
small mechanism controls varying body size and argument count independently.
Compare total visits with distinct body nodes and actual forced variable
occurrences. If most cost lies in genuinely required computation, an environment
will add overhead. If a large immutable body is recopied at each application
while few nodes are demanded, it supports an isolated private evaluator
prototype. Count closure/environment allocations, environment lookup depth,
materialization frequency and final reconstruction work. This is a major change;
its possible gain must be bounded by measured affected time, not by smalltt's
published ratios.

## Lean4Lean narrows the experiment further

The inspected Lean4Lean checker already batches binder instantiation in
`inferLambda` and `inferApp`, and keeps distinct inference and WHNF caches.
This supports testing operation granularity and cache policy, rather than
concluding that a self-hosted checker must inherently be slow.
[Pinned checker](https://github.com/digama0/lean4lean/blob/143d58a3e14e1e5e344fd1a18ee506329b48c307/Lean4Lean/TypeChecker.lean).
Our telescope batching is already an analogous technique. Per-policy caches
would still require the context and identity investigation above; no cache is
selected by this source comparison.

## Decision order and source provenance

First count unchanged reconstruction and repeated identities. Then pursue the
smaller change-aware experiment if its opportunity survives. Escalate to closure
environments only if body-substitution work remains a broad, dominant cost.
Do not reinstate the rejected Phase61 backend telescope cursor on the strength
of this research; its actual mixed timing remains contrary evidence.

The sources were inspected selectively through primary web pages and read-only
raw downloads on CPU0. Initial sandbox DNS/raw-page failures produced no source
evidence; subsequent permitted raw downloads resolved the exact commits below.
No external compiler was built. The pinned files and observed SHA256 values are:

| Project revision | File | SHA256 |
|---|---|---|
| Lean `d024af099ca4bf2c86f649261ebf59565dc8c622` | `src/kernel/instantiate.cpp` | `42527c96f4053fb3cbf4c26fbd544b1c4e0399e5c41b0fd792935d1d42f8916a` |
| Same | `src/kernel/replace_fn.cpp` | `2edfa1721059dbb570ba99746f2cd60d1d691071523c129a12b3b9414972ac67` |
| Same | `src/kernel/expr.cpp` | `cb02c18964aca67289b8c1d64864355bb5c10fc93d55bd3c3c9646776af9c592` |
| smalltt `ea99b0f478e50dcb81ea19e40bfb4262339b22aa` | `src/CoreTypes.hs` | `6efc910cd8daee99bdfa4056eb2e03e6990db6d77221ca08d9212d1369ccbe9d` |
| Same | `src/Evaluation.hs` | `19129d265076f17fabb88d7057c4cbd111ed08ea24cc49cb1e496ee256899a4d` |
| Lean4Lean `143d58a3e14e1e5e344fd1a18ee506329b48c307` | `Lean4Lean/TypeChecker.lean` | `1c38299515e56ace7438a3f9e86b71c154cf0855bdc8c6e340821fdfb54217d7` |
| Same | `Lean4Lean/Instantiate.lean` | `b384f94482139794df252132b115125a45a90497243687388d98c3022067f41b` |

Lean reuses the research repository's existing v4.30.0 pin. Smalltt was resolved
from `master`, Lean4Lean from its paper's `cpp2026` branch. These identifiers fix
the inspected source; they are not claims about the newest available versions.
