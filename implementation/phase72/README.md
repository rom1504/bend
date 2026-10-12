# Phase72: connect product transport, retain the small compiler

The compiler now carries known products across private calls and loop backedges.
The final paired campaign removes **22.2% of Array.map runtime,13.8% of lexer
runtime and7.7% of BST runtime**, with the other nine cases within1% of the old
compiler. Production grows **13 physical lines /6 code lines**, across two
existing Bend modules. No new IR, runtime representation, host algorithm or
benchmark-specific recognition was added. One agent; no delegation or PR comments.

[Design](../../design/phase72/product-transport.md) ·
[Measurements](measurements.json) ·
[Native backend documentation](../../selfhost/src/back/native/README.md) ·
[Methods](../../selfhost/tools/performance/phase72/README.md).

## Mechanism and correctness boundary

The saved-C BST falsifier showed694→644ms (7.20%). A one-line change then made
Bend recognize a matching constructor argument's result shape before argument
sequencing had converted it to a virtual bundle. The existing flat result could
reach its consuming call without a temporary heap Tuple. Compiler01 reproduced
the benefit:688→640ms (6.98%).

Array.map and lexer had a second barrier: their product parameter can be dropped
on an exit path, so historical prefix-demand admission rejected the private
worker. On the already checked, effect-admitted host path, private workers now
accept exact, already-evaluated bundles even when some path drops the product.
Existing lowering still materializes shared, dropped and opaque bundles at the
original use. Array.map allocates its discarded Tuple on the cold zero exit,
while the hot backedge carries fields directly. No new adapter unpacks an
unknown boxed argument; scheduler/device interfaces remain boxed. Raw compilation
retains the old prefix-demand restriction. Constructor layouts, per-field
ownership, scalar facts, dependency admission and unsupported-case fallback are
all reused. This is the same mechanism applied to three independent families.

## Controlled generated-program execution

All108 final intervals pass independent16-input digests, exact outputs and the
100ms floor. Three rotated rounds compare the old Phase70 compiler, selected
candidate02 and pinned TypeScript upstream0592662. Each family has identical
work/warmups, Clang-O3, CPU3, one thread and GPU disabled. These are internal
execution clocks, excluding compiler emission, Clang and warmup.

| Family | Old C program, ms | New C program, ms | Upstream, ms | Less time |
| --- | ---: | ---: | ---: | ---: |
| numeric | 251 | 252 | 252 | -0.4% |
| array | 170 | 169 | 169 | 0.6% |
| closures | 156 | 157 | 222 | -0.6% |
| tree | 318 | 316 | 194 | 0.6% |
| map | 352 | 354 | 393 | -0.6% |
| lexer | 378 | 326 | 208 | 13.8% |
| list-pipeline | 647 | 649 | 301 | -0.3% |
| bst | 687 | 634 | 317 | 7.7% |
| expression | 443 | 444 | 318 | -0.2% |
| array-map | 734 | 571 | 299 | 22.2% |
| tape-observer | 895 | 892 | 297 | 0.3% |
| string-order | 276 | 277 | 341 | -0.4% |

Original-six geometric mean: **1.11080×→1.08442× upstream**,2.37% less time.
Additional-six: **1.84039×→1.74312×**,5.29% less time. The optional equal-family
combined twelve score improves **1.42979×→1.37488×**,3.84% less time. These are
finite cohorts, not a distribution of every Bend program. This phase does not
establish parity. Seven complete C programs are byte-identical; generated C
across the twelve grows22,005bytes. Static worker/site analysis is retained in
`selfhost/build/phase72/shapes.json`; these counts are not allocation profiles.

An intermediate BST repeat had a misleading median690→698ms during visible
within-run timing drift. Compiler01 and02 BST C and executable hashes are exact;
all observations remain preserved. The final preselected full comparison above
is the reported campaign, rather than choosing the fastest historical samples.

## Compiler speed is a separate metric

A short alternating B1 Numeric screen is unchanged:2341.87→2342.54ms. The final
three-source campaign makes45 fresh requests, alternating old/new B1/B2 and
upstream with three rotated/reversed rounds; all produce their exact role's C.
Imports and explicit Bend Base preparation are outside requests; upstream Base
checking remains inside, as in previous C-request campaigns. No Clang or native
execution enters these clocks, and no profiling clocks enter the samples.

| C compilation metric | Old/upstream | New/upstream | New versus old |
| --- | ---: | ---: | ---: |
| Checked B1 | 3.48067× | 3.47263× | 0.23% less time |
| Genuine B2 | 2.23883× | 2.24608× | 0.32% more time |

