# Phase78: retained native facts and nonescaping entries

Compiler21 is installed as genuine B2 `cc99ac9b…`, with its checked B1 parent
and exact B3 reproduction. [Installed/relocated checks](release.json) pass.
Parity remains unachieved.
[Design](../../design/phase78/b1-parity.md). No agents; one guarded CPU3 process
tree, 2GiB aggregate RSS, 4GiB available-memory floor. No upstream modifications.

## Selected result

| Metric | Same-run Phase77 | Compiler21 |
| --- | ---: | ---: |
| Fresh B1 Bend-to-C request / upstream | 1.88678× | **1.73205×** |
| Fresh B2 Bend-to-C request / upstream | 1.46354× | **1.38187×** |
| Native execution / upstream, twelve families | measured alongside | **1.06678×** |
| Native execution / Phase77 | 1× | **1.00162×** |
| Production Bend physical/code lines | 32,317 /26,408 | **32,471 /26,523** |
| Production Bend modules | 132 | **132** |

The45 paired compilation requests show **8.20% less B1 time and5.58% less B2
time**. Do not compare the new ratios directly with the previous session's1.920×
and1.482× to calculate savings: the paired baseline above controls timing drift.
The clocks exclude imports, explicitly prepared Bend Base, Clang and execution;
upstream checks Base inside its request. No backend products or persistent process
are used. [Complete samples](measurements.json).

The non-IO held-outs improve less. Small B1/B2 take321.7/347.8ms versus334.5/348.4ms
before; upstream302.9ms. Functions65 takes663.1/637.8ms versus676.9/649.5ms;
upstream366.8ms. Thus the three-source mean is not a universal speed ratio.
[Thirty paired held-out requests](heldout.json).

All108 native runtime intervals pass independent checksums. The0.16% aggregate
change versus Phase77 is effectively unchanged at this precision, with individual
changes from about−3.0% to+1.9%. Tree, expression and Array.map remain materially
slower than upstream despite the near-parity aggregate. [Per-family data](runtime.json).
All23 JS benchmark sources are byte-identical to qualified Phase66 outputs, covering
the45 benchmark points; no fresh JS execution timing is claimed.

## Selected implementation

- Retain the weak-head-normal type already computed during annotation and the
  constructor field quantities. A private checked layout walk consumes those
  facts instead of rebuilding lambda environments and constructor telescopes.
  Public raw layout validation keeps its existing reconstruction path.
- Compute an escape index over the whole erased runtime closure. Exactly saturated
  non-bang calls do not need curried factories; bare, partial, overapplied or bang
  references keep them. In the existing checked no-bang host path, inline native
  operations and omit intrinsic entries proven unused. The three timing C files
  shrink21–23% compared with Phase77.
- Retain pre-compaction erased bodies for symbolic observers and make three pure
  observer admission predicates conditional. Raw/foreign paths retain fresh-ID
  construction and the original fallback.

The implementation adds154 physical/115 code lines,0.48%/0.44%, without a new
module. The experiment did not simplify total source size. It rejects160 branch
helpers and the more complicated early-observer plan for insufficient gain.
[Size accounting](simplicity.json).

## Correctness boundary

The checked frontend36, native100, raw31, new14, word10, held-out2, JS9 and28
threaded executions pass. Genuine B2 driver8, own-source type acceptance and exact
B3 reproduction pass; B2 emits all twelve qualified C artifacts exactly. The
reference retains its same seven native failures and thirteen broader native API
gaps remain. This is finite conformance evidence, not a compiler correctness proof.
[Source qualification and exact image identities](source-qualification.json).

## Why the ambitious trials did not reach parity

Direct Boolean control helped less than expected once code growth and cold V8
work were included. Retained type/layout facts and unneeded entry elimination
were more useful. Shortened C names did not help. Two string-tag classifiers did
not help; one emitted48,945 bytes for its discriminator. Early observer planning
passed six native executions but removed only11–22k additional C bytes and gave
no timing gain:1.7649× upstream in its short screen. Reject it and preserve the
[result](early-observer.json) and [prototype patches](../../experiments/phase78/prototypes).

Fresh selected-image profiles still show substantial allocation/GC, normalization,
runtime-template scanning and B1 trampoline work. B1 numeric samples attribute
about238ms to `run_loop`; B2 template scanning costs32–44 sampled ms and GC65–133ms
across these sources. These are overlapping/instrumented profiles, not additive
clean-time savings. [Profiles](profiles.json).

Reaching1× still requires about42.3% less B1 request time or27.6% less B2 time on
this loop. The next larger discriminator is [prepared native library products](../../design/phase78/native-library-products.md).
It must measure actual work avoided, decoding/admission and one-time preparation,
and report that prepared-library contract separately. It is not implemented here.

## Preserved experiment sequence

## First discriminators

