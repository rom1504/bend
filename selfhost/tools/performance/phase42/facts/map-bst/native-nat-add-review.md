# Exact native Nat.add residual proposal (held)

Executed diagnostic probe06, using frozen producer v07 on checked10, identifies
the original bench's first source refusal precisely: the level4 expression
`Nat.add(U32.to_nat(size),1n)`, with a valid partial graph containing build and
inorder. Nat.add is native, arity2/templates0, its signature passes, but native
admission and capture eligibility refuse. Its original Zero/Succ source body is
retained. U32.to_nat is also marked native, but saturated conversions already
use the existing primitive emitter; it must not be added to residual native
trust merely because its standalone eligibility refuses. The hashed diagnostic
is summarized in bst-probe06-nat-refusal.json.

Runtime's final Nat.add implementation is the original
`checkedNat(a+b)`, including the maximum281474976710655n bound and `bad()` error
proof suspension. The proposed j_pure_nat_native admits only native Def Nat.add,
arity2/no templates, nonforeign body, quantity1 Nat/quantity1 Nat->Nat, checked
against original primitive Nat owner/constructor ABI. It retains the generic G
call and runtime range behavior. Direct and flat native gates remain Bool-only;
no other Nat operation or inline BigInt arithmetic is admitted.

Candidate01 proposed adding Nat.add to the scalarCapture factory whitelist.
Independent review refused its preimport observable registration difference:
scalarCapture calls mutable Number.isInteger, descriptor helpers and Array.every
for each new snapshot. A preimport observer could count the additional calls
before any entry guard. This is a concrete static trace issue; no candidate01
execution is claimed.

Candidate02 instead stores a snapshot of the just-created native fn's known
fresh own code/bound/arity fields in one private local variable. It does not call
host predicates, write the possibly host-created/proxied scalarSnapshots table,
or mutate/expose the public fn. scalarGuard selects the local snapshot only for
Nat.add; existing scalarCapture registrations and native G assignment are
unchanged. Both native registrations update the local so the final checkedNat
wrapper is the one guarded. The isolated patch is syntax-checked and unexecuted;
root has not applied the runtime change.

This narrow metadata design still requires actual preimport controls on root
entry. Newly opening a full proof can expose existing conversions such as
`BigInt(size)` or native argument spread to a preimport observer wrapper whose
identity an import-time guard has captured. Such a callback must not inherit
proof permission and reenter a public data-taking function with an alien ADT.
The actual checked07/checked11 sequential bridge witness now confirms failure,
independent of native Nat.add: proxy callback result26 becomes30 and seven
mutated G.code calls become zero. See the [executed assessment](returning-host-callback-assessment.md).
That preimport case is outside the published initialization contract. The
earlier reversal recommendation is superseded; candidate02 remains isolated
and resumes narrow static review pending supported controls.

Required subsequent evidence: an independent scalar root with native Nat.add
and a useful admitted component must enter; max+0 and (max-1)+1 preserve complete
results; max+1 preserves the original error and order; a later valid call can
enter again. Error-hook reentry must see parent proof suspended and public-data
calls generic. A fresh independently guarded scalar root may legitimately open
its own proof, so all scalar reentry is not forbidden. Changed Nat.add binding,
code/accessors must force generic behavior with matching callbacks and zero
inherited private entries. Preimport metadata/BigInt/iterator observer traces and
full native bounds are separate controls. Final runtime/API identities and
ordinary conformance/cost measurements must include any promoted metadata patch.

Contract clarification: docs/BEND-IN-BEND-PERFORMANCE.md405–416 already
assumes standard intrinsics at module initialization. The retained preimport
BigInt witness deliberately violates that assumption; the earlier blanket
stop is superseded and no rollback is required solely on it. Nat.add
candidate02 resumes narrow metadata review, with original runtime arithmetic
and calls unchanged. Bounds and supported postimport mutation/Error-reentry
controls remain required; arbitrary preimport observer support is not added.
