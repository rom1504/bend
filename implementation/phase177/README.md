# Phase177 — remove repeated frontend work

The selected frontend reduces the frozen compiler request from **56.186 to
54.0595 seconds (3.78%)**. This is a modest, repeatable component improvement,
not the hoped-for architectural breakthrough. Nine candidate forms were screened;
only core substitution and declaration lookup reuse were selected together.

[Design](../../design/phase177/frontend.md) · [Measurements](metrics.json) · [Reproduce](reproduce.md) ·
[Experiment sources](../../selfhost/tests/phase177/README.md) ·
[Profile analysis](../../selfhost/tests/phase177/profile/medium02-analysis.md).

## What work disappeared

**Substitution has one recursive owner.** The previous traversal crossed
`subst`, `subst_node`, `subst_terms` and eager application rebuilding. The new
checked Bend loop keeps child traversal and nested beta substitution in the same
tail-recursive worker. It enters the existing verified private-worker path and
avoids constructing a completed application only to dismantle it immediately.
A restore frame preserves the enclosing substitution after nested beta work.
Opaque variables, direct `subst_node` behavior, malformed applications, source
spans and child order retain their original meanings. Frames and list reversal
still cost work; this is not allocation-free traversal.

**Definition parsing reuses the actual local declaration.** A forward-law fill
previously resolved the same raw local declaration about six times. The parser
now carries that exact result through its continuation chain. The outside book
and scope remain unchanged until publication, so five redundant scans disappear
on this path. We deliberately do not substitute a header-index hit: headers can
erase bodies and include imported declarations. The existing diagnostics and
publication functions retain their order and behavior.

The frozen source has 698 local law fills. A static six-query model predicts
roughly five million avoided row visits. This is a source-derived model, not a
dynamic count or a timing claim. The transformation preserves arbitrary explicit
book/scope arguments, including inconsistent ones used by the controls.

## Measurements and rejected experiments

The small and medium inputs are real compiler closures of 356,626 and 656,302
bytes. Software screens run independent comparisons on separate physical cores
under one aggregate guard. Their single-pair ratios select candidates; they are
not promotion measurements or reliable rankings of differences below a few
percent. Each pair uses the same core, prepared Base, runtime and toolchain.

| Candidate | Small frontend ratio | Medium frontend ratio | Decision |
|---|---:|---:|---|
| One-owner core substitution |0.9725|0.9711|Selected|
| One-owner ID freshening |0.9827|0.9861|Not selected; small marginal effect|
| Tail-recursive declaration filter |0.9744|0.9979|Not selected; neutral at scale|
| Reuse reachability membership |0.9728|0.9987|Not selected; neutral at scale|
| Materializer producer summary |0.9746|0.9903|Not selected; weak transfer|
| One-owner materializer |0.9967|0.9786|Investigated further|
| Materializer plus direct parser substitution |0.9726|0.9777|Not selected|
| Reuse exact local declaration |0.9686|0.9690|Selected|
| All materializer entry points |—|0.9709|Not selected; separate isolated screen|

The last row has two balanced isolated rounds: 12.9310→12.5545s. It is a
different experiment from the concurrent screens. Existing callers bypassed the
combined materializer entry; extending all entries recovered coverage, but the
complete saving remained modest. Private-worker admission is necessary for this
mechanism, not sufficient for a large whole-request gain.

The selected combination then ran **alone on CPU3**, B/C/C/B, on the unchanged
3,150,535-byte Phase170 compiler source:

| Metric | Baseline Phase175 | Selected Phase177 | Less time |
|---|---:|---:|---:|
| Frontend |56.1860s|54.0595s|3.78%|
| Whole diagnostic frontend process |64.5502s|62.4243s|3.29%|

Individual frontend observations were B56.292, C54.165, C53.954, B56.080s.
The whole process includes Base preparation, complete digest observation and
teardown; roughly eight seconds of observation are outside the frontend clock.
Both images were built by Phase175 N2. This is not a comparison of differently
pruned inputs or diagnostic profiler timings.

The actual full native compiler then completed one **candidate-first cold pair**
on that same frozen source: **178.7954→176.8633s, 1.08% less time**. QBE,
assembly and object bytes are identical. Both runs use the same prepared Base,
runtime/toolchain and CPU3, fresh processes, streamed exact-output checking and
no retained IR. No filesystem-cache flush or confidence interval is claimed.
Emission overlaps QBE construction; its clock must not be added to machine time.
The small saving is consistent with about two seconds removed from the frontend.
It is not a new upstream parity result or evidence that the 100s goal is reached.

The checked Bun API screen on the small source gives median ratio 0.9872, but
large warm-up differences make it inconclusive. It does not establish a JS gain
or cover a full JS-hosted self-build. A preceding medium-input screen exhausted
its 90s limit after recording only the baseline; no ratio was derived from it.

## Refreshed profile

The first capture was rejected: a wrapper marker was bypassed by direct-worker
execution, and a 2ms sample interval overran badly. A separate 8ms capture used
eleven actual boundaries, delivered 2,103 samples without loss, and passed the
observer's quality and output checks. The failed capture remains retained.

The medium frontend's disjoint diagnostic intervals total 13.9934s:

