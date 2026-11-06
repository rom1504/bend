# Descendant v13: bounded independent semantic audit

Source-only audit, 2026-11-06. No compiler, generated program, profile or
instrumentation was executed. This reviews the transducer mechanism and its
existing final gates, not compiler-wide correctness or measured performance.
Source13 and its results remain historical evidence; any fix needs a successor.

## One concrete gap: removing a sink loses its result assignment

`descendant-v13/borrowed-selectors.bend:237–238` removes the entire
`p111_rt_sink` statement. The actual runtime returns integer zero
(`selfhost/src/runtime/qbe/runtime.c:3933`). Removing its ownership operation is
intentional, but its result binding must still become zero.

The unchanged verifier allows reassignment of a local with the same width:
`verify-segments.bend:48–59`. Therefore this supported low-level pattern is a
counterexample to the transformation's general assignment contract:

```text
x = 1
x = p111_rt_sink(state, a_known_owned_alias)
return x
```

The original returns zero; the transformed body retains the earlier value one.
Both bodies can satisfy the structural direct verifier. A later conditional
using `x` can likewise select a different Data result, so a scalar-only return
restriction would not establish that the assignment is dead. This was found by
source reasoning, not by executing a reproducer. I have not established that
the selected actual compiler owner reads such a reused sink destination: the
usual emitted `ignored` destinations are dead. It is a blocker to treating the
general transducer contract as established, not a demonstrated failure of the
current lookup fixture.

The minimal successor retains `N111Set{name,typ,N111Const{0,0}}` and updates
that local's provenance to `P171DWord{""}` while suppressing the drop. Include
both a fresh destination and a reused destination in complete-body controls.
Do not change take results to zero: `p111_rt_take` and
`p118_rt_borrow_fields` both return **count** (runtime lines3962 and4680).
Their retained destination/result handling already agrees.

## No second concrete blocker found in the new buffer/branch mechanisms

- Local buffers remain `P171DBuffer`, rejected as returned values and ordinary
  helper arguments (`borrowed-selectors.bend:49–65,126–136`). Pointer arithmetic
  and arbitrary stores decline; exact pointer copies preserve the buffer origin.
- A permitted field load requires the last established view's origin, sufficient
  capacity, U64 width and aligned in-range offset (lines202–207). `take` and the
  supported special takes replace that view. New allocations and helper calls
  invalidate it (lines186–188,273–278). This is conservative: independent
  buffers do not retain separate live-view facts.
- The special `scratch` origin does not permit a verified pointer overwrite.
  `p113e_seed` seeds `scratch` as a 2,048-byte alloca
  (`verify-direct.bend:43–47`); `p111v_decl` rejects every later declaration of an
  existing alloca name, including a pointer assignment
  (`verify-segments.bend:55–56`). Named allocas have the same protection.
  Ordinary pointer aliases may be rebound; the transducer shadows their origin
  and a stale view then fails the exact-origin test.
- Scalar `N111If` expands into separate branch environments with their complete
  continuations (lines156–159,192–196). The compact case accepts only one
  same-local integer-constant assignment in each arm (lines172–176). It preserves
  the original conditional, records the result as an unrooted scalar, and does
  not change buffer memory. No stale pointer provenance crosses this join.
- Runtime special-take kinds4/5 only write `term-1`/`term` into the supplied
  one-word buffer (runtime lines4451–4463). Allocating word conversion and array
  cases remain excluded. `borrow_fields` copies existing fields without taking
  ownership (runtime lines4667–4680).

The entry still requires actual ordinary source, instantiated Data ownership,
original final validation and the actual constructor/header catalogue
(`borrowed-selectors-entry.bend:10–31,96–110,124–128`). The splice retains an
exact original fallback and invokes the final gate again
(`borrowed-selectors-emission.bend:41–68`). Projection verifies imports,
capacities, definitions and control flow (`ownership.bend:206–218,250–260`);
it is **not** a proof that dropping assignments or introducing escaping borrows
preserves source semantics. The transducer's provenance and wrapper ordering
remain additional obligations.

## Follow-up: promoting an RFC descendant whose count is one

The source13 wrapper holds its owned roots throughout the read. Its result
guard currently reuses `p118_rt_borrow_scalar_safe`, which rejects nontrivial
RFC count1 (`runtime.c:4794–4805`). This is stricter than required for
**result promotion**, under a valid read-only, root-tied Data result contract:

1. `borrow_fields` copies the exact stored Term, including its existing RFC
   cell identity; it does not create an independent owner.
2. `term_keep` on an RFC increments that **same** cell before root release
   (lines919–930). An RFC count1 therefore becomes count2.
3. `term_drop` destroys the payload only when its decrement observes old count1
   (lines970–985). Releasing the parent's stored reference after promotion
   leaves the new output reference live. If the parent itself remains shared,
   its field reference remains too, and the count correctly remains two.

Root-return and overlapping ancestor/descendant roots use the same accounting:
the new output credit is acquired before releasing any input credit. This
assumes a valid runtime ownership graph, retained entry roots, unchanged reader
purity, no escaping stack buffers and a genuine source Data result. It does not
authorize loosening root admission or arbitrary runtime import access.

Raw non-RFC descendants remain different: `term_keep` creates a new wrapper
without rewriting the parent's raw field (`runtime.c:932–934`), so dropping the
parent can free the payload under the new wrapper. They must still decline.

There is also a bounded-state caveat: `rfc_bump` posts `ERR_RFCS` when the old
count is at least `RFC_CNT-1` (lines919–923). A dedicated promotion guard should
refuse that range if it must avoid introducing an extra transient overflow.
The existing scalar guard is unchanged; this paragraph is a runtime argument
for a separate source-authorized result-promotion interface, not a new tested
guard or theorem. No count1 experiment was executed by this audit.

## Source identities

Paths below are relative to the repository; SHA256 pins the audited bytes.

| Source | SHA256 |
| --- | --- |
| `selfhost/tests/phase171/descendant-v13/borrowed-selectors.bend` | `8aa845bbcf14481d0b79d73c40ae7090a0e0967e990509199e16347649428a9d` |
| `selfhost/tests/phase171/descendant-v13/borrowed-selectors-entry.bend` | `f3b40f6eac33dff9180d57ada9c0ff260b64113a94c02ce167f4cc1c552dae7a` |
| `selfhost/tests/phase171/descendant-v13/borrowed-selectors-emission.bend` | `1721877ff9b3ba79f4ea1d0253e5e964d5d0ba56fa660e9ba98e47b8dd38b068` |
| `selfhost/src/runtime/qbe/runtime.c` | `aa95d2c0426c05bcc4d34244dd8b22b79ebcaf6d30634569201961f60b57f333` |
| `selfhost/src/back/qbe/verify-segments.bend` | `1f23d3fcd7376395d26f228b3a1a813b6ee5ea21ce7e004e4ebdea5bdebdf690` |
| `selfhost/src/back/qbe/verify-direct.bend` | `a8a7e350cda88aaa3785183d02ac60dda0a0815a54b2efb09a9154cc1a2a027c` |
| `selfhost/src/back/qbe/ownership.bend` | `698de939860f6d38041084c27d964f7b277e9c410b56dda22141102c22710799` |
