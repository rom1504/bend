# Prepared Base world candidate

Status: implemented candidate; compilation, correctness and timing pending.
No gain or promotion is claimed by this source change.

## Hypothesis and scope

The Phase61 private checked prefix state skips checking Base, but each request
still reconstructs its patched checked definitions, declaration index, raw world
and event-history index. Preserve those immutable values in a prepared record
and extend only the request suffix. This removes reconstruction, not a second
claim of skipped Base checking.

Implementation: `selfhost/src/check/prefix-state.bend`. The original public and
private state APIs remain unchanged as fallbacks.

The new private `KBasePreparedWorld` holds `state`, `prefix`, `final`, `book`,
`checked` and `seen`. `book` is the actual raw-definition world and cached index;
`checked` is the reverse checked output list. Those are deliberately distinct:
checking may elaborate bodies without publishing those elaborated bodies into
the unfolding book. `seen` retains source-event publication for duplicate/law
diagnostics. The record can share term and index nodes with the parsed Base.

`base_prefix_world_prepare(prefix, state)` first applies the existing admission
predicate against the empty suffix. It constructs a snapshot using the existing
saved-state resume function. A refused state produces a record with `ready=false`.
This producer is for the existing identity-bound, trusted-local preparation
path. It is not a certificate for hostile state files or a new unchecked public
compiler input. The host must preserve the API/Base/source interval identities,
state digest and same-seed association through serialization and admission.

`check_program_diagnostic_world(load, origins, prepared)` is a private consumer.
Its `FPrefixLoad` must originate from the same authenticated leading Base
injection as `prepared.prefix`; changing either independently is outside this
private API's precondition. The host must enforce that coupling and must never
select the path for raw public source/book objects.

## Request work

1. Use the preparation-time prefix maximum and scan only the fresh suffix.
2. Retain the existing name, constructor, closed-prefix and bound admission rules.
   Closed-prefix checks were established by the original state producer; suffix
   name/constructor/disjointness checks remain at request admission. Name-set
   disjointness scans suffix names against the saved prefix index, rather than
   building a suffix index and scanning every prefix event.
3. Install only suffix headers into the saved raw-world index.
4. Preserve the exact declaration-list order: Base raw final definitions first,
   followed by reverse-final suffix headers. The saved prefix list cells are
   copied when the suffix is nonempty; terms and index subtrees are shared.
5. Rebase only the world-bound stamp, known fresh counter and seen bound using
   the original arithmetic. Continue chronological checking on suffix events.

Installing suffix headers after Base publication differs from the historical
insertion order when a suffix name has a full 32-bit hash collision with a Base
name. Lookups remain equivalent, but bucket order changes. The candidate detects
that rare cross-prefix collision using the saved index and uses the old replay
path, preserving exact world equality. Suffix-only collisions retain their
original chronological order.

The old `KBasePrefixState` and its frame1/frame2 transport remain valid. A ready
world should use host transport that preserves DAG sharing: naïve JSON would
duplicate definitions inside indexes and lists and can erase any request gain.
The cache-host owner evaluates the transport separately; session reuse and
fresh-process gains must be reported separately.

## Required controls

- Compare complete `DChecking` values against `dg_check_world` and the old prefix
  resume path, including error worlds and located final diagnostics.
- Alternate suffixes against the same frozen world and verify unchanged inputs.
- Empty suffix, ordinary successful definitions, law/body pairs, duplicate names,
  constructor collisions, unknown names, unsafe flags and reserved names.
- Suffix binders above the Base floor; delta/stamp arithmetic; refused bounds.
- False/missing admission state; loader error and false ready carrier fallbacks.
- Cross-prefix and suffix-only full hash collisions; same-name disjointness.
- Preserve the distinction between raw-world and checked-output bodies.
- Host frame identity, schema, digest and same-Base coupling failures must refuse
  optional ready state and retain the old path; public callers cannot inject a
  ready snapshot into an owned private session.
- Output identity, focused semantic gates and generated-code nonregression before
  measuring first request and persistent request latencies separately.

Root owns all compiler/test execution under the serial resource guard. This
agent has not launched Node, a compiler or target programs.

## Source-build correction

The first state01 checked build refused a nested match in
`base_prefix_world_order`: after the outer suffix match, the compiler did not
admit `declared` as a matchable parameter/field. The failed snapshot is retained
by root. State02 moves that inner match into `base_prefix_world_order_tail`,
whose `book` argument is matched directly. List contents, order, admission and
runtime control flow are otherwise unchanged. State02 then refused the combined
nested `match trace state` in the new ready-world consumer. State03 uses separate
single-parameter load, trace, result and world helpers, plus a state-bound
accessor; the resume path also matches its state in its own helper. Both failed
snapshots remain retained. These are source-build corrections, not passed
correctness gates.
