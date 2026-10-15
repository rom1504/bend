# Phase98: separating observer permission from array representation

The scoped permission split passes small native qualification and the complete
1,444-pair string corpus. A synthetic repeated shared-string workload takes
0.145866× baseline process time; actual compiler gains remain a separate
integration measurement. Root ran all targets serially; this reviewer performed
source audits, prepared frozen methods and verified receipts offline.

Qualified isolated source02 is
`selfhost/build/phase98/observer-permission-source02/compiler.bend`, SHA-256
`9f4e516a9bd5b9134a3f0fd29017ee441bbad63f844a75a61517a5b877da0a94`.
Its [producer](../../selfhost/tools/performance/phase98/observer-permission/prepare-v2.py)
records seven reversible original-function edits,16 introduced/changed function
declarations and an unapplied patch for four maintained modules (+55 physical
lines). Packed arrays, scalar widths, cold constructors, planned host selection
and checked product admission keep their old authority; only observer admission
is separated. The earlier +37-line source01 and its failed admission are retained.
Final composition and independent proof connections are detailed below; this
report alone does not qualify a compiler release.

## Why the current gate refuses

[`ns_definitions`](../../selfhost/src/back/native/scalar-array.bend:44) checks
the reachable program for one scalar-array representation and permits only
`IO.args`, `IO.print` and `IO.now`. Both
[`nc_compile_checked`](../../selfhost/src/back/native/scalar-array.bend:60) and
[`nr_compile_prepared`](../../selfhost/src/back/native/request.bend:49) pass
that same `packed` Boolean as observer permission. Consequently a supported
file provider or `IO.print_err` disables unrelated string observers as well.

The authenticated native compiler entry already supports nine providers and
passes its externally established effect permission to the checked entry.
Its actual D04 `p86_effect_file` is at line38437, and `p86_compile` at38487;
the older Phase88 standalone entry still lists only three and must not be
mistaken for the installed entry. The native launcher verifies exact Base,
runtime and all nine provider bytes before execution. The JS driver's separate
three-provider hash table remains narrower and is unchanged by this proposal.

The [real I/O code audit](../../selfhost/tools/performance/phase98/comparison/held-code-shape-own-io01.json)
already establishes the symptom: `IO.print_err` gives observer/scalar flags0;
the equality walker has three static `ctr_take` sites and no borrowed observer.
The pure control emits an observer. These are static facts, not dynamic counts
or an estimate of removable time.

## Scalar ABI audit

`NATIVE_TYPED_SCALARS=0` does not box every scalar. It selects `Term` instead of
`u32` for certain C locals and private parameters; the same native scalar values
remain immediate. The existing observer emitter declares full `Term` values.

| Value | Existing representation with typed narrowing disabled | Observer consequence |
|---|---|---|
| Char | `nc_constructor_value("Chr",...)` returns its U32 word unchanged; the Chr field reader is identity. `io_str` writes decoded codepoints directly into SCon fields. | Full unsigned character values remain available. No byte truncation or UTF-8 reinterpretation is needed. |
| U32 / F32 | Their native values are32-bit words held in `Term`; construction from structural Word uses `term_word`, while destructuring allocates `native_word`. | Scalar primitives remain valid; the observer schema deliberately excludes structural U32/F32/Word views. Do not remove that exclusion. |
| Bool | Ordinary constructors emit0/1. `native_bool` also accepts the established generic tagged True form. | No scalar narrowing is enabled; existing `nc_condition` and primitive templates retain generic Bool handling. |
| Nat | Immediate bounded native Nat, with existing checked arithmetic/error behavior. | This does not establish arbitrary-precision semantics or justify erasing overflow checks. |
| Other nullary enums | Native constructor tags in `Term`. | Existing enum schema/constructor identity checks remain necessary. |
| Array / File | Arrays have separate mutable block ownership; File is a foreign handle. | Neither becomes a borrowed recursive root merely because permission is enabled. |

Source anchors: [constructor and field ABI](../../selfhost/src/back/native/bridge.bend:356),
[generic Bool matches](../../selfhost/src/back/native/bridge.bend:425),
[private scalar kind](../../selfhost/src/back/native/flat.bend:86),
[C local type](../../selfhost/src/back/native/layout.bend:2),
[observer reads](../../selfhost/src/back/native/observer-emitter.bend:64),
[scalar schema](../../selfhost/src/back/native/observer-layout.bend:57),
[runtime Word conversion](../../selfhost/src/runtime/native/runtime.c:927),
[runtime string creation](../../selfhost/src/runtime/native/runtime.c:2438).

