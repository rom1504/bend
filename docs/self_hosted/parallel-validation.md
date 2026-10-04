# Parallel validation without contaminating measurements

**Status: proposed, not implemented or benchmarked.** This plan changes neither
the selected compiler nor the current serial execution policy in
[STEERING](../../experiments/STEERING.md). It proposes a measured pilot with two
correctness/acquisition workers, then three or four if the pilot passes. Generated
program timing, compiler-cost timing and profiles retain exclusive host access.

The objective is shorter time from a frozen compiler change to a trustworthy
decision. More workers are useful only when they shorten that path without losing
identity checks, semantic coverage, failure evidence or measurement isolation.

## What Phase45 actually measured

The [final accounting](../../implementation/phase45/accounting.md) records
**323.10 minutes elapsed** from the first ledger job to the final target-work
cutoff, and **138.15 minutes of summed measured job durations** after nested-job
deduplication and documented additions outside the ledger. Their arithmetic
difference is about **185 minutes**, but this is not measured idle time: it mixes
unclassified implementation, analysis, review, coordination, writing, waiting and
unrecorded work. Summed durations also differ from merged occupied intervals.

| Measured category | Minutes | Scheduling implication |
| --- | ---: | --- |
| Checked compiler builds | 22.87 | Most candidates depended on the previous result; do not assume independent builds. |
| Program and fixture acquisition | 33.56 | Independent source graphs are the clearest batching opportunity. |
| Focused controls and maintained suites | 7.13 | Some independent suites can overlap; mutable-process controls stay isolated. |
| Final semantic qualification | 18.27 | Shard independent observations with exact inventory reconciliation. |
| Execution screens and selected full runtime | 38.46 | Keep clean, serial, fresh role comparisons. |
| Profiles and compiler-cost preparation/run | 7.48 | Reserve quiet measurement windows; distinguish preparation from timed requests. |
| Historical unledgered runtime batches | 7.69 | Already incurred, including a deliberately stopped regression run. |

The table is a selected breakdown, not an alternative total. Final acquisition
inside an enclosing mechanism or compiler-cost job is not added a second time.
The accounting and its
[closed raw evidence index](../../selfhost/tools/performance/phase45/evidence/raw/archive.json)
preserve the complete denominator and excluded nested jobs.

Approximately **40–60 measured minutes** look realistically eligible for parallel
correctness/acquisition work in a comparable campaign. This is a planning estimate
from acquisition and semantic categories, not an identified independent job DAG.
At four effective workers, an ideal divisible pool saves 30–45 minutes:
`P - P/4`, for `P = 40..60`. Dependencies, shared initialization, storage and worker
startup reduce that saving. A reasonable initial target is **15–35 minutes saved**
on a similar 323-minute campaign, roughly **1.05–1.12× overall**. The ideal pool
calculation gives approximately 1.10–1.16×, not four times faster overall.

About 54 measured minutes combine timing screens, final runtime, profiles,
compiler-cost work and the historical interrupted runtime work. Treat this as a
conservative quiet-window reservation, not proof every second was timed execution.
Shortening the unclassified elapsed work needs new instrumentation; more CPUs
alone cannot be credited with saving it. Artifact reuse and earlier rejection may
save additional work, but those gains must not be added to parallelism estimates
without accounting for overlap.

## Hardware and resource ownership

The inspected host has approximately 32GB RAM, four physical cores and eight SMT
threads. The Linux CPU identifiers pair as follows:

| Physical core | Logical CPUs | Initial correctness assignment |
| --- | --- | --- |
| 0 | 0, 4 | Worker A on CPU0 |
| 1 | 1, 5 | Worker B on CPU1 |
| 2 | 2, 6 | Optional worker C on CPU2 |
| 3 | 3, 7 | Optional worker D on CPU3; otherwise quiet timing CPU3 |

