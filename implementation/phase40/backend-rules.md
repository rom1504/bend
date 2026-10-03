# Retained backend rules and proof boundaries

Phase40 extends the existing private structural-component engine. It retains
tagged materialized trees and lists, the existing scalar-root proof, and the
generic fallback. The new source rules admit native-Nat structural descent,
one-child reconstruction or tail transfer, and one exact grounded List layout.
They select typed source shapes rather than benchmark or function names. The
[checked05 source accounting](source-counts.md) records 17 additional definitions
and 141 additional physical Bend lines; runtime bytes, laws, types and module
counts are unchanged. Semantic evidence below applies to checked06 API
`630879d8f030241a1d2c56e97f18f88b5be2070ac45dd02304afd06b3e3c5c0a`.
Final performance and release decisions require separate completed measurements.

## Admission and ownership

A component must remain an ordinary captured definition with a bounded, fully
checked pure source graph. Its signature, prefix matches, recursive call arity
and source-size limits are checked before emission. The first input may be an
eligible closed tagged ADT, the grounded List described below, or native Nat
with the existing native-Nat representation check and an eligible data result.
The new Nat-first alternative refuses primitive U32/Bool/Nat/F32 results, keeping
existing scalar islands in control of those selections. The existing normalized
result peeler and scalar predicate provide this restriction; whole-graph purity
still independently proves the remaining result type. This narrowing repairs
the rejected checked05 raytrace selection and leaves ADT/List-first scalar folds
eligible. A recursive first argument
must be the actual pattern-bound variable marked as a proper descendant. For
Nat, that is the predecessor extracted by the guarded Zero/Succ match. A computed
equivalent predecessor, reconstructed parent, or unchanged first argument cannot
stand in for that provenance.

The existing two-child rule still requires independent recursive RHSs: neither
can refer to the other's new binding. The whole-graph purity check remains
independent of lowering success. Helper backedges into the component are refused,
because they could nest JavaScript worker calls instead of using the runtime's
tail trampoline. Type, quantity, fuel or shape failure retains generic emission.
No acyclic-only broadening or general native-container purity rule is included.

An emitted call chooses a private worker only while an active proof covers its
complete checked graph. The enclosing scalar root retains entered-call,
canonical-input, host-identity and captured-dependency guards. Root recognition
can now include a residual with a valid component plan, allowing these workers
to reuse the existing proof scope. Proof opening and restoration stay inside
`try/finally`; throwing and reentrant evaluations must restore the previous
proof. Diagnostic adapters are separate from ordinary source entry and cannot
supply evidence that the ordinary root admitted a call.

## Grounded List is a specific layout proof

The added exception is exactly `List<&2,U32>`. The normalized List head must have
two parameters, the literal unrestricted quantity, canonical U32 element type,
and no extra removals. The declared parameterized owner must have the expected
arity and exactly Nil/Con. Specialized Nil has zero fields; Con has the required
affine U32 head and same grounded List tail; the specialized result kind is
unrestricted. Thus the test checks the declaration and constructor layout, not
just the spelling `List`. List type comparisons also check the complete grounded
parameter identity. The exception is shared by existing purity, local, finite,
producer and structural checks; those checks retain their other obligations.

Affine List instances, Bool or Nat elements, nested Lists, arbitrary parameterized
ADTs, native arrays, String/Char/Sigma and higher-order or dependent fields receive
no new eligibility from this rule. This is a compile-time layout proof within an
owned pure region, not validation of arbitrary host-supplied list objects. Foreign
calls retain generic demand and errors. After fallback, another separately
guarded region may legitimately enter; a hostile-call result alone is therefore
not evidence that the original complete component proof was admitted.

## Frames preserve source evaluation and identity

One-child branches admit a saturated self call in tail position, or as one
immediate argument of a tagged constructor or saturated known pure combiner.
The combiner can return a different eligible ADT. Primitive-call combiners are
refused: reading their generic mutable binding would not follow their existing
primitive capture path. Only inert field-atom aliases may precede the recursive
expression; allocating or effectful sequential lets retain generic emission.

Tail position replaces the current argument vector without adding a frame. For
reconstruction, arguments before the child are evaluated and saved first, then
the child's own arguments are evaluated and descent begins. On return, the exact
child object becomes the saved argument; later arguments and reconstruction run
afterward. Existing unary producer helpers implement this split. A finite-ready
combiner uses the existing finite emitter; another eligible known combiner uses
the ordinary owned call path. No scalar checksum, fusion or alternate list/tree
representation replaces the materialized result.

Unary frames use phase 2 and resume through phase 3. Existing binary frames keep
their left-descent, right-descent and combination phases. A single component can
alternate both forms. Prefix reconstruction repeats inert private reads only;
leaves and demanded expressions execute at their original phase. Saved frames
retain exact child aliases, including a combiner that returns the child itself.
Emission recovers the already-proved saturated self-call position separately
from analysis: lexical emission environments carry types and names, whereas
analysis environments carry descendant provenance. This distinction fixes the
preserved checked04 undefined-saved-argument failure without relaxing ownership.

## Independent checked06 semantic owners

[Nat controls](../../selfhost/build/phase40/tree-nat-controls06/report.json) pass
302 oracle rows and 84 boundary groups, including 240 complete independent tree
shapes, refusal cases, alias/freshness checks and 30000 frames. An ordinary source
call increments both an actual proof admission and actual component entry.
[List controls](../../selfhost/build/phase40/list-actual-controls06/report.json)
pass 52 oracle rows, 106 host-boundary rows and an ordinary admission witness.
They compare complete produced, filtered and mapped List/Chain stages and folds
against independent BigInt integer models, including depth 30000. Boundaries
compare live values, errors and event order under mutation, getters and reentry.

[Linear-order controls](../../selfhost/build/phase40/linear-order-controls06/report.json)
pass 160 complete structure/scalar oracle rows, 12 order cases and 36 dependency
refusal groups. They observe child positions first/middle/last, different-result
combiners, mixed unary/binary phases and 208 exact resume aliases. Native-Nat
overflow distinguishes before-child, leaf and after-child demand; depth-zero
cases leave sibling expressions undemanded. Error ordering pairs preserved
Phase39 with checked06. TypeScript supplies small-Nat scalar comparisons only;
maximum-Nat errors and private alias identity are selfhost-specific checks.
These owners establish selected semantic gates, not a compiler fixed point,
broad conformance, compiler throughput or final speed claim.

Checked05 semantic and timing evidence remains preserved, but that image failed
performance admission. Checked06 focused output checks restore exact Phase39
raytrace bytes and preserve exact checked05 tree/list bytes. Its short screen
is not final performance acceptance; complete checked06 catalog preparation and
release gates remain separate.
