# Phase194 native qualification method

The active generator is `qualification-plan-v2.py`; it writes metadata only.
It takes an explicit final
`--source`, optional `--assets` and optional fresh job `--prefix`. If the source
does not yet exist, it emits a draft with `readyToStart:false`; regenerate after
freezing the source. Source presence alone does not establish source checking or
authorize candidate acceptance.

```sh
python3 -B selfhost/tests/phase194/qualification-plan-v2.py \
  --source selfhost/build/phase194/selected-source02/compiler.bend \
  --prefix fresh- \
  --out selfhost/build/phase194/qualification-plan-next.json
```

Choose unused prefix/output names for any new plan. The original generator and
frozen `qualification-plan02.json` preserve a compiler-screen argv error:
`--set all` is unsupported and `--guarded` is absent. The corrected generator
uses `--set full --rounds 2 --budget 60 --guarded`. `full` selects all four
requests in these compiler manifests. Without `--guarded`, the current bench
runner refuses execution; it does not supply its own outer guard. Preserve the
failed attempt and use separately recorded corrected argv with fresh job/output
names for both N1 and N2 screens. Do not replay those two old plan02 entries or
mutate their frozen evidence.

The root owns serial execution of each active step's exact `argv`. Authenticate
the selected-source and input pins before starting and before each later step;
check each producer report is complete, unchanged and successful before continuing.
Keep exact-source checking, finite controls and selected runtime evidence as
prerequisites. The older Phase192 runner can consume the basic plan shape, but
does not enforce every report/result requirement or the compiler-cost review;
do not use its zero exit alone as the acceptance gate.

The twelve-step sequence is:

1. Existing frozen Phase186 QBE seed builds N1, then N1 acquires all native45 products.
2. Prepare and run two balanced rounds of four N1 compiler requests; review cost.
3. N1 emits direct-object N2; N2 passes native64 and runtime10.
4. N2 emits N3 with N2's complete object as the required exact oracle.
5. N2 acquires all native45 products; compare all 45 objects and 135 linked sections with N1.
6. Prepare and run the same two-round four-request N2 compiler-cost screen; review net cost.

Native target commands come from the successful Phase193 budget guard receipts.
Only output destinations, assets and the explicit selected source are substituted.
The maintained native builder, Phase190 native45 acquisition/product comparison,
native64 qualifier, Phase183 runtime controls and bench runner own their existing
checks. No validator, benchmark definition or target compiler is copied or edited.

`compiler-cost-plan.py` calls Phase193's `prepare_role()` with explicit compiler
source identities for both roles. This avoids that historical CLI's hardcoded
Phase192 baseline. The actual baseline is qualified Phase193 budget N1/N2.
Both roles compile identical request source with identical Base/carrier/stamp and
runtime. Each must emit its own frozen complete object. N1 retains the common
QBE producer/toolchain comparison; N2 measures the net changed compiler source
and generated x86 implementation. Linking and generated-program execution are
outside these request timings. Two rounds are a guardrail, not significance or
a controlled cold-build/research-throughput result. No automatic performance
cutoff is invented; preserve every request, spread and regression for review.

Every execution step uses existing Phase194 `job.py`: CPU3, one outer disk guard,
explicit disk/RSS/file ceilings, 16GiB available-memory floor, the unchanged
5GiB disk reserve and retention closure. Image jobs retain the established 3GiB
RSS ceiling; ordinary jobs use 2GiB. Never nest guards or prune active products.
The prior comparable guarded work took about 19.9 minutes; new setup, analysis,
source growth and variability can extend that. Individual ceilings intentionally
sum to more than 20 minutes. Stop between jobs if remaining time or admission is
insufficient; never reduce coverage or correctness checks to meet the estimate.

Qualification does not install or promote the compiler. N3 is an object fixed
point, and native45 comparison transfers exact machine products for those inputs;
neither establishes a general compiler theorem or recursive research acceleration.