Start with one worker per physical core, not eight workers. SMT siblings share
execution resources. **Never schedule a background worker on CPU7 while measuring
on CPU3.** Different physical cores still share caches, memory bandwidth, package
power and storage: CPU0 publication work is not automatically harmless to CPU3
timing. Phase45 retained its overlapping first candidate24 screen as exploratory
and used a clean repeat for the comparison.

The largest observed supervised process tree was **1,382.375MiB, about 1.45GB**.
That is an observation, not a bound for future programs. Preserve the current
1,024MiB Node heap and 2,048MiB per-tree RSS limits for initial trials. Four such
tree reservations total 8GiB, but heap limits alone do not reserve or bound total
host memory. Polling may overshoot; tree RSS can count shared pages more than once.

For the proposed scheduler, reserve each tree's configured maximum before launch,
retain at least 4GiB global host headroom, and account for non-worker processes.
Use an aggregate active-tree budget as well as per-tree limits; four independent
checks of available memory are subject to a launch race. Stop new launches when
headroom is insufficient. Record any swap activity and treat new swapping as a
reason to reduce concurrency. These are pilot settings, not new production defaults.

## Two execution modes

**Throughput mode** permits bounded correctness and acquisition work. A coordinator
owns the work queue and global resource budget. A job owns a fresh output directory,
one immutable compiler attempt, an explicit source selection and its process tree.
Builds of truly independent hypotheses can join this mode only after each source
snapshot and tool dependency is frozen. Never build two evolving working trees
that write the same generated files or Base cache.

**Measurement mode** drains all throughput workers and obtains exclusive host
ownership before timing. Keep fresh processes, role rotation, CPU3 affinity,
fixed Node/runtime/options, unchanged inputs and complete paired samples. Pause
builds, acquisition, profiling, archive compression, large report generation and
publication. Small remote agent messages do not need to stop; local analysis must
not turn into an unrecorded competing CPU or I/O job.

The proposed transition is `throughput → drain → verify quiet → measurement →
release`. Verify process-tree termination and record the idle host state before
starting; do not substitute an arbitrary sleep for checking active work. A queued
measurement prevents new throughput launches so it cannot starve indefinitely.
Cancellation stops the owning process trees and preserves partial receipts.

An alternative is a dedicated benchmark host and a build/validation host. Transfer
immutable modules and manifests, verify hashes after transfer, and run all roles
fresh on the benchmark host. This allows acquisition to overlap timing without
sharing a machine. Ratios remain local to that host and protocol: do not combine
TypeScript samples from one host with candidate samples from another. Hardware,
OS, Node and tool identities must be recorded independently on both hosts.

## Reuse existing tools; change scheduling explicitly

[ExecutionGuard](../../selfhost/tools/performance/programs/support.py) currently
takes one exclusive nonblocking execution lock and runs serial children.
[prepare.py](../../selfhost/tools/performance/programs/prepare.py) and
[run.py](../../selfhost/tools/performance/programs/run.py) share that lock.
Launching several copies currently fails on contention; assigning different lock
paths would bypass protection without establishing aggregate safety. Do not do so.

The [checked development workflow](../PHASE5_DEVELOPMENT.md) already supports
`jobs` from one to four for relevant conformance work. Its workers share the CPU
mask; that setting does not implement the proposed global scheduling contract,
parallel compiler builds or source-acquisition cache. Preserve persistent-worker
histories and recycling rules when interpreting results from a different shard
layout. A correctness pilot may record timings for scheduling analysis, but these
are not controlled compiler-throughput measurements.

Implement the pilot by extending the existing supervisor/coordinator boundary,
not by creating another compiler or benchmark runner. Required additions are an
exclusive measurement lease, bounded throughput slots, aggregate resource
reservation, cancellation and one ledger writer. Keep `run.py` serial. For
acquisition, distribute **distinct source graphs**, then merge verified manifests;
do not compile each input point separately when several points share a source.

A merged acquisition must reject missing or duplicate source/point IDs, mixed
compiler identities, changed tools, incomplete emissions and conflicting module
hashes. Every point retains its original adapter, export, input and oracle. The
complete-row observer is part of the measured work and cannot be removed to make
a worker easier to schedule.

