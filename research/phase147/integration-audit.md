# Independent integration audit

The reviewed integration has no identified static semantic blocker. This is a
source audit, not a compiler-correctness proof or release qualification. No
compiler, generated program, or benchmark ran during this audit.

The baseline is commit `d0212e1792a231b08b8dbc9da54338e193d2e00e`. The first reviewed
assembled source is 3,044,053 bytes, SHA-256
`15e240909a0d27e268c69822d657e34a3ed1da0fedc58b42a9befe6e5108ec80`.
An independent in-memory assembly of the current maintained modules matched
`selfhost/build/phase147/integrated-source01/compiler.bend` byte for byte.
The subsequent classifier integration and literal-pattern simplification are
audited separately below. Source03 is the final reviewed snapshot; source01 and
source02 remain explicit historical audit boundaries.

## Exact change boundary

Comparing declaration bodies with the baseline found exactly six changed
existing definitions in the four edited implementation files:

| Definition | Change |
| --- | --- |
| `p114s_open_functions` | Initial direct-list admission uses `p147d_functions`. |
| `p114s_commit` | Candidate-list admission uses `p147d_functions`. |
| `p134v_check` | Only the changed-function check uses `p147d_function`. |
| `p111q_args` | Returns reversed string fragments instead of flattening arguments. |
| `p111q_memory` | Builds address/load/store fragments without intermediate lines. |
| `p112a_original_stmt` | Builds simple statement fragments and consumes argument fragments. |

`p134v_check` remains in `selfhost/tests/compiler/native-controls.bend`, where
the maintained assembly already includes this operational definition. Its
location was not changed or duplicated during this integration.

The new production module contains 609 lines: 71 definitions and six types.
All 77 retained declarations are normalized-identical to the measured candidate04
snapshot, SHA-256
`7352cfde6f0a0a538993e33b0e46981db74f539c60ea4a9c2fcc7fd7e1e9de60`.
Three exact experiment wrappers moved to the test observer module; four unused
helpers were removed. There is no new full-compiler copy or alternative frontend.
The maintained recipe adds this module and its inventory explicitly; the test
observer is not part of production assembly.

## Protected verification and admission

The complete `protectedDeclarations` object is unchanged from the baseline.
All **112** normalized declaration hashes independently matched their existing
manifest values. In addition, these entire files are byte-identical to baseline:

- `verify-segments.bend` and `verify-direct.bend`;
- `verification-context.bend` and `retained-context.bend`;
- `static-data.bend`, `verified-plan.bend`, and `region-emission.bend`;
- `ownership.bend`.

Thus raw verification, session misses/hits, the final actual-direct verifier,
namespace checks, and ownership-projection verification remain unchanged.
In particular, `p140v_direct_step` was not changed. The raw admission path remains
original: this matters because Phase146 retains successful raw/static validity
instead of rerunning that work at the final boundary.

The three changed admission hooks preserve their existing valid-bit gates,
exact structural/header comparisons, ready-prefix insertion order, fallback
behavior, and retained original metadata. The final `p146c_functions` still calls
the original `p113e_functions` on every actual transformed direct function.
A compact-check acceptance does not replace that independent final check.

The compact representation's equivalence is scoped to complete entries with
privately constructed schemas. Successful schema collection fixes width/kind;
flow stores assignment and dynamic capacity. Ordered schema errors, parameter
seed precedence, unequal-capacity joins, terminal arms, runtime imports, and
ready-prefix calls preserve the original decisions. Arbitrarily fabricated
schema/live pairs are outside that helper contract.

Candidate04's fused memory query preserves exact leaf identity, pointer width,
bounds, and alignment. Presence remains separate from capacity, so assigned
zero-capacity pointers remain present. Every nonlocal value has zero bounded
capacity; rejecting it directly is equivalent for accesses of four or eight
bytes. Persistent tree sharing is source-reviewed and covered by finite controls;
this audit does not claim a native ownership theorem.

## Renderer equivalence

The three renderer changes only repartition the reversed `P111QCode.chunks`
list. Expanding the fragments in final output order reproduces the original
statement strings, including separators, spaces, newlines, value/name rendering,
invalid-ID markers, and argument order. Empty argument lists retain `()`.

Memory rendering preserves the zero-offset case, temporary-name selection,
exactly one counter increment for nonzero offset, and U32 `loaduw` behavior.
Every changed arm preserves terminal/error metadata. Branch, return, alloca,
specialized dispatch, final flattening, and output boundaries are unchanged.

`p111q_args` intentionally changes its **internal Bend return type**. A source
census found one nonrecursive maintained caller, the adapted Call arm. This does
not change generated function signatures, runtime imports, calling convention,
layout, or runtime ABI. No maintained consumer relies on one chunk per line;
existing consumers carry/prepend fragments or flatten them.

The renderer before/after snapshots and patch are recorded in
`selfhost/build/phase147/render-integration01/report.json`; the verifier snapshots
and patch are in `selfhost/build/phase147/verifier-integration01/report.json`.
The integrated renderer file hashes are:

