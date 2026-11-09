# P186-001 — remove private machine state and expose real instruction effects

The initial hypothesis is in the pre-implementation
[Phase186 design](../../design/phase186/README.md). This note consolidates its
implementation and observations; it is not a new preregistration.

The retained assembly fold loop had 123 instructions versus QBE's 17. Private
scratch stores, incomplete forwarding and simultaneous loop-state snapshots
survived despite no observer requiring them. Admitted F32 operations were also
classified as arbitrary machine calls before being emitted as inline SSE.

The selected Bend implementation combines bounded private-memory analysis,
shared exact inline effects, acyclic parallel-move scheduling, fixed-frame
callee-save selection, expression reuse and direct physical/ABI moves. It keeps
unknown calls, escaping addresses, overlapping reads, cycles and malformed
frames on conservative paths. Original final IR verification is unchanged;
custom machine-frame controls are explicitly distinct from whole-IR checks.

Relevant modules are under `selfhost/src/back/x86/`: `private-memory.bend`,
`inline-effects.bend`, `parallel-moves.bend`, `callee-saves.bend`,
`expression-reuse.bend`, `physical-moves.bend`, and `call-arguments.bend`.
Focused fixtures and independent C observers live under `selfhost/tests/phase186`.
They cover barriers, widths, aliasing, loop backedges, move cycles, live registers,
all 32 callee-save masks, argument snapshots and out-of-frame refusal.

The first ten-case candidate improves all ten assembly cases, geometrically
19.63%. The fourth candidate improves the nine uncontaminated cases another
7.36%; a generic-row outlier is explicitly rejected and separately repeated.
These are composed-candidate results. They do not isolate the contribution of
individual passes. The final fold loop has 66 instructions, 47 moves and 21
frame references, versus the original 123 instructions. It still performs the
same one array load/store and has no calls per iteration.

[First-screen analysis](../../implementation/phase186/first-screen-analysis.json),
[fourth-screen analysis](../../implementation/phase186/fourth-x86-runtime01-analysis.json),
and [remaining machine work](../../implementation/phase186/remaining-assembly-work.md)
preserve scope and exact artifact identities. The final full-corpus comparison
is in [the report](../../implementation/phase186/README.md).

The transformation removes real work, but adds analyses and source complexity.
The full assembly compiler's acquisition cost increases. Future work should
share these facts instead of repeatedly scanning equivalent statement lists.
