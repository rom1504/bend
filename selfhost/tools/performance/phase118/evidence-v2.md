# Separate native-source bridge for Phase118 evidence

`evidence-v2.py` imports the frozen v1 verifier, requiring its exact SHA256
`94031d4eb931e461a50ba711e33b10ea4e9c638e90bd559cbaedce4b4ae64437`.
It leaves every hosted broad405/control19 gate unchanged. The timing producer
continues to be the source/API recorded in `broad-emit01`, presently float01.
The original `evidence.py` and its successful replay remain unchanged.

Optional `--native-equivalence-report NEW_ALL45_EMISSION/report.json` requires
all 45 original fixture identities exactly once, a complete request-bound
checked emission from an authenticated new API/source composition, and the
identical linked runtime. Every new case must bind `exactDiagnosticMatch` to
the old broad-emission QBE pin, as recorded by `emit-integrated.mjs` with
`P118_EXPECT_EMISSION_REPORT` set to the old broad report. The verifier checks
both sizes/hashes and streams the actual QBE bytes for equality, without
normalization. A missing/mismatched case fails the bridge.

When a bridge is supplied, the native plan must match its **new** source/API
and runtime. Without a bridge it must match the original timed producer.
There is no implicit source substitution. The finite exact45 bridge does not
establish arbitrary compiler equivalence or qualify a native image by itself.
The hosted runtime measurements retain their original producer label; native
self-reproduction and suites retain separate receipts and counts.

```sh
python3 -B selfhost/tools/performance/phase118/evidence-v2.py \
  --out selfhost/build/phase118/evidence-final-v2-01 \
  --native-equivalence-report selfhost/build/phase118/NEW_ALL45_EMISSION/report.json \
  --native-plan selfhost/build/phase118/NEW_NATIVE_PLAN.json \
  --capsule
```

The capsule includes both complete compiler/API snapshots, both composition
recipes and module snapshots, the raw bridge receipt, original oracles and
observations, and historical rejected attempts. Large machine artifacts remain
external. Pending native campaigns still defer sealing. A finished outer guard
with nonzero return code is instead labeled `terminal-failed`: its evidence may
be archived, and absent successor stages are labeled not reached. A sealed
failure is never relabeled native qualification. The native inventory remains
receipt status only, as in v1; its separate qualification methods own the native
lineage and semantic checks. Root alone runs targets and chooses final sealing.
