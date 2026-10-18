# P108-001: retain mature semantics, change machine-code acquisition

Status: implemented and qualified experimentally; performance prevents production
promotion. [Design](../../design/phase108/full-native-qbe.md) ·
[Report](../../implementation/phase108/README.md).

Hypothesis: an ordinary-ABI segment trampoline plus cproc/QBE can build the full
Bend compiler without porting all semantic lowering to Nx first. Existing Bend
ownership, closure, array and IO decisions can remain unchanged.

Result: the full QBE compiler self-emits exactly the parent’s complete 30,396,376
bytes of C under matched runtime policy. The self-emitted successor builds through
QBE in 56.08 s and passes nine frozen controls, six complete-C/diagnostic comparisons,
six actual generated-program outputs, five requests in one process and live Base.
No Clang or Bun is invoked on this route. The compiler remains written in Bend;
C is the compatibility boundary and GCC support tools remain dependencies.

The runtime uses a one-pointer segment ABI and five pure accessor expansions.
Six-source request time falls from a 4.18× initial screen to 3.22× versus the
selected Clang-built native B2; successor qualification screens at 3.34× with
identical executable text. These single-round screens establish a large remaining
regression, not a statistically resolved difference between Q0 and Q1. Full
self-emission takes 338.89 s. No upstream or generated-program runtime ratio is
claimed. Production default unchanged.

Falsifiers retained: one 3 GiB build guard rejection; pointer-ABI build required
about 3.05 GiB with a 4 GiB guard. Initial source setup errors and a sampler with
period overruns remain in evidence. The original plan proposed two fresh full
Q0 self-emissions; instead one exact self-emission was followed by a real rebuilt
Q1 and its independent finite gates. No repeated full-self timing claim.

Next experiment: general runtime helper inlining or a reusable optimized runtime
ABI. cproc/QBE does not inline tiny C helpers. Use frozen/output controls and six
small compiler requests before another complete self-image. Direct Nx lowering
remains a separate scalar experiment, with this full route as a semantic reference.
