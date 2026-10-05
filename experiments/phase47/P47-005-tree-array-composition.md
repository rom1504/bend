# P47-005: compose private raw arrays with scalar trees

Date: 2026-10-05. Pre-implementation status: investigate; not built, qualified,
measured, or installed. Parent: frozen checked-array04, API
`1accfefd906c6bcfd25b2e3f65788cf083c7f14a6f2cefc8165c6073731416a7`.

Hypothesis: complete scalar-tree emission embeds a handle-based copy of an
otherwise eligible array helper graph, bypassing the public raw-array root.
Carrying the same proved representation through that existing private tree will
remove backing-view helper costs there without changing public semantics.

Static evidence: array04 editdist's positive-depth private tree directly invokes
its own `$R_pair`; no public array guard or inherited region proof is involved.
The prepared, separate saved-output counter producer checks maintained local-pair
and editdist depth0/2/3 against exact source/module/oracle identities. Its predicted
path has four/eight handle-based local pair entries at positive depths and one
public raw pair entry at depth zero. Execution is root-owned; no outcome is
assumed here.

The [design](../../design/phase47/tree-array-composition.md) reuses the shared
array audit/normalizer and existing tree frame emitter. Audit both checked branch
terms plus every helper. Retain full host and dependency guards, old helper/body
fallback, zero matcher ABI, and unchanged runtime. Add one raw-tree closure and
an independently observable successful-entry marker. Expected source integration
is at most about 70 lines; generated helper duplication is an explicit cost.

Accept only after independent static review, checked build, maintained and renamed
tree controls, real raw-tree activation, and clean comparison against array04.
Reject on value/event/demand/ABI mismatch or unjustified size/compile-cost growth.
Retain every consumed candidate and failed diagnostic. No universal or target
speed estimate is claimed. Append actual outcomes below after execution.


## Initial source checkpoint

The implementation is frozen pending independent review and root-owned builds.
`array-view.bend` grows from 197 to 221 lines and `tree.bend` from 1164 to 1172:
net +32 lines across exactly those two compiler files. The shared audit now accepts
an explicit list of checked executable terms. The tree adapter adds its root only
to allowed-call lookup, audits the original helper bodies separately, and emits
`$arrayViewTreeBody` through the existing normalized declarations and tree body.
The original guard/body/fallback remain assembled from the original book.
Runtime guards, stack machinery, and public descriptor/Zero entry are unchanged.
Delimiter and whitespace checks pass. Build, activation, correctness replay,
performance, and promotion are still pending at this source checkpoint.


Independent static review subsequently passed both this source checkpoint and
the exact-parent counter producer. Review confirmed closure over both checked
arms, lookup-only root admission, preserved predecessor-plus-one convention,
depth bound, original dependency set, Zero ABI, and complete old fallback. Frozen
source hashes are array-view
`7509f9d5f27c888064b5927bc958d74a5b1c0492619ab576ee878a7bef56ea95`
and tree `4936fad0f0ea6e49200e21c9751d5c3fa52c139732cacf19dd79aee88a325b2c`.
No target execution or performance evidence is implied by this review.


## Checked tree05 checkpoint

The root reports the checked tree05 build, all eight maintained quick suites,
and independent array controls v2, v3, and v4 pass. This validates the newly
composed tree path alongside prior representation/public-boundary controls.
The current root-owned performance screen is separate; no runtime ratio or
promotion result is recorded here before it completes. A proposed narrower
integer-only entry guard is a distinct follow-up with unchanged tree semantics.


## Executed tree05 timing

The root-owned two-point comparison completed successfully in 36 seconds with
the 300-second preset. Relative to the freshly paired worker23 baseline, editdist gained **1.8404×**,
from **2.1046×** to **1.14354×** the pinned TypeScript-generated program's execution
time. The depth-three variation gained **1.85308×**, from **2.10407×** to
**1.13545×** TypeScript time. These are the two measured tree points, not a
whole-corpus parity claim. Maintained canaries also passed. The short row canary
was about 10% slower in that screen despite unchanged reachable code; retain it
for final repeated measurement rather than infer a compiler cause from that point.

The result supports the composition hypothesis: the improved representation must
reach the private body actually executed by an outer optimization. Changing only
the separate public root had left positive-depth trees unchanged. Guard-cost work
remains independent and the original short-fold regression is not resolved by
these tree results.

## Final outcome — installed array06, 2026-10-05

The shared tree adapter is included in installed array06. Independent v4 controls
pass 159 scalar oracles and 11 boundary comparisons; separate counters establish
entry into the actual private tree closure and exactly `2^depth` raw-array leaf
calls at positive depths, unchanged zero behavior and refusal under mutated
hooks. These witnesses exercise composition rather than only a public leaf.
[Control evidence](../../implementation/phase47/control-plan.md#array-tree-v4-private-leaf-composition).

The final full-corpus run measures 1.850–1.863× gains on the two positive-depth
edit-distance points relative to freshly paired worker23, reaching about 1.14×
TypeScript time. This is the final combined array06 result; the earlier tree05
screen remains a separate campaign. Checked build, eight maintained suites,
installed verification, all 42 CLI checks and portable replay pass.
[Final results](../../implementation/phase47/results.md),
[selected qualification](../../selfhost/tools/performance/phase47/evidence/selected-qualification.json).

The five initial canaries had missed this enclosing private path. Future changes
use the existing core8 timing screen, including positive edit distance, alongside
the independent activation controls before spending a full-corpus pass. Neither
the timing screen nor output equality alone proves private-path admission.
