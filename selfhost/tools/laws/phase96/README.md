# Replaying and auditing the Phase96 laws

Use the [run guide](../../../../docs/self_hosted/COMPILER_LAWS.md) and
[result report](../../../../implementation/phase96/README.md).

```sh
python3 -B selfhost/tools/laws/phase96/run.py \
  --out selfhost/build/phase96/my-check --tier fast
python3 -B selfhost/tools/laws/phase96/run.py \
  --out selfhost/build/phase96/my-audit --tier audit
```

Measured fresh runs take15.48s and90.72s respectively. Every destination must be
new. The runner refuses changed prerequisites instead of bootstrapping or falling
back; see the guide for the existing authenticated toolchain/image dependencies.
It keeps targets serial and applies the established Phase86 resource guard.

| File | Responsibility |
| --- | --- |
| `run.py` | Prepare current source, run complete positives, optionally all negatives and native witnesses, retain aggregate status and timing. |
| `check.py` | Snapshot source closure, check/elaborate, require nonopaque law bodies, invoke unchanged BendTT and reject an independent false equality. |
| `proof-negatives.py` | Admit semantic helper mutants standalone, then require frozen laws to reject them for the intended semantic reason. False-statement controls are classified separately. |
| `production.py` | Guard the frozen B2 contract worker; require complete full-value agreement, semantic mutation mismatches, or exact generated-C stdout. |
| `collect.py` | Verify accepted receipts, all ten executable counterexamples, serial target accounting and the complete raw archive readback. No targets. |

The production worker, oracle and source extraction live under
[`selfhost/proofs/phase96/production`](../../../proofs/phase96/production/README.md).
Representation preparation extracts exact maintained helper bodies and removes
only the leading unsafe annotation. This produces a temporary `production.bend`
beside the tracked law source; do not attempt to check that tracked law file
without preparing its dependency first. The integrated runner does this.

## Retained evidence

[`evidence01/summary.json`](evidence01/summary.json) records the authoritative
integrated `audit01` and `fast01` results. The
[execution ledger](evidence01/execution-ledger.json) covers every retained target,
including earlier failures. The [archive inventory](evidence01/archive-members.json)
gives a SHA256 and byte count for every member of
[`raw-evidence.zip`](evidence01/raw-evidence.zip). The collector read and verified
all1,752 members; the compressed file SHA256 is in the summary.

The ZIP uses repository-relative member paths, including
`selfhost/build/phase96/`. Restore into a separate empty checkout/staging directory
and verify each member against the inventory before relying on it. Do not
overwrite an existing attempt directory. This restores sources, expected values,
products and receipts, not the external Lean/Bun/Clang/B2 installations. Reports
retain their original absolute paths and tool identities for audit; a replay at
a different root requires restoring the dependencies and regenerating a fresh
run, not editing an old receipt.

`attempts/check-v1.py` is the preserved initial result-flag/inventory method.
Other frozen versions are inside the corresponding raw attempt snapshots.
The current `collect.py` intentionally names this campaign's accepted attempts;
use a new collection directory and explicitly select a later campaign when
extending it. The runner itself always tests fresh current-source extractions.

Universal laws, finite cases, helper admissions, frontend mutation rejections
and kernel rejection controls are different counts and trust claims. A passed
negative test means the intended bad behavior was detected, not another theorem
was proved. None of these receipts measures compiler or generated-program speed.
