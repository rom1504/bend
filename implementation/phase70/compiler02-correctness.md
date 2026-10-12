# Compiler02 correctness review

Historical checkpoint: compiler02 was superseded by
[compiler03](compiler03-correctness.md), which removes the occurrence-insertion
experiment after it failed the performance retention gate. Its helper controls
and native results below remain compiler02 evidence; the helper does not ship
in the selected successor. P70-008's ordinary-ready skip also remains unapplied.

The compiler02 Phase70 B1 candidate passes its strict checked build, 100 selected
native golden controls, 31 raw-API controls, focused occurrence and Bool controls,
and unchanged-JS closure comparison. Upstream passes 93 of those native goldens;
the other seven are exactly the known unused-demand differences. The paired
workflow therefore correctly reports failure. Genuine B2 production and eight
driver observations pass; B2 self-check and B3 qualification remain pending.
This is candidate readiness, not release installation or full upstream conformance.

The reviewed derived B1 API is
`f326862f5163fce83e47642c9b8dcfdb6596683bafe36054b7fb6d5430376f2f`.
The [portable checkpoint](evidence/compiler02-correctness-checkpoint.json)
records its identity, exact source hashes and the initial focused-control checkpoint.
The [native/raw/driver follow-up](evidence/compiler02-native-raw-driver-correctness.json)
pins the completed broad results and exact seven upstream observations.
This reviewer read source and retained data on CPU0; root executed all targets.

## Source changes at the compiler02 checkpoint

The then-current `bridge.bend` and `scalar-array.bend` matched the compiler02
checked snapshot. Relative to the prior observer integration, they added ten
lines for occurrence insertion and add Bool to one existing allowlist. Neither
change alters the native runtime or introduces a new IR or public API.

`nc_uses_put` skips replacement when the complete U32 variable ID already exists
in the occurrence set. The collector starts empty and inserts one immutable
marker into a singleton bucket for each ID. Under that invariant, generic
insertion reconstructs an identical tree, so returning the original tree is
equivalent. Empty and novel-key insertion still use the existing leaf/insert
operations, and the existing tip search is performed only once. No production
caller supplies a legacy or arbitrary index to this collector; no equivalence
claim is made for forged internal-helper arguments. Malformed raw Var nodes
still act as leaves, preserving the previous occurrence policy.

The scalar-array change admits trusted Base Bool alongside U32/F32/Char. Checked
Bool producers yield exactly 0 or 1, and closure, scheduler, constructor-field,
word-view and product transport preserve those bits. Packed 32-bit storage is
therefore exact and carries no element ownership. This does not make all arrays
unshared: aliasing still uses the separate unshared certificate. User enums,
unknown foreign effects, raw compilation and explicitly untrusted effects keep
the generic representation. The checked entry remains a trusted precondition;
this is not authentication for callers forging a supposedly checked book.

The same packed permission gates observers. Adding one immediate scalar element
does not add mutable root handles, foreign access, or root-identity observation;
the separate observer schema and origin proof remain required. See the
[full Bool audit](../../selfhost/tools/performance/phase70/coverage/bool-admission-v2/README.md)
and [observer review](../../selfhost/tools/performance/phase70/observer-controls/source-review-v2.md).

## Completed checks for compiler02

| Gate | Finished result | Scope |
| --- | --- | --- |
| Strict checked B1 build | Pass | Checked snapshot and derived B1 API above; not a genuine B2 claim |
| Occurrence helper comparison | 38 terms, 67 IDs, 2,546 membership queries per role; 228 ordered partitions and 228 sharing queries per role | Complete indexes, ordered output and independent membership/string oracles agree |
| Repeated occurrence work | Repeated-single insertion calls 63→0; leaf calls 64→1 | Diagnostic invocation counts, not compilation-speed measurements |
| Bool native controls | Candidate 7/7; upstream 7/7 | Updates, clone independence, shared mutation, mixed scalar types, producers and two refusals |
| Bool admission controls | 9/9 | Actual emitted flags; seven programs plus raw and false-effect-permission calls |
| JS protection | 2,992 reachable functions, all 100 public wrappers and runtime bytes unchanged | Exact original nonnative dependency closure; no broadened root exclusion |
| Selected native controls | Candidate 100/100; upstream 93/100, with exactly seven expected demand differences | Complete selected candidate run; paired workflow complete but fails |
| Raw API controls | 31/31 paired passes | Exact legacy/error/ownership boundaries and three observer metadata/node rejection controls |
| Genuine B2 production and driver | Image emitted; 8/8 driver observations agree | JS results executed and JS/C emitted bytes compared; C emitted only at this gate |

The shared Bool-array control enables scalar storage but keeps
`UNSHARED_ARRAYS=0`. Enum, foreign, raw and untrusted-effect controls keep scalar,
typed-scalar and unshared flags zero. The nine admission checks emit C; their
count must not be presented as nine extra native executions.

The occurrence comparison preserves original input bytes and entire summary
values. Three duplicate-heavy terms reduce insertion work; the unique-ID case
retains the same tip/insert/leaf work. Earlier occurrence-summary and reuse
optimizations already existed; this change specifically avoids replacing an
existing key.

Selected conformance reports may have `complete=false` for the repository-wide
inventory while `selectedComplete=true` for the requested cases. The enclosing
seven-case workflow is complete and passes both roles. This is seven selected
native cases, not the full repository test inventory.

## Observer diagnostics and known upstream differences

The preceding observer-emission02 image passed four adapter/error diagnostics
and two recursive demanded-error controls with actual adapter-entry markers.
Keep these earlier-image results separate from compiler02's final broad gate.
The four include one real shared-root route and three explicitly instrumented
host shared-error visibility checks. They do not establish physical GPU behavior,
production host asynchronous cancellation or normal failure teardown.

The first straight-line error diagnostic produced the expected overflow but
never entered the observer adapter because an ordinary private worker handled
the call. That failed coverage attempt remains preserved. Recursive successors
reconstruct the root after recursion, forcing the ordinary non-tail worker to
decline; their markers and exact overflow then qualify actual observer demand.

The new source controls expose one existing class of upstream difference:
unused computations can overflow in the self-hosted compiler while upstream
discards them. Five original controls plus two recursive variants cover this
class. The original five also fail with the expected overflow on the
pre-observer compiler01, proving those differences predate observer integration.
The two recursive variants preserve that behavior through the new observer.

The final compiler02 100-case gate confirms **100 self-hosted golden passes**
and **93 upstream golden passes plus exactly seven expected mismatches**, with
no changed inputs or unexpected failure IDs. Each differing upstream program
returns `7080` with exit 0; the self-hosted result is the expected Nat overflow
with exit 1. The conformance harness records that error in its stdout/output
field. These are seven programs covering a known demand difference, not seven
independent bugs. The enclosing paired workflow is complete and correctly has
`pass=false`; this is not a 100/100 paired conformance pass.

The genuine B2 image is
`7c638e4ae4ae57a9ae759247a30ede1b27a24a2d07e239d94c0b2ee9828cee56`.
Its eight driver observations agree with B1, including emitted JS/C bytes and
executed JS results. This gate emits C without executing those C outputs and
makes no compiler fixed-point claim.

## Still pending

- Genuine B2 self-check, B3 and final native qualification.
- Final B1/B2 C compilation-request timing; diagnostic call counts do not prove a speedup.
- Release installation and the final portable evidence bundle.

The existing source review finds no blocker in either final edit. Promotion
still depends on these remaining gates; completed focused controls do not
substitute for them.
