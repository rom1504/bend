# Phase81 unchanged-compiler survey

[Report](../../../../implementation/phase81/README.md),
[prospective design](../../../../design/phase81/compilation-parity-investigation.md).

One guarded CPU3 target tree,2GiB RSS ceiling,4GiB available-memory floor,
Node24.18.0 with1GiB heap/4MiB stack. No agents or concurrent target jobs.
`prepare.py` freezes unchanged Phase78 B1/B2 and upstream roles using the
Phase78 paired and held-out plans; new projects own new prepared-Base caches.
`worker.mjs`/`run.py` derive from Phase80, adding TS CPU profiles, optional
allocation sampling and a separately labelled no-report request contract.
Every request must match its previously qualified complete C artifact.

Executed from repository root, sequentially:

```sh
python3 selfhost/tools/performance/phase81/prepare.py
python3 selfhost/tools/performance/phase81/run.py --plan selfhost/build/phase81/survey01/plan.json --group prepare
python3 selfhost/tools/performance/phase81/run.py --plan selfhost/build/phase81/survey01/plan.json --group clean
python3 selfhost/tools/performance/phase81/run.py --plan selfhost/build/phase81/survey01/plan.json --group profile
python3 selfhost/tools/performance/phase81/prepare-regions.py
python3 selfhost/tools/performance/phase81/run.py --plan selfhost/build/phase81/regions01/plan.json --group prepare
python3 selfhost/tools/performance/phase81/run.py --plan selfhost/build/phase81/regions01/plan.json --group clean
python3 selfhost/tools/performance/phase81/summarize.py
```

Output directories must not already exist. For new measurements derive the method
with new paths; do not overwrite the recorded survey. The internal-region image
is an observation-only derivative, not a qualified B2 release. Its derivation
file lists renamed/wrapped functions and hashes; it never memoizes results.
Recursive wrapper counts and inclusive times must not be interpreted as distinct
analysis products or removable CPU cost. Heap sampling estimates total allocation,
including collected objects; it does not measure peak live data.

The [evidence capsule](evidence01/README.md) contains all new raw receipts,
profiles, generated C, diagnostic image and methods. Historical Phase78 baseline
plans/images/oracles, pinned upstream and Node/toolchains are external prerequisites,
identified by each frozen plan's hashes and preserved by their original phases.
Restore bytes without installing anything:

```sh
python3 selfhost/tools/performance/phase81/restore-evidence.py selfhost/tools/performance/phase81/evidence01 /tmp/phase81-restored
```

The destination must be new. All selected measurement jobs passed; no production
compiler or generated-program behavior changed. The report's recommendations
remain unimplemented estimates.
