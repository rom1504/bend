# Hybrid direct-first: the smallest route beyond closed libraries

Source-only proposal at Phase163. No target execution, production patch or new
performance claim. The direct-only experiment must establish its economics
before this larger interface change is attempted.

## Concrete route

Keep one prepared request and the existing compacted `NativeStaticBody` cache.
Construct `p113pl_candidates`, tail-SCC candidates and their existing ordered
admission **before** generic lowering. Select only positively admitted ordinary
boxed one-result entries; keep every other definition on the original generic
path. Do not require the entire compiler root to be a closed direct library.

For an admitted owner, retain its actual scheduler entry and any closure factory,
but replace the redundant scheduled worker body with a real adapter to its
verified native worker. For a nonadmitted owner, retain all of `p111_entry` and
its continuations. Preserve the original raw candidate list for later ownership
composition/retries, and keep the existing direct optimizers and final verifier.

The insertion point is
`selfhost/src/back/common/constructor-facts.bend:202`, `p144o_lower_bangs`, which
currently evaluates both `p111_compile_defs` and `p113pl_candidates` before
`p128raw_plan_finish`. The prepared body is already shared; the proposed saving
starts after preparation.

## What can actually be omitted

`back/qbe/lower.bend:613–649` gives the exact split:

- `p111_entry` creates a zero-argument factory/eta entry when appropriate.
- `p111_extend` additionally lowers the reapplied body into its argument-taking
  scheduled `$direct.*` worker and that body's continuations.
- `p111_compile_step` collects the factory, worker and continuations.

For arity greater than zero, preserve the factory construction and replace only
the admitted worker side of `p111_extend`. For arity zero, the admitted source
entry itself can become the adapter. Compute owners with `p113d_public` and
`nc_ref_name`; do not assume source spelling or the `$direct.` prefix.

Initially reject omission when the entry would need nonstandard flags, incoming
captures, multi-results, foreign/bang behavior, or an escaping closure not
represented by the retained factory. Keep full generic lowering on that owner.
Record omission ownership explicitly: a continuation may be omitted only when
it belongs to the skipped worker lowering and has no retained references. Do not
filter globally by `$p111.k.*` spelling after emission.

## Function IDs and continuation freshness

Current jumps, frames and closure construction carry `N111FuncId{name}` in typed
IR (`lower.bend:367,408,533`). Numeric IDs are assigned later from the final
segment list by `p111q_function_ids` (`emit.bend:223`). Consequently a hybrid can
regenerate a consistent ID map after assembling real generic segments and real
adapters. All descriptor tables and emitted references must use that one map.

There is no need to keep old numeric positions merely for correctness. Removing
continuations also changes the global fresh counter and later continuation/local
names; carry the returned fresh counter from each retained lowering normally so
new generated identities remain unique. Do not reuse a counter value across
retained owners.

Preserving **byte-identical old QBE** would require retaining old segment-ID
positions and knowing skipped fresh-name consumption, which currently comes
from lowering the skipped body. That defeats much of the first experiment.
Target complete semantic output and deterministic new self-reproduction, with
old/new output changes reported as a new qualification boundary. Source-level
function identity, constructor identity and internal references must remain
consistent; external/raw saved FIDs from another executable are not supported.

## Independent mixed-verifier contract

Do not represent an omitted body by an empty `N111Segment`, or pass it through an
old successful-verification certificate. The new boundary must distinguish:

1. **Generic segment:** unchanged `p111v_segment` validation against the complete
   final header/constructor schema.
2. **Direct adapter:** actual entry metadata plus actual fixed adapter body,
   independently checked against an admitted one-result direct signature.

An explicit `Generic(segment) | DirectAdapter(metadata, owner)` descriptor is
the clean representation. A bounded additive prototype may carry a separate
adapter map and real `N111Segment` bodies, provided the mixed checker dispatches
on that authenticated map and never accepts arbitrary calls merely because
their textual symbol starts with `p113d_`.

For each adapter independently require:

- unique source/entry identity, exact source arity, zero incoming captures,
  one result and ordinary flags;
- a present final direct function with matching name/argument count/result;
- exactly the current `p113e_public` calling convention: load every argument
  register once, pass borrowed state and argument words in order, capture the
  owned word result, call `p111_rt_return` with one result, and return its reply;
- no other effect, user callback, extra runtime import or arbitrary body;
- valid constructor/static tables and the real executable entry/readback
  descriptor.

The unchanged ordered direct verifier then checks every native worker against
the final header schema and direct dependencies. It must still reject unknown
calls, incorrect arities, illegal FIDs, bad pointer use, and ordinary recursive
cycles. Self-tail calls remain `P113DAgain`; eligible tail pairs retain the
existing checked SCC transformation. Direct admission stays closed over direct
callees, so the new adapter does not introduce a direct-to-generic cycle.

The current opening boundary, `p114s_open`, first calls `p112s_verify` and only
then verifies direct functions (`checked-boundary.bend:18–37`). Replace that
specific original-program check with the explicit mixed check; do not simply
set `valid=True`. Preserve `p114s_commit`, inlining, scalar/array namespace checks,
`p146c_finish`, ownership composition and final direct verification. Header facts
used by `p113e_originals` must come from actual adapters/generic segments, never
invented scheduler bodies.

