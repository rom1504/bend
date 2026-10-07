# Residual frontend work after state06

This is a read-only proposal, not a selected optimization. State06 focused
prefix qualification passed; root still owns broader source/B2 qualification
and measurement. Reported clean short-window compile times are Numeric
486/316 ms, MapSet 1577/649 ms and Ray 1230/550 ms (candidate/TS). Repeated
combined windows remain distinct from compile-only windows and first requests.

The saved state06 CPU/allocation captures suggest two next experiments. They
include import and later annotation/emission, so allocation or an inclusive
function label is not evidence that checking alone consumes that amount.
Shared `$...$scc` labels remain dispatchers, not individual source functions.

## 1. Leaf reuse before change-aware substitution

Root subsequently chose the smallest first slice: reuse KTerm nodes with empty
children and a non-App tag. `subst_terms(Nil)=Nil`; `core_rebuild` is identity on
non-App nodes, so every field is unchanged. Existing Var/KLiteral cases remain.
This requires no change-result wrapper, second tree walk or new list algorithm.
The rough model removes one KTerm object per qualifying old substitution call;
no actual qualifying count or byte saving has yet been measured. The guard's
runtime cost still needs the actual emitted B2 and clean screen. Fourteen exact
old/new structural controls precede broader qualification. The optional old-only
leaf counter probe need not delay this candidate. [Pre-outcome registration](../../experiments/phase61/P61-009-leaf-substitution.md).

The larger change-aware idea below remains unimplemented research, not the
selected leaf patch.

MapSet samples attribute 51,559,760 estimated self bytes to `subst$scc` and
13,371,680 to `subst_terms`, disjoint contributions of approximately 25.7% of
252,321,752 estimated bytes. These are sampled allocation estimates, not retained
heap or guaranteed removable allocations. CPU substitution leaf samples have
nearest non-substitution ancestors including telescope fill (21.55 ms), backend
`j_app_type` (15.90 ms), `j_specialize` (10.62 ms), annotation `ka_args_head`
(10.38 ms), eager telescope fill (6.44 ms) and normalization (5.35 ms).
Consequently a general substitution improvement can help several stages; a
checker-only explanation of the remaining MapSet gap would be misleading.

Current [subst_node](../../selfhost/src/core/term.bend) reconstructs every
nonliteral non-Var term and its child list, then invokes `core_rebuild`.
The existing environment cursor avoids several complete substitution passes but
still uses ordinary substitution for single bindings and unsafe/beta cases.
Pinned upstream uses higher-order telescope continuations (`tele_head(...).B`)
and in-place declaration maps; reproducing those representations wholesale is
not this proposal.

Test a private first-order result that records whether a subtree changed. A
nonmatching Var and a literal are unchanged. An ordinary non-App node whose
children are unchanged may retain its original immutable node/list. On the first
changed child, rebuild only the affected list prefix and parent. Matching Vars
return the raw replacement exactly as ordinary substitution does; later bindings
must still act on inserted values in their original order.

**Critical boundary:** absence of the substituted ID is insufficient for App.
`core_rebuild` may beta-reduce an already present lambda and canonicalizes App
metadata even when no Var changes. An App retains the old rebuilding path unless
both children are unchanged and the existing exact canonical/non-Lam App
predicate proves identical output. Literal payloads, constructor variants,
quantity presence, removed names and source intervals remain exact. This is the
specific Phase57/Phase61 falsifier, not a blanket no-match shortcut.

Keep ordinary `subst` as the raw reference. Introduce the optimization only on
compiler-owned immutable terms if pointer/alias behavior of a public raw caller
cannot be preserved. No mutable global memo, hash-only identity, JSON key or
book-independent reduction cache is needed. A result flag/Maybe may itself
allocate; the experiment fails economically if those wrappers replace rather
than remove the observed allocation.

**Cheap falsifier:** instrument old reconstruction versus new changed-node counts
on actual MapSet/Numeric type terms, then compare exact old/new output and input
immutability. Include independent no-match lambda Apps, malformed App metadata,
Var payloads, replacement values mentioning later IDs, literal NaNs, nested
binders and the existing 63/64/65 telescope cases. Root can use the current
diagnostic-export method. Only a surviving candidate earns a short clean screen;
held-out Ray/Lexer and complete source/error/trust gates follow selection.

## 2. Reuse authenticated Base structural facts, not another full book

The private native carrier already establishes which actual Base prefix was
preserved. Its checker nevertheless computes `norm_max_book` across the whole
joined prefix/suffix, recomputes the prefix maximum for admission, and constructs
the final-event Base list. State06 Numeric/MapSet CPU captures still assign
26.70/43.06 ms of self weight to the shared `book_final_scan` dispatcher. That
label includes other callers; these totals must not be claimed as prefix savings.

An authenticated private resume can compute the request floor from the prepared
Base bound and the actual suffix maximum. Public arbitrary book/state methods
must retain their full maximum/equality checks. For final publication selection,
consider a compact list of actual final event positions prepared from the exact
Base book, then one shallow scan selecting those existing KDefs. Positions must
preserve last-event selection and chronological output order, including law/fill
pairs and constructors. Do not serialize a duplicate final KDef book: the current
checked-patch payload is already about 2.2 MB and extra decoding can erase gains.

**Cheap falsifier:** actual producer-bound private carrier only, exact complete
world/index/memo/fresh/checked output versus full checking, moved floors, Base
law/fill event ordering, constructor collisions and changed source/API/span/cache
state. Counter attribution must show which full Base walks disappear. Invalid or
unproved capabilities use unchanged full checking. Same prepared-cache local
trust model applies; rehashing fabricated state does not prove its semantics.

Prefer substitution first if the next source audit supports a small bounded
implementation: it addresses substantial cross-stage allocation rather than
only fixed Base setup. The structural-facts experiment is simpler and broadly
applicable, but its maximum plausible benefit is smaller. Neither establishes a
future speedup or justifies dropping existing semantic/refusal gates.

Evidence read: `selfhost/build/phase61/state06-b2-latency01/`
`cpu-map-numeric01` and `allocation-map-numeric01` candidate captures. No compiler
or target process ran for this investigation; no production source changed.
