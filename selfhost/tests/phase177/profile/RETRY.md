# Fresh stage specification after profile-medium01

The first capture passed its supplementary stdout and strict timing-line output
contract, but remains rejected for two independent reasons:

- `p175fp_ordinary` recorded zero dispatcher entries. All other eleven markers
  recorded exactly one entry in chronological order; clocks had no error.
- The 2000us timer delivered4239 samples with4239 overruns, about half the expected
  periods. Its physical distribution is not admitted for quantitative attribution.

The retained QBE explains the missing boundary. At `program.ssa:808990`, the
continuation calls the `p112w` wrapper for `$direct.p175fp_ordinary`; that wrapper
calls its private `p113d` implementation at line840, whose body begins at18238.
The public dispatcher entry still exists at809015 but this edge bypasses it.
The existence of a public segment therefore was insufficient admission evidence.

`prepare-v2.py` retains all eleven observed unique boundaries, removing only
ordinary and combining erasure/request with wrapping/clocks. It authenticates
and preserves the old failure, reuses the unchanged program object/runtime
recipe, and writes a new spec/runtime plan for a new executable and capture.
No old capture is reinterpreted as valid. No preparing-agent target runs occurred.

Fresh metadata:

```sh
python3 -B selfhost/tests/phase177/profile/prepare-v2.py \
  --out selfhost/build/phase177/profile-prep02 \
  --products selfhost/build/phase177/profile-products02
```

Root-owned build and fresh product manifest:

```sh
python3 -B selfhost/tests/phase177/job.py \
  --extra-root selfhost/build/phase177/profile-products02 \
  profile-build02 60 64 \
  python3 -B selfhost/tests/phase177/profile/prepare.py build \
  --plan selfhost/build/phase177/profile-prep02/build-plan.json \
  --out selfhost/build/phase177/profile-build02

python3 -B selfhost/tests/phase177/profile/prepare.py manifests \
  --prep selfhost/build/phase177/profile-prep02 \
  --build-report selfhost/build/phase177/profile-build02/report.json \
  --out selfhost/build/phase177/profile-manifests02
```

Fresh 8000us capture using the existing default period, then offline observation:

```sh
python3 -B selfhost/tests/phase177/job.py profile-medium02 75 32 \
  python3 -B selfhost/tests/phase177/profile/adapter.py capture \
  --manifest selfhost/build/phase177/profile-manifests02/medium-manifest.json \
  --modes sample --periods-us 8000 --rounds 1 \
  --out selfhost/build/phase177/profile-medium02

python3 -B selfhost/tests/phase177/profile/adapter.py observe \
  --spec selfhost/build/phase177/profile-prep02/spec.json \
  --run selfhost/build/phase177/profile-medium02/report.json --row 0 \
  --out selfhost/build/phase177/profile-medium02/stages.json
```

All stage-order, marker-count, loss and delivery checks remain mandatory.
Intervals below500 samples remain descriptive; diagnostic stage clocks can still
identify complete work boundaries. Active-owner unknown remains in denominators.
No clean-time comparison, inclusive attribution, removable-cost ceiling or
whole-frontend optimization claim follows from this diagnostic retry.
