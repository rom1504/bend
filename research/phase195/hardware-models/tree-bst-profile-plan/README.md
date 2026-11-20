# Prepared current N1 tree/BST capture — not executed

The existing maintained profiler can acquire these two cases without a new
harness, build, runtime relink or independence waiver. Metadata preparation and
`run.py --check-only` passed:6 workloads,832 checked inputs, no targets run.
Execution waits for root's explicit GO after native qualification/cost screens.

Use **`captureCommand` in [execution.json](execution.json)**, which has a60s
whole-job cap and64MiB disk budget. The generic planner's174s command in
`plan.json` is retained provenance, not the selected execution budget. Do not
nest guards. The active reusable plan is also under
`selfhost/build/phase195/profile-tree-bst-plan01`; capture/guard roots are the
fresh `profile-tree-bst01` and `profile-tree-bst01-guard`.

| Case | Ordinary arguments | Independent result | N1 / C / QBE repetitions |
| --- | --- | --- | --- |
| tree-bitonic | `8 0` | `971629740\n` | 5730 / 18010 / 7573 |
| coverage-bst-64 | `64 17` | `861157620\n` | 106557 / 405660 / 161751 |

All roles preserve four warmups, CPU3/one worker/GPU off and the ordinary runtime
argument convention. The output contract checks the independent complete result,
exact warmup/repetition lines and one elapsed-integer line, with empty stderr.
N1 products match the independent-oracle-passing `native45-01` acquisition;
the C/QBE products exactly match retained Phase194 references. ELF/object/source/
oracle/build-receipt hashes and calibration observations were rechecked.

Each case-role gets one clean3.0s process and two sampled3.0s processes at8/13ms:
18 processes,54.002s estimated target CPU, approximately606 pooled samples per
role. The earlier equivalent18-process batch took59.659s guard wall for57.61s
estimated target CPU; the proposed60s cap therefore has a plausible margin.
This is an estimate, not a guaranteed completion. Per-process timeout is8s;
the outer deadline wins. Retain partial captures if the deadline trips and do
not automatically retry or lower quality gates.

Keep existing admission rules: complete unchanged checked outputs, at least500
pooled samples, both periods, adequate thread/process CPU coverage, zero loss or
overruns; report unknown weighted shares and rejected captures. Individual
captures remain below500 and must retain their individual flags. Unequal role
counts prevent direct total-process CPU comparisons. The existing offline
normalizer divides clean CPU and admitted physical-leaf estimates by each exact
role denominator. `offlineCommands` and successful close argv are frozen in the
execution receipt; classify a failed capture as failed instead.

Primary questions: tree resume versus take/ctor cost on current products; BST
down/step construction versus up rebuilding versus inorder continuation. Join
sampled PCs to the authenticated narrow disassemblies from the
[offline investigation](../tree-bst-followup.md). This capture gives physical
attribution only: no dynamic helper invocation counts, raw/RFC/unique/shared
path frequencies, hardware stalls or causal speedup are claimed. If categories
remain ambiguous, state the additional ownership observation needed before an A/B.

The plan uses the authenticated existing all-created-thread sampler from
Phase159,2GiB RSS cap,16GiB available-memory floor and5GiB disk reserve. No perf
permissions or host settings change. Ordinary outputs and input pins come from
the completed `broad-runtime02` calibration, not from sampled runs.