This is source correspondence under the documented checked Base/runtime ABI,
not a theorem about arbitrary forged `KDef` values or arbitrary C effects.

## Provider audit

The nine admitted provider snapshots are byte-identical to the maintained copies
inspected here. Exact pins, including runtime
`9e1c59078878be94052cb4d2d63a713e19e29b41ed3f94b034f2175a50efd0a9`
and Base `99ac43f2…`, are in
[source-audit.json](../../selfhost/tools/performance/phase98/observer-permission/source-audit.json).

| Exact Bend API | Relevant effect on immutable roots |
|---|---|
| IO.args | Constructs fresh strings and a list; does not expose a string heap address. |
| IO.print / IO.print_err | Consumes its owned string through `io_cstr`/`io_cbuf`, copies UTF-8 to a separate C buffer and prints it. It is not a borrowed callback. |
| IO.now | Returns a native immediate timestamp. |
| File.open | Consumes path/mode into separate C buffers; produces an opaque file handle or fresh error data. |
| File.read | Reads into a C buffer, constructs a fresh String and returns the handle alongside the result. |
| File.size | Produces a U32 size or error and returns the handle; no string-root identity. |
| File.write | Consumes data into a separate C buffer before asynchronous OS writing; it does not retain a Bend string pointer in the I/O worker. |
| File.close | Consumes a handle, returns Unit; does not read a String root. |

`io_cbuf` does use normal `ctr_take`/release on its owned argument. The claim is
not that providers are read-only: it is that they respect ownership and do not
retain, expose or mutate a borrowed immutable root. The observer residual itself
cannot call any provider. `noa_reference` rejects foreign helpers and dynamic
applications; borrowed cursors stay within one synchronous native traversal.
File.read_bytes/read_at share a provider file but are **not** newly admitted by
the exact nine-function certificate.

## Initial source01 split and its boundaries

`no_effect_definitions` now requires trusted native intrinsics, or a filled
trusted Foreign body with an exact allowlisted API, or an ordinary filled Def
whose syntax has no `Rwt`. Missing and unfilled foreign definitions decline.
The new syntax scan deliberately preserves the old rewrite refusal while
allowing unrelated generic arrays. Typed observer schema, origin tracking,
exact reconstruction, residual operation admission and dependency admission
remain unchanged. A successful coarse certificate alone emits no observer.

`packed` and `unshared` calculations are byte-identical. The new observer
permission is separately combined with `effects_safe` at both checked entries.
New internal `ns_compile*_scoped` functions carry a separate sharing permission;
compatibility wrappers preserve prior entry signatures. This matters because
the previous `observers` argument also reached `nh_macros`, which can authorize
`NATIVE_COLD_CTORS`. Merely replacing the last argument with True would have
widened more than borrowing. The candidate sends the original `packed` value
to that sharing analysis and does not enable new field-width or cold macros.

The initial split also widened the planned-worker path in `ns_compile_named`,
including private host call facts. The subsequent audit found a checked-product
admission coupling as well. Source02 below preserves both old permissions; they
are not part of the measured observer-only intervention.

The current integration has two routes. Root-preserving product observers
replace a scheduler entry; an ordinary private product worker can bypass that
entry. Scalar observers instead prepend a shared-root redirect to the existing
owning worker, retaining the original unique-root path. The latter is already
implemented in [no_scalar_redirect](../../selfhost/src/back/native/observer-integration.bend:118).
This means original `p88_string_eq_go` may benefit without adding a held wrapper.
That is a testable possibility, not established coverage of the compiler's hot
calls. Inspect the exact worker selected before rebuilding a full image.

## Qualification and stop conditions

The [qualification plan](../../selfhost/tools/performance/phase98/observer-permission/qualification.json)
reuses existing methods and cases. The18 direct finite certificate inputs cover
all nine exact providers, unknown/user-spelled/unfilled names, missing lookup,
ordinary filled code, rewrite refusal and array independence. They test helper
classification, not adversarial authenticity. New source controls are frozen
but have not passed source admission yet; preserve any first failure.

