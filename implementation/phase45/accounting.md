# Phase45 final time and resource accounting

The final measured target-work cutoff is **2026-10-04 19:32:05.733 UTC**, ledger sequence 314 (`job-candidate25-vs23-confirmation`). The campaign began at **14:08:59.451 UTC**: **323.10 minutes, or 5h23m6s**, of observed elapsed time. Design commit `0339d08` was recorded at 14:13:16; its hash is not a time. Subsequent archive/index publication and commit/push time are outside this measured cutoff.

After nested-job deduplication, the ledger contains **294 enclosing jobs totaling 130.11 minutes**. Two unledgered historical runtime batches add 7.69 minutes and two measured data-only preflights add 0.36 minutes: **138.15 minutes (2h18m9s) of measured wall-duration sums**. This is not CPU time, exact merged occupancy or agent reasoning time. The receipts cannot apportion the rest of the session among implementation, analysis, review, coordination, writing, waiting or uninstrumented work; it must not be labeled idle time.

Worker23 is the installed, qualified version. Its complete runtime, semantic and compiler-cost checks, 12 profiles, 42 CLI checks and 27 portable smoke samples passed. Workers24 and25 were measured as unselected prototypes; their work remains included in the accounting. Neither narrow screen was promoted into the selected 45-point performance aggregate.

## Enclosing ledger work

| Category | Counted jobs | Wall seconds | Wall minutes |
| --- | ---: | ---: | ---: |
| Source and artifact preparation | 13 | 2.61 | 0.04 |
| Checked compiler builds | 30 | 1,372.45 | 22.87 |
| Program and fixture acquisition | 88 | 2,013.44 | 33.56 |
| Execution timing screens | 46 | 1,163.58 | 19.39 |
| Focused semantic and boundary controls | 81 | 135.70 | 2.26 |
| Eight-suite maintained gates | 19 | 292.27 | 4.87 |
| CPU and allocation profiles | 6 | 100.26 | 1.67 |
| Selected-image mechanism qualification | 1 | 70.41 | 1.17 |
| Selected-image full runtime | 3 | 1,144.19 | 19.07 |
| Selected-image full semantics | 1 | 1,096.10 | 18.27 |
| Selected-image compiler-cost preparation and run | 1 | 348.73 | 5.81 |
| Selected-image qualification closure | 1 | 3.96 | 0.07 |
| Installation, release and portable smoke | 4 | 62.93 | 1.05 |
| **Deduplicated ledger total** | **294** | **7,806.63** | **130.11** |

Every ledger event was checked against its rehashed enclosing receipt: command, start/finish, status and wall time must agree. The original ledger has 313 job events. `job-mechanisms23` at sequence 275 encloses 19 acquisition/control jobs at sequences 256–274. Count its 70.409s once and exclude their 67.817s from the sum. Their successful detailed receipts remain evidence, not extra elapsed work. A naive sum of all ledger rows would overcount by that 67.817s.

Compiler builds and program/fixture acquisition together consume 56.43 minutes. The 30 builds include 28 successful builds averaging 48.68s and two early failures. The table places selected-image mechanism acquisitions inside their enclosing mechanism category, and cost preparation inside its enclosing cost category; those children are not silently added to the acquisition column.

## Full selected-image validation costs

| Stage | Enclosing measured seconds | Nested detail, already included |
| --- | ---: | --- |
| Final 45-point runtime | 1,144.187 | Three runner reports total 1,143.510s; 669 samples |
| Full semantics | 1,096.102 | Frontend 781.293s, broader frontend 38.155s, backend 268.932s, plus composition/acquisition/overhead |
| Compiler-cost preparation and run | 348.730 | Runner 309.599s, including 36 requests and their child processes |
| Mechanism qualification | 70.409 | Nineteen ledger children total 67.817s |
| Final CPU/allocation diagnostics | 19.948 | Inner 12-profile report 19.708s |
| Installation/verification/CLI/portable smoke | 62.925 | Four enclosing jobs; 42 CLI checks and 27 portable samples |

These stage values explain the serial validation cost; they are not additional totals to add to the ledger table. In particular, compiler-cost request time totals 95.298s and its child-process time 267.376s inside the 309.599s runner. The generated-program runtime comparison and compiler request comparison remain separate metrics.

Workers24 and25 add 15 and 12 ledger jobs totaling 197.074s and 190.703s respectively. Candidate25's final enclosing confirmation job is 49.625s; its internal 30-sample runtime report is 49.550s. The selected release remains23 because the narrow prototype improvements came with substantial code growth and lacked broad qualification, not because their successful work disappeared from the time accounting.

## Work outside the ledger

The rejected worker17b runtime stage was launched directly from `final17-plan/02-runtime.sh`:

| Historical batch | State | Retained sample entries | Enclosing seconds |
| --- | --- | ---: | ---: |
| `qualification17b/runtime-0` | 15 points completed; values passed; major row regression found | 219 | 377.136 |
| `qualification17b/runtime-1` | Deliberately stopped after that regression; incomplete | 52 | 84.205 |
| `qualification17b/runtime-2` | Not launched | 0 | 0 |
| **Additional historical runtime wall** | | | **461.342** |

