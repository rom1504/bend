# Current frontier: Phase64 State09 installed

[Final report](../implementation/phase64/state09-results.md) ·
[Compiler qualification](../implementation/phase64/evidence/state09-qualification.json) ·
[Release](../implementation/phase64/evidence/state09-release.json) ·
[Design](../design/phase64/typed-facts-and-compact-state.md) ·
[Prepared Base architecture](../docs/self_hosted/prepared-base-artifacts.md).

Phase64 State09 is installed and verified as equality-derived checked B1. The
compiler algorithms remain Bend. Its separately generated B2 and B3 pass
self-hosting and exact reproduction. No upstream update or PR comment was made.

## Measured result

The balanced 23-source, three-role, three-round campaign passes 207/207 workers.
Equal-source geometric means of per-role/source median times:

| Clock | Phase63 B2 / TS | Phase64 B2 / TS | Time reduction |
| --- | ---: | ---: | ---: |
| Compilation alone | 1.64387× | 1.43894× | 12.47% |
| Host/API import plus first compilation | 1.18920× | 1.06173× | 10.72% |

All 23 sources improve under both clocks. Every candidate sample is faster than
every baseline sample for its source, a descriptive result rather than a
confidence interval. Two sources are below TS compilation time, one essentially
at parity. The aggregate compilation-only gap still requires about 30.5% less
time to reach parity, or 65.3% to reach 0.5× TS.

These are genuine B2 fresh processes with a prepared persistent Base cache.
Preparation/output verification are outside timing; this is not OS-cold storage,
installed B1 CLI timing or generated-program execution. The tested complete
modules and runtimes remain byte-identical. The earlier Phase63 headline
1.63275× is a different campaign; use the same-campaign baseline above.

## Selected changes and complexity

- Retain original Base TODO count and exact checked-output maximum ID, with
  actual successful request/world coupling and full public fallbacks.
- Share one host-instantiated telescope; avoid rendering discarded tail-admission
  arguments; prefilter native owned-name candidates and use exact classifiers.
- Load an indexed frame4 artifact with full eager validation, typed references,
  exact identity admission, old-format fallback and explicit migration.

Physical Bend source grows 28,115 → 28,279 lines (+0.58%) across the same 114
modules: +19 definitions and one type. The host helper adds 129 lines and driver
13. This is a measured performance tradeoff, not a simplification claim.

Strict36/export95, full checked and B2 source96/numeric34/composition18/
overapplication2, direct26/maintained8/native3/runtime45, fresh own-source type
acceptance, exact B2/B3 reproduction, raw23/point45 equality, legacy42/default24
and five helper-integrity controls pass. Expected unsafe proof-trust refusal
remains. These finite overlapping suites are not a full-language soundness proof.

## Negative evidence and next discriminator

Child-type avoidance removed many queries but regressed whole-request time; it
was rolled back. Compact annotations were deferred after a small measured
allocation share. Neither lazy materialization nor a semantic arena was shipped.
Small local 1–3% B1 gains remain provisional: identical-image A/A showed 3.82%
apparent difference. Do not multiply those gains or assign each an independent
share of the final bundle result.

The next useful investigation is a fresh selected-B2 stage/allocation survey,
then a local intervention that eliminates a whole repeated backend/completion
traversal. Retain facts at their exact demand point and immutable owner. Require
an exact oracle and complete-request gain before extending to a broader typed
plan. Earlier memoization, typed-spine and binary-decoder rejections remain
relevant; a new hypothesis must explain why its discriminator differs.

## Identity, evidence and iteration

Source `41ddb951470b9e80dd6650af7b99cb29ee05994d1bd96a5873e7b817e98a7d4e`.
Checked B1 `a2f8b021c20becc730cf91e8e7fd6db98f2bba8b743adec89154ff9c6217bd6f`.
B2/B3 `b09fe54ad58d105d1c77ccb399f4076660d6109cf2a7f4b21e13933b89c22c2e`.
Upstream `018751270e800bc222a93dad7f257083ee53a5f7`; Node 24.18.0.
Source commit `4e5fe70`.

The previous seven installed artifacts remain under release-history/4a208bff…
and in the Phase64 capsule. All 110 inherited files, 16,691 closed Phase63 files
and the prior published archive were verified unchanged. Failed/rejected runs
remain in the closed Phase64 raw tree and published evidence capsule.

Through final qualification, 75m13.5s elapsed; 36m22.6s (48.36%) was inside closed
supervised target intervals. Remaining time is unclassified work, not measured
waiting. Archival/publication follows that cutoff. The final broad confirmation
itself took 3m38.5s after preparation.

Keep compiler targets serial on CPU3 with one guard: 1 GiB heap, 2 GiB tree RSS
and 4 GiB available-memory floor. Agents handle independent source/review/data
work on CPU0. Use focused checked-B1 controls/screens before full B2 and release
qualification. Stage only owned files; do not reopen closed raw evidence.
