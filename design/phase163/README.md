# Phase163 — direct-first QBE and compact semantic computations

Start: `a8b598980ef7016133484eb28563b63bd5e30f09`, 2026-11-05.
Completed experiment: [implementation and measured limits](../../implementation/phase163/README.md).
The user authorizes an extremely ambitious attempt to reduce native QBE
self-compilation cost, informed by bendc rather than restricted to local patches.
The architectural research target is roughly50s versus the qualified249s full
build. This is an ambition, not an estimated or achieved speedup.

## Hypotheses

1. Construct ordinary direct native functions first, using existing typed
   preparation, ownership rules, tail loops and independent direct verification.
   A closed admitted computation should not require first materializing a generic
   scheduled version of every function, its optimizer metadata and registries.
2. Store semantic terms and state as compact typed data through complete
   computations. The concrete App representation tax is3objects/15words versus
   one/four in bendc. Changing just a helper or temporarily packing/unpacking
   generic records does not establish an architectural benefit.
3. Preserve the known publication work reduction as an integration candidate;
   do not substitute its C diagnostic gain for its measured native~10s saving.

## Implementation sequence and gates

- Freeze current source/images/oracles. Recover only authenticated archived
  obsolete build intermediates to retain the5GiB reserve.
- In parallel, audit direct ABI/fallback requirements and compact-term consumer,
  proof and host/cache contracts. One leader owns integration and the serial
  resource-intensive lane. Bounded agents own separate files.
- Build a **Bend-implemented direct-first library route** for a closed set of
  actual compiler computations. Reuse valid existing P113 direct ABI and
  ownership operations; explicit declaration/constructor metadata must not
  pretend that nonexistent generic bodies have been checked. Require all
  dependencies admitted, ordinary final verification, and explicit refusal of
  escaping/dynamic/static/FID/effect forms that need unsupported metadata.
- Start with real helpers already having direct workers: the first claim is
  eliminating construction work, not newly discovering direct execution.
  Compare complete preparation/lowering/admission/verification/rendering and
  machine construction. Compare exact complete results and actual execution on
  retained compiler workloads. Charge conversion and cleanup.
- Add a missing general capability only when the initial representation permits
  it economically. Non-tail recursion may not silently become native recursion;
  bounded stack, strict evaluation order and continuation semantics remain gates.
- Implement a compact-term experiment only with an explicit lawful boundary.
  Existing arbitrary-child structural laws and host/cache ABI must not silently
  weaken. Prefer a complete typed computation with conversions at true external
  boundaries; record a refusal if global migration requires changing public
  invariants before a useful pilot exists.
- Small source checks, independent controls and same-image comparisons precede
  large acquisitions. Full source-to-executable/native reproduction is earned
  by a substantial transferable result. Preserve negative evidence and do not
  launch broad validation merely because a prototype compiles.

## Ambition ladder

**1×:** a truthful closed direct-only QBE route, real compiler workloads, no
generic bodies, independent correctness, exact accounting of rejected forms
and savings in compilation cost. Establish executable semantics, not IR size alone.

**10×:** reuse the route for a meaningful compiler subgraph, couple it to compact
semantic representation or a new stack-safe general transformation, demonstrate
multi-fold improvement in complete computations and actual generated execution.

**100×:** a direct-first whole compiler with generic fallback only where required,
typed semantic facts across stages and a qualified native reproduction. Attempt
this only if local evidence and coverage support it; the ambition is not a reason
to bypass proof, ownership, ABI or output gates. A10× gain over90% of total work
would yield about5.3× overall, whereas tiny fast kernels cannot justify50s.

Record source/semantic checking, mathematical proof, generated execution,
compiler request speed and full acquisition separately. Keep the qualified
Phase152 and installed JS/C/QBE selection intact until new qualification.
All compiler jobs use guard.py, explicit fresh roots/budgets, CPU3, ordinarily
2GiB RSS and16GiB available floor. Close/seal every run; no PR comments. Commit
and push completed work and an honest report, including unsuccessful approaches.
