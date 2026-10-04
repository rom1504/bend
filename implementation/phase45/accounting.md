# Phase45 time and resource accounting

**Provisional through campaign sequence 223 and the two completed/stopped worker17b qualification reports. No selected release is claimed.** This update ends at **2026-10-04 17:38:13.910 UTC**. The observed campaign starts at **14:08:59.451 UTC**, giving **209.24 minutes (3h 29m 14s)** elapsed. Design commit `0339d08` was recorded at 14:13:16; its hash is not a time. Later worker21 work is outside this cutoff.

The 222 enclosing ledger job receipts total **62.16 minutes**. Two separately launched qualification batches add **7.69 minutes**, giving **69.85 minutes of measured enclosing wall time**. These are wall durations, not CPU time or agent reasoning time. The ledger cannot apportion the rest of the session among implementation, analysis, coordination, review, documentation, waiting or uninstrumented gaps.

## Measured ledger work

| Category | Enclosing jobs | Wall seconds | Wall minutes |
| --- | ---: | ---: | ---: |
| Checked compiler builds | 25 | 1,115.08 | 18.58 |
| Program and fixture acquisition | 69 | 1,356.88 | 22.61 |
| Execution timing screens | 35 | 851.21 | 14.19 |
| Focused semantic and boundary controls | 71 | 114.25 | 1.90 |
| Eight-suite maintained gates | 14 | 210.98 | 3.52 |
| CPU and allocation profiles | 5 | 80.31 | 1.34 |
| Read-only artifact preparation | 3 | 0.99 | 0.02 |
| **Ledger subtotal** | **222** | **3,729.70** | **62.16** |

Every campaign event's command, start/finish, status and wall time agrees with its rehashed `phase43/job.py` receipt. Count each enclosing job once. Do not additionally sum its compiler bootstrap, supervisor, preparation children, suite subprocesses or execution samples.

The three read-only artifact derivations total 0.986s. Two briefly overlap acquisition, for 0.150s and 0.370s. No recorded target-job intervals overlap. Ledger-only merged occupancy is **62.16 minutes**; it differs slightly from monotonic wall sums because of timestamp/receipt overhead and those overlaps.

Builds plus program/fixture acquisition account for **41.20 minutes**, or **66.30%** of measured ledger target time. The 25 builds comprise 23 successful builds and two early failures. Their successful build mean is 48.08s. The full worker16/17b/18 source acquisitions take 155.79/162.48/160.38s; most focused boundary controls take about one or two seconds. Profiling totals only 1.34 minutes.

## Full-comparison cost outside the ledger

The worker17b runtime stage was launched directly from `final17-plan/02-runtime.sh`. Its enclosing report durations must be added separately:

| Qualification batch | State | Retained sample entries | Enclosing seconds |
| --- | --- | ---: | ---: |
| `qualification17b/runtime-0` | 15 points completed; values pass; major performance regression found | 219 | 377.136 |
| `qualification17b/runtime-1` | Stopped by root after that regression; incomplete | 52 | 84.205 |
| `qualification17b/runtime-2` | Not launched | 0 | 0 |
| **Additional measured wall** | | | **461.342** |

The 271 sample processes consume 435.638s *inside* those batches; their time is not added again. Their timestamps do not overlap any ledger target interval. Together with ledger job intervals they establish at least **69.42 minutes** of timestamped occupancy; batch setup/report overhead has no separate enclosing absolute timestamps and is included only in the measured wall total. Therefore a precise full-session merged-occupancy percentage is not asserted.

The stopped batch's final child records `stoppedFor: "signal"`, returncode −9, and a peak of 62,156,800 bytes. It was deliberately stopped following the regression, not reported as an OOM or failed language-value test. Its partial samples are never pooled into a completed benchmark. The generic-row regression was repaired by worker18; worker20's later 14.841s probe rejected reopening acyclic admission without another long run. See [selection evidence](../../experiments/phase45/P45-018-acyclic-root-profitability.md) and [the causal ablation](../../experiments/phase45/P45-020-acyclic-reentry-ablation.md).

## Failed jobs and rejected ideas

