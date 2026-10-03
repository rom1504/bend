# Phase40 installed: direct recursive components

Authorization covers design, compiler experiments, reports and commit/push to
`rom1504/bend`, branch `selfhost/bootstrap`. No PR comment without an explicit
new request. Preserve all 103 unrelated starting files and closed raw evidence.

## Installed compiler and scope

Phase40 checked06 is installed. Release verification, all 42 ordinary/relocated
CLI checks and 15 final audit groups pass; 227 canonical files match its checked
snapshot. API
`630879d8f030241a1d2c56e97f18f88b5be2070ac45dd02304afd06b3e3c5c0a`. Pin
`018751270e800bc222a93dad7f257083ee53a5f7` remains unchanged. This is a checked
B1 derivative, not a new self-emitted fixed point. Phase39 is preserved in
release history.

[Report](../implementation/phase40/README.md) ·
[Release](../implementation/phase40/release-06.md) ·
[Admission](../implementation/phase40/performance-admission.md) ·
[Profiles](../implementation/phase40/profile-findings.md) ·
[Portable loop](../selfhost/tools/performance/phase40/README.md)

## Results and costs

Lists at 128/512 improve 9.973× / 13.113× over Phase39; trees at 6/8/9 improve
2.031×/2.176×/1.829×. These points win all five pairs with disjoint ranges, but
tree internal drift remains explicit. Remaining TS gaps are 4.51–6.52× for lists
and 17.15–21.54× for trees. Symbolic regression gains 1.069× historically; its
varied points have overlapping ranges. No typical-program or parity claim.

Selected execution covers 45 points / 23 sources: 42 intact checked05
comparisons whose modules exactly equal fresh checked06 emission, plus three
fresh checked06 ray rotations. Per-row measurement API and protocol remain
explicit. Selected samples total 669; rejected checked05 ray rows remain
preserved. Do not call these 45 fresh checked06 timings. Thirty final points
equal Phase39 bytes; their timing shifts are negative controls. The smallest
Mandelbrot point retains a 9.68% slower median with overlapping ranges.

Checked05's 2.426× ray regression was rejected. Its broad Nat rule bypassed an
existing stronger scalar island. Restricting new Nat-first admission to data
results restores both ray modules byte-for-byte. Final ray ratios vary about
−0.6% to +2.5% with overlapping ranges; they are controls, not new improvements.

All 36 normal checked requests reproduce expected bytes. Request costs rise
24.45% for tree / 19.09% for list, with disjoint ranges and consistent pairs.
Local has a noisy 18.44% increase; numeric is flat. Requests remain 4.66–8.37×
TS on four sources. This release improves selected program execution, not
compiler throughput. Source adds 141 lines (+0.753%) and 17 definitions,
reaching 18,863 lines / 2,104 definitions; 70 modules, 71 types, 640 laws and
runtime bytes remain unchanged. Do not claim simplification.

All 18 diagnostic captures pass. Allocation samples normalized per call fall
81.8% for list512 / 46.9% for tree8. Static total generic call sites grow
because fallback code remains; list hot workers contain no generic calls. Tree
still spends material sampled time in apply/invokeExact/warp and warp_leaf.

## Retained rules and rejected attempts

Reuse existing structural frames and full typed graph/dependency proof for
canonical Nat data producers, proper-descendant tail transfers, and one-child
constructor/known-combiner continuations. Admit only exact built-in
`List<&2,U32>`. Keep materialized tagged intermediates, aliases, original
evaluation/error order, public host/dependency fallback and reentry cleanup. No
fusion, new runtime or new IR.

Preserve checked04's missing saved argument, checked05's ray regression and
inherited diagnostic failures. Versioned counter/decoder/entry-boundary
corrections keep all semantic assertions and bind successful reports to
checked06. The lexer complete-component prototype gains roughly 2× but remains
manual JavaScript; wider String/Char/Sigma proof support is deferred. Do not
count prototype gains as installed results.

## Next investigations

1. Recover tree/list compiler analysis cost. Start with a small normal checked
   request profile; do not assume slower requests arise solely from pass count.
2. Integrate a narrow proved lexer component only after independent String/Char/
   Sigma, Unicode, overflow, mutation and error-order boundaries pass.
3. Follow tree residual hotspots, then Map/String/BST components, using complete
   values and exact ordinary fast-path entry before broad timing.
4. Test fusion only against the new direct-unfused list denominator; the current
   benchmark is first-order, not evidence for callback specialization.
5. Simplify inherited diagnostics around stable semantic owners and explicit
   provenance schemas. Keep assertions and failed artifacts; avoid another
   phase-specific framework merely to rename or relax old expectations.

Use 20/60/300/600-second presets with independent cases. The portable fast-five
check passes in 20.36 seconds including overhead; a checked build plus 36
focused probes takes 45.845 seconds. Full conformance and broad timing are
release gates. Root alone runs heavy work serially: Node 24.18 / CPU3, a 1 GiB
heap, 2 GiB tree RSS and free-memory bounds, fresh paths and deadlines. Do not
nest lock-owning supervisors.

## Correctness and evidence

Frontend agrees on 3,026 main + 196 broader exact observations; preserve 2,525
pass / 497 observed / 4 shared main failures. The 81 backend outcomes retain 69
pass / 8 not applicable / 4 shared failures. The 154 expanded application
observations and 15 + 7 + 3 + 4 inherited owner groups close; new Phase40
controls cover complete lists, Nat/data, mixed frames and scalar precedence.
Counts overlap. Full backend/GPU and independent proof validity remain
unestablished.

The [closed capsule](../implementation/phase40/evidence/README.md) retains
failures, modules, profiles, costs and release checks. Session accounting
excludes the long interruption from declared windows and cannot establish a
causal model-speed multiplier. Future experiments use a new raw phase directory
after closure.