# Public string identity and wider borrowed records

Metadata/source review only, against final combined source
`1bc5930edcf80cda6c3572645df3c846fa631a83c2b936f20c83b05e0a6728f9` and retained
Phase128 runtime. No compiler gates or runtime functions are changed here.

## Owning public equality shortcut

The supplied Bend reflexivity law justifies the scalar result for valid finite
immutable String values. Runtime ownership is a separate obligation.

An exact full-64-bit Term comparison at the **owning** `$direct.p88_string_eq`
entry may return True when the inputs match, provided it consumes both input
owners with their original sink operations. For `$direct.p88_string_eq_go`,
also require the pending comparison flag to be True. With False, the function
must preserve its original result even when the remaining tails match.
Arguments are already evaluated; this shortcut must not move before source
argument evaluation or suppress effects that produce them.

The same-root rejection in `p118_rt_borrow_scalar_safe` is not applicable as a
legality rule for this different transformation. That guard refuses observing
with two adapter-owned aliases that might be the final two references. The
identity shortcut observes no fields and performs both releases itself.

In `runtime-borrow01/runtime.c:929`, `term_drop` decrements a shared reference
count and follows/frees the payload only when the previous count was 1. Thus
with two owning aliases and count 2, the first sink leaves count 1 and the second
reclaims the object. No contents may be read between or after the sinks. With
additional retained aliases, those aliases remain valid. Empty/trivial strings
also need both conceptual consumes; their sinks are no-ops. A duplicated unique
non-RFC raw pointer is not two valid owners and is outside this proof.

A **private borrowed** reader has the opposite obligation: never sink these
arguments. A scalar identity law does not allow treating an owning adapter and
its borrowed worker as interchangeable.

Keep the original body as the unequal/pending-False branch. Use complete Term
identity, not only payload location or hash: tags, constructor metadata and RFC
representation are part of identity. Malformed foreign words can make the old
code fail while an unguarded identity path returns True; the claim is therefore
for values admitted as valid String inputs. It does not cover corrupted heaps,
arbitrary FFI words or cyclic invalid representations. Pure string reclamation
has no user-defined finalizers; allocation/profiling events can differ.

Minimum native controls: empty, nonempty and Unicode self-equality; equal
separately allocated strings; unequal strings; pending-False self-tails;
exactly-two owning references; additional retained root aliases observed after
the call. Reuse the independent ordinary oracle and compare both root sinks in
actual QBE/machine code. The provided reflexivity law alone does not replace
these ownership checks.

## The eight-field restriction

KDef has 9 fields in its main constructor, plus two-field KIndexLeaf and
four-field KIndexNode constructors. Its type contains recursive structures that
must remain opaque unless separately supported.

The number 8 is conservative in this path, not a physical buffer/ABI limit:

| Layer | Current restriction | Consequence for a 9–16-field experiment |
| --- | --- | --- |
| `nol_fields` / `nol_ctor_fields` | telescope/descriptor count ≤ 8 | Extend bounded layout derivation after checking the same telescope/type conditions. |
| `p131rg_width` | zero or 2–8 | Permit 9–16 only with the same opaque-field nonescape rules. |
| `no_layout_valid` | Boxed width ≥ 2, excluded native constructors | Already has no 8 upper bound; changing it is unnecessary. |
| `p118b_project_borrow` | exact known constructor/count, 2–8 | A derived-import contract extension is required; preserve exact descriptor arity and original pointer/capacity verification. |
| `p128bf_match` / field-template oracle | 2–8 | Can remain unchanged initially: wider imports retain the original runtime fallback. |
| direct scratch / generic buffer verifier | 2048 bytes; count ≤ 255 | 9–16 fields require 72–128 bytes and fit without relaxing protected gates. |
| `p118_rt_borrow_fields` | exact descriptor count and valid output; no 8 cap | Existing runtime handles the wider copy; no runtime edit is required. |

The buffer facts are explicit in `p113e_seed` (state 2088 bytes,
scratch 2048 bytes), `p111v_buffer` (count ≤ 255 and capacity ≥ 8 × count), and ordinary
memory offset checks. Helper parameter-count and local continuation limits of 8
are distinct from fields inside one record; do not widen those incidentally.
Likewise constructor-budget 8 is a count of constructors, not a field count.

This is not merely changing one constant: both semantic layout discovery and
the independent derived-import contract currently refuse the request. A safe
extension keeps constructor identity, exact width, typed root, held origin,
alias/fallback rules and final structural verification. Wider opaque fields
must stay unread and must not escape as return values or borrowed call inputs.
Keep the initial inline template at its already checked width; a 9–16 template
requires wider state-oracle tests and an instruction/profitability measurement.

## Cheapest falsifier and expected work

First use an actual 9-field KDef-shaped record and a scalar whole query
`String.eq(dn(record), key)` on retained roots. Compare its ordinary owning
baseline with a frozen borrowed-runtime ceiling, with exact output and alias
observations. Add an unrelated 16-field record to test transfer. This tests
whether eliminating reconstruction/ownership work is worth the generic wider
field-copy cost before acquiring a new full compiler image.

The important compiler workload is a scalar query over KDef or List<KDef>.
Merely admitting the layout cannot optimize `f_find` or `index_bucket` returning
an owned KDef; escaping results retain ownership/materialization obligations.
A name getter returning owned String alone is also insufficient. Preserve the
complete scalar consumer when measuring this capability.

A bounded implementation experiment is approximately 30–60 minutes for layout
and derived-contract changes plus finite/native controls, using existing checked
API acquisition and small emissions. Native compiler qualification is separate.
There is no honest whole-compiler gain estimate without measuring how often
such queries remain exposed after inlining and how much ownership work they do.

Required controls include widths 8/9/16, refusal at the chosen upper boundary 17,
wrong descriptor arity, malformed field telescope, insufficient output buffer,
wrong pointer/state type, unknown constructor, held aliases, opaque nested
payloads and unchanged fallback. Existing protected verifier declarations should
remain unchanged; the wider derived contract must still pass them. Stop if the
ceiling is neutral or the relevant caller has already inlined away the query
boundary. The recent dead-field ceiling also warns that copying every field may
erase the benefit: wider admission and selective demand are separate hypotheses.
