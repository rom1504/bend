# Phase70: native observers, broader coverage and a qualified release

The compiler written in Bend now has a general root-preserving observer pass,
checked Bool-array transport and two reductions in repeated native compiler
work. **Compiler03 is installed and qualified.** Compared with Phase69 measured
in the same campaigns, generated C programs take **12.95% less geometric time
on the original six families** and **18.90% less on six broader additions**.
The broader set also exposes substantial remaining allocation/transport gaps.

[Design](../../design/phase70/observers-and-compilation.md) ·
[Verified release summary](evidence/summary.json) ·
[Compiler guide](../../docs/BEND-IN-BEND.md) ·
[Native observer architecture](../../docs/self_hosted/NATIVE_OBSERVERS.md).

This is still the self-hosted Bend compiler: the production algorithms are
Bend source, with the existing C runtime and host drivers. Upstream remains
pinned at `059266225b77c8ca256ac6b25ee5c21449bab151`.

## Five metrics, with separate clocks

| Metric | Selected result | Scope |
| --- | --- | --- |
| Generated C program runtime, original six | **1.12124× upstream**; 12.95% less time than paired Phase69 | Equal-family geometric mean, three rotations |
| Generated C program runtime, six additions | **1.84036× upstream**; 18.90% less time than paired Phase69 | Independently selected membership, separate denominator |
| B1 compilation to C | **3.41827× TypeScript** | Three sources, checked request time |
| Genuine B2 compilation to C | **2.16517× TypeScript** | Same three sources and method |
| Correctness | Candidate native **100/100**, raw **31/31**, B2 self-check and exact B3 | Seven known upstream demand disagreements remain explicit |
| Simplicity | **31,444 physical / 25,722 code lines**, 128 modules | +1,183 physical lines; native production physical lines grow 30.58% |

B1 and B2 are compiler images running on Node and producing C. Their request
clocks exclude Clang, generated-program execution, module imports and the
explicit Bend Base preparation. TypeScript's ordinary request includes its Base
load/check. These are not replacements for earlier broad JS-target compilation
or generated-JS runtime results. Clang acquisition times remain separately
recorded; this phase claims no controlled aggregate Clang speed improvement.

An optional equal-weight view of all twelve native families is **1.43649×
upstream**. It is not a population estimate or a replacement for either primary
cohort. Historical Phase69's 1.0332× score came from another campaign; the same
saved binaries measure 1.28809× on the original six here. The
[timing-drift audit](native-runtime-noise-audit.md) retains that discrepancy and
a targeted repeat without selecting favorable samples.

## Generated-program results

![Native runtime comparison across twelve families](native-runtime-comparison.svg)

| Family | Phase69 ms | Selected ms | Upstream ms | Selected/upstream |
| --- | ---: | ---: | ---: | ---: |
| Numeric | 252 | 251 | 250 | 1.004× |
| Array | 191 | 185 | 174 | 1.063× |
| Closures | 164 | 158 | 225 | 0.702× |
| Tree | 338 | 320 | 194 | 1.649× |
| Map | 737 | 373 | 420 | 0.888× |
| Lexer | 389 | 380 | 210 | 1.810× |
| List pipeline, added | 644 | 646 | 301 | 2.146× |
| BST, added holdout | 681 | 693 | 317 | 2.186× |
| Expression, added holdout | 564 | 483 | 344 | 1.404× |
| Array-map, added | 1126 | 817 | 334 | 2.446× |
| Tape observer, added | 1169 | 897 | 302 | 2.970× |
| String ordering, added | 472 | 276 | 340 | 0.812× |

Each row compares identical work within that family. Absolute milliseconds
across rows represent different work counts. Three-role/three-round primary
campaigns contribute 108 qualified intervals; a separate array/closure
sensitivity check contributes another 36. All outcomes and unfavorable samples
are retained. The two native holdouts were frozen before timing, but their
sources and source-acceptance results were already known.

These binaries were acquired from compiler02. Final compiler03 removes a
compiler-only occurrence shortcut. **All twelve complete C outputs match for
both final B1 and genuine B2**, and 56 host/runtime support files match. This
24-emission qualification transfers the measured results to the selected
release without relabeling the timings as fresh compiler03 executions.
[Full runtime report and reproduction](native-runtime-results.md).

## What shipped, and what did not

1. **P70-001, root-preserving observers.** A bounded structural analysis proves
   that a function returns the same immutable roots while computing a scalar
   observation. An owned adapter retains those roots; a private worker traverses
   borrowed cursors and returns the scalar. This avoids reconstructing every
   visited node and the associated ownership traffic. It admits unrelated
   user-defined shapes without function-name rules. Checked effect and layout
   permissions, residual errors, fresh binders and strict tail progress remain
   part of admission. Unsupported shapes retain ordinary compilation.
2. **P70-004, lazy product-demand checks.** Nested conditional evaluation avoids
   unnecessary scans when an earlier condition decides the answer.
3. **P70-005, compact-body reuse.** Three native consumers reuse bodies that are
   already compacted rather than traversing them again.
4. **P70-007, checked Bool arrays.** Admit the existing exact Bool scalar
   representation so packed arrays and typed scalar helpers become available.
   Uniqueness-based array shortcuts still require the separate unshared permission. Raw, foreign and
   unrelated enum cases retain their refusals.

The first two small compiler-work changes reduced B1 request time by 3.58% in
an early exact-C screen. That is checkpoint evidence, not the final whole-phase
compiler gain. A final balanced comparison of genuine Phase69/final03 images
finds Numeric requests **6.54% slower in B1** (four of four rounds) and **1.09%
slower in B2** (three of four). These are whole-release changes on one source;
they establish the B1 cost without attributing it to one pass. The observer
implementation adds analysis cost of its own.
[Final compilation measurements](compilation-results.md).

