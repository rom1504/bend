# Removing a recursive constructor intermediate

A checked compiler acquired from the frozen Phase197 source emitted complete ELF objects from the ordinary input and an independently written held-out datatype. Inspection of the emitted public bench function confirmed it calls the new private worker. Every timed observation separately checked the expected output and the warmup/repetition counters.

| Program | Candidate / incumbent x86 | Candidate / mature Bend C |
|---|---:|---:|
| Expression, depth 128 | 0.14025 | 0.14681 |
| Held-out invoice, depth 128 | 0.21160 | Unmeasured |

The first program used the unchanged native45 arguments. The held-out program has different constructors, subtraction orientation, seed progression and expression selection. A separate modular arithmetic interpreter supplied its expected result. Four additional inputs exercised zero depth and overflow on both programs. Altering the interpretation, duplicating the recursive child or calling an unknown helper refused the transformation. Changing the discriminant preserved admission. An unrelated records workload followed the original path. These results establish transfer inside the admitted single-recursive-child U32 algebra. They do not establish suite parity or kernel-proved equivalence.

[Legality argument](algebra.md) · [Checked matcher](recognize.bend) · [Worker construction](emit.bend) · [Complete emission](rule.mjs) · [Held-out source](heldout.bend) · [Balanced measurements](time-products.py) · [Exact receipts](evidence/)

## Two independent checks on experiment selection

- In four ordinary programs the early arithmetic hook for constant U32 division produced **byte-identical native objects**, despite admitting 45,039 divisors in controls and an Ivy Bridge model favoring reciprocal multiplication. Runtime ratios clustered between 0.9976 and 1.0026. Generated remainder calls from the lexer came from later direct workers where the divisor was a constant in a scratch slot. A lower-level selector must first demonstrate changed code at those sites. [Source](../quotient/rule.bend) · [Hardware model](../quotient/model.py) · [Dynamic observer](../profile/count.py)
- Changing the *program source* to stream lexer input into its consumer gave 0.911× the incumbent x86 runtime. Distributing delimiter replacement over string repetition gave 0.443× on Unicode-64, or 1.037× mature C. These measurements bound opportunities for automatic transformations. Two attempts to express a fixed-orbit law directly in Bend were refused by the checker. The first used an unfilled recursive declaration, and the second obscured structural descent. [Source projections](../streams/) · [Exact reports](evidence/)

To replay the compiler rule, reconstruct the Phase197 stage as described in the qualification README, run prepare-rule.py, acquire its checked hosted API using queue.py, then run rule.mjs with the ordinary and held-out inputs and time-products.py. Use the phase guard for each fresh execution. The archived JSON records retain exact commands, compiler/runtime and program identities where applicable, observation counts, controls and raw timings. Qualification of native self-compilation is separate. [Native source checkpoint](../qualification/README.md)
