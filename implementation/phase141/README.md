# Phase141: smaller algorithms without runtime abstraction overhead

The bounded simplification trial retires two duplicated implementations in the
latest experimental incremental compiler: its second top-declaration parser and
its handwritten specialization of structural comparison. The complete source
shrinks from **64,408 to 63,580 physical lines**, or **46,808 to 46,202 code
lines**. This is a useful 1.3% reduction, not evidence that the complete compiler
can already fit in 10k lines.

[Design](../../design/phase141/README.md) ·
[First-hour decision](first-hour.md) ·
[Exact candidate](candidate.json) · [Measurements](metrics.json) ·
[Reproduction and usage](../../docs/self_hosted/compiler-simplification.md) ·
[Independent final review](../../research/phase141/final-review.md).

## What disappeared

| Replacement | Before | After | What remains |
|---|---:|---:|---|
| Normal plus stop-aware top-declaration grammars | Two independently maintained 34-function copies | One stop-aware grammar plus three small adapters | Original public entries, diagnostic/metadata behavior, incremental checkpoints |
| Comparator family |35 definitions /220 code lines |13 definitions /83 code lines | One canonical comparator per structure and one statically specialized list traversal |
| Whole experimental compiler |6,955 definitions /700 laws /357 types |6,887 definitions /683 laws /357 types | All 108 published roots; protected verifier and proof bodies |

The parser removes 393 code lines. Comparison consolidation removes 137 production
algorithm lines and 76 test-helper lines. The latter are reported separately:
replacing redundant test matrices is not production-algorithm simplification.
The17 removed law declarations belong to the retired duplicate parser helpers;
the original public laws and all 11 protected proof-related declarations remain.
No new mathematical proof was written or claimed.

The most useful result is **static algorithm sharing**. Bend's existing `~`
arguments specialize closed types and named comparison policies at compilation
time. The compiler can share the source algorithm without introducing runtime
function application in its hot loop. This is different from the Phase7 generic
visitor experiment, whose modes, shapes and traversal frames introduced their
own complexity and execution costs.

## Evidence and performance boundaries

The native structural-comparison proxy uses real compiler IR value/argument
types, independent input construction and mismatch/length/alias controls. Across
six alternating rounds at 32, 256 and 2,048 elements, static and handwritten
specialization have identical millisecond medians. Runtime callbacks take
1.81–1.88× as long. Scoped QBE and machine inspection confirms that the static
loop reaches local recursion without `rt_apply`; it does not establish identical
machine bytes or a 1.8× whole-compiler gain. A separate nested recursive-template
native program also produces its independently expected result.

The complete native compiler image is 18,854,984 bytes, versus 19,193,752 for
Phase140 N1d (−1.76%). Its QBE is 115,809,396 bytes versus 117,801,984 (−1.69%).
These compare the different compiler sources, so their acquisition times must
not be presented as a same-source compiler-speed experiment.

Four alternating small-request rounds compare the final native candidate with
Phase140 N1d on identical source/Base/runtime/output contracts:

| Request | Candidate / baseline median wall time |
|---|---:|
| Lexer |0.9823× |
| Closures256 |0.8987× |
| Map churn128 |1.0019× |

These include process startup, source reads and QBE output. They support no
observed material compilation regression on these three cases, not a universal
speedup. The earlier parser-only candidate gave 0.9624× on one same-source full
compiler request (370.351s versus384.828s), and a 4.5% slowdown on the small
closure request. Keep that preliminary result separate from the integrated one.
Final self-hosting and real incremental-edit results are recorded in
[metrics.json](metrics.json) and the completion section below.

The final ordinary same-source request gives a more cautious result:

| Compiler executing identical source02 | Native request wall time |
|---|---:|
| Qualified Phase137 N3 |369.697s |
| Direct Phase140 N1d parent |366.331s |
| Phase141 N1, initial self-reproduction |397.840s (+8.60% versus parent) |
| Phase141 N2, flagged-case repeat |376.982s (+2.91% versus parent) |

All products match byte for byte. All allocated file-backed sections of the N1
and N2 executables also match, although their complete ELF hashes differ.
The repeat was warranted by the initial slowdown; it does not justify deleting
that observation or claiming a precise speed ratio. The source is about1.3%
smaller, but this experiment demonstrates **no full-request throughput gain**.
The cold-session bound below is met in its observed pair; an across-the-board
5% ordinary-request bound is **not established** by these noisy observations.
The qualified artifact remains unselected rather than being promoted for speed.

The matched full compiler-edit session uses the same qualified compiler source,
the same late product-policy edit and the same independent QBE oracles in both
versions. This is one ordered pair, not repeated statistical qualification:

| Full-edit measurement | Phase140 parent | Phase141 candidate | Change |
|---|---:|---:|---:|
| Cold session compilation stages |353.636s |361.511s |+2.23% |
| Warm edit compilation stages |101.065s |101.249s |+0.18% |
| Entire native two-revision process |458.418s |466.532s |+1.77% |
| Process plus decoding/transport |469.123s |477.182s |+1.72% |
| Outer guarded command, including preflight |470.759s |478.750s |+1.70% |

All four full products are exact. Peak recorded process-tree RSS is about 2.15GiB
for both sessions. The cold seed is slightly slower, predominantly in backend
work (90.177→95.730s); the warm edit is effectively unchanged. This meets the
existing 5% cold-cost bound but is **not a compilation-speed improvement**.
No machine build is included in this paired session; machine output construction
and the separate compiler self-build are accounted for elsewhere. The historical
Phase140 warm result was 101.030s, close to the freshly rerun parent 101.065s.

