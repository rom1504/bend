# Phase156: canonical provenance across actual checking

Source audit starts at `209f2df`; candidate is
`selfhost/tests/phase156/publication.bend`. No targets were run. This is a
source-grounded invariant and finite-test proposal, not a proof or qualification.
Exactly `p143cp_seed_ready` and `p143cb_resume_state` are replaced in an isolated
assembly. The original scheduled loop remains available as the independent
reference; all production files remain untouched.

## The invariant

Let C be the unchanged `p143cp_canon`: preserve the leading cache and its exact
index, remove obsolete raw-tail definitions in first-visible order. The new loop
carries one Boolean outside KWorld:

- dirty=True promises nothing about raw canonicality and retains the old
  canonicalization before a non-childless publication.
- dirty=False means C(book) equals book as complete structured data, including
  ordering and cache/index. The cache must also agree with first-visible raw-tail lookup; ordinary checking preserves both facts in admitted worlds.

Both initializers start True. This avoids claiming that an arbitrary initial
prepared list is already canonical and avoids an eager additional pass. The
first existing non-childless fallback executes C and ordinary book_put, which
establishes cleanliness. Existing childless logging always sets True, even if
its particular update happens not to create a duplicate. A skipped publication
(because a later same-name event exists) preserves the incoming bit. Every
returned success or failure still passes through original p143cp_result and C.

The only removed computation is C immediately before book_put when False has
already been established. Its complete book result is then unchanged. The old
index_set sequence, cache fields, checked-output insertion and seen-history
book_put are retained. No constructor membership metadata is introduced here.

## Why real checker mutations preserve cleanliness

A conservative lexical named dependency closure from check_definition_world
contains 435 distinct maintained names (578 declaration blocks), matching the earlier Phase143 audit.
All reachable world/book mutation sites are the following. KWorld has no
function-valued fields that could hide another mutation through a callback.

| Source location | Operation | Canonicality argument |
| --- | --- | --- |
| `check/kernel.bend:1328`, check_template_open | book_put of temporary binder | Removes every old same-name row, inserts exactly one new row. |
| `check/kernel.bend:1430`, kw_restore_definition | On successful template checking, restore kw_book(world) captured at that check's entry | The captured entry was clean whenever the incoming bit was False; this does not restore an older event-loop world. Failure retains the actual returned world. |
| `check/kernel.bend:1614`, kw_bound_book | Replace cache-bound metadata or add one cache sentinel | The raw definition tail is unchanged. Private incoming worlds already carry the normal cache. |
| `check/kernel.bend:1626`, kw_temporary_fresh | Bound update, or retain the book while adding deferred roots | Same argument; fresh state is unchanged by the candidate. |
| `check/kernel.bend:1479`, kw_owner_fresh | Retain book, change deferred roots | No publication change. |
| `check/specialize.bend:429`, sp_live_body | kw_bound_book then book_put of declared instance | Both preserve cleanliness; memo/fresh fields are retained exactly. |
| `check/specialize.bend:435`, sp_live_done | On success book_put of completed instance; otherwise original result | Both branches preserve a clean incoming book. Checked bodies and memo transitions stay original. |

kw_with_book is a plain constructor; its reachable callers are the temporary
binder insertion and captured-entry restoration above. kw_book/kw_memo/kw_fresh/
kw_checked merely project fields. Other KWorld constructors found outside this
closure are initializers, checkpoint drivers and event publication, not hidden
mutations inside check_definition_world. This source closure must be refreshed
if new checker mutation sites are added.

The argument is about genuine well-formed parsed/compiler worlds in the existing
private checking route. It does not license callers to fabricate a False bit,
forge inconsistent caches or inject malformed raw host values. New helpers stay
private. Existing regular-event and prepared-world admission is not broadened.
The fallback and original reference remain available for the established raw
control lanes; malformed host-value demand ordering is not a new claimed lane.

## Failures, restoration, admission and routing

The new loop calls unchanged event_error before checking, unchanged
check_definition_world with p143cs_mode, and unchanged dg_event_failed on a
check failure. It retains exact seen history, first-error ordering, diagnostic
payload, term/type/uses/consumed fields, memo, fresh state and checked bodies.
Final canonicalization is unconditional on outward logging results, including
guard and check failures. Logging=False executes the original loop directly.

Prepared initialization retains check_declarations, base_prefix_world_order,
bound/stamp/delta arithmetic and checked bodies byte-for-byte. The surrounding
ready/disjoint-name/constructor/bound and full-hash-collision fallback gates are
unchanged. Starting True means the first clean-state fact is established by the
same existing canonicalization even if initial Base/suffix ordering is unusual.

Crucially, p86_plan_loaded only selects this logged checker when
p143cg_enough(suffix,256) succeeds. Base declarations do not count. The two
Phase155 transfer inputs had 603/504 total events including Base; those counts
did not establish active ordinary routing. The new p156cp_enabled and route
helpers expose exactly this unchanged gate. Small controls may call the private
checker directly, but active performance requests must prove enabled=True.

## Load-only and observation boundary

The module includes renamed copies of the p86_plan ancestor loader chain,
ending at FPrefixLoad instead of entering checking/annotation/erasure. Its path,
location arithmetic, import admission and prefix completion are unchanged.
The harness must require P156CLoadReady and empty trace.result.error before
checking, just as the original p86_plan_loaded does. Base comes from actual
external IO through p86_prepare; no large embedded Base fixture is needed.

p156cp_reference_load preserves the original admitted prepared path and its
fallbacks. p156cp_route selects it or the candidate at runtime, with original
base_prefix_check_world_load below the unchanged threshold. Compare full raw
DChecking values first. Any native timed consumer must traverse complete worlds,
diagnostics and final output and charge setup/destruction explicitly.

## Controls, exposure and stop rule

`experiments/phase156/publication/spec.json` lists exact replacement/extraction
instructions and exports. fixtures.json targets consecutive ADTs, dirty-to-clean
transitions, law/fill and open laws, duplicate/type failures, template restoration,
instance creation and subsequent failure. Repeat logging=False and the existing
deferred-fresh, collision and malformed-event data controls. Genuine prepared
world tests must include admission refusal and unready fallback, independently
of the ordinary routing gate. These are pending checks, not asserted passes.

A cheap real active workload is the current checker named closure (435 distinct
names in the mutation audit, not435 declaration blocks). The executed checker
fixture has645 suffix definitions and its256-childless routing gate is confirmed
in `controls02`. Do not inflate an unrelated fixture or regroup ADTs.
Current full source has 369 static type declarations in 75 runs, hence 294
adjacent type pairs as explanatory exposure, not measured dynamic savings.
Phase153 puts all checking/publication at 33.568s; even eliminating that whole
stage cannot independently establish a 20% whole cold-build gain. Stop before
full acquisition if actual complete-region timing is weak or any full-state
comparison fails. Constructor-cache integration remains deferred rather than
being combined with an untested canonical-state candidate.