1. Check both checked entries, raw entry and false effect permission. A copied,
   byte-modified provider must fail host authentication. Never modify admitted
   artifacts to construct that negative.
2. Require observer emission with `TYPED_SCALARS=SCALAR_ARRAYS=UNSHARED_ARRAYS=0`
   on the real I/O control and the shared-string/Array<String> control. Confirm
   the original cold-constructor permission remains unchanged. Array-root and
   structural Word-view functions must have no selected observer even when the
   global observer permission is1.
3. Reuse the unchanged1,444-pair full-value string corpus, alias/shared-tail and
   fresh-owned controls. Keep the existing complete held-observation law and
   codepoint law. Those constrain source behavior; they do not prove this new
   admission analysis or C lifetime bridge. The proof/read/release distinction
   from Phase97 still applies.
4. Inspect actual borrowed/owning call edges and measure small saved native
   programs. Stop before a full image if the hot call still bypasses borrowing,
   scalar ABI disagrees, ownership controls fail or the improvement is tiny.
5. Only then acquire one compiler candidate and run the balanced six-source
   comparison. Its emitted C may intentionally differ because the compiler now
   admits observers: use semantic checks and review the permitted structural
   delta, rather than incorrectly requiring old C byte identity everywhere.

There is no promised end-to-end gain. The optimization is more substantial than
a tiny leaf rewrite because it can remove repeated shared-root ownership work
across many equality callers and can apply when the compiler builds itself.
But real benefit still depends on eligibility, shared inputs and actual routing;
new whole-book analysis also has a compilation cost. A candidate B1 timing
alone does not establish a native B2 speedup.

## Successor02: separate all existing permissions

The first bounded qualifier preserved a source-admission failure: `effects_safe`
was consumed twice in `nc_compile_checked` after the new certificate was added.
No emitted candidate program ran. Source02 adds the explicit shared parameter;
`nr_compile_prepared` already had it. It also embeds the exact safe foreign-name
predicate prepared by the proof lane. The unsafe classifier and authenticated
host boundary remain outside that predicate's prospective proof.

The review found two additional uses of the old observer Boolean beyond cold
constructor selection. `ns_compile_named` selected the planned host-worker path;
`nf_plan` passed the same Boolean as `checked` to `nq_candidates_mode`, bypassing
historical product prefix-demand checks. The latter is justified by checked,
evaluated product bundles, not by scalar widths, but broadening both together
would needlessly enlarge the intervention.

Source02 therefore keeps old `packed` authority for cold macros, planned-host
selection and product checked admission. New `nf_plan_scoped` separately uses the
new permission for observer names and final routing. The fallback path still
builds its ordinary workers and then attaches these observer routes after
successful ordinary lowering; it does not disable observers when host planning
remains off. Existing exported helper signatures are compatibility wrappers.
The exact reversible derivative is
`selfhost/build/phase98/observer-permission-source02/changes.json`, source SHA256
`9f4e516a9bd5b9134a3f0fd29017ee441bbad63f844a75a61517a5b877da0a94`.
It adds55 physical lines to D04; no canonical source was edited.

The width audit supports keeping these concerns separate: `nf_param_type`
emits `NF_SCALAR`, which `nf_finish_ready` defines as full `Term` when typed
scalars are off; expanded product fields and result arrays are always `Term`.
`nq_layout` identifies only fixed constructor shells and leaves array/nested
fields opaque, while `ALeaf` lowering still reads `NATIVE_SCALAR_ARRAYS` for its
runtime representation. No new width or generic-array exception was required.
This is a bounded source audit, not a proof of every host-worker/product pass;
the conservative split avoids depending on such a claim.

A suggested shortcut `packed => new observer predicate` is not an identity on
arbitrary raw KDef lists: the old foreign classification can accept trusted
known names with an unfilled `Absent` body, while the new predicate deliberately
requires `Foreign`, and the new ordinary case requires kind `Def`. Successful
checked/filled entry may establish stronger preconditions, but source02 does
not silently weaken the explicit unfilled and forged-name controls for speed.

## Observed small qualification

Root's `observer-permission-qualify05/report.json` is complete: all18 direct
certificate cases, three actual emission groups, provider/raw boundaries and
seven generated C executions pass. This reviewer rehashed189 pinned records
and checked the emitted policy/route observations independently. Source02's
safe provider predicate also passed its separately recorded universal-law check;
that does not prove the unsafe classifier, FFI identity or generated ownership.

