# A bounded checked hook for a profitable String identity law

This is an implementation-size audit, not an implemented or qualified pass.
The frozen Phase131 candidate is unchanged. First use the whole-N2 QBE ceiling
to decide whether this work is worth doing.

The existing `p128bs_functions` is the smallest useful integration point. It
already has the checked book, source owner, admitted observer plan, typed root
positions, public signature, owned fallback and exact root-release list. It
emits the public adapter as ordinary `P113DStmt` and sends the complete program
through the unchanged independent verifier. A positive identity arm can use
existing `N111Bin`, `P113DIf`, `P113DResult` and `p128bs_drops`; no new runtime
helper, QBE instruction or calling convention is required.

The transformation must be conditional on a semantic certificate, not the
function name. A user program can define a function named `p88_string_eq` with
different behavior. The initial certificate should express:

```
diagonal result: True
root arguments: [0, 1], both concrete String
additional premise: argument2 == True (go only)
result representation: admitted nonowning Bool, native scalar1
ownership: consume each root exactly once after observing the premise
source dependencies: exact checked equality and Char/Word comparison bodies
```

The source theorem already exists and is independently kernel checked, with an
exact source bridge for the three production equality declarations. It does
not automatically authorize an arbitrary caller-supplied certificate. The
compiler must derive admission itself, conservatively matching the actual
checked body and required helper identities against the proven contract. Use
structural equality (including signatures and binding structure), not an
unchecked name or a collision-prone hash alone. Unknown/redefined helpers,
different recursion, extra effects or unmatched result layout must retain the
original adapter. Exact canonical body comparison may conservatively reject
renamed or differently elaborated equivalent definitions; that is acceptable
for the initial bounded experiment.

The positive arm compares complete native Term words, then performs both
original root sinks in order and returns the scalar True. The original adapter
is the entire negative arm. The `_go` form additionally requires pending True.
This does not remove the existing borrowed alias guard or move releases across
a borrowed read. Runtime ownership, immutable typed String provenance and the
native Bool encoding remain explicit ABI obligations, separate from the source
theorem. Corrupted foreign Terms are outside that theorem.

Estimated implementation size and work, conditional on the whole-request gain:

| Scope | Estimated Bend lines | Implementation and focused testing |
|---|---:|---:|
| Adapter branch once a valid certificate exists | 40–80 | 15–25 minutes |
| Conservative source/dependency admission plus branch | 150–300 | 30–60 minutes |
| Targeted semantic/admission/ownership controls | 80–150 | included in preceding estimate |
| General symbolic diagonal-law inference | 400–800+ | several hours; defer |

Those estimates exclude full image acquisition/reproduction. A new source
candidate should first pass unchanged final verification, an unrelated
String-query workload, and explicit retained-alias, count2-destruction,
pending-False, unequal-word/equal-content and redefined-function refusal tests.
Compare actual machine code and compiler request cost before native promotion.

Do not build a generic theorem registry or change the language annotation
system for one small gain. The reusable concept worth retaining is a
source-bound semantic fact consumed at an already verified ownership boundary.
If the whole-compiler ceiling is negligible, keep the proof and negative
evidence and defer the pass.
