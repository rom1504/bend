# Phase64: retain original Base completion facts

Status: TODO-count source prototype implemented; root qualification and timing
pending. Baseline is installed Phase63 State09 at `fd01066`. No gain is claimed.

## Selected first experiment

`driver_program_checked` still invokes `driver_todos(original)` after every
successful check. That selects final original declaration events and traverses
their types, bodies and constructor definitions, including the complete Base.
The Phase63 ready world already removes Base rechecking and index reconstruction;
this experiment targets the remaining completion scan only.

Extend private `KBasePreparedWorld` with one last field, `todos: U32`.
`base_prefix_world_saved` computes `driver_count_todos(final)` on the **final
original prefix definitions**, never on elaborated checked bodies. TODO holes
can survive ordinary checking, so this is a measured count, not an assumption
that checked Base contains zero holes.

The existing `check_program_diagnostic_world` entry performs its original
admission decision once. When admitted, it continues the original chronological
checker and completes a successful result using:

```
prefix_todos + driver_todos(actual_suffix)
```

`driver_program_checked_prefix` keeps this addition and suffix scan inside the
successful-check branch. A failed checker therefore retains its original first
error, diagnostic, world and source location without doing TODO completion.
`sp_assembled` still assembles the same checked output. Non-admitted requests use
the original full checker and original full-book completion.

The old DChecking-level ready-world controls remain available unchanged. A
small common helper handles the already-admitted world resume; a cross-prefix
full hash collision still uses old prefix replay before the new completion
count. Such a hash collision does not invalidate name disjointness.

## Why the count splits

The existing ready-world admission proves that prefix and suffix top-level names
are disjoint. Final event selection therefore cannot remove a prefix definition
because of a later suffix declaration. The same final suffix events are selected
whether finalized alone or after that prefix. Each selected definition keeps its
original type, body and constructor list, all of which are what the TODO fold
reads. Addition is associative modulo U32, matching the original fold.

A suffix law filling a Base law, duplicate cross-prefix definition, reserved
name, constructor collision, invalid floor/state or non-ready loader carrier
does not obtain this split-count permission. Within the suffix, ordinary laws
and fills still pass through `driver_todos`'s final-event selection.

## Private transport and compatibility

The new fact requires prepared-world producer/admission version **2** and the
exact changed API identity. The named ABI field list appends `todos`. The graph
codec validates its U32 representation. A legacy world shape/version is not a
version-two fact: the host must drop it and retain the existing prefix-state or
full-checking fallback. Existing raw/public checker exports remain unchanged.

The host and codec owners implement and qualify those corresponding boundaries.
This source owner modifies only `check/prefix-state.bend` and `driver/api.bend`.
No TypeScript compiler algorithm, public proof claim or general memo table is
introduced.

## Controls and falsifier

The [fixture manifest](../../selfhost/tools/performance/phase64/base-facts/cases.json)
records focused semantic cases. Required differential observations are complete
DResult equality, including failed diagnostics and returned books, against the
ordinary `driver_program_checked` path. Reuse frozen prepared state across
requests and retain whole-source/program-byte gates.

Required controls include actual Base, a native prepared-prefix TODO, suffix
TODOs, law/fill finalization, repeated suffix names, an earlier type failure,
cross-prefix filling, full-hash collision, false readiness and old/malformed
optional count metadata. Count the removed prefix traversal in a diagnostic
run, then decide on clean whole-request latency. A counter reduction without
a request benefit is not sufficient for retention.

## Deferred scope

Emit-policy summaries and checked-output finalization are **not implemented**
in this first ablation. `driver_emit_owned` scans the assembled checked book,
whose semantics differ from original-source TODO counting. Optimizing it needs
separate treatment of fixed owned-name error precedence and both directions of
foreign-definition/constructor collisions. A naive suffix-only policy scan is
not justified by the TODO fact. The original policy remains authoritative.

Root owns all compiler/Node/target execution under the serial process-tree
resource guard. This implementation agent performed source/data work only.

## Separate unapplied policy prefilter

The [owned-name prefilter patch](../../selfhost/tools/performance/phase64/base-facts/owned-filter.patch)
is a distinct candidate, not part of the TODO source freeze. It adds ten Bend
lines and changes no cache schema. `driver_emit_owned` filters the input book to
non-native definitions once before its existing fixed-order, fourteen-name
ownership check. A native definition cannot satisfy any ownership violation, so
removing it preserves each name query, duplicates and name-precedence ordering.

