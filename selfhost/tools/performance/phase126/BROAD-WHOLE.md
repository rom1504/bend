# One guarded broad45 campaign

This is an explicitly authorized resource-supervision variant for the original
45 batch programs. It retains all emission, admission, merge, aligned-build,
oracle, fixed-count, three-round and summary commands. It does not reuse the
native qualification's one-shot binaries: their source bytes differ in all 45
cases from the frozen batch programs.

First prepare a fresh original command list with `broad-plan.py prepare` and the
selected API report, source manifest and runtime report. Then derive the single
guard plan without executing targets:

```sh
python3 -B selfhost/tools/performance/phase126/broad-whole-plan.py prepare \
  --plan selfhost/build/phase126/FINAL-plan.json \
  --out selfhost/build/phase126/FINAL-whole-plan.json
python3 -B selfhost/tools/performance/phase126/broad-whole-plan.py verify \
  --plan selfhost/build/phase126/FINAL-whole-plan.json
```

The emitted `rootGuardCommand` is the exact command array for root to execute.
It runs the existing serial `phase113/run-jobs.py` supervisor with all six fresh
emitter processes, merger, exact ordered-45 check, screen and summarizer inside
one guard. Do not execute the derived inner jobs outside that guard. Failed jobs
stop the campaign; their receipts remain failures. Each emission retains its
300-second cap and the screen its 1,200-second cap; the outer ceiling is 3,330
seconds, including bounded host-only checks and slack.

`guard-small-files-derivation01.json` records the exact three textual changes
from the pinned Phase111 guard: description, default file cap and allowed file
cap. CPU3, 2 GiB process-tree RSS, 16 GiB available-memory floor, execution lock,
deadline supervision and cleanup are unchanged. The original startup-disk
formula is unchanged: more than 160 + 2 × 8 = 176 MiB must be free. The stricter
8 MiB individual-file limit is only for this batch campaign, never full native
image acquisition. The adapter authenticates the derivation and preserves every
inner command byte-for-byte after removing its resource-guard wrapper.

`selfhost/build/phase126/broad-storage-audit01.json` authenticates the prior
Phase125 receipts and records observed file sizes. Its QBE plus build-directory
total is 93.26 MiB; adding 64 MiB slack gives 157.26 MiB. Every prior SSA,
assembly, object, executable and oracle is below 8 MiB. These are historical
observations, not an aggregate bound on the new candidate. Reports, logs and
temporary files consume additional space, and the guard's file cap is not a
total-output quota. No deletion or disk reclamation is performed by these tools.

`broad-whole-planner-check01.json` is an offline transport check only. It is not a
selected candidate or an executed campaign. The source-mismatch audit remains
in `native-full45-reuse-audit01.json`.
