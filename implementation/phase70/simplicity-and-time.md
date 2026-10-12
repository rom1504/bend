# Phase70 source complexity and time accounting

## Selected compiler03 source

The selected source at **`d6d6049`**, checked B1 **`386ae358…`**, contains
**31,444 registered Bend lines**: **1,183 more (+3.91%)** than Phase69.
The observer modules still account for **1,162 lines**. The native directory
as a whole grows **3,879 → 5,062 lines (+30.50%)**, including its unchanged
11-line fixture; the increase is concentrated in this backend. This is a
performance/coverage tradeoff with more implementation complexity, not a
simplification claim. Compiler03 is installed and verified. Its separate
three-source C-emission screen records B1 3.41827× and genuine B2 2.16517×
upstream TS over 27 exact-C requests; imports, Base preparation, Clang and
generated-program execution are excluded. Runtime gains and compiler cost are
distinct, and these narrow compilation ratios do not establish broad parity.
A separate four-round paired Numeric screen takes 6.54% more B1 time and 1.09%
more B2 time than Phase69 (slower in four/four and three/four rounds respectively).
The phase does not establish a whole-version compiler-speed gain.

| Registered Bend source | Phase69 | Selected compiler03 | Net change |
| --- | ---: | ---: | ---: |
| Physical lines | 30,261 | 31,444 | +1,183 (+3.91%) |
| Code lines | 24,768 | 25,722 | +954 (+3.85%) |
| Definitions | 3,533 | 3,701 | +168 |
| Law declarations | 644 | 652 | +8 |
| Types | 126 | 135 | +9 |
| Modules | 121 | 128 | +7 |

Registered native production modules grow **3,868 → 5,051 lines (+30.58%)**,
from 22 to 29 modules. Recursive directory counts are 23 to 30 `.bend` files,
including `fixtures/override_add.bend`. All 1,183 net added production lines are
in the native backend. The seven observer modules retain 1,162 physical / 940 code
lines, leaving 21 physical / 14 code net lines elsewhere in that backend.

The [selected-source census](evidence/compiler03-size.json) pins every registered
module at `d6d6049` and checks its bytes against compiler03's actual checked
snapshot. The [source-lineage review](evidence/compiler03-source-lineage.json)
separately verifies that the only executable change from compiler02 restores
Phase69's `bridge.bend`, removing the rejected occurrence shortcut: **10 physical
lines, seven code lines and two definitions**. The ordinary-ready observer skip
was declined and never added. Removing the shortcut does not remove any of the
six observer concepts documented below.

The compiler02 accounting below is retained under its original timestamp and
source identity. It is historical checkpoint evidence, not the final duration
or source count of compiler03. The [Phase70 report](README.md) records final
release gates and completed target-work accounting separately; the checkpoint
intervals below must not be relabeled as full-phase duration.

## Final guarded-time accounting

The [final source/time snapshot](evidence/source-and-time-final01.json) was
captured at **2026-10-12 02:40:20 UTC**, after target work closed. Its registered
source hashes match the selected compiler03 census above. It contains **558
unique completed guard receipts**, **no pending receipts**, and preserves the
same deduplication/interval-union method as the earlier snapshot. That method
measures occupied wall-clock intervals, not CPU-seconds or model effort.

| Final receipt metric | Observation |
| --- | ---: |
| First recorded target start | 00:33:02.509 UTC |
| Last recorded target finish | 02:39:14.516 UTC |
| First-to-last target span | 7,572.01 s (**2h06m12s**) |
| Union of completed guarded intervals | 2,319.12 s (**38m39s**) |
| Guarded share of recorded span | 30.63% |
| Peak reported process-tree RSS | 1,617,465,344 bytes (**1.506 GiB**) |
| Nonzero guard exits | 19 |
| Pending guard receipts | 0 |

The final scan reads 3,023 JSON files. Forty-six `frame4.json` cache payloads are
recorded as parse exclusions; they are not guard receipts. The 19 nonzero exits
include intentional runtime-error controls, preserved source/harness failures
and upstream disagreements, so they are not 19 compiler regressions.

Eight checked-build/frontend guard intervals occupy **183.27s**, analysis/core
queries **77.54s**, compiler/profile probes **101.48s**, and saved-binary
comparisons **116.37s**. Other guarded commands account for **1,840.46s** and
include native acquisition, broad correctness, self-hosting, identity and
release operations. These are command-category totals, not exclusive
engineering tasks or a claim that all time was spent compiling.

The remaining **87m33s** of the recorded span lies outside completed guard
intervals. Receipts cannot divide it among reading, reasoning, implementation,
review, coordination, unrecorded work or waiting. They also cannot reconstruct
model tokens, quota consumption or billing. The source/emitter/control lanes
worked in parallel while root retained the serialized guarded target lane.

