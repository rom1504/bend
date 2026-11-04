# Phase159 reproduction and evidence map

[Result](../../implementation/phase159/README.md) ·
[Design](../../design/phase159/README.md) ·
[Final audit](final-audit.md).

Start commit53e237195351cc32013d5b39ea45c67ebd1412de. No production compiler
edit. Phase152 remains qualified; Phase156 publication integration is pending.

## Frozen inputs and scope

Historical self-emission uses exactly Phase158's bendc9c54842e seed, runtime,
2.0.32 Base/effects and expected checker report. The common compiler computation
uses exactly Phase157's compatible Bend source, captured book, independent
QBE oracle and upstream02/qbe02/gc03 executables; bendc there is56edcc65.
Do not substitute one revision's source/runtime/profile for the other.

`selfhost/build/phase159/prep01` contains the actual frozen recipes/manifests.
Each run also snapshots its manifest and methods. The exact
[capsule](../../implementation/phase159/evidence/capsule.json) restores all new
files at their repo-relative names, including pruned captures. Referenced prior
inputs are in the pinned Phase157/158 capsules; toolchain executables are hashed
external prerequisites. Verify archive/member hashes and restore only missing
identical artifacts. Never overwrite frozen existing products. Paths in the
receipts refer to the original repository root; relocation needs explicit path
mapping and fresh manifests, not silent editing of frozen receipts.

## Replay boundaries

All compiler/benchmark jobs require the maintained disk/process-tree guard with
fresh run/guard directories, explicit disk budget, CPU3,2GiB RSS,16GiB available
memory floor and default5GiB disk reserve. Do not nest guards. Original command
arrays and limits are in each `*-guard/process.json`; run reports bind inputs
and output expectations. BEND/loader environment cleanup is explicit in the
two profile wrappers. No shell is preloaded as if it were the target.

1. Build the maintained sampler with `build-sampler.py --all-threads` and the
   pinned C toolchain. `thread-sampler01/report.json` binds the exact collector.
2. Historical routes use `tools/profile.py` with `self-threads-manifest.json`.
   `self02` is a clean/4ms pilot; `self03` uses4/7ms on unchecked emission,
   checked emission and check-only. Expected checking exit1 is the previously
   established24-definition foreign/unsafe report, not a failure hidden as a
   proof pass. Every emission must equal the complete historical C seed.
3. Common routes use `tools/common-profile.py` with `common-manifest.json`.
   `common-control01/02` bracket ordinary output oracles; `common-time01`
   measures0/1/4/16 batches in two rotated rounds; `common-sample01` samples
   sixteen batches at4/7ms. CLI adapters intentionally account for differing
   `IO.args` argv0 conventions. See [comparison plan](comparison-plan.md).
4. `tools/stage-seed.py --allocations --out FRESH` prepares the private historical
   stage/count image without executing it. Build using `stage-build01/report.json`
   command/flags; `tools/stage-run.py --help` describes replay. Counts off/on must
   emit the full exact seed, return zero diagnostic errors, and agree on stage
   cardinalities. Diagnostic timing is not clean timing.
5. `tools/refill-prepare.py --help` prepares the one-line private current-runtime
   cap with inverse-patch equality. Build the **unchanged** Phase157 generated C
   using `refill-build01/report.json`. [P159-003](P159-003-refill.md) and the
   [source audit](refill-audit.md) explain legality boundaries and risks.
6. `refill-control01/02` contain before/after exact oracles and an initial
   four-batch screen. `refill-time01` has four balanced16-batch pairs.
   `refill-sample02` uses cap-only8/13/8/13ms captures. Pool these with the
   maintained comparator; no minimum-sample or coverage gate is relaxed.

After restoring raw evidence, `python3 -B experiments/phase159/tools/analyze.py`
recomputes metrics into a fresh `implementation/phase159/metrics.json` path.
Move an existing report aside explicitly before replay; the tool refuses
overwrite. It verifies binary/input/output/capture identities and uses the
maintained pooling rules separately for each workload/executable. It does not
pool the three backend implementations together. `refill-pooled-final.json`
also demonstrates the standard comparator after its argv0 identity fix.

## Evidence directories

| Path beneath `selfhost/build/phase159` | Meaning |
|---|---|
|`self01`|Rejected main-thread-only capture, preserved with original methods.|
|`self02`, `self03`|Historical clean/sample evidence and exact outputs.|
|`common-control*`, `common-time01`, `common-sample01`|Identical compiler-workload comparisons.|
|`stage-prepare01`, `stage-build01`, `stage-run01`|Historical diagnostic source, build and counted/uncounted receipts.|
|`refill-prepare01`, `refill-build01`|Exact private runtime patch and candidate ELF.|
|`refill-control*`, `refill-time01`|Output gates and causal clean timings.|
|`refill-sample01`|Rejected2/3ms overrunning captures; never quantitative evidence.|
|`refill-sample02`|Four individually short but jointly admissible8/13ms captures.|
|`analysis01`|Refill disassembly, ELF symbol/section census, rejected pilot and pooled comparison.|

The initial pooled comparison predates the explicit argv0 comparator check;
its exact method is preserved as `analysis01/compare-pre-argv0.py`. The final
comparison has the same sample data/results under the stronger identity check.
All Phase159 common variants explicitly use `compiler-work` argv0.

Seventeen guarded runs total472.859s, including123.227s for the two private
Clang builds. This excludes agent work, documentation, host-tool tests and
offline analysis/retention. All runs are closed; self01, self02, self03 and
stage-run01 were pruned only after exact verified archival. The final capsule
includes their original bytes directly at the original relative paths.
Post-seal pruning additionally retired stage-build01 and common-sample01 through
their verified plans; see the separate post-seal-pruning receipt in evidence.