| Candidate | Change over predecessor | B1 / same-run Phase77 B1 | B1 / TypeScript |
| --- | --- | ---: | ---: |
| compiler02 | Direct scanner branches | 0.9936 | 1.9021 |
| compiler03 | 19 native helper functions | 0.9649 | 1.8991 |
| compiler04 | Retain normalized annotation heads | 0.9407 | 1.8143 |
| compiler06 | Central lowering/erasure branches | 0.9305 | 1.7991 |
| compiler08 | Checked annotation-driven layout | 0.9217 | 1.7371 |
| compiler09 | Compact injective C symbols | 0.9426 | 1.7924 |

Each screen has 18 fresh requests, 2 rotations over numeric/array/lexer. Compiler02
through08 reproduce Phase77 C exactly. Compiler09 reproduces an independently
lexically alpha-renamed C oracle exactly (strings/comments/non-symbol tokens
unchanged). The compact-symbol prototype did not improve request time; it is not
in compiler10. These small screens do not establish statistically precise gains.

The broader direct-branch rewrites add many helpers for only a few percent; prune
or reject them if an ablation does not justify that complexity. Compiler01 failed
at parsing a computed match scrutinee; compiler05 failed at typed definitions with
existing laws; compiler07 failed a linear-use check. Corrected versions use normal
Bend syntax and passed the checked bootstrap plus its36 frontend cases.

Compiler10 tests a larger change: whole-program escape analysis to omit curried
closure factories for admitted host workers referenced only by exactly saturated
calls. This changes C and is not selected before execution/conformance checks.
Checked layout also remains provisional pending differential and own-source gates.

Raw attempts, snapshots, pins, guard receipts, errors and complete C files are in
`selfhost/build/phase78`. [Screen medians](screens01.json) are a checkpoint, not a
final evidence capsule. Experimental source has not replaced the released image.

## Structural trials and fresh attribution

Compiler10 removes only39–73 closure segments from the timing sources; its
paired result is0.9312× Phase77 B1 /1.7870× upstream. Compiler11 extends the escape
certificate to ordinary nonescaping direct entries and removes inlined intrinsic
entries. It passes six native execution checks and produces21–23% less C on the
three timing sources. Its paired result is0.9041× Phase77 B1 /1.7302× upstream.
These are18-request screening measurements, not final confidence intervals.

Compiler12 removes all160 branch helpers and the scanner rewrites. It retains
annotation/layout and structural entry changes in164 added/18 removed lines
across six production files, and exactly reproduces compiler11 C on three cases.
It costs about3% against compiler11 in these screens but avoids the large source
expansion. Compiler13's exact string-pattern tag discriminator creates48,945 bytes
of B1 JS; compiler14 factors prefix characters. Neither improves the short screen,
so both are rejected. [Further screens](screens02.json).

[Fresh compiler11 profiles](diagnostic11.json) show observer routing123–195ms,
native preparation95–114ms, and final C rendering96–117ms. String.cmp is a
successful expensive observer route. Nat.read.trim bears the first substantial
annotation cost, including possible cold JIT work; do not infer a body-specific
algorithmic defect just from that attribution. Compiler15 tests an exact cheap
negative intrinsic-name filter on the smaller compiler12 source.

The next larger proposal is [reusable native library products](../../design/phase78/native-library-products.md).
Prepared-native-library measurements must remain separate from the existing
prepared-frontend-only baseline, with preparation and reading/admission reported.
No product implementation or parity claim is made at this checkpoint.

## Observer work experiments

Compiler15's prefix filter measures0.9363× Phase77 B1 /1.7637× upstream.
Compiler16 retains pre-compaction erased bodies for observers:0.9227×/1.7632×.
Compiler17 makes three eager observer predicates conditional:0.9134×/1.7319×.
All54 requests across these three screens reproduce compiler11 C exactly;
[receipts and medians](screens03.json). These successive short screens suggest
small gains but do not isolate them precisely from process/JIT variation.
Compiler17 avoids the160 generated branch helpers of compiler11 while recovering
similar upstream-relative speed. No release has changed.

P78-009 tests early observer planning to avoid lowering proved-redundant generic
bodies. Compiler18 hit Bend's match-placement restriction and compiler19 its
affine binder rule; both failures are preserved. Corrected compiler20 is pending.
No cached-library mode is implemented and parity remains an unachieved target.

## Final installed checkpoint and time accounting

Compiler21 is now installed and passes the installed/relocated42/24 checks and
five real session-CLI checks. Earlier pending-installation statements above are
chronological experiment checkpoints; [release receipts](release.json) are final.
[Guard accounting](timing-account.json) records41.65 minutes of guarded execution
within117.77 minutes spanned by those receipts, with overlapping guards counted
once. The remainder includes analysis, editing, orchestration and unrecorded
intervals; this is not a quota estimate. Peak recorded tree RSS was1.66GiB.
No warm-session timing was repeated in this phase.

[Complete verified evidence](../../selfhost/tools/performance/phase78/evidence01/README.md) preserves selected and rejected attempts.