The earlier 11m12s occupancy snapshot below is retained as an intermediate
checkpoint, not added to these final totals. Final accounting includes its
receipts once. The broader runtime improvement and the retained compilation
overhead should guide the next optimization: measure and reduce proof/planning
work without weakening observer demand, identity or fallback requirements.

## Earlier compiler02 checkpoint

At **2026-10-12 01:52:34 UTC**, registered compiler source has grown by
**1,193 physical lines (+3.94%)** versus installed Phase69. The seven observer
modules account for **1,162 lines**; integration and other changes account for
another **31 net lines**. This is a complexity increase for broader optimization,
not a simplification or line-reduction result. At that checkpoint, the installed
release remained Phase69 and Phase70 qualification was still running.

The increase is concentrated in the native backend: its recursive Bend source
directory grows **3,879 → 5,072 lines (+30.76%)**. The whole-compiler percentage
therefore understates the local maintenance cost. All figures below retain the
**compiler02 checkpoint**; selected compiler03 counts are given above.

The [machine-readable snapshot](evidence/source-and-time-checkpoint01.json)
pins every registered module and records the guarded-process receipts used
below. The [read-only census script](../../selfhost/tools/performance/phase70/accounting/source-and-time-v1.py)
reads Git/source files and existing JSON receipts; it launches no compiler or
native target.

## Counting boundary

Baseline `32d159b` and Phase69 release `f1655d0` have identical registered Bend
module bytes. The working-tree census was captured with HEAD `b23c3b9` plus
uncommitted compiler02 source changes. A second census at the end of receipt
collection verified that those source bytes had not changed during the audit.
The snapshot is an explicit working-source identity, not a claim that HEAD alone
contains all counted changes.

The module list comes from `selfhost/src/compiler.json`. Physical lines use
`splitlines`; code lines are nonblank lines whose first nonspace character is
not `#`. Declaration counts recognize top-level `def`, `law` and `type` lines.
These lexical metrics reproduce the Phase69 totals. They are not AST size,
cyclomatic complexity or a count of independent semantic concepts. In
particular, `law` declarations here include recursive function signatures;
counting them does not count proved compiler theorems.

| Registered Bend source | Phase69 | Working checkpoint | Net change |
| --- | ---: | ---: | ---: |
| Physical lines | 30,261 | 31,454 | +1,193 (+3.94%) |
| Code lines | 24,768 | 25,729 | +961 (+3.88%) |
| Definitions | 3,533 | 3,703 | +170 |
| Law declarations | 644 | 652 | +8 |
| Types | 126 | 135 | +9 |
| Modules | 121 | 128 | +7 |

The count excludes copied proposal versions, fixtures, experiment reports,
generated compiler images/C, runtimes, host tools and the bundled Base library.
Those remain real maintenance/storage costs, but mixing them into compiler
source would obscure the implementation change.

## Native backend size

All **1,193 net added production lines** are in `selfhost/src/back/native/`.
Two related counting boundaries make the local change explicit:

| Native backend boundary | Phase69 | Compiler02 checkpoint | Net physical change |
| --- | ---: | ---: | ---: |
| Registered production Bend modules | 3,868 lines /22 modules | 5,061 lines /29 modules | +1,193 (+30.84%) |
| Recursive directory, all `.bend` files | 3,879 lines /23 files | 5,072 lines /30 files | +1,193 (+30.76%) |

The directory count includes the unchanged 11-line
`fixtures/override_add.bend`, which is not a registered compiler module. Calling
all 30 files production modules would therefore mix a fixture into the compiler
census. Both boundaries show the same net implementation growth.

The [separate local derivation](evidence/native-local-checkpoint02.json) reuses
the frozen compiler02 module hashes/counts, records the checkpoint hash, and
verifies that the extra fixture has identical Phase69 and working bytes. It
does not modify the original accounting evidence. These local totals matter
alongside the six added architectural concepts below: the observer pass is a
substantial addition to this backend even though it adds only 3.94% to the whole
compiler.

## Where the new source lives

| Added module | Physical lines | Code lines | Definitions |
| --- | ---: | ---: | ---: |
| `observer-analysis.bend` | 465 | 385 | 66 |
| `observer-layout.bend` | 286 | 230 | 42 |
| `observer-emitter.bend` | 129 | 108 | 16 |
| `observer-adapter.bend` | 102 | 82 | 14 |
| `observer-integration.bend` | 97 | 78 | 14 |
| `observer-plan.bend` | 53 | 41 | 10 |
| `observer-literals.bend` | 30 | 16 | 4 |
| **Observer modules** | **1,162** | **940** | **166** |

