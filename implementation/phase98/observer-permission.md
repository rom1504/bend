# Phase98: separating observer permission from array representation

Source review supports a small, scoped experiment: admit the existing borrowed
observer analysis for the native host's nine authenticated providers while
keeping packed arrays, typed scalar narrowing and constructor-sharing permission
on their old certificate. **This is not a flag-only runtime change.** The isolated
candidate has been prepared, but this review ran no compiler or program targets.

Candidate: `selfhost/build/phase98/observer-permission-source01/compiler.bend`,
SHA-256 `2293f8e79216f42774b17ef2ddd592081863cf147b6c2371dbc734311352a3e3`.
Its [producer](../../selfhost/tools/performance/phase98/observer-permission/prepare.py)
records five exact reversible function edits from D04 and an unapplied patch
for three maintained modules. It adds37 physical lines. Production, runtime,
providers, driver and installed images are unchanged.

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

## The prepared split and its boundaries

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

Enabling observers also enables the existing planned-worker path in
`ns_compile_named`, including private host call facts. Therefore performance
attribution must inspect these routes too; a speed change cannot automatically
be assigned solely to the borrowed equality loop.

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