| Stage | Seconds | Frontend share |
|---|---:|---:|
| Parse/load |5.4460|38.92%|
| Check/publication |3.5497|25.37%|
| Reach/annotation |1.9869|14.20%|
| Layout |1.0196|7.29%|
| Erasure/request/wrapping |1.7433|12.46%|
| Other frontend work |0.2480|1.77%|

String comparison, destruction and scheduler work span several stages. About
43% of frontend samples lack a valid lexical owner; physical leaves and exact
dispatcher identities are reported separately. Only parsing exceeds the
per-interval 500-sample attribution threshold. Do not convert these samples into
claimed removable seconds or treat missing ancestry as evidence of one caller.

This explains the limited local gains: no selected walker owns most of the
frontend. The three later semantic stages together still cost about 34%.
Earlier attempts to retain types or fuse annotation/erasure already had negative
results; this profile does not justify repeating them without a new mechanism.

## Correctness and qualification boundaries

- 264 complete substitution controls and 565 complete declaration-parser controls
  pass against unchanged checked implementations and independent expectations.
  The latter include 540 direct-header combinations with incoherent scopes.
- The combined API passes complete parse/request values and diagnostics on 14
  real and negative sources. Native digest observations supplement these full
  comparisons; hashes do not replace semantic controls.
- The complete selected compiler passes independent upstream source/type checking
  with zero holes. This is separate from executing the compiler or BendTT proof.
- Its actual native N1 passes all 64 finite native cases, including refusals.
- All 45 timed benchmark QBE products match Phase175 and their historical
  qualified references byte-for-byte. This preserves that measured code quality;
  it is not a new generated-program runtime benchmark or fresh upstream ratio.

Forward `law` declarations in the implementation are signatures, not proofs.
No full-compiler correctness theorem or new BendTT result is claimed. N1's build
omitted the output-stage binding flag; its original receipt was preserved and a
separate supported standalone binding records the exact successful build/source
check. Metadata binding itself establishes no semantic qualification.

## Integration, complexity and research cost

The maintained `src/core/term.bend` and `src/front/compact-parser.bend`, plus
their manifest inventory, now assemble the exact measured selected source:
3,174,925 bytes, SHA256
`1a359a4c94c8293fec12b8722793a5beafae1896dc2a8307bf5359a7f367532f`.
The integration preserves all 112 protected declarations, original declaration
order and all five entry-profile transformations. Three definitions change;
16 helper definitions, 10 forward signatures and one frame type add 260 source
lines/11,341 bytes. Historical experimental-origin comments are retained in the
exact selected source; the maintained manifest now selects these definitions.

This is a performance tradeoff, not source simplification. The six parser
continuation copies must track future semantic fixes to their public counterparts.
The [independent audit](../../selfhost/tests/phase177/selected-audit.md) found no
blocking issue, but records that maintenance risk and changed allocation lifetimes.
Other candidates remain experimental overlays only.

Acquiring the complete N1 cost 181.314s. Its generated QBE grows 98,149,013→
98,163,162 bytes; its binary changes 16,140,352→16,129,616 bytes. These compare
different compiler sources, not same-source runtime quality. The candidate N1
and its standalone binding remain available explicitly under
`selfhost/build/phase177/full-native-n1/`. The installed Phase171 release and
qualified Phase175 N2 reference remain untouched. No new N2/self-reproduction or
JS/C image qualification was purchased for this modest frontend change.

The 61 outer guarded jobs cost **2,302.904 seconds (38.38 minutes)** in aggregate
wall time; 10 nonzero jobs cost 110.461s, including the 90s hosted timeout. Parallel
children are included in their outer job once. Agent effort, research, metadata
work and writing are outside that sum; it is not CPU time or quota accounting.
Three bounded agents supplied source hypotheses, controls and independent audits;
one coordinator owned compiler acquisition and execution. Independent small
screens ran concurrently in software, while final measurements ran alone.

Three concurrent hosted acquisitions hit the 2GiB aggregate cap and the guard
terminated them; a two-worker retry under 4GiB succeeded. No OOM was needed to
discover the bound. Other retained failures include source quantity/match-order
errors, incorrect host String fixtures, missing control exports, the rejected
profile and an evidence-sealer preflight that initially confused failed guards
with unfinished jobs. No old receipt was relabeled as successful.

The byte-verified [evidence archive](evidence.tar.gz) retains 1,389 reports, logs,
source/method snapshots and closure receipts in 12.19MB. The
[index](evidence-index.json) records per-member identities, omitted local machine
artifacts, terminal failures and complete cost accounting. All outer jobs have
retention closures. No installed artifact or unrelated work was deleted.

## Interpretation and next step

The useful general lesson is to carry an already-established semantic result
through the complete computation, and to verify that a traversal actually reaches
the fast execution path. Explicit frames by themselves can add work; smaller
intermediate structures alone do not establish faster compilation.

The strongest cheap shared-mechanism follow-up is the already-researched String
identity test **before the owning adapter's alias guard**, with both ownership
sinks preserved. Phase131 found a few-percent request effect, while a reader-only
shortcut barely helped. It needs current-image causal measurements and semantic
admission, not another name-based runtime patch. It is not a credible10× claim.

A larger gain needs evidence that we can remove a complete semantic stage and
its intermediate consumers, or improve execution across several stages. These
results argue against hand-converting every walker or adding another global
representation based solely on an isolated kernel gain.