The new modules add nine data types and eight law declarations. Existing native
modules add 31 net physical /21 code lines and four definitions: bridge +10,
book +10, scalar-array +4, product +4 and flat +3 physical lines. Static-body
reuse changes `static.bend` without changing its line count. Bool admission also
changes existing code without adding a new line; net line counts alone do not
measure semantic scope.

The initial 350–600-line observer estimate was too low. The analysis/layout/query
portion reached 834 lines; owned adaptation, checked routing, worker admission
and the residual emitter bring the separate observer modules to 1,162. The
result does reuse existing native infrastructure, but that reuse does not make
the new proof machinery free.

The main additional concepts are:

1. A bounded typed schema describing immutable recursive roots and a fixed
   result wrapper.
2. Branch-local origins and ordered field reconstruction as evidence for
   returning the original root.
3. Bounded symbolic evaluation of helpers and raised matchers, preserving
   demand with scoped environments and fresh runtime binders.
4. A small borrowed residual language: scalar bindings, qualified matches,
   scalar returns, strict self-loop transitions and explicit errors.
5. Separation of borrowed cursors from stable owned roots, followed by ordinary
   owned wrapper construction.
6. Explicit checked permission and late scheduler-entry routing with optional
   worker admission and untouched fallback paths.

This six-part explanation is an architectural grouping, not an objective
complexity score. The implementation still relies on ordinary/product workers,
constructor representations, ownership rules, scalar emission and error polling.
It removes no general backend or runtime subsystem. New failures are bounded
refusals of an optional optimization; no second general-purpose compiler IR is
introduced. [The backend guide](../../docs/self_hosted/NATIVE_OBSERVERS.md)
explains the interfaces and limits.

## Guarded time at this cutoff

The snapshot reads completed guard receipts under `selfhost/build/phase70`,
deduplicates identical command/start records and takes the union of their time
intervals. Copied/embedded receipts and enclosing supervisors are not added twice
to occupancy. This is receipt accounting, not CPU utilization, agent effort,
model tokens, quota or billing.

| Receipt metric | Interim observation |
| --- | ---: |
| Unique completed guarded-process receipts | 188 |
| Guarded interval union | 671.66 s (**11m11.7s**) |
| First recorded target start | 00:33:02.509 UTC |
| Last completed target finish included | 01:49:30.508 UTC |
| First-to-last recorded target span | 4,588.00 s (**1h16m28s**) |
| Peak reported process-tree RSS | 1,617,465,344 bytes (**1.506 GiB**) |
| Nonzero guarded process exits | 17 |
| Pending receipt at cutoff | `compiler02-native100/supervisor/run.json` |

Nonzero exits include deliberately exercised runtime errors, preserved source
or harness failures and paired upstream disagreements. They are not seventeen
compiler regressions. Eighteen `frame4.json` cache payloads did not parse as JSON
and were recorded separately; they are compiler caches, not guard receipts.
The in-flight native100 interval and any later completed work are absent from
these totals. This is not a final phase-duration report.

Within the completed receipts, seven checked-build/frontend jobs consumed about
**150.06 seconds**: four successful jobs totaled **127.62 seconds**, and three
failed source builds totaled **22.44 seconds**. Successful checked iterations
were **31.2–32.6 seconds**. The independent core/plan query guards totaled about
**77.54 seconds**; 65 saved-binary/calibration guards totaled about **44.40 seconds**.
Other receipts cover native acquisitions, source acceptance, correctness checks,
compiler probes and diagnostics. These categories describe process work, not
exclusive source-development tasks.

Recorded targets occupy about 14.64% of their first-to-last span. The remaining
65m16s is time outside these completed intervals; it cannot be assigned precisely
to reading, reasoning, coding, review, coordination, unrecorded work or waiting
from the receipts alone. It would be misleading to label all of it validation
waiting or to infer model cost from it.

## What the iteration record supports

The expensive new work was establishing a general analysis and its correctness
boundary. The source lanes developed schema/identity, emission/adaptation and
independent controls concurrently; root retained one guarded target lane. Actual
Bend plan queries preceded C integration, and saved binaries separated program
measurement from compilation. Local source issues were caught by short failed
builds rather than repeated full self-hosting runs.

Keep that separation for the next pass: use schema/plan queries for admission,
small semantic and route controls for code changes, and saved-binary comparisons
for timing. Run broad native and B2/reproduction gates on stable candidates.
Measure repeated planning before adding caches; the current scalar descriptor
scan occurs only after the parameter/result schema qualifies. Shared per-request
descriptors and skipping redundant ordinary-ready plans are candidate compiler
cost reductions, not established gains in this snapshot.

A later accounting snapshot should pin the final selected source and recompute
completed receipt intervals after root closes all targets. It must retain this
interim snapshot rather than rewriting its totals as if final qualification had
already finished.
