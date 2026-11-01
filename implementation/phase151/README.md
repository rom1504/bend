# Phase151 — cheaper dispatch exposes lost constant information

The two-table component compiles **2.05× faster** when U32 literal patterns are
spelled as scalar predicates. That source change alone regresses execution.
Machine inspection and a controlled generated-code experiment identify the
cause: selector expansion reconstructs and discards known immediate Unit values.
Removing only those runtime calls restores approximately original execution speed.

This is a validated optimization opportunity, **not a production compiler gain**.
Production source, installed selection and qualified Phase147 compiler are
unchanged. There is no new full cold build, self-reproduction, upstream ratio or
generated-user-program corpus score.

[Design](../../design/phase151/README.md) · [Metrics](metrics.json) ·
[Source audit](../../research/phase151/dispatch-audit.md) ·
[Machine audit](../../research/phase151/runtime-regression.md) ·
[Independent audit](../../research/phase151/independent-audit.md) ·
[Evidence and replay](evidence/README.md).

## What we measured

The source pair contains the actual maintained `p88_roles` and `p112fp_binary`
tables, renamed consistently, with the same dynamic input/consumer main. The
candidate uses full U32 equality and lazy Boolean choice, preserving every list,
opcode spelling and fallback. The original safe annotation on `p112fp_binary`
is retained. Qualified Phase147 N2, Base, carrier, runtime, QBE and machine flags
are identical. Fresh processes and machine outputs are used; OS caches are not
flushed. All targets run serially on CPU3.

| Two-table source | Original patterns | Scalar chain | Balanced direct helpers |
| --- | ---: | ---: | ---: |
| Compiler emission, excluding machine construction | 1.1673s | **0.5702s** | 0.9978s |
| Complete native acquisition | 1.4254s | **0.8201s** | 1.3114s |
| Emitted QBE bytes | 151,981 | 200,485 | 578,610 |

Each value is the mean of two observations. Original/scalar acquisitions use
reversed order; direct acquisitions are subsequent screens. Separate emission
observations rotate reference/scalar/direct and reverse the order, requiring
exact previously retained QBE. Native acquisition overlaps emission and QBE
construction; those clocks must not be added to the separate emission clock.
No confidence intervals or individual-function cost attribution are claimed.

Both ordinary and scalar functions are then executed through the same consuming
loops. Every returned list element or String character contributes to the result.
Inputs vary over valid and fallback cases and wrap U32; timing uses 20 million
queries, seed 4294967290, with no per-query IO. Scalar chains take about **1.91×**
as long for roles and **1.41×** for opcode names in their alternating screen.

Balanced parameter-matched Boolean helpers remove the regression, but require
134 lines/27 declarations including the probe chooser, versus the compact
33-line/three-declaration scalar module. They emit 3.8× the reference QBE while
saving only 8% acquisition time. That is an unattractive production expansion.

## The causal experiment

The original table workers return static data using scalar comparisons and masks.
The scalar chooser workers retain two runtime calls for every visited branch:
`p111_rt_ctor` for a nullary Unit and `p111_rt_sink` for its ignored argument.
QBE already simplifies Boolean comparisons. No runtime closure application or
Boolean heap construction explains this particular gap.

The constructor returns `term_pak(cid,0)` for count 0. Unit has cid 0 in this frozen
image, and its packed word is 72057594037927936. Its sink has no reclamation work.
These are call/check/dispatch costs, **not eliminated heap allocations**.

A small checked Bend tool reads externally authenticated QBE and exact body pins.
It accepts only the two selector workers actually called by the test loops,
requires one occurrence of each body and exact replacement counts, then replaces
42 constructor calls with the immediate value and 42 corresponding sinks with 0.
All other source bytes remain identical, including common loop machinery and
the original table paths. The unchanged pinned toolchain constructs the new binary.

| Same frozen program, 20 million queries | Original binary | Patched binary | Change |
| --- | ---: | ---: | ---: |
| Scalar roles path | 1.3135s | **0.6850s** | 47.85% less |
| Scalar opcode path | 2.1950s | **1.5600s** | 28.93% less |
| Original roles path | 0.6935s | 0.7110s | 2.52% more |
| Original opcode path | 1.5665s | 1.5560s | 0.67% less |

