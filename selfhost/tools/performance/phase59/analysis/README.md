# Exact-ancestor attribution replay

`profile-stage-attribution.py` preserves the actual recorded inline analysis;
only an explicit fresh-output argument and its check were added. It reads saved
profiles and hashes inputs; it imports no compiler, executes no target and writes
no historical raw file. Run from repository root, with a fresh destination:

```sh
taskset -c 0 python3 -B \
  selfhost/tools/performance/phase59/analysis/profile-stage-attribution.py \
  /tmp/phase59-attribution-replay-NEW.json
```

It requires the original Phase59 first-cpu01, first-allocation01 and separate
first-cpu-evening-ts02 captures, their original worker/API/driver files, and the
pinned TS source paths. Missing/changed inputs refuse. The partition assigns each
raw sample count/allocated size once to its nearest exact ancestor; unknowns remain.

Producer SHA256: `47db456730d429767fd39018db08b8baa846f3b34ee48aa00a89b731bffb5d91`.
The executed CPU0 replay to `/tmp/phase59-profile-stage-attribution-replay01.json`
was byte-identical to [the original evidence](../evidence/profile-stage-attribution-v1.json):
SHA256 `55e71c37afc2afac5817983873a4aca84e8bde1a0b3c5f4f701531dbacc30454`.
The evidence's original bytes were retained; this reproducibility check did not
add or relabel a target observation. [Scope and results](../../../../../implementation/phase59/profile-stage-attribution.md)
remain complementary to stage wall clocks and whole-profile attribution.