## Cache artifacts by content, not by candidate name

Use a versioned key over the complete artifact-producing input tuple:

| Input | Required identity |
| --- | --- |
| Compiler | Checked attempt provenance, source snapshot, API bytes and derivation profile |
| Runtime | Runtime module/fragments and host integration bytes |
| Prelude | Base bytes, validated cache identity and upstream pin |
| Program | Root source plus transitive imported sources and foreign dependencies |
| Configuration | Target, emission/check flags, relevant environment and resolution rules |
| Tools | Node/toolchain, acquisition worker, verifiers, adapters and cache schema |
| Observation | Catalog point, export, arguments, oracle and observer derivation |

Some observation inputs can belong to a second adapter layer rather than forcing
recompilation of identical raw source. Keep both keys explicit and bind the adapter
receipt to the raw emitted module. Changes to catalog expectations still require
fresh validation even if raw program bytes can be reused.

API hash alone is insufficient: worker22 and selected23 shared the API but changed
the runtime. A candidate label, path, Git commit or modification timestamp is not
a complete key. Verify immutable inputs before and after acquisition; publish
successful cache entries atomically, and rehash the output and its provenance on
lookup. A failed/interrupted entry remains evidence and is never a cache hit.

Reuse checked emissions and unchanged source artifacts, not old timing samples.
Each claimed speed comparison still runs TypeScript, baseline and candidate
together. Record hits, misses, bytes read, verification time and work avoided.
Do not infer the avoided cost from an unrelated historical compilation.
Cache-hit correctness receipts must identify the original acquisition and the new
identity-verification receipt rather than pretending compilation ran again.

## Agent and integration workflow

Nine agent slots were available in Phase45; that does not mean nine continuously
busy agents or nine local execution slots. Use agents to remove independent
analysis/review dependencies while the coordinator owns host resources.

1. Freeze a common parent with compiler/runtime/Base identities. Give each agent
   one bounded hypothesis, explicit owned files and the smallest discriminating
   counterexample. Keep control fixtures independent of the preferred rewrite.
2. Run code inspection, source transformation, independent controls and review in
   parallel. Use isolated worktrees or patches against the frozen parent when
   ownership overlaps. Keep shared IR/schema changes under one integration owner.
3. Record the minimum deliverable before requesting execution: patch, source
   identities, expected mechanism activation, semantic risk and falsifier.
   Do not queue full-corpus runs for an unreviewed or unactivated mechanism.
4. Build and acquire the minimal exact selection once. After a checked build,
   parallelize independent correctness work in throughput mode. Report actual
   verdicts, not just exit codes or successful source compilation.
5. Enter a quiet window for canaries and a causal baseline/candidate comparison.
   Preserve an ablation for interacting changes before integrating survivors.
6. Rebase accepted changes into one frozen integration image. Rerun affected
   boundary controls and canaries. Broad semantics and the complete corpus qualify
   that exact image; passing sibling snapshots do not qualify the combination.

Default investigations to the existing 20-minute bounded experiment and five-minute
progress checkpoint. At the checkpoint report a concrete observation or blocker;
at 20 minutes either provide a falsifier/prototype or justify a new explicit bound.
A long build or gate receives its own deadline. These are decision checkpoints,
not a reason to cancel a nearly complete approved job without assessing its cost.

## Coverage and duration are separate choices

Use the maintained [Phase45 portable guide](../../selfhost/tools/performance/phase45/README.md),
the [45-point catalog](../../selfhost/tools/performance/phase37/catalog.json) and
the existing runner. The following is a proposed escalation policy, using existing
presets; no new replay was executed to write this plan.

| Stage | Preset and selection | Decision |
| --- | --- | --- |
| Preview | `--plan` with exact manifests/cases | Verify inputs and protocol without program execution. |
| Cheap screen | 20, explicit pair/scalar/generic-row cases | Reject obvious regressions; incomplete samples do not pass. |
| Mandatory canaries | 60, `--set fast`, all five points | Run before feature-focused timing or a long campaign. |
| Transfer | 60 core, then 300 broad | Look for effects outside the motivating case. |
| Focused confirmation | 300 or 600 on explicit affected points | Check drift and activation with a deeper protocol. |
| Candidate qualification | 600 per each of three full slices | Complete all 45 points and 669 fresh samples before aggregation. |