Retain a final obligation set of omitted owners. If any later transformation
removes an obligatory boxed entry without an equivalent replacement, refuse the
hybrid result or materialize that owner's generic fallback and reverify. A raw
initial admission alone does not authorize a dangling adapter at final emission.

## The less obvious blocker: preserve generic-to-direct fast calls

Simply removing generic bodies can preserve results yet slow execution.
`p112c_index_with` currently derives the region registry by inspecting generic
bodies (`closed-regions.bend:396–492`). Its `ready` and `symbols` maps permit
generic callers to use `p112w_*` machine entries. `p113e_old_private` emits those
entries as forwarders to final native workers when possible
(`verify-direct.bend:389`).

A tiny adapter is not the same analyzable body as the old worker. If it disappears
from the registry without a replacement, a generic caller can fall back to
`rt_jump` even though its target has a native worker.

Give positively verified adapters an explicit **direct import** registry entry:
the entry records its exact arity, one-result ABI and verified target. Emit the
same ordinary `p112w_* -> p113d_*` forwarding function as before. Seed these
imports before normal registry passes so generic callers can still resolve fast
calls. Validate imports separately; do not forge a `P112WorkerPlan{valid=True}`
for an absent body. The dependency rank must denote an already closed native
worker, not arbitrary mutually recursive imports.

Run existing fusion/local-continuation analysis only on real generic bodies.
Adapters still participate in function-ID/header tables, public wrapper emission
and target resolution. This removes their redundant body scans without
discarding the fast-call information the rest of the compiler needs.

Most later ownership planning uses the actual source/native book and direct
functions (`ownership.bend:53`, `borrowed-regions.bend:431`). Preserve that input
and the raw candidates. The first hybrid need not invent a new ownership pass.
Where a later stage explicitly requires original headers, adapters provide real
headers; where it needs a generic body, retain that owner until an equivalent
summary has been demonstrated.

## Cheapest honest prototype

After direct-only economics are known, start with one positively admitted owner
inside a **mixed** request: `book_final_reverse` called by a deliberately generic
caller, with a retained closure/factory use as a second control. Keep every other
owner unchanged. Add the real adapter, mixed verifier, and verified direct-import
forwarder together. Check complete results, malformed signatures, lost target,
ordinary generic-to-direct calls and a long list. This tests the actual hybrid
interface rather than another all-direct program.

Then increase the omission set to all initially admitted boxed entries, keeping
the final-required-owner check and all later optimizers. Record candidate count,
omitted workers/continuations, generic IR nodes, registry entries, output size,
construction time, and generated-program time. Compare like-for-like source and
constructor/static catalogues. Do not count a refused owner as optimized.

The Phase16111.59s generic-production envelope bounds direct savings from that
one stage. This change can also remove attributable verifier/registry/render
work, but leaves private candidate construction and retained factories intact.
No claim to eliminate the full11.59s is justified before counting admitted
owners' contributions.

## Offline machine census and its limits

The following is a fresh read-only scan of the qualified
`selfhost/build/phase152/native-n2/program.ssa`. Symbols were decoded from their
decimal-byte names; function text spans and call presence were counted. No target
was run, and no new hash of the118MB file was needed; its identity is recorded in
the sibling direct-first audit.

| Emitted family | Functions | Function-text bytes |
| --- | ---: | ---: |
| `p113d` native workers | 2,254 | 22,891,518 |
| `p111` scheduled entries/continuations | 56,649 | 82,212,762 |
| `p112w` wrappers/regions | 14,929 | 7,078,438 |

There are1,448 native workers with same-name scheduled entries;1,420 use the
canonical `$direct.*` owner naming and28 use other names. All1,448 scheduled
entries already call a native worker. Those wrappers total808,182 text bytes.
They are **required interfaces**, not1,448 still-slow execution bodies.

There are48,096 emitted `$p111.k.*` continuation segments totaling66,056,209 text
bytes. This scan cannot independently attribute them to admitted owners after
fusion/optimization. It is therefore incorrect to claim all48,096 can disappear.
The1,448 paired entries are an observed final-owner opportunity, not a guarantee
that all were admitted before later ownership/TRMC transformations, and not a
percentage of arbitrary compiler functions supported by direct-only emission.

For larger transfer controls, combine roots from the sibling audit: lookup,
`f_find`, `p111v_value`, `p111q_value/args/descriptor/ctor_table/string_defs/words`,
and `p113e_signature`. Keep scheduled `constructor_exists`, `book_final_scan`,
`p111q_tables`, and `subst` as explicit negative/coverage controls. A whole-compiler
hybrid can support these via generic fallback while a closed all-direct library
must refuse them.

Extra root closures and tables matter: `p163d_plan` follows a union of root
closures, then may retain all admitted auxiliary candidates in that union; this
is not a minimal final machine call graph. Constructor tables currently come
from the actual entire request source catalogue, and static preparation covers
selected reachable definitions. Count these separately when increasing roots.
The executable adapter adds only its actual scheduler entry; library export
wrappers and standalone library tables must not also be charged as required
executable machinery. Source02's plan/render split already avoids the earlier
duplicate library rendering.
