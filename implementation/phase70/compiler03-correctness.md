# Compiler03 correctness and selection review

Compiler03 removes the unsuccessful occurrence-insertion optimization from
compiler02 and keeps the existing observer-routing policy. Its checked B1 API is
`386ae358ee8fe33c5af3f7fec16f956b59451ee6004da99a94146140d3e8a162`.
Compiler03 now passes its own 100 selected native goldens and 31 raw controls;
JS protection and genuine B2 production/driver comparisons also pass. Upstream
returns the same seven known demand differences, so the paired native workflow
correctly fails. Fresh B2 type-checking, B2/B3 byte equality and all 24 complete
C mappings now also pass. This is qualification evidence; installation is a
separate operation.

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

The [final-candidate follow-up](evidence/compiler03-native-raw-js-driver-correctness.json)
pins compiler03's completed results and exact observations. The checked B1
build is confirmed by its attempt and API derivation. No new source-review
blocker was found.

| Gate | Compiler03 result | Scope |
| --- | --- | --- |
| Selected native goldens | Candidate 100/100; upstream 93/100 | Exactly the same seven unused-demand differences; no changed inputs or unexpected failure IDs |
| Raw API controls | 31/31 paired passes | Error ordering, raw fallback and observer metadata/node boundaries |
| JS protection | 2,992 reachable functions and 100 public wrappers unchanged | Original protected dependency closure, no additional excluded roots |
| Genuine B2 production and driver | Image emitted; 8/8 observations agree | Executed JS and emitted JS/C bytes; driver gate emits C without running it |
| Complete native C identity | 24/24 outputs match across 12 programs and both B1/B2 | Prior native behavior transfers with equal C and all host/runtime support |
| Fresh B2 own-source check | Type accepted; expected unsafe proof-trust refusal | 3,701 explicitly unsafe definitions; no mathematical proof claim |
| B2/B3 fixed point | 4,563,498 bytes equal | Actual B2 re-emits the pinned checked-source/export closure |

The selected native workflow is complete with `pass=false`, as expected when
upstream's seven results do not match the self-hosted demanded-error goldens.
Each differing upstream program returns `7080` with exit 0; compiler03 retains
the Nat overflow with exit 1. The exact IDs and actual stdout/stderr fields are
in the receipt. This is selected regression coverage, not full upstream or
full-language conformance. The [compiler02 review](compiler02-correctness.md)
remains historical evidence under its original image identities.

The genuine compiler03 B2 image is
`d069204f38786de7142f10dbc7126371dfa6f7fa234347da98e7d46a23cced8b`.
The separate fresh self-check accepts its exact complete source after starting
with an empty private Base cache. Proof trust correctly fails for 3,701
explicitly unsafe definitions; `kernelChecked=false` and `mathematicalProof=false`.
The separate B3 emission reproduces all 4,563,498 B2 bytes exactly. Its inherited
checked-source lane does not independently establish mathematical correctness.
The [self-hosting and C-identity receipt](evidence/compiler03-selfhosting-correctness.json)
records these distinct outcomes and verifies their pins and successful guards.

The completed C-identity v2 gate binds twelve independently native-validated
compiler02 programs: all 24 B1/B2 complete-C outputs match.
It additionally verifies equality of all 56 frozen host/runtime support files,
native support path sets, Base and the prior acquisition's effect/compiler
support identities. This closes the gap where unchanged C could still include
a changed external runtime. The earlier v1 plan was not run. The independent
review verifies these constraints, every C output/oracle hash and all 26
successful preparation/request receipts.

Remaining outside this correctness review: final balanced compiler latency,
release installation and sealed evidence. Runtime behavior is inherited only
for the demonstrated C-and-runtime identities; its timings remain attributed
to the original acquisition. No full-language conformance or mathematical
compiler-correctness proof is inferred from these finite gates.