For generated-code quality, all 45 frozen N1 programs compile, build and produce
their independent expected outputs. Complete emitted QBE matches retained
qualified products. Exact products under the unchanged runtime/build policy
give a stronger preservation check here than rerunning a noisy broad speed
campaign. This is **not a fresh program-runtime benchmark**, a newly measured
upstream ratio, or a claim covering arbitrary programs.

## Correctness and negative evidence

- 1,739 old/new parser results match exactly: 865 successful parses and 874
  matching rejections, including diagnostic and metadata structure. Five further
  files exceed the hosted stack limit in both versions and remain untested.
- 48 checkpoint, edit, error and recovery comparisons pass against the old API.
- The migrated comparison controls cover 501 independently specified record pairs
  plus list/length controls in 19 rows. They do not compare a function with itself.
- Two-family fresh/cold/warm/no-op session checks preserve complete plans and
  errors;12 full products also match the independently compiled old API.
- The exact native source has its own independent checked-API receipt. The
  earlier controls-added API checks a different source and is not substituted
  for that certificate.
- All 108 published roots and 227 reviewed protected declarations are retained.
  Private `p134v_list` intentionally changes to a static-template interface;
  callers are migrated, and it is not exported as a runtime function.

Failures are retained. The first hosted corpus process exhausted its mismatched
OS/JavaScript stack limits; the bounded rerun records shared RangeErrors
explicitly. The first integrated source put a template below its caller and
failed checking; only declaration placement changed in the corrected source.
A qualification selector initially chose the six-case adapter instead of the
frozen 45 adapter; its subsequent explicit-name attempt failed before targets.
The corrected full45 run is the one cited. None of these is counted as a pass.

The qualified/installed Phase137 compiler remains available. Ordinary native
qualification, finite tests, source checking, proof-body preservation and
experimental incremental behavior establish different properties. No fresh
JS/C-specific conformance campaign, full-language correctness theorem, or
promotion of the incremental service is implied.

## What this says about 10k

The [current-source census](../../research/phase141/deletion-budget.md) counts
38,046 production/API/proof-reachable code lines in qualified Phase137 and
41,187 in experimental Phase140. The remainder includes controls and unresolved
references; “unreached from native main” is not permission to delete supported
JS/C APIs. Blank-line removal, relocation into generated files, host-language
reimplementation and dropping laws would not satisfy the simplification goal.

Three competing source audits prevented a speculative rewrite:

1. The existing checked-output annotator has only 170 implementation lines.
   Deleting it could remove a pass, but replacing its metadata obligations is
   unlikely to provide a large source reduction.
2. R/G/H local-region recognition has a plausible 283-physical-line shared slice,
   not an entire 1,152-line subsystem that can safely be collapsed by 2–3×.
3. Parser duplication and comparator specialization have explicit deletion
   contracts and cheap independent oracles. Those are the two implemented bets.

Reaching 10k while retaining the current functionality would require replacing
roughly three quarters of the actual implementation. This trial establishes a
useful consolidation technique, not confidence in that larger outcome. Do not
spend another three hours collecting tiny cleanups merely to approach a line
target. The next substantial proposal should identify thousands of lines of
existing mechanisms it can retire, preserve their complete contracts, and prove
one replacement slice before beginning a broad rewrite. Static specialization
is a useful tool for such a proposal; a universal runtime visitor is not the
demonstrated answer.

## Completion, cost and reproducibility

The integrated ordinary native route is qualified through an actual
Phase137 N3 → Phase141 N1 → Phase141 N2 chain. Complete Q1/Q2 bytes match;
focused19 passes on both new generations (16 programs plus three expected
source/backend refusals), and all 45 programs pass on N2 with exact frozen QBE.
The native four-revision A→B→A→B session also preserves every independent
product. The persistent incremental service remains experimental.

The selected implementation shrank; total repository text did not. Historical
implementations remain external oracles, and this phase adds audits, controls,
transport/measurement metadata and reproducibility documentation. Python and
JavaScript additions contain no compiler transformation or semantic replacement.
Source counts refer to the assembled active candidate, not deletion of history.

Final native and incremental receipts, campaign cost and archival identities are
linked by [candidate.json](candidate.json), [metrics.json](metrics.json) and the
[evidence inventory](evidence/inventory.json). The capsule preserves failed
attempts, source snapshots, exact methods, small logs and scoped machine-code
excerpts. Large QBE, assembly and native images remain hash-pinned/rebuildable;
the capsule is not a complete independent toolchain distribution.

One controlled CPU3 target lane was used, with at most 3GiB configured tree RSS
for final checks and a 16GiB available-memory floor. Bounded agents audited source,
deletion budgets, contracts and evidence; they did not compete for the target
measurement lane. Research/agent effort has no reliable token or compute meter
in this session and is not fabricated from target wall times.

The experiment reached final measurements about 1h42m after starting, inside the
three-hour limit. Recorded guarded wall time totals69.66minutes, including failed
attempts:44.24minutes native source requests (acquisition, reproduction and timing),
15.93minutes incremental sessions,4.12minutes native semantic gates,1.20minutes
independent source checking,0.82minutes machine construction and3.36minutes other
controls/probes/measurements. Guarded intervals and exact per-job costs are in the
metrics file; the remaining elapsed time includes source audits, integration,
documentation and coordination, often overlapping target execution. It is not a
measurement of agent thinking time. Peak recorded process-tree RSS was about
2.16GiB; no OOM occurred. Packaging and final Git operations follow these timings.

One avoidable cost was acquiring a parser-only native image before the static
family opportunity was established. Its checks exposed no blocker, but the
later integrated image needed another acquisition/reproduction block. A future
similar trial should combine cheap independent component checks before acquiring
one final image, unless an intermediate native failure is the key falsifier.
The large native timings are documented separately from the few-second static
proxy; the latter must not hide the full cost of this investigation.
