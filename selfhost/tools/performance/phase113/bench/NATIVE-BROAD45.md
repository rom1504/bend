# N2 batch runtime qualification

The N2 conformance suite compiles Phase88 one-shot wrappers. The frozen runtime
benchmark compiles Phase93 batch wrappers, which accept repetition/warmup
arguments and report timed success counts. **Zero of 45 source pins match**;
all 45 workload-output oracles match. Reusing the conformance binaries would
change the workload and clock. The original binder correctly refuses them.

Native producer receipts already work with the unchanged Phase112 batch binder.
No kind relabeling, fabricated hosted receipt or relaxed source check is needed.
Use the selected N2 to acquire the batch wrappers after native qualification:

```sh
python3 -B selfhost/tools/performance/phase113/bench/prepare-native-batch45.py prepare \
  --qualification-plan selfhost/build/phase113/native-finalNN-plan.json \
  --tag p113-finalNN-native-batch45 \
  --out selfhost/build/phase113/native-finalNN-batch45-plan.json
```

This preparation runs no target and can precede N2 availability. The first
execution job requires completed exact-source hosted/native QBE reproduction,
the same N2 binary/runtime in focused19 and conformance45 receipts, and passing
semantics. Execute the printed `rootGuardCommand` as described in
`NATIVE-FINAL.md`. It uses CPU3, 4 GiB RSS, 128 MiB files and a 720-second ceiling.

The remaining jobs call the existing methods without changes:

1. `phase112/benchmark45/acquire-native.py --image N2 --runtime RUNTIME
   --producer-receipt EXACT_QBE_RECEIPT --prefix FRESH_PHASE111_PREFIX
   --out FRESH_PHASE112_ACQUISITION --seconds 30 --build-seconds 30
   --budget-seconds 300`.
2. `phase112/benchmark45/run.py bind --label NEW_LABEL
   --reports ACQUISITION/products-map.json --out FRESH_BINDING.json`.
3. `phase112/benchmark45/run.py measure --bindings BINDING.json
   --profile phase112/benchmark45/upstream-50ms-profile01.json --rounds 3
   --seconds 30 --budget-seconds 300 --out FRESH_PHASE112_TIMING`.

The actual generated commands contain separate option/value arguments. Native
acquisition preserves the exact image, image build receipt, full-source
reproduction receipt, unchanged sources/assets/runtime and individual build
receipts. Binding checks the original QBE/as/link toolchain and flags. Timing
rechecks complete outputs/counts in three rotated rounds with the previously
frozen upstream-derived repetitions: 45 output points, 44 timing ratios, named
`scalar-region-0` correctness-only. Compilation and build time are excluded.
These old programs are reused regressions in Phase113, not fresh heldouts.