These changes are too small to claim a compilation-speed improvement or a
material regression. They are C-target request ratios, not the historical JS
compilation ratios. Numeric/Array/Lexer medians and every request are in the
machine-readable measurements. The B2 Lexer cell is1.35% slower and Numeric
0.62% faster; retain the per-source detail instead of hiding it in an average.

## Qualification and simplicity

Checked B1 frontend36, native candidate100/100, raw31 and the two new loop
controls pass. The pinned reference retains its same seven unused-error-demand
disagreements (93/100); the paired gate remains failed. This does not close all
language/backend gaps. The2,992 non-native generated functions, runtime and
public wrappers are exact. No new JS/GPU runtime sweep or formal proof is claimed.
Genuine B2 generation and eight driver comparisons pass. B2 emits all twelve
complete timed C programs identically, freshly checks its own source and
reproduces B3 exactly. The checked B1 is installed; six release jobs, including
legacy42/default24/helper5 and verification before/after, pass. All seven old
release files are preserved byte-for-byte. [Qualification receipts](qualification.json).
Only the B2 subset of the separate C-identity plan was executed: B1 supplied the
already validated acquisitions, so its twelve redundant re-emission jobs were
intentionally skipped. Unsafe proof-trust refusal remains expected.

Maintained Bend source is31,457 physical /25,728 code lines in128 modules,
+13/+6 against Phase70. Native production uses the existing product/worker
modules; supporting research scripts, fixtures, documentation and preserved
artifacts are separate costs and are not included in that line count.

## Failures, scope and next decision

Three early array-fixture versions were rejected by both compilers: missing
annotation, illegal duplication of affine Array, then a computed match. The
corrected named-consumer fixture uses fresh arrays and passes. The first BST
measurement used the wrong archived upstream path; its empty failed attempt is
retained. One acquisition was refused by the execution lock while a build was
finishing; it was retried in a fresh directory, with no concurrent target run.

The first two ranked opportunities were implemented as one product-transport
change. Constructor-storage reuse and collection fusion were not started: they
require separate cost attribution and ownership controls. Tape (~3×), list
pipeline (~2.16×) and BST (2×) remain useful targets for the next bounded saved-C
falsifier. The balanced-parallel result from Phase71 is unchanged; this phase
makes no new parallel/GPU speed claim.

## Released identities and preservation

Selected source commit:`1176262`; checked B1:`0ab62a7a075d7a3574cbb2d797dee696955b70c79fdddb85623ec95d6b961e44`.
Genuine B2/B3:`bd39db0d7d29c0f3002bdad7045989a0476a37271f69c74c320dc40105bb61b1`.
Flattened Bend source:`2dfc191e23299cc6e93d01b666d36b756005472932087cb31dfc833c45587425`.
Upstream remains`059266225b77c8ca256ac6b25ee5c21449bab151`.

The methods' evidence capsule preserves all Phase72 raw attempts, generated C,
binaries, checked snapshots, B2/B3, validation receipts and failed fixture versions.
Every member and executable mode is reopened and verified. Private usage snapshots
are excluded; only aggregate [accounting](accounting.json) is published. Earlier
baselines/toolchains remain pinned external dependencies. Absolute historical
paths require restoration/adaptation; the archive is not a hermetic environment.

## Time and resource accounting

The measured local telemetry interval spans34.1minutes after initial repository
inspection. One thread changed counters; no subagent was used. Account-limit
events moved52%→54%used over comparable observations: **two percentage points
observed**, not an exact per-task bill. Private telemetry stays local.

The285 unique guarded target trees occupied18min16s total over a27min44s
first-to-last-target span; peak tree RSS was1.525GiB. Preparation, reasoning,
documentation, archiving and Git are outside guarded occupancy. The early BST
saved-C build took4.90s, checked builds31.4/34.1s, native100 gate259s and genuine
B2/full-image generation57.1s. Broad gates were run once for the selected compiler;
B1 re-emission was omitted from the final B2 identity check to avoid redundant work.

The reopened archive contains6,136 files in50,535,513 bytes (48.2MiB), with every
member hash/mode verified. Archive SHA256:
`b7182090fa26f8d9422a848e81c4c8e96e625ce11d6c29088b67dabff8dd28eb`.
The [manifest](../../selfhost/tools/performance/phase72/evidence01/manifest.json)
and [verification](../../selfhost/tools/performance/phase72/evidence01/verification.json)
record exact membership; private usage files are excluded. Historical unrelated
workspace changes were preserved and are not part of this phase.
