# P167-002: no speculative direct-candidate construction

Status: source prepared; root owns all checked acquisitions and target runs.
Production source and the qualified Phase152 compiler remain unchanged.

The demand prototype still creates direct candidates for the whole prepared
source closure, tries ordered admission, then creates genuine scheduler families
where direct admission fails. The true plain-emission experiment removes the
registry but does not remove that private-candidate work. This counterarchitecture
tests a complete route with **one demanded generic family IR and no private
candidate production at all**.

`selfhost/tests/phase167/demand-single.bend` preserves checked request/runtime
admission, the same constructor/static preparation and the same demanded-family
queue. It calls `p167l_functions(...,[])` directly, so every demanded source owner
uses genuine original `p111_entry` lowering. No admitted adapter or factory-only
shortcut exists. All ordinary workers, closures and continuations are actual
generic bodies and pass the unchanged independent final gate.

Interfaces:

- `p167single_request(request) -> P167Lowered`: one lowering, same statistics.
- `p167single_mode(mode,plan) -> P111Emission`: mode 0 uses the actual plain
  per-segment emitter; mode 1 intentionally reuses the inherited region emitter.
- `p167single_plan(plan)`: mode 0 convenience entry.
- `p167single_lowered(mode,request,lowered)`: reuse an already computed semantic
  result for diagnostics and final admission/emission without lowering twice.

Both modes use the conservative original constructor flags, no private
inlining/scalar pass, no source-cold pass and no optional live-register flag.
The emitted table format and runtime ABI are unchanged. The plain emitter still
has existing local statement-emission rules; "plain" means no whole-program
region registry, not deliberately unoptimized individual instructions. Chunk
materialization and teardown remain charged prototype limitations.

Before timing, retain complete output/diagnostic gates, source-runtime admission,
all applicable malformed-final-program controls, and an escaping closure plus
non-tail fallback. Statistics must show zero direct functions, zero adapters and
zero admitted-factory-only constructions. Confirm the lowerer does not reach
`p113pl_candidates`, `p113d_passes`, `p126sc_candidates` or `p113i_functions`.
The shared renderer entry's mode branch may retain registry functions in a
static extraction even for mode 0, but mode 0 must not execute that branch.

Compare complete backend and whole request clocks against raw demand mode 0
on the same checked request and fresh-process boundary. Do not subtract the
times and call the difference exclusive candidate-production cost: removing
direct workers necessarily creates more generic body/continuation work, changes
emitted bytes, and may change machine construction and execution substantially.
This is a lower-complexity architecture contrast and a falsifier for the claim
that private candidate construction explains most remaining backend cost.

Expected limitation: generated execution can be much slower without direct
workers. A construction win with a large runtime regression is evidence about
work distribution, not a compiler promotion. No additional expensive native
self-build is authorized by this experiment note; root chooses the smallest
complete checked request and existing bounded execution gate.
