# Bounded destination passing for recursive constructor spines

Read-only feasibility audit,20 October2026. No target/compiler run and no
production implementation. The existing checked body normalization, ownership
partitioning and constructor identities are reusable. No mature tail-modulo-
constructor transformation was found; this would be a new small semantic plan.

## What the current backends do

The upstream list-pipeline512 C saves the head/seed plus a return FID on the
worklist stack in `FID_P37_LIST` and `FID_DBL`, then allocates Con in
`FID_P37_LIST_K24` and `FID_DBL_K28` while unwinding. See lines1886–2040 of
`selfhost/build/phase93/broad01/coverage-list-pipeline-512/upstream.1.c`.
The Unicode64 C does the same in `FID_STRING_APPEND`/`K32`, lines2099–2150.
It already loops on descent, but retains one explicit continuation per element.
Under its parallel branch it allocates task continuations instead.

Mature `flat.bend:nf_call_local` and Phase113 `p113d_call` both refuse non-tail
self calls. Therefore this is not a missing switch enabling an existing flat
worker plan. The Phase111 CPU runtime is sequential; its frames are words on
the explicit worklist stack, not one heap object per frame. A new CPU builder
would remove those words and return-dispatch transfers, not merely change
native recursive calls into tail calls.

## Smallest useful eligibility rule

Work from the authenticated checked/erased function body, applying the same
`nd_*` normalization and `nc_sequence` order as ordinary lowering. Do not infer
the rule from a function name, emitted QBE, or C text.

Admit a one-result, first-order, non-bang function only when all reachable
recursive paths have one of these forms:

1. A base result that contains no self call.
2. An ordinary tail self call, preserving the current builder destination.
3. A constructor whose final live field is exactly one saturated self call;
   the recursive result is used once and nothing executes after that return
   except filling this constructor and returning it.

All other constructor fields are evaluated first in their original order;
then evaluate the recursive arguments in their original order. These
expressions may use already admitted acyclic ordinary callees, but no recursive
call, foreign effect, parallel form, escaping closure, or unknown application.
Match/let prefixes retain normal ownership partitioning and field transfer.
Constructor identity, live arity and recursive result position must come from
the original checked layout. The first version should restrict the recursive
carrier to the final field of canonical List/String constructors; arbitrary
names or malformed reflected records must not establish this fact.

This admits the actual `dbl`, `p37.list`, `stake`, and Base `String.append`
source shapes. It initially refuses `keep_gt1`, whose selector executes after
the recursive call; `ssplit`, which inspects the recursively returned value;
`sjoin.go`, which calls append after recursion; and binary tree rebuilders with
two recursive results. Moving those post-call operations before recursion is
an additional strictness/termination theorem, not part of this rule.

## Forward-builder mechanism

Keep a private root owner and the location of one unfinished tail slot. For a
constructor step, after evaluating all prefix fields and next-call arguments:

1. Use ordinary constructor allocation with the prefix fields and a private
   `TERM_HOLE` tail. Prefix fields are sealed exactly as today.
2. For the first node, retain its owner as the builder root. For subsequent
   nodes, transfer the new node into the previous tail slot using `rfc_seal`.
3. Remember the new node's tail location and jump to the self-loop with the
   next arguments. No recursive result is saved on a continuation stack.
4. On a base result, transfer that result into the final tail slot using
   `rfc_seal`, then return the root. If no node was built, return the base value
   directly.

The output allocation count and final child-sealing policy can match ordinary
construction. Allocation moves from unwind to descent; there is no reverse
pass or second result spine. Ordinary argument evaluation, errors and
termination must keep their order. Earlier allocation can alter resource
exhaustion timing; this must be explicit rather than described as identical
allocation order.

## Ownership and publication constraints

Only freshly allocated, privately owned result nodes may be patched. Do not
mutate input nodes, static nodes, or shared constructors. Existing destructive
input matches continue through the normal shared/unique runtime paths.

The root and slot capability must never be passed to a user callee, captured by
a closure, shared, observed through a match, returned, or published to an effect
while a hole exists. A linked child may already have a count-one RFC wrapper;
the saved slot is a private borrow of its storage, not another owning Term.
Each hole is initialized once. All ordinary return paths finish the outstanding
hole. CPU fail-stop behavior is the current error boundary; a future recoverable
error mode would need explicit cleanup of a partially built result.

Sealing links is mandatory. Runtime04 `rfc_seal` wraps raw CTR values, including
raw static constructors; storing the raw child directly would violate the
representation expected by shared destructive matching (`span_fade`). The
base suffix may be shared, static, or physically alias an input. Its existing
owner must be transferred, not duplicated or lost.

Store a checked location/slot capability rather than exposing a general Term
pointer. Derive the memory address from the current runtime state at each fill.
The current public direct structural verifier deliberately forbids arbitrary
state/heap pointer operations, so this belongs in a separate exact private
producer/adapter with focused validation, not a blanket verifier relaxation.

## Runtime/API size

`p111_rt_ctor` already supplies allocation and prefix sealing. The missing
operation is narrowly **fill a certified fresh constructor hole with an owned
value using normal sealing**. A tiny additive helper could check raw CTR,
heap location, constructor arity, field index and `TERM_HOLE`, then write
`rfc_seal(state->e,value)`; the private producer supplies the unobservable/unique
capability proof. Runtime checks alone cannot establish that no alias exists.

The public function ABI remains unchanged. This needs no general multi-result
ABI or new runtime scheduler. Reusing `keep(newRawCtr)` followed by one `sink`
can emulate a count-one sealed link, but adds calls/count operations and hides
the intended ownership operation; it is not the preferred interface.

Two alternatives avoid the new fill operation but give weaker outcomes:

- Build a reversed private spine and reverse it with existing take/constructor
  helpers: safe representation, but another traversal and potentially another
  allocation per element; no speed advantage is established.
- Run descent and unwind locally while retaining the existing explicit capture
  stack: preserves current allocation/evaluation ordering and removes global
  dispatcher/register-bank transport, but retains O(n) continuation storage.
  This is a useful fallback milestone if the hole capability is too much scope.

## Decisive first gate

Use unchanged `dbl` and Base `String.append` as real witnesses, plus `stake`
for multiple input matches. Independently test deep input beyond native stack
capacity, empty/base-only input, Unicode, shared/static inputs, result suffix
aliasing the input, repeated owned head aliases, and both release orders.
Refuse non-final recursive fields, repeated recursive results, post-call work,
two recursive children, effects/bangs, escaping partial applications, unknown
constructor identity and forced early publication. Retain strict overflow and
termination controls around prefix and recursive-argument evaluation.

The emitted positive witness must have a local loop, no per-node frame/return
dispatcher calls, one constructor shell per retained element, exactly one
finalization per slot, and bounded native stack. Complete-output/lifetime tests
are necessary before timing. A static accepted count alone is insufficient.

## Inspected artifact pins

| File | SHA256 |
|---|---|
| Phase93 list-pipeline512 upstream C | `90cfc0c1156b671bd186bd59060a3f72ac319e564f483017b8a4fc4c350133fb` |
| Phase93 Unicode64 upstream C | `51c5ef5ed1c9fd9dc579776c27ac7660ad75885262e23ce09694a9616098ffb1` |
| Phase111 runtime-source04/runtime.c | `c0fc18aabb2749cc85b5040c29756d8d73d90b73bb954d10ed1d0d410528aa50` |

Actual compact checked-body dumps for these proposed TMC witnesses were not
produced during this audit. The eligibility is grounded in the unchanged source
and existing normalization rules; a parent-run diagnostic must confirm the
recognized normalized shapes before implementation is selected.