Foreign-definition/constructor checking still receives the **original full
book**, including native foreign definitions. The patch does not summarize or
skip that policy. Raw `driver_owned_names` and all public argument contracts
remain unchanged. This removes repeated scans of native Base declarations
without relying on a Base certificate; its whole-request value is unmeasured.

The [focused controller](../../selfhost/tools/performance/phase64/base-facts/owned-filter-controls.mjs)
takes `CHECKED_ATTEMPT NEW_PHASE64_OUTPUT`. It requires a checked named-layout B1
containing the candidate, appends diagnostic exports without changing function
bodies and compares complete policy strings against the unchanged original
queries. Controls include every owned name, native/non-native duplicate pairs
in both orders, fixed fourteen-name precedence, kind-independent raw values,
native foreign collisions, foreign collision order, a large native prefix and
512 deterministic generated books. Input freezing and exact filtered lists
check immutability and retained order. Root must run it after applying the patch;
writing this controller is not a passed control result.

## Unapplied exact checked-prefix context fact

The [isolated context patch](../../selfhost/tools/performance/phase64/base-facts/checked-context-v1.patch)
addresses a different remaining full-Base traversal. After checking,
`sp_assembled` reverses `kw_checked` into an ordinary list. The host later calls
`book_context`, which rebuilds an index and computes `norm_max_book` over the
complete assembled book. The ready checker's raw-world index does not solve this:
its raw unfolding definitions differ from elaborated checked output.

Existing `KBasePrefixState.bound` is the exact maximum of the original prefix
and only an upper bound on the checked prefix. Reusing it blindly could change
fresh binder numbers. The proposed version-three prepared world instead appends
`checkedBound: U32`, computed as `norm_max_book(kw_checked(world))` during genuine
preparation. The value is exact, including types, bodies and nested constructors.

The new private `book_context_world(assembled, load, prepared)` must receive the
actual successful checker result, matching native loader carrier and admitted
prepared state from one owned driver request. It rechecks the existing ready
world admission and conservatively falls back on full hash collisions. A paired
list walk skips the number of saved checked-prefix definitions from `assembled`;
it does not traverse their terms. The context is then built with:

```
book_cached(assembled, max(prepared.checkedBound, norm_max_book(checked_suffix)))
```

The index still builds from the same full assembled definition sequence. Only
the redundant deep maximum scan is removed. Cached input books, non-admitted
carriers and a result shorter than the saved prefix use ordinary `book_context`.
The public raw `book_context` contract is unchanged.

The leading-prefix invariant follows from the checked-world operations:

- `kw_put_checked` only prepends a newly checked definition.
- `sp_live_done` only prepends a newly checked specialization.
- Other admitted world updates preserve `kw_checked`; they do not replace its
  saved tail. The admitted Base producer requires an empty specialization memo.
- `sp_assembled` reverses that list, making `reverse(prepared.checked)` the
  complete leading prefix of every successful assembled result.

Therefore the maximum of the saved prefix and actual checked suffix equals the
original full-book maximum exactly. Freshening, specialization output and
annotation subsequently receive the same bound and index as before. The stored
checked prefix is not used as a replacement for raw unfolding definitions.

This is an authenticated private producer/consumer relationship, not a claim
that any same-length caller-supplied book has that prefix. The host must select
the private API only for its actual owned check result; no fresh deep prefix
hash/equality traversal is proposed. Arbitrary public books keep the full scan.

Required controls compare complete cached contexts (including exact index
structure and bound), output bytes and fresh-ID-sensitive semantic cases. Include
suffix laws/fills, generated specializations, high binder floors, absent/malformed
facts, old world versions, non-ready carriers, full hash collisions, empty and
short books, and ordinary public raw books. Count removed maximum traversal in
diagnostics and measure the extra admission cost against the saved scan.

The patch adds 47 Bend lines and one private export; no live source was changed.
World-version-three metadata, named ABI fields and the isolated graph decoder
patch must be integrated together before testing. Existing old rows may decode,
but cannot obtain the new exact-bound capability without the actual field and
matching producer/API identity. This proposal is not yet a selected result.
