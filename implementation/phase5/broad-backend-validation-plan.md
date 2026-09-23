# Prospective final JS/native validation

**Prepared scope only; no broad backend execution result is claimed here.** The final checked API is bound by a genuine attempt and its bootstrap/source/runtime identities. Every comparison uses a fresh pinned TypeScript run on the same fixtures; Phase2 execution counts are scheduling history, not current passes or a substitute baseline.

The pinned inventory contains 1,378 fixtures. Its existing `probes()` policy yields **999 JavaScript and 982 native eligible observations per compiler**, or 1,981 each and 3,962 paired observations in total. Eligibility requires a main entry point and that backend in the fixture policy. The **379 JS and 396 native ineligible fixture/lane entries** are listed separately with reasons; they are not executed observations or counted as passes. These per-lane exclusions must not be summed as distinct excluded fixtures.

An eligible positive program can still receive the existing `not-applicable` verdict when its validated main type cannot be printed. That is an actual compile observation, distinct from inventory ineligibility. A negative fixture rejected during parsing may pass its exact rejection oracle, but does not establish type/proof checking or backend execution. Final reporting will separate actual runtime observations, frontend/check/compile rejections, not-applicable cases and failures.

## Planned execution

After the exclusive proof and public-H/derived frontend gates finish, root grants the slot. The existing paired `target.mjs` runs reference then candidate with four isolated workers sharing cores0–3, 4 GiB V8 heaps, 4 MiB stacks and a120-second per-probe deadline. `retain: all` preserves successful C/JS programs and native binaries as well as failed repros. Both compilers see the same selected fixture bytes, runtime/Base policy and local Clang environment. The driver/harness remain frozen; no compiler source or oracle is changed.

The child phase has a2,695-second supervised budget, below45minutes. The outer launcher uses2,760seconds to allow process-tree shutdown and metadata flush. Any incomplete run remains incomplete: partial JSONL records and artifacts survive, and no skipped pending probe is assigned a verdict. No speed claim follows this correctness schedule. System Node/Clang libraries and headers remain recorded external prerequisites, not a hermetic toolchain.

Disk capacity was29GiB during the earlier metadata check. The18native programs in the selected gate used1.50MB of C and0.58MB of executables; this is only a sizing observation. Recheck available space before broad launch; retain all evidence rather than deleting user files to make room.

## Result interpretation and failure paths

* `complete` means both1981-row schedules and the paired comparison finished with unchanged input/artifact/adapter identities. It does not mean all fixtures passed.
* `selectedComplete` is the existing stricter paired selection verdict: both fixture oracles pass and paired semantic observations agree. Known strict failures remain failures even when both compilers produce the same result.
* `exactDifferences` compares status, phase, checked flag, exit, diagnostic and output fields. `semanticDifferences` excludes diagnostic text but retains acceptance/phase/checked/exit and runtime output. Neither count replaces exact fixture verdicts.
* Infrastructure counts are explicit per compiler: crash, timeout, unsupported and hardware-gated. Raw `status:error` is classified by phase and strict fixture verdict; expected semantic rejection is not automatically an infrastructure failure. `infrastructureHealthy` is separate from completion and strict conformance.
* A target child exit1 can be an ordinary strict-conformance failure and is retained. Signal, parent deadline, capture overflow, failed launch, missing final report or unfinished paired comparison makes full coverage incomplete. Existing process supervision kills remembered descendants, including detached probe groups.

## Reviewed pre-launch amendment

Snapshot01 retained the original three-worker tool. Snapshot02 records only the approved resource change to four workers/cores0–3. Both snapshots and exact tool copies remain historical and unexecuted.

A subsequent static review found three reporting counterexamples in the broad wrapper: adapter drift was omitted from its completion guard; exit1 after both raw reports but before the paired comparison could claim completion; and a truncated final JSONL fragment could be counted as a finished observation. Root authorized narrow fixes. The current tool now checks the adapter flag and complete paired row/missing/error fields, and counts only valid JSON observation records while preserving invalid-line/trailing-fragment facts. Pure tests cover those cases and distinguish expected rejection from infrastructure failure. After the exclusive proof finished, the actual file-backed Node runner passed all **three pure test groups** (3tests,0failures), and metadata preparation produced fresh `broad-snapshot-03`. Both processes exited0 and all jobs closed at **2026-09-23 02:11:56.783 UTC**. Tool SHA is `a5119f751a43071aa537299fdf01773b04cf3decd66e7c3ff75d130393e20441`; snapshot SHA is `5ee8f714b88e69c7512823efdab467343cab328b3f1f691f3f3f31c8d80ceb15`. Logs and `broad-prelaunch-03.json` are under `selfhost/build/phase5/final-backends`. No compiler was executed, and snapshots01/02 remain unchanged. Broad execution is still held until the public-H and derived frontend gates finish. No compiler or source change is part of this amendment.

After tests pass and root grants execution, prepare a fresh snapshot and use the recorded Clang environment from the selected backend report:

```sh
# From selfhost/; preparation is metadata verification, not a bootstrap.
node --test --test-isolation=none tools/performance/phase5/broad-backends.test.mjs
node --stack-size=4096 --max-old-space-size=4096 \
  tools/performance/phase5/broad-backends.mjs prepare \
  build/phase5/integration/attempt-05 NEW_SNAPSHOT

timeout --kill-after=5s 2760s taskset -c 0,1,2,3 \
  node --stack-size=4096 --max-old-space-size=4096 \
  tools/performance/phase5/broad-backends.mjs run NEW_SNAPSHOT NEW_OUTPUT \
  > NEW_OUTPUT.stdout 2> NEW_OUTPUT.stderr
```

Use a separately verified newer attempt explicitly if root changes the final API. Never attach the old checked proof to different bytes. The eventual archive/report must preserve all observed failures and list any unfinished requests separately; this plan alone is not validation evidence.