Eleven enclosing ledger jobs returned nonzero status, totaling **28.481s**. The separately stopped qualification batch above is additional work, not hidden in this total.

| Nonzero-exit job | Wall seconds |
| --- | ---: |
| `diagnose-worker02` | 0.059 |
| `checked-worker04` | 4.112 |
| `qualify-worker09` | 0.415 |
| `number-nat-controls11` | 0.599 |
| `runtime-worker10` | 2.649 |
| `monomorphic-controls13` | 1.067 |
| `record-controls16` | 0.583 |
| `checked-worker17` | 5.216 |
| `number-nat-refusal17b` | 6.596 |
| `number-nat-refusal18` | 6.296 |
| `primitive-positive-controls19` | 0.890 |

These include source acquisition errors, manifest/control mismatches and behavioral failures. Worker04 hit a source-match restriction; the isolated worker10 predecessor omitted the shared budget declaration; the first alias-admission control exposed a matcher-prefix ABI mismatch; worker17 needed a local constructor annotation. Primitive-positive v1 selected a different preexisting backend and correctly failed its activation assertion; the new v2 source later passed 40 observations. The Nat-refusal jobs have nonzero statuses and are not relabeled as passed here; their diagnosis belongs to the semantic qualification report.

Nonzero exits are **not the entire cost of rejected ideas**. Successful builds/acquisition/timings for later-rejected nullary, primitive-guard or acyclic-entry proposals stay in their ordinary categories. A completed timing probe can correctly reject an optimization. Prepared but unexecuted fixture files contribute no measured target time.

## Concurrency and resources

Nine agent slots were available, including root. Actual parallel task roles included IR/model work, worker lowering/emission, analysis and representation, independent review, fixture/controller validation, and primitive-capability investigation. This is not a claim that all nine slots were occupied continuously. No per-agent active-time, token-cost or reasoning ledger is available, so none is estimated.

Agents overlapped source work, analysis, documentation and static review with root-owned target execution. Builds, profiles, benchmarks and heavy validation stayed serialized. Extra agents can shorten independent development and review; they do not divide this serial validation path by their count.

Policy was CPU3, Node24.18.0, 1,024MiB Node heap, 2,048MiB process-tree RSS cap and 2,048MiB available-memory floor. The largest observed supervised peak remains **1,449,525,248 bytes** (**1,382.375MiB; 1.45GB**), from `run-checked-worker13b/run.json`. Tree RSS can double-count shared pages; it is not exact private heap. No recorded failure here was attributed to the RSS limit.

## Evidence and remaining qualification

The updated ledger prefix is 308,194 bytes through sequence 223, SHA-256 `624eac6b175ab0a401a93f6b597b93714b3702dbf3a52ec0c92f17a2447aa2e3`. Its raw path is `selfhost/build/phase45/campaign.jsonl`; later appends are outside this cutoff. Completed/stopped runtime report hashes are:

- Batch0: `6b4e5b529c63cafaf1105f4f6a71398a645f9f6defcff4082d266438f65aa814`.
- Batch1: `1b58f36c73af3b30bbcb876acb39bdfa2ad9db18fe2084afd0e7d2de8e9b5eaf`.

The earlier data-only `selfhost/build/phase45/accounting-provisional01.json` remains unchanged. It describes only the earlier sequence 193 cutoff, 49.71 minutes of ledger jobs, and then-pending final batches. It is historical accounting, not the latest total. All raw paths will be preserved in the final evidence archive; they are not GitHub links to ignored files.

Full frontend, broader frontend, backend, final mixed-feature composition, compiler-cost comparison and a completed fresh 45-point runtime comparison still require the eventual selected image. Reusing an existing same-image maintained-suite receipt must not count its gate twice. A future stage is accounted either by its enclosing job or by disjoint child reports, never both.

The largest measured efficiency opportunity is exact artifact reuse and smaller first acquisition screens. Run all maintained fast canaries before broader feature screens: omitting the generic row allowed its regression to reach the expensive long run. Full representative validation remains necessary, but successful fast falsifiers should stop bad candidates before it.
