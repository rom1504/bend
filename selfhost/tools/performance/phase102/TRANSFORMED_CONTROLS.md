# Controls for a separate generated-C intervention

`check-transformed.py` reads a completed `check-emitted-v2.py` report and its
original complete manifest. It authenticates the actual Bend producer C,
emission receipt, compiler build and every prior full-output observation. The
new result is explicitly a **C intervention**, never a forged Bend emission or
a qualified compiler image.

The transform receives each complete saved producer C once. All products retain
its exact method/pattern inputs and returned admission/fallback metadata. Only
changed C is built with the same Clang/O3 command and reruns every corresponding
frozen payload, worker count, full stdout/stderr and expected exit status.
Unchanged C inherits the exact old binary and authenticated raw observations.
No baseline/upstream rebuild or oracle regeneration is needed. Existing TRMC
activation/refusal and baseline-identity obligations remain enforced.

```sh
python3 -B selfhost/tools/performance/phase102/check-transformed.py \
  --controls selfhost/build/phase102/depth-controls01/report.json \
  --transform selfhost/tools/performance/phase102/projection/prepare.py \
  --out selfhost/build/phase102/projection-controls01
```

Add `--prepare-only` with a fresh output folder to authenticate all evidence and
produce transformed C without running any target. Such a report has
`prepared=true`, `passed=false`; changed-program semantics remain untested.
The supplied full manifest includes shared/static/dynamic String values, U32
characters, Unicode, retained aliases, arrays, empty/prefix/equal/mismatch
observations, parallel workers and expected failures. Activation is reported
per product; an unchanged fallback is not an execution test of the new path.

The existing long-argument guard retains complete argv and bounds memory/time.
Nonzero expected exits are accepted only with the exact status, complete raw
captures and no guard interruption/resource stop. Failed jobs and partial
reports are retained; the runner stops on the first failure. Root owns all
target execution. The separate app catalog supplies performance screening;
these controls make no new timing or native-chain claim.