- `emit.bend`: `c9f3a0db8eb22abde614cbb42295ce183215db539d692fe1840b735cb46df2fa`;
- `tail-workers.bend`: `9856d1a90f82999d0227d1885e104cfe709cf5dfb7bc49debf6d72f5b82c2155`.

## Qualification still required

The region experiments and finite controls motivate this integration; their
speed gains are not whole-compiler gains. The next gates must source-check this
exact assembled image and compare complete selected-emitter QBE products with
the original on fixed inputs. Integration also reaches nested branches through
the existing dispatch, extending beyond the earliest straight-line renderer
experiment. Self-reproduction, relevant conformance controls, and matched full
request timing remain release gates owned by the main experiment queue.

Keeping the original independent verifier adds real code complexity. A later
simplification can share invariant decisions or strengthen proofs, but this
integration must not remove the independent check merely to report fewer lines.

## Subsequent closed runtime-name classifier

The classifier integration changes exactly one additional existing definition,
`p118z_runtime`, and adds two helpers, `p147z_runtime_111` and
`p147z_runtime_118`. Comparing the complete source01/source02 declaration sets
found no other changed or removed declaration. All 112 protected normalized
hashes still match. The original `@unsafe` annotation and
`p118z_runtime(+symbol: String) -> Bool` header are exact; the two helpers precede
their caller. Source ordering corrects the retained failed API04 acquisition;
it does not change the accepted experiment's definition bodies.

The intermediate source02 is 3,048,291 bytes, SHA-256
`d4542be8e680d401e102fa1929a1794f62f7878e76f163f121e1bb9d9cc5491c`.
Independent in-memory maintained assembly matched this snapshot byte for byte.
At source02 the `ownership.bend` hash is
`139a336a64a0c282dafda148f2665e0ca9ddd0c9f49fe010e6424c921a979d97`.
Thus that file is no longer wholly baseline-identical; its sole existing
definition change is this Boolean predicate. Its ownership-projection verifier
and all final-check declarations remain exact.

The review independently decoded every `Chr`/`SCon` accepting pattern. The result
is exactly the 18 names with nonempty original `p111v_signature` results plus
the seven original extension literals: 25 distinct strings, without additions
or omissions. Prefix dispatch is exactly `p111_rt_` or `p118_rt_`; every accepted
suffix and standalone pattern ends in `SNil`. All other constructors/characters
reach `False`. Proper prefixes, trailing characters, embedded NUL, case changes,
Unicode lookalikes, and non-ASCII characters therefore cannot become accepted
merely by sharing a prefix. All 677 independently enumerated fixture expectations
also match this decoded set in an offline comparison.

The accepted experiment is `runtime-classifier-v2.bend`, hash
`7cd4914681ad5b6e2a11108160068913ba1fe49f8ff373ab9b002b20a5642640`.
At source02, both helper bodies and the renamed entry's match body are
normalized-identical to that experiment. No runtime signature table, argument validation, runtime ABI, or
final verification was replaced. When supported runtime names change, this
closed membership table must remain synchronized with the signature table and
extension set; it is not an open-ended prefix recognizer.

The reviewed native measurement method requires CPU3 affinity, exact complete
677-bit outputs before and after timing, zero-repeat and salted-negative
controls, and exact timed totals. Four ABBA blocks compare both paths in one
binary. The measured input preserves captured symbol frequencies but groups
repeated symbols; its classifier gain is not a whole-request speed estimate.
Canonical integration still requires the combined-image gates described above.
This independent audit executed no compiler or native target.

## Final source03: readable literal patterns

Source03 replaces exactly 25 complete `SCon`/`Chr`/`SNil` patterns with matching
String literal patterns in the same three classifier definitions. Independently
decoding each original pattern and comparing its literal found exact equality.
The two open-prefix patterns, their tail bindings, every default rejection,
definition order, and public signature remain unchanged. No declaration was
added or removed and no other declaration changed from source02.

The final source is **3,045,282 bytes**, SHA-256
`0f3bd8a0f29944a317d6de14db05e6e34ba36daa22b350c25236d07519227eaf`:
3,009 fewer bytes than source02. The final `ownership.bend` hash is
`698de939860f6d38041084c27d964f7b277e9c410b56dda22141102c22710799`.
Independent in-memory assembly matches this source03 snapshot exactly; all
112 protected hashes still match.

The root-owned bridge record is
`selfhost/build/phase147/integrated-source03/classifier-literal-bridge.json`.
It binds the passing 677-case hosted controls and the literal fixture's native
emission: 1,188,233 QBE bytes, SHA-256
`144a2b11fc38a24297267dd4e43b54b62a987f20cdf90b30498dce85870e010a`,
identical to the qualified constructor-pattern fixture. This supports the syntax
simplification; it does not substitute for combined-image qualification. The
source01 and source02 claims above apply to their named snapshots, not to an
unrecorded later source. No target was run by this reviewer.
