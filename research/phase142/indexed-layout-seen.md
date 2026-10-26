# Indexed visited names for the existing layout validation walk

Source-only candidate; await profiling and independent checks before integration.
Audited exact Phase141 source
`f5bfca6d1fe9b378955d6c89ba5ec2428ec1627d7d008eb0c15eac1b51c8a06a`.
No compiler target, machine build or benchmark was executed by this investigator.

The selected `jl_checked_error`17137 calls `jl_visit`17142 with an empty
`List<String>` visited set. Every nonsentinel todo name runs
`has_name(seen,name) || has_name(stops,name)`. A new name is prepended before
`jl_def`17152 decides whether its body needs inspection. Thousands of reachable
definitions and repeated references can therefore pay many linear seen-list
searches. Existing Phase140 erasure and reachability paths use indexed membership,
but this exact layout walk remains unchanged; no prior replacement was found in
the retained relevant research/implementation overlays.

The candidate
[`core-v01.bend`](../../selfhost/tools/performance/phase142/layout-seen/core-v01.bend)
is42lines, seven private functions and no new data type. Its public experimental
comparison root is `p142j_checked_error(book,defs,roots,stops)`; the original
`jl_checked_error` remains the oracle. `jl_term`, its layout/type queries, todo
construction, stop-list membership, definition lookup and both book preparation
calls remain unchanged. There is no cache, invalidation policy or removed dynamic
validation.

## Membership and sequence argument

Let `S` be the old seen list and `I(S)` the map built by `p142j_members(S,missing())`.
For each name it stores a KDef with that exact name and the dedicated kind
`P142JSeen`. Membership tests use `index_hash(name,2166136261)` and
`index_find(...,name,...,32)`, followed by the exact kind check.

Assuming the existing index's insert/find laws, for every string `x`:

```text
has_name(S,x) = p142j_member(I(S),x,index_hash(x,2166136261))
I(Con{x,S}) has the same membership as p142j_mark(I(S),x,hash(x))
```

Duplicate keys do not affect membership. Full-name collision-bucket comparison
is essential; a matching32-bit hash is never sufficient. The marker kind is
not `Absent`, and the lookup uses the queried name itself, so an empty name or
a user name literally `Absent` does not become a missing-key test.

The old and new traversals maintain identical `book`, `defs`, `todo`, `stops`
and the membership relation above:

1. Empty todo returnsFalse in both.
2. `$layout.open-array` returnsTrue **before** consulting seen or stops in both.
3. Already-seen or stopped names remove exactly the same todo head, without
   definition expansion or seen insertion.
4. Every other queried name is inserted before dispatch, including missing,
   non-Def and templated definitions. The same `lookup` result reaches the same
   `dk == Def && dx == 0` test.
5. Eligible bodies call the original `jl_term(book,dv(d),rest)`. The resulting
   todo list and its order are identical; ineligible bodies leave the rest
   unchanged. The invariant continues at the recursive call.

Thus this changes the representation of a membership predicate, not visitation
order, dynamic layout checks or the returned error string. The reasoning is a
source-level simulation argument, not a mechanically checked theorem.

Independent source controls by the review agent are in
[`controls-v01.bend`](../../selfhost/tools/performance/phase142/layout-seen/controls-v01.bend),
export `p142jt_controls`,26rows. They compare original results and explicit
expected outcomes for cycles, duplicate/missing references, sentinel ordering,
stops, templates/non-Defs, shared/live branches and native Array marking.
Membership cases include the actual FNV collision `costarring`/`liquid`, empty,
Absent and Unicode names. These are prepared finite checks, not execution evidence.

## Cost hypothesis and limits

Let `V` be distinct visited names and `R` the number of popped todo entries.
The old visited membership can require O(R×V) string comparisons, in addition to
unchanged body traversal. The new path hashes each nonsentinel name once and uses
the existing32-bit Patricia index; ordinary traversal depth is bounded by key
bits, with full-name work for hash collisions. Insertion occurs only for new
visited names. Adversarial collisions retain bucket costs, so this is not a
claim of worst-case constant-time lookup.

The tradeoff is real: hashing and persistent tree/marker allocation may cost more
for small walks. The old seen insertion was a single list cell. Native ownership,
reclamation and borrowed helper admission can change the balance. Keep stops as
the original list for this first experiment to isolate the visited-set change.

This applies to cold and warm compilation because both execute the same layout
gate. It could benefit the JS and native frontends without changing generated
program semantics. No gain estimate is justified until native/profile evidence
shows that visited membership is material, and an actual request retains exact
output. The existing hosted `jl_checked_error` replay includes type/layout work,
book preparation and traversal; it is only a ceiling for the entire gate, not
an estimate of removable seen-list time.

## Small execution surface for the coordinator

Append the two modules without overrides to the checked source. Useful roots:

```text
jl_checked_error p142j_checked_error
jl_visit p142j_visit p142j_members p142j_member p142j_mark
p142jt_controls
```

First compare actual annotation products already held by the Phase142 attribution
observer; prepare them once and alternate old/new gate calls. Include a larger
real compiler annotation slice, rather than relying only on tiny fixtures.
Record reachable-name/reference volume if available without adding another full
walk to timed requests. Then substitute only the top entry in a separate candidate
and require complete request QBE equality before clean whole-request timing.
Preserve the old implementation in the independent frozen oracle; no production
selection or source replacement is authorized by this prototype alone.

## Prepared component/scaling observer

[`component-screen.mjs`](../../selfhost/tools/performance/phase142/layout-seen/component-screen.mjs)
prepares actual Lexer/Map A→B frontend results once, retains the original context
and annotation products, and runs five alternating original/indexed gate pairs.
If direct roots are exported, it also times `jl_visit`/`p142j_visit` with book
preparation held outside the interval. Exact empty error/False outcomes must match.
The original26 finite controls run first. No additional whole-codegen oracle is
required merely to compare this component against its unchanged original function.

```sh
selfhost/.bootstrap/bun-1.4.3/bun \
  selfhost/tools/performance/phase142/layout-seen/component-screen.mjs \
  CHECKED_API_REPORT.json \
  selfhost/build/phase142/layout-component01
```

Optional checked
[`fixture-v01.bend`](../../selfhost/tools/performance/phase142/layout-seen/fixture-v01.bend)
adds `p142jg_fixture`. It generates128/512/2048 annotated definitions, each
referencing its predecessor twice, ending at a missing node. The original
`jl_term` still determines traversal. Generation is outside measurement; these
are scaling diagnostics, not source-typechecked corpus programs. The observer
records structural edge counts and explicitly does not label them measured
visited-query events. A60s resource-guarded budget is suggested but unmeasured
for this new observer.

The coordinator's new native profile elevates the membership hypothesis:
`has_name` occupied42.62% of the conservative23.2s warm frontend window's active
contexts. This is **not** caller attribution to `jl_visit`; other frontend
analyses also use `has_name`. The component screen is intended to test this
particular explanation rather than assign all those samples to it. No independent
final verifier changes are proposed.
