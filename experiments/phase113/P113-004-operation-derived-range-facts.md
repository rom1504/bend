# P113-004: operation-derived range facts after inlining

Snapshot: 2026-10-20, 19:37 UTC. Source19 is checked and has finite-model,
native-witness and development-screen evidence. No broad runtime parity or new
native compiler generation is established. The
[interim03 capsule](../../implementation/phase113/interim03/index.json) preserves
the receipts used here; this audit executed no targets.

## Hypothesis and mechanism

Inlining makes helper results local, but the emitted code still inspects boxed
Bool tags on comparisons already known to produce 0 or 1 and repeatedly masks
bounded words. The [residual audit](../../selfhost/tools/performance/phase113/direct-opt-products/residual-audit.md)
identifies those operations in actual scalar-loop QBE and assembly. Conservative
facts derived from the operations themselves should remove this work without
changing the full-Term ABI.

The [Bend pass](../../selfhost/tools/performance/phase113/scalar-facts/README.md)
tracks exact 64-bit constants or unsigned bit-width bounds. It does not infer a
numeric range from ownership metadata such as `N_W32`: packed Bool Terms can
have nonzero high bits. Parameters, loads and call results start unknown; each
assignment replaces the destination fact. Joins keep facts valid on every
continuing path, and functions start with empty environments. There is no loop
fixed-point assumption. Pointer operands remain separate.

Copies, comparisons, masks and bounded arithmetic propagate facts. Only proven
constant branches disappear; effects retain their order on reachable paths.
Unknown or out-of-width shifts stay intact, respecting raw QBE's modulo shift
semantics. Functions at the 4,096-node cap remain unchanged. Original and changed
programs pass the existing verifier, with rollback on failure.

## Evidence and distinct causes

[Source19's API receipt](../../implementation/phase113/interim03/files/020-report.json)
is checked and complete. Its independent
[finite suite](../../implementation/phase113/interim03/files/039-report.json)
passes 78 groups and 483 observations, including full-width values, joins,
reassignment, load/call invalidation, shifts and ordered observations. Four
range witnesses must remove the impossible high-bit test, so an unchanged pass
cannot satisfy every gate. This is finite interpretation, not a general proof.

The [native/build batch](../../selfhost/build/phase113/wide-ranges18-19/report.json)
completed all 31 jobs, including exact baseline/candidate Bool/Nat observations.
The [one-round screen](../../implementation/phase113/interim03/files/050-phase113-report.json)
records these milliseconds:

| Program | Arrays17 | Wide18 | Ranges19 |
|---|---:|---:|---:|
| Scalar-region | 64 | 63 | 38 |
| Local-pair | 166 | 157 | 151 |
| Edit-distance | 164 | 155 | 149 |
| Active ray | 140 | 131 | 136 |
| Lexer | 115 | 114 | 112 |
| Closures | 65 | 64 | 63 |

Wide18 raises the inliner node/growth limits; ranges19 instead retains the
original limits and adds range simplification. They are parallel variants of
arrays17, not successive isolated changes. This is `diagnostic1`, not paired
qualification: one round, a historical upstream target of 15 ms, a 5 ms floor
and a 1 ms clock. Small percentage changes remain unresolved; qualified
aggregate fields are null. The six selected cases do not replace the 45-case
corpus.

An earlier, separate [ray witness](../../implementation/phase113/interim03/files/003-ray16-static-delta.json)
shows that inline15 and shared16 QBE become exactly equal after **111 Succ
extraction replacements across 12 functions**. Each recognized helper/scratch
extraction becomes the existing full-word predecessor subtraction. The witness
pins both complete QBE inputs. This isolates a static source16 change; it is
neither a dynamic call count nor evidence attributable to source19's range pass.

## Falsification and remaining gates

Reject on changed full-word results, signedness/shift mistakes, stale facts after
assignment, incorrect terminal-arm joins, lost overflow or reordered effects.
Preserve independent mathematical and call-trace oracles, packed-word cases,
native ownership witnesses and verifier refusals when composing later passes.
If the targeted tests remain in reachable machine code, the proposed mechanism
has failed. If they disappear but matched runtime does not improve, retain that
negative result rather than broadening the claim. Measure compiler cost, code
size and memory separately before full acquisition or promotion.