For real IO.print_err and generic Array<String>, observer permission changes
from0 to1 while typed scalars, scalar/unshared arrays and both cold-constructor
flags remain0. Each equality observer has three static term_peek sites, no
keep/sink/take/allocation in the borrowed body, and a shared-root redirect from
the ordinary worker. This confirms an eligible static route, not a dynamic hit
count or speed measurement. The array/Word refusal control keeps its previous
scalar1/observer1 policy but emits neither prohibited observer. Both checked
entry points emit identical C; explicit false and raw entry keep observers off.
A separately altered provider fails authentication; an unknown provider receives
false permission. The inert forged raw context executes its exact original
value, while raw observer-return/loop nodes retain exact rejection diagnostics.

Earlier failures are preserved: qualify01 source affinity, qualify02 emitter/
guard directory collision, qualify03 incorrect harness Base-location comparison,
and qualify04's historical unknown-provider fixture failing at an unrelated
unfilled Strand law. Only the last fixture was replaced by a minimal equivalent
external effect declaration using identical C/JS provider bytes. The preserved
early source refusal earns no native-provider semantic credit.

The corrected harness authenticates the bytes of the actual installed Base,
requires the exact Base-origin effs path, mirrors typed-driver's maintained
provider resolution and checks canonical provider identity plus admitted bytes.
It records the ordinary JS driver's narrower permission separately: false for
IO.print_err and true for ordinary IO.print. This is a scoped authenticated
qualification harness, not a production driver permission change.

The prepared real-I/O corpus follow-up retains the existing38-input1,444-pair
matrix and12 original result fields, adding both complete surviving strings as
codepoint arrays. Its120,386-byte expected stdout is computed independently
from the frozen corpus. It uses the admitted APIs and two complete generated
program products rather than rebuilding a compiler image. Root's `observer-permission-corpus-check01/report.json` is now complete: both
old/new corpus products produce that exact stdout and expected stderr, plus the
reused raw boundary product passes. The reviewer rehashed the receipt's pinned
inputs and verified the1,444-pair/14-field observations. Old/new real-I/O observer
flags are0/1 with unchanged representation permissions. These finite executions
support this scoped path; they are not native lifetime proofs.

## Bounded native timing and final-source connection

`observer-permission-micro01/report.json` completes four balanced pairs with
exact output in all eight native executions. The32-line program obtains two
separate64-character equal strings from IO.args, compares them100,000 times,
and prints the deterministic count and both complete surviving strings. Real
IO.print_err keeps old observer permission0, new1. Both products use the same
ClangO2/runtime and one CPU thread; the qualified APIs produce their C.

Median whole-process time is **0.298058s baseline versus0.043477s candidate**,
ratio **0.145866×**, or about6.86× faster for this synthetic workload. The
reviewer rechecked the four orders, medians, full outputs and pinned inputs.
The guard's roughly20ms observation granularity matters at the candidate's
short duration. Equal long strings repeatedly held shared exercise a favorable
path; short tags, early mismatches, unique inputs and unrelated compiler work
can have different gains. This is evidence the route pays for substantial
shared reads, not a prediction of compiler or representative-program speed.

The source-bound `permission-declaration-bridge02/report.json` connects this
isolated permission implementation to the final composed candidate
`59b36a1ca3f7843ff7a03628cd39ed0f530ed137c4825d508a274a8e1ede2714`.
Both recipes replay exactly; all16 introduced/changed permission declarations
are byte-identical. Five direct callees differ: the p88 equality helper uses the
final held implementation; nc_compile_error_known, nc_foreign, nc_unann and
nq_candidates_mode differ only by authenticated tag-comparison substitutions.
The bridge verifies those exact differences and binds the final-source seven-law
permission and six-law tag proof closures, both independently checked/nonopaque.
Repeated inherited comparator laws are not seven plus six new independent laws.

The original small/corpus native qualification remains explicitly attributed to
source02. The bridge preserves it as separate evidence and does not label the
final image qualified: its full B1/B2 semantic/fixed-point gates and actual
compiler timing are still required. The pure equations do not prove generated
C ownership, foreign authenticity or whole-compiler correctness.
