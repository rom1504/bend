# Production entry wiring: indexed layout and reachability

2026-10-26. Source-only review of `layout-seen/core-v01.bend`,
`reach-seen/core-v01.bend` and their `override-v01.bend` modules, against Phase141
integrated-source02. The final reach wiring is `reach-seen/override-v02.bend`,
which retains `kr_visit`'s original inferred declaration syntax so its attached
law remains compatible; v01's annotated signature is a preserved failed attempt.
This supplements the individual
[layout](layout-seen-audit.md) and [reach](reach-seen-audit.md) audits. No new
execution, native qualification or performance claim is made here.

## Integration verdict

No source-semantic blocker found. The proposed production changes are two entry
bodies:

```text
jl_checked_error(book,defs,roots,stops) -> p142j_checked_error(...)
kr_visit(book,todo,seen,stops)          -> p142r_kr_visit(...)
```

Argument/result shapes and names are retained. The private loops never call
their overridden entries; there is no wrapper cycle or per-iteration rebuilding
of the initial seen index. Existing callers of `reach_book` continue through
the original `kr_filter`. An external call to retained `kr_visit_def` can enter
the new `kr_visit`, but the initial membership index is rebuilt from the exact
list it receives, so that helper's list-shaped contract is preserved too.

The changed set is local to each call. It is not shared between requests and
needs no source-version invalidation. No runtime ABI, native helper, tagged-term
representation, QBE instruction selection or final verifier changes are involved.
The two entry declarations must be the complete override inventory; inspect the
composed source/protected-declaration report independently before acquisition.

## Exact semantics and evaluation

For layout, sentinel rejection remains the first branch, before hashing, seen
or stops. For reach, that same spelling remains an ordinary visited name. Each
index contains only full-name `P142JSeen` markers built with the original
`index_hash`, and uses the original `index_find` collision bucket equality.
Empty keys, `Absent`, qualified names, non-BMP characters and colliding hashes
are therefore supported without a hash-only or missing-payload shortcut.

The original `lookup`, `kr_resolve`, `kr_dependencies`, `jl_term`, worklist and
stop predicates remain authoritative. Reach preserves both queried-name and
resolved-name cons operations, including duplicates, and still expands a
resolved parent when a distinct constructor alias reaches it again. Its output
list and filtered KDefs retain their original order and payloads.

Strict evaluation now performs finite hashing and index allocation where the old
code performed a list membership scan. Those helpers have no effects and do not
select a compiler diagnostic. The demanded term/type traversal and its error
branch remain inside the same `kc` branches; stops and already-seen names do not
start validating skipped definitions. The fixed layout error text and the
reachable-name result are unchanged for valid finite inputs. This is not an
equivalence claim about memory exhaustion, corrupted native objects or fabricated
cyclic host graphs: the representation allocates different amounts of memory.

Canonical Patricia path depth is bounded by the 32 hash bits. Same-hash bucket
length, name length and visited graph size are not constant bounds; existing
qualified index/list/String routines handle those traversals. The new visitor
cycles are tail-position worklist loops at source level. Actual native lowering
and stack/ownership behavior still need the selected image's normal validation;
source inspection alone does not certify generated machine stack usage.

## Independent oracle caveat after wiring

The 26 layout and 28 reach controls were designed against original declarations
in a source **without** the overrides. Once wired, `jl_checked_error`, `kr_visit`
and `reach_book` calls in those same control bodies can enter the candidate.
Their explicit expected results still test behavior, but that is no longer an
independent old/new differential comparison. Preserve the frozen pre-override
API/results, or call separately frozen original helpers. Do not count a same-API
candidate-versus-itself comparison as new independent evidence.

## Focused native gates, not another broad campaign

Beyond the existing finite controls and exact-QBE comparisons, the most useful
small native checks are:

1. A live open-Array rejection through the ordinary compiler request path, with
   the exact diagnostic/exit result compared to the frozen compiler. The existing
   `tests/reg/array_open_element.bend` is a source witness; use the selected
   pinned version accepted by the current frontend. Pair it with the existing
   erased/dead positive cases in `selfhost/src/back/js/test-layout.mjs`, so
   traversing too much cannot appear to be safer validation.
2. One bounded larger graph that includes a cycle/shared tail and constructor
   aliases, under the usual native memory/stack guard. Check output/QBE equality
   and completion; this targets stack/ownership/scaling differences introduced by
   the set representation. If the full real compiler request already exercises
   a larger graph under that guard, do not duplicate the campaign solely for an
   arbitrary synthetic count.
3. If the 54 finite cases are already being executed by the native candidate,
   their sentinel/collision/empty-name negatives need no additional standalone
   campaign. If they ran only in hosted JS, execute a compact representative
   subset once through the native lane when economical.

Exact positive QBE equality alone does not test refusal behavior, so the first
negative/erased pair is particularly valuable. Full self-reproduction is an
integration gate, not a necessary first discriminator for the data structure.

The measured small layout regressions must remain visible. A large constructed
graph win does not establish that layout should be enabled by default, nor that
the native `has_name` samples belong to layout rather than reach/`kr_push`/other
callers. Decide production selection from the real native request comparison;
keep the independently tested conventional implementation even if that specific
performance decision is to defer one entry override.