The 271 nested sample processes total 435.638s inside those batches and are not added again. Their timestamps do not overlap ledger target intervals. The stopped batch records `stoppedFor: "signal"` and returncode−9 in its final child; this was root's deliberate stop, not an OOM or failed language-value test. Partial samples are not pooled into a completed comparison.

Two later CPU0 data-only preflights have separate duration receipts: publication validation 20.835s and index validation 0.472s. Their reports explicitly record no compiler or generated-program execution. They add **21.307s** to measured wall-duration sums, but have no absolute start/finish timestamps. Earlier failed publisher preflights and the first index-wrapper error are preserved without reliable measured durations; no seconds are invented for them.

Ledger intervals plus the timestamped 17b sample processes establish at least **137.37 minutes of known occupancy**. This is a lower bound: the 17b setup/report overhead and data-only preflights lack enclosing absolute intervals. Wall-duration sums, known timestamped occupancy and the 323.10-minute elapsed campaign are different quantities. No exact full-session occupancy percentage or breakdown of the remaining elapsed gap is asserted.

## Failures, rejected proposals and concurrency

Fourteen counted ledger jobs returned nonzero status, totaling **39.471s**:

| Nonzero-exit job | Enclosing seconds |
| --- | ---: |
| `job-diagnose-worker02` | 0.059 |
| `job-checked-worker04` | 4.112 |
| `job-qualify-worker09` | 0.415 |
| `job-number-nat-controls11` | 0.599 |
| `job-runtime-worker10` | 2.649 |
| `job-monomorphic-controls13` | 1.067 |
| `job-record-controls16` | 0.583 |
| `job-checked-worker17` | 5.216 |
| `job-number-nat-refusal17b` | 6.596 |
| `job-number-nat-refusal18` | 6.296 |
| `job-primitive-positive-controls19` | 0.890 |
| `job-nullary21-baseline` | 3.606 |
| `job-exact-entry-hooks22` | 0.985 |
| `job-number-nat-refusal23` | 6.399 |

These include source/harness failures and real semantic findings. Examples include the missing shared recursion-budget declaration in the first 10 isolation, the public matcher-prefix bug in13, a required constructor annotation in17, and the six reproduced host-hook differences in22. The nullary fixture's first acquisition needed a Nat annotation. The separate large-Nat rejection probes returned nonzero because strict diagnostic text differed; expected rejection is not relabeled successful exact conformance.

Nonzero-exit time is not the cost of every rejected idea. Successful builds, acquisitions, profiles and timings for proposals subsequently rejected stay in their normal categories. Prepared but unexecuted fixtures have no target execution time. The intentionally stopped 17b batch and unmetered publication failures are separate from the 14-job failure sum.

Nine agent slots were available, including root. Independent IR, lowering, representation, review, control-fixture, capability, documentation and publication tasks overlapped root-owned heavy execution. No per-agent active-time, token-cost or reasoning ledger exists, so none is estimated and nine slots are not presented as nine continuously busy agents.

After removing nested mechanism children, the only ledger interval overlaps are the previously recorded source/artifact derivations with acquisition: 0.150s and 0.370s. No ledger target-job intervals overlap. **Root also documented CPU0 publisher work overlapping candidate24's first focused timing screen.** No reliable absolute interval/duration receipt establishes that overlap's length. That screen is retained as exploratory; a later clean repeat supplies the candidate24 comparison. Different CPU affinity does not make overlapping publication work a controlled benchmark. The overlap is disclosed without inventing elapsed time or pooling the exploratory run into selected23 metrics.

## Resources, evidence and lessons

Policy was CPU 3 for target jobs, Node 24.18.0, 1024MiB Node heap, 2048MiB process-tree RSS cap and 2048MiB available-memory floor. The largest observed supervised peak remains **1,449,525,248 bytes (1,382.375MiB; 1.45GB)** at `run-checked-worker13b/run.json`. Resource receipts from 294 raw files were inspected without adding their nested durations. Tree RSS can double-count shared pages and is not exact private heap. No recorded failure in this campaign was attributed to the RSS limit.

The frozen data-only producer is `selfhost/build/phase45/accounting-final01.py`, SHA-256 `6fbdaa0be9a53e5243be61eeae2ca1ea026b4224329b8d3afb16642df06b3eeb`. It was preserved before being run on CPU0 and executes no compiler or generated programs. The final data receipt is `selfhost/build/phase45/accounting-final01.json`, SHA-256 `6bc2119e857f65141d24e78185c24a51dd38a9e79d96d9d3659ebe73831ede31`. It binds the full 314-row ledger, 294 resource input identities, excluded nested jobs, additional duration receipts, failures and overlap scope. The ledger is 430,846 bytes, SHA-256 `422e75da832431401b0c8e09bf2d51a8bf4baaaa8a368483324938b777d74e3c`.

The earlier `accounting-provisional01.json` remains unchanged and describes its earlier cutoff only. Raw paths are preserved evidence, not links to ignored GitHub files. Final archival/index/commit work follows this target-work cutoff and receives no guessed duration here.

The largest measured opportunities for a shorter future campaign are reducing repeated acquisition/build work through exact artifact reuse, running every fast canary before feature-focused screens, and reserving full semantic/representative qualification for a concrete survivor. The generic-row regression demonstrates why a broad cheap falsifier saves time. Parallel agents shorten independent implementation/review; they do not divide the serial final validation path by their count.