Each row has two alternating pairs. The small changes on the unchanged original
paths remain visible; layout/noise is not ruled out. The much larger removal of
the scalar regression is consistent across both workloads. Patched scalar paths
reach approximately original performance without adding the balanced helpers.
Machine inspection, whole-process clocks and all raw samples are retained.

This patcher is a **fixed-artifact counterfactual**, not a general optimizer.
Its exact body pins are intentionally stronger than a syntactic search. Copying
its text recognizers into the compiler would be the wrong implementation.
The scalar source-acquisition saving and this generated-code experiment are
separate results; the cost of an automatic transformation is still unmeasured.

## Correctness and rejected attempts

Both source variants and the revised patcher pass the independent pinned source
checker. The scalar controls also execute through the independently generated JS
API. Original, scalar, balanced and patched native observations pass:

- 514 paired inputs covering the small domain, high-bit aliases and U32 wrap.
- 28 independently specified table/fallback expectations.
- Ten comparator controls and ten complete loop-observation pairs.
- Exact repeated QBE emission oracles and matching runtime observation hashes.

The Bend patcher refuses a changed body, missing worker and duplicate worker
before creating its output. Root independently confirms exactly 84 changed lines,
all within the two authenticated functions, and unchanged input hashes.
The 514 exact table inputs primarily exercise the unchanged standalone table
definitions; the patched selectors are exercised by loop observations. Their
stronger semantic justification is the independent audit of every changed
instruction pair against the actual runtime object. Finite tests and this
artifact argument are not a new BendTT theorem.

Retained negatives include a malformed initial export manifest, prohibited
computed-match syntax, a callback quantity mismatch, and safe forward helper
references. Each was corrected without weakening checking or safety annotations.
Embedding the 66KB body pins as Bend String literals was a poor tooling choice:
native acquisition hit its 40s deadline; hosted emission of the live transform
hit the host stack limit. Passing authenticated pins as input makes the same
transform cheap to acquire and execute. The prior sources/errors are retained.

A complete prepared-Base decoder driver was prepared but not executed. The
source-only rewrites did not justify a larger consumer/qualification campaign.
Historical whole-compiler profiling bounds all Base preparation at about 0.233s
CPU, so accelerating roles execution cannot itself yield a large cold-build win.
Compiling those helper definitions is a different cost, measured locally here.

## Decision and next step

Do not integrate the scalar regression, the 27-helper expansion, or the frozen
text patcher. Preserve the inexpensive controls and causal evidence.

The strongest next step is the already identified Phase131 prepared-value
boundary: `nbc_definition` retrieves erased source through `nc_source_body`,
so expansion recreates nullary constructors after static preparation. Preserve
the authenticated prepared value and its nonowning fact through bounded inlining.
The Phase131 proposal and controls provide a starting point; its old unqualified
overlay is not an implementation to install blindly.

Keep original semantic admission, constructor identity/arity, special/foreign
refusals, ordered evaluation, ownership and final verification. Prove or check a
narrow nullary-immediate contract first; measure emitted call removal and compiler
analysis cost. Transfer to an existing safe usage-summary/compiler workload before
paying for a full compiler image. This could enable source forms that are both
cheaper to compile and fast to execute, without many hand-written helpers.

The observed saving for these two definitions is only about 0.6s per component
emission. It is not evidence that the 258s compiler build can become 100s. A broader
claim needs attribution and transfer across complete frontend/optimization work.

## Research cost

71 guarded jobs total 122.03s of target execution, with peak tree RSS 220.70MiB.
Two bounded agents supplied source work and independent audits; root owned all
target execution. The 40s failed embedded-pin build is included. Guard time does
not measure agent effort or total wall time; quota/token counters were unavailable.
All runs are closed into verified retention archives, with no pruning or OOM.
[Cost receipts](cost.json) and [retention receipts](retention.json) retain failures
and the separate pre-execution fresh-root refusal.
