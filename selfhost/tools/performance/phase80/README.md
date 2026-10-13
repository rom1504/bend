# Phase80 bounded representation experiments

[Results and selection](../../../../implementation/phase80/README.md).
Production remains Phase78. Five candidate patches and frozen checked builds
are preserved; none is installed. Restore a patch in an isolated checkout.

Build with `development.json` using the checked development workflow through
Phase46 `job.py`, with a fresh directory and the pinned Node24 executable.

```sh
python3 selfhost/tools/performance/phase80/prepare-screen.py selfhost/build/phase80/NEW-compiler/attempt.json selfhost/build/phase80/NEW-screen --rounds 5
python3 selfhost/tools/performance/phase80/run.py --plan selfhost/build/phase80/NEW-screen/plan.json --group prepare
python3 selfhost/tools/performance/phase80/run.py --plan selfhost/build/phase80/NEW-screen/plan.json --group clean
```

Independent roles use Phase78 B1, candidate B1 and pinned TypeScript. Two default
rounds give18 requests; five give45. `prepare-heldout.py` takes the same arguments
for small/functions65. Missing ready Base, changed inputs or complete-C mismatch
stop the guarded runner. Backend products/process reuse are off. Output paths
must be new. The C oracles were independently executed in Phase78.

`prepare-profiles.py` creates Numeric baseline/candidate diagnostic CPU profiles;
run prepare/profile groups. `prepare-counts.py PARENT_PLAN NEW_OUT` and its `-v2`
successor observe exact-argument repetition in **the parent's baseline**. Run
prepare/clean groups. Original functions always execute; no result is cached.
V2 also counts first-argument identities and queries with no active call to the
same function. Those counts do not authorize omitting other cache dependencies.

`occurrence-controls.mjs ATTEMPT NEW_OUT` checks list summaries; its `-v2`
successor checks integer-set summaries. Run through Phase46 `job.py`. Appended
accessors call the frozen compiled Bend functions over1,206 generated trees and
15,678 binder queries. Diagnostic derivatives are not release images.

`summarize.py` creates report JSON. `seal.py` archives raw artifacts/methods
after writers close; `restore-evidence.py` restores into a **new** directory.
Historical baselines/upstream/toolchains remain separate dependencies.
[Verified evidence](evidence01/README.md).

One CPU3 target tree,2GiB RSS/4GiB available floor,Node1GiB heap/4MiB stack.
No subagents. Preparation, request time, supervision and program execution
remain separate. These methods do not install a compiler.
