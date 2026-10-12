# Phase70 source complexity and time checkpoint

At **2026-10-12 01:52:34 UTC**, registered compiler source has grown by
**1,193 physical lines (+3.94%)** versus installed Phase69. The seven observer
modules account for **1,162 lines**; integration and other changes account for
another **31 net lines**. This is a complexity increase for broader optimization,
not a simplification or line-reduction result. The installed release remains
Phase69, and Phase70 qualification is still running.

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
