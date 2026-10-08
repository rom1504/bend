# Saved native timing continuity

`saved-native.py` measures admitted existing binaries with the Phase67 runtime
protocol: the same Phase46 independent oracle and child runner, fixed plan,
warmups, role rotation, 45-second deadline, integer program clock and 100 ms
qualification threshold. Root alone executes `measure`, under the existing
single guard on CPU3 with 2 GiB tree RSS and a 4 GiB memory floor. It invokes no
Bend compiler, Node compiler image or Clang. Do not add an outer guard.

The original acquisition recipe, receipts, wrapper, emitted C, executable,
toolchain and method files stay immutable and verified. The only live-input
exception is `selfhost/src/compiler.json`: its original bytes must match the
frozen manifest in the selected checked attempt, whose actual API must exactly
match the acquisition recipe. Timing saved binaries does not read that live
compiler configuration. All other original recipe pins must still match.

```sh
python3 selfhost/tools/performance/phase68/benchmark/saved-native.py measure \
  --recipe selfhost/build/phase67/native-scalars01-recipe.json \
  --attempt selfhost/build/phase67/scalars-build01 \
  --acquired selfhost/build/phase67/native-scalars01 \
    selfhost/build/phase67/native-heldout-scalars01 \
  --plan selfhost/build/phase67/native-fast06-plan01.json \
  --out selfhost/build/phase68/saved-baseline01 --rounds 2
```

`--check-only` performs source/data admission without creating output or
executing a target; run this on CPU0. `--cases` defaults to all six families and
`--roles` to `selfhost`. Acquisition folders or their exact report paths are
accepted. Failed attempts retain their fresh output directory. A report's
`complete` means correctness; `allTimingQualified` is separate.

New compiler acquisitions still use the unchanged Phase67 freeze/acquire tools.
Their recipe must be frozen after the intended compiler-manifest change. Use
the same runtime plan for baseline and candidate. The data-only comparator
accepts original Phase67 timing receipts and new saved-native receipts, checks
their exact execution protocol, and retains the predecessor method identity.

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase68/benchmark/saved-native.py compare \
  --baseline-timing selfhost/build/phase68/native-baseline-fast01/report.json \
  --baseline-attempt selfhost/build/phase67/scalars-build01 \
  --candidate-timing selfhost/build/phase68/saved-candidate01/report.json \
  --candidate-attempt selfhost/build/phase68/checked-candidate01 \
  --allow-compiler-input selfhost/src/compiler.json \
  --out selfhost/build/phase68/saved-comparison01.json
```

The candidate paths above are placeholders for the actual selected attempt and
receipt. An explicitly registered manifest difference is recorded with both
original and frozen identities. No other shared method, toolchain, runtime,
wrapper or host-input difference is accepted. Selected API paths may differ;
each is bound to its own checked attempt. Every compared interval must be
correct and at least 100 ms. Ratios describe separate sequential campaigns,
not temporally interleaved samples. Clang clocks and C sizes come from the
original acquisitions and remain separate from saved-binary runtime timing.

`saved-native-v2.py compare` additionally admits the exact candidate-only
`selfhost/tools/performance/phase67/benchmark/fast-plan.py` input when explicitly
registered with `--allow-added-input` and that path. Its SHA-256 is
`a94c28533fffa7286425014b1486fded365e0bca1038098be7d96136e83e7082`
(2,919 bytes). The baseline recipe predates this pure data-only calibration
producer. It is outside the acquisition and runtime commands; their unchanged
controller pins and lack of an import/reference are recorded. Both campaigns
must still use the same frozen plan. No other added or removed input is admitted.
V2 accepts the pinned, consumed V1 timing receipts; V1 and failed comparison
attempts remain unchanged. The exact source transformation is recorded in
`saved-native-v2.derivation.json`.
