# Phase144 native profile preparation

Metadata only, no targets:

```sh
python3 -B selfhost/tools/performance/phase144/profile/prepare.py prepare \
  --out selfhost/build/phase144/FRESH_PROFILE
python3 -B selfhost/tools/performance/phase144/profile/stages-v02.py prepare \
  --profile selfhost/build/phase144/FRESH_PROFILE \
  --out selfhost/build/phase144/FRESH_STAGES
```

Each output has a frozen `jobs.json`; the coordinator executes its commands in
order. For stages, stop before the full run unless the small exact-QBE sampled
pilot and offline marker join pass. These tools reuse qualified143 N2's retained
object, not the old142 image. They preserve the unchanged142 request input and
output oracle. All builds/targets use the root-owned CPU3 lane with3GiB/16GiB
limits. Diagnostic clocks never replace clean compiler timings.

Prepared evidence: `phase144/profile01` completed; `stages01` preserves a valid
output but invalid universal-final-marker assumption; `stages02` records that
conditional final-verifier branch separately. See
[profile-plan.md](../../../../../research/phase144/profile-plan.md) for contracts,
limitations and the expected source paths.