**P70-006's occurrence update was removed.** In a four-arm B1/B2 experiment it
failed its retention rule and made B2 Numeric requests slower in all four
paired rounds under the ordinary observer route. Removing it deletes ten lines
and restores the previous implementation. **P70-008's ordinary-ready observer
skip was not selected:** the B2 effect was small and inconsistent. The
[factorial report](compiler-factorial.md) retains every arm, edited diagnostic
image, exact-output check and timing. Diagnostic JS edits were never promoted
as the compiler.

## Correctness and release identity

The selected production source is commit
[`d6d6049`](https://github.com/rom1504/bend/commit/d6d6049e24a083a9b4a2922969c2c66da33ef4d7).
Its installed checked B1 is
`386ae358ee8fe33c5af3f7fec16f956b59451ee6004da99a94146140d3e8a162`.
Genuine B2 and the reproduced B3 both hash to
`d069204f38786de7142f10dbc7126371dfa6f7fa234347da98e7d46a23cced8b`
and contain 4,563,498 bytes.

- The checked build passes its 36 frontend controls. Selected native candidate
  cases pass **100/100**; the reference passes **93/100**. The seven differences
  are one preexisting unused-overflow demand class. The paired workflow is
  deliberately recorded as failed, not reclassified as full conformance.
- Raw execution controls pass **31/31**, including one/four-worker boundaries.
  The checked observer route stays disabled for raw and device paths; this is
  no GPU qualification claim. The broader thirteen native API coverage gaps
  inherited from Phase69 remain outside this selected suite.
- JS executable protection finds **2,992 reachable functions and 100 public
  wrappers unchanged**, with the same runtime. This is continuity evidence,
  not a fresh full frontend/JS sweep.
- Genuine B2 driver checks pass **8/8**, and its own-source check accepts the
  compiler. Proof trust still reports 3,701 explicitly unsafe definitions and
  no independent kernel proof. Type acceptance and fixed-point reproduction
  are not a mathematical correctness proof.
- Final B2 reproduces B3 exactly. Installed verification succeeds before and
  after **42 legacy, 24 default and five helper** controls.

The [correctness report](compiler03-correctness.md) and
[data-only release collector](../../selfhost/tools/performance/phase70/summary-method.md)
separate these gates. The collector verifies 1,259 input files and writes the
portable [summary](evidence/summary.json). The old installed seven-file release
is preserved under its `674e7960…` history identity.

## Complexity and the next useful experiment

The observer implementation adds seven modules and 1,162 physical lines. The
350–600-line estimate was too low: origin analysis, capture-safe symbolic
execution, representation proofs, borrowed residual emission and ownership
adaptation account for the difference. Net compiler growth is 1,183 physical
lines (+3.91% globally, +30.58% within native production modules). This phase
improves performance and coverage at a real maintenance cost; it is not a
simplification result. [Census and time accounting](simplicity-and-time.md).

The strongest new finding is that **avoiding unchanged reconstruction transfers
across different programs**, but it does not solve arbitrary allocation.
Map and String improve substantially; Tape improves yet remains almost 3×.
List pipeline and BST receive no demonstrated benefit. Broadening the benchmark
was necessary to expose this instead of optimizing the old aggregate alone.

The next general runtime candidate is **product and loop-state transport**.
The [Array-map C inspection](native-array-map-opportunity.md) finds recurring
Tuple allocation/destruction even after Bool enables the existing packed path.
Use a saved-C intervention to measure the value of scalar tuple transport,
then test independent array/state loops before adding a new production pass.
For Tape, trees and lists, separately attribute ownership and reconstruction
cost before assuming the same intervention applies.

For compiler speed, profiles favor **reusing validated native layout/arity and
Base planning products**. Native planning/emission dominates sampled requests;
the current observer wrapper still repeats some constructor-book searches and
ordinary lowering. Small CLI programs genuinely reach String comparison through
Nat parsing; this is not evidence of accidental whole-Base emission. A shared
per-request descriptor experiment is more promising than the rejected Boolean
admission shortcut, but no unmeasured gain is claimed.

## Iteration and preservation

The workflow used parallel source, methods, coverage and review lanes, with
one root-owned CPU3 target tree. Node used a 1GiB heap/4MiB stack; the guard
limited process-tree RSS to 2GiB and required 4GiB available memory. Source/data
agents used CPU0. Final receipt accounting finds **38m39s of guarded target
occupancy over a 2h06m12s first-to-last-target span**, peak **1.506GiB** tree
RSS and no pending guard. The remaining time cannot be assigned to waiting,
reasoning, source work or model cost from these receipts alone. Evidence
packaging and final documentation occur afterward. Saved binaries separated runtime timing from Clang; exact-C
checks made compiler-only experiments cheap. Broad native and self-hosting gates
ran on stable candidates. Failed builds, invalid diagnostics and rejected
optimizations remain evidence rather than being overwritten.

Design and source checkpoints were pushed throughout the phase (`658de8a`,
`ee8463a`, `b23c3b9`, `70dfe49`, `d6d6049`). The final release/report commit
collects the qualified installed image and the
[verified evidence capsule](../../selfhost/tools/performance/phase70/artifacts/evidence01/README.md).
The capsule verifies **21,124 entries**, compressed into **148,180,824 bytes**
in four partitions of at most 40MiB. Raw receipts retain historical paths and need the pinned earlier capsules and
external toolchains for replay; this is not a hermetic build claim. Unrelated
inherited work was preserved. No PR comment was posted.
