# Reproducing Phase162

Read the [report](../../implementation/phase162/README.md), input identities in
the receipts, and [boundary audits](bendc-frontend-boundaries.md) first.
The prerequisite evidence capsules preserve Phase152/156/157–161 sources,
images, runtime policy and independent output oracles. The system Clang remains
an external pinned toolchain prerequisite. Do not substitute current upstream.

1. Restore absent evidence paths using the capsule index and hash checks. Never
   overwrite frozen files. Keep the qualified compiler and production selection.
2. Each `selfhost/build/phase162/*-guard/process.json` records the complete guarded
   command, CPU/RSS/time/disk budgets and method hashes. Replay to **fresh** roots,
   changing output paths coherently. No nested guard; one resource-intensive lane.
3. `tools/frontend.py` supplies the clean observations. Its original type-error
   classification is intentionally preserved as failed evidence. Use the exact
   diagnostic in `implementation/phase162/control-admission.json` when evaluating
   that control, rather than its overbroad prefix rule.
4. `tools/instrument-v2.py prepare` adds exact-bound additive counters to private
   copies. `tools/build-diag.py` builds a separate fresh image under the guard.
   Version1's wrong-thread dump is rejected and must not supply measurements.
5. `tools/observe.py` compares complete diagnostics or streams complete QBE
   byte-for-byte against the immutable oracle. The Map pilot uses2GiB RSS;
   full C requests explicitly use6GiB because prior measured demand was4GiB.
   Both full requests have a4MiB artifact budget and the ordinary5GiB reserve.
6. `tools/analyze.py` admits marker multiplicity/order, parser/checker success,
   negative-control failure, output identity and ablation internal controls.
   It summarizes operation counts; it is not a clean performance benchmark.
7. Close each job, then seal/reopen/hash-verify the capsule. No pruning is needed
   for this campaign. Counter images are research artifacts, not qualified builds.

The worker-return dump is explicit in the v2 tool and private header. Its addition
is not separately enumerated in the old-shaped `runtimeEdits` array, so use the
whole method/header pins when auditing instrumentation. Source-only hook proposals
are not themselves executable evidence; the actual generated preparations are.
