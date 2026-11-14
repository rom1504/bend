# Optional final compiler-request profile

`selfhost/build/phase193/budget-compiler-profile-plan01` freezes one request from
the validated `budget-compiler-cost-n2-plan01` manifest. Preparation and the
maintained profiler's `--check-only` passed (one workload, 64 global inputs,
no target execution). `selfhost/tests/phase193/budget-compiler-profile-plan.py`
authenticates the acquisition, image, source, object and independent runtime
oracle receipts again before freezing the profiler recipe.

The roles are exactly `baseline` (Phase192 `native-self01/program`) and
`candidate` (Phase193 `budget-native-self01/program`). Both compile the same
7,234-byte `test-map-set-ops.bend` input, SHA-256
`e93dc56e4c91670bb831c329e9ced90a0e17126bc02f4d7709131a516f0eb0ca`.
The complete argument tails, Base, cache carrier/stamp and compiler linked
runtime are identical. Commands are copied unchanged from the cost manifest;
there is no argv0 substitution.

Compiler sources differ: baseline is Phase192 selected-source01; candidate is
Phase193 selected-source02, SHA-256
`fd95adc1bdc210bc3827c9dd3536b8e7289fb60c4e983f0e008714665239428a`.
Each role must emit its own exact, previously independently runtime-validated
object and empty stderr:

| Role | Object bytes | SHA-256 |
| --- | ---: | --- |
| baseline | 587720 | `8f72c7a3e386b4e1f2e21437e23e1858294b36c25a1a3825d2e5e7ea675c8e98` |
| candidate | 598440 | `d4082ea4a8ee36d88f31c4dc5137e79db568b9d5e6e4702c7445da1dfed6be59` |

The existing all-thread sampler and all snapshot receipts are pinned. Two
clean rounds plus four sampled captures per role (8, 13, 8, 13 ms) yield twelve
processes with rotating role order. Historical acquisition durations imply
64.21 seconds of target time; this is a planning estimate. Each request has a
12-second timeout; the existing job wrapper limits the campaign to 150 seconds,
128 MiB disk growth, 2 GiB RSS, a 64 MiB file limit and CPU 3. Root may schedule
the optional job after qualification and current lane/disk admission:

```sh
python3 -B selfhost/tests/phase193/job.py --file-mib 64 budget-compiler-profile01 150 128 python3 -B selfhost/tools/profiler/run.py --manifest selfhost/build/phase193/budget-compiler-profile-plan01/manifest.json --out selfhost/build/phase193/budget-compiler-profile01 --modes clean,sample --rounds 2 --periods-us 8000,13000,8000,13000
```

`plan.json` also records exact offline comparison/render commands. Use reference
`baseline` and the maintained default quality gates, including 500 pooled
samples, multiple periods, coverage and loss checks. Only clean samples estimate
request cost. Sampling diagnoses physical CPU owners; normalize shares by clean
CPU time before interpreting changes. A changed leaf share alone does not
establish changed dynamic call counts or instruction cost.

This is a same-input comparison across different compiler sources and generated
implementations. It cannot isolate compiler-source changes from generated-code
effects, establish bootstrap qualification, measure full compiler self-build,
or establish research acceleration. No profile result exists at preparation.
