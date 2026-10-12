# Compiler03 correctness and selection review

Compiler03 removes the unsuccessful occurrence-insertion optimization from
compiler02 and keeps the existing observer-routing policy. Its checked B1 API is
`386ae358ee8fe33c5af3f7fec16f956b59451ee6004da99a94146140d3e8a162`.
This source review does not transfer compiler02's target results automatically:
compiler03's native, raw, genuine B2 and exact-C gates remain pending here.

## Exact source lineage

The [independent source receipt](evidence/compiler03-source-lineage.json)
compares all 263 files in the compiler02 and compiler03 source snapshots.
Only `back/native/bridge.bend` changes executable source; the other difference
is a documentation addition in `back/native/README.md`. All 256 non-Markdown
files in the working source match compiler03's checked snapshot.

The complete new `bridge.bend` is byte-identical to the pinned Phase69 version.
`nc_uses_term` again calls `index_set(uses, mark, ix(t), 32)` directly, and both
`nc_uses_put` helpers are absent. This restores the existing generic insertion
without changing occurrence traversal, complete U32 keys, malformed Var-as-leaf
handling or ordered sharing/drop policies. The rollback adds no new semantic
assumption. The checked Bool-array change and observer implementation remain
byte-identical to compiler02.

`no_route_one` is unchanged. It still attempts the bounded observer proof after
direct-entry eligibility; there is no ordinary-ready membership guard. The
P70-008 edited JavaScript images remain diagnostic artifacts only.

## Selected and rejected experiments

| Experiment | Compiler03 status | Basis |
| --- | --- | --- |
| P70-001 root-preserving observers | Selected | Existing checked permission, root-origin proof, borrowed-only residual and owned adapter remain |
| P70-004 lazy product demand | Selected | Preserves the decision while avoiding eager rejected-branch work |
| P70-005 compact-body reuse | Selected | Reuses request-owned prepared facts; legacy fallback remains |
| P70-007 checked Bool arrays | Selected | Trusted Bool values are immediate 0/1; raw/foreign refusal and separate sharing certificate remain |
| P70-006 occurrence insertion | Removed | Failed its performance retention rule despite passing semantic helper controls |
| P70-008 ordinary-ready observer skip | Unapplied | Bounded factorial did not establish a stable cross-stage benefit |

P70-002 adds independent coverage and P70-003 gathers compiler profiles; neither
is an optimization requiring a separate shipping code path.

The [factorial report](compiler-factorial.md) retains all eight Base preparations
and 32 clean Numeric requests. The source/data audit verified all forty pinned
worker/guard receipts and the exact reversible substitutions in six diagnostic
images. Every clean request emitted the same complete Numeric C. This validates
the diagnostic comparison's output, not a shipping status for those images.

With the ordinary observer policy, occurrence-off B2 is faster in all four
paired rounds: 1528.654 ms versus 1562.592 ms medians. Occurrence-on therefore
regresses B2 by 2.22%, failing the predeclared maximum 1% per-stage regression
condition. B1 is mixed: 2404.650 ms current versus 2523.401 ms occurrence-off,
with only two of four pairs favoring current and uneven slow samples. There is
no claim that the rollback speeds up B1. The decision removes ten lines that
failed their retention rule rather than promoting a noisy aggregate gain.

## Correctness status and remaining gates

The checked B1 build is confirmed by its attempt and API derivation pins. No
new source-review blocker was found. The [compiler02 review](compiler02-correctness.md)
preserves its completed 100 candidate native goldens, 31 raw controls, Bool
controls, JS protection and B2 driver observations under their original image
identities. Those do not constitute completed compiler03 validation.

Compiler03 still needs its own native100 and raw31 receipts, genuine B2 driver
and self-check/B3 qualification, JS protection, and complete C comparison for
both B1 and B2 against all twelve qualified compiler02 programs. Runtime
evidence can be inherited only for programs whose complete emitted C is shown
identical. The expected seven upstream unused-demand differences must remain
separate from candidate golden passes; the paired workflow must not be labeled
a full conformance pass. Final compilation timing and installation are also
separate from this source checkpoint.