The budget chooses warmup/sample/round presets and a deadline; it does not promise
that a selection finishes in exactly that many seconds. Selecting one case at 600
does not warm it for 600 seconds. Source acquisition is a separate step. Full
coverage needs three serial batches: 669 one-second warmup floors alone cannot
fit into a single 600-second budget. Missing, interrupted and failed points remain
visible; never shrink inputs or select only completed favorable points.

Stop escalation after a semantic mismatch, missing activation or a clear canary
regression. For small differences, inspect raw variation and half-window drift,
then permit one predeclared confirmation before deciding whether more work is
justified. Do not repeatedly sample until an attractive ratio appears. Instrumented
entry counters, profiles and transformed saved outputs explain mechanisms; they
never replace clean timings or checked compiler qualification.

## Accounting required for the pilot

Extend the existing [job receipt wrapper](../../selfhost/tools/performance/phase43/job.py)
and supervisor receipts with a parent job ID, dependency IDs, candidate key,
job kind, requested/start/finish times and explicit wait reason. Distinguish queue
wait, input dependency, measurement lease, memory reservation and execution.
Preserve consumed producer scripts before execution and keep one append-only
ledger writer; workers write separate immutable receipts.

Record CPU mask and sibling topology, Node/version/flags, host identity, per-tree
and aggregate RSS, minimum available memory, deadlines, cancellation and exit
status. Bind checked observations, module/sample hashes, exact role rotation and
process receipts. Record stdout/stderr even for early failures and empty results.

Publish separate totals for elapsed campaign time, summed enclosing job duration,
union of occupied intervals, quiet measurement intervals and unclassified gaps.
Count either a parent interval or its nested children in additive totals, not
both. Parallel sums can exceed wall time; do not call them utilization or speedup
without the interval calculation. Log data-only archive/report/publication jobs
too, so future overlaps are identified rather than reconstructed from chat.

Measure agent task dispatch, first deliverable, review and integration timestamps
if coordination latency is of interest. Those intervals do not measure continuous
agent reasoning, CPU use or token cost. Report only the quantities actually logged.

## Pilot acceptance and rollout

1. Freeze one existing checked image and a fixed correctness/acquisition selection.
   Establish a serial reference, then two workers on CPU0/1, with unchanged source,
   tools, worker-history rules and total observations. Alternate schedule order
   over at least three complete trials; keep trials outside performance claims.
2. Require identical canonical semantic observations and emitted bytes, or a
   documented pre-existing normalization rule. Retain all known failures and
   require complete, disjoint shard inventories. Missing results are a pilot failure.
3. Require clean cancellation, no leaked descendants, no lock bypass, respected
   aggregate reservations and no new memory-pressure failures. Exercise a small
   synthetic timeout/cancellation case before real parallel compiler jobs.
4. Adopt two workers only if median selected-workflow wall improves at least 20%
   with repeatable direction and no semantic/resource regression. This is a pilot
   decision threshold, not a measured expected gain. Report startup and cache
   effects separately. If three/four workers add less than 10% incremental benefit,
   keep the lower count and avoid extra coordination.
5. Demonstrate the measurement lease: throughput admission stops, running jobs
   drain, CPU3 and sibling7 are quiet, and no publisher/profile/build overlaps the
   subsequent clean timing. Preserve separate serial timing control results.
6. Only after independent review update the active resource policy and tool docs.
   Roll back to serial execution if identity, resource or measurement isolation
   checks fail; retain the failed pilot and its exact scheduling configuration.

The first useful outcome is a reproducible reduction in one measured validation
path. A shorter campaign is established only by a later complete accounting with
comparable scope; it must not be inferred from worker count or a fast shard alone.
