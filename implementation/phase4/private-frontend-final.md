# Final private frontend audit

The opt-in private image `4318bbcd…` preserves **all 2,756 raw parse/check result objects and harness verdicts** from final checked B1 `0653f21e…`. Exact diagnostics, status, phase, checked flags, exit information and resolved input paths match. The fresh pinned TypeScript reference also exactly matches its earlier 2,756 observations. No changed result or verdict was found.

This covers 1,378 fixtures in two lanes, not full conformance: the candidate retains **377 strict failures**, and the reference retains three. Those failures are not all established diagnostic-only differences. The audit compares each underlying result plus `status`, `reason` and `evidence`, independently of aggregate counts.

## Independent checks

The [audit report](private-frontend-final-evidence/report.json) and [auditor](../../selfhost/tools/performance/phase4/private-frontend-audit.mjs) verify:

- Exact fixture inventories, imported/foreign input hashes and canonical paths, without changed inputs or artifacts.
- Four complete, duplicate-free 2,756-probe inventories, without timeout, crash, unsupported result or worker infrastructure failure.
- All 176 persistent sessions, 44 per run: closed histories, contiguous request indices, result digests and replay-prefix validation.
- Shared host, runtime, Base and harness hashes between historical and final runs.
- Private manifest/artifact bytes, profile name and association with completed public H `b33b38e3…`, initial B1 and source `34c6ef63…`.
- Both public proof stages exiting successfully with verified inputs and byte-identical H outputs; all captured inputs rehashed afterward.

The frozen execution reports deliberately contain process exit 1 because strict fixture verdicts fail. Complete observation inventories and clean worker results distinguish this from interruption. No compiler source, frozen harness or consumed private image was edited.

The private sweep process wall was 2,337.382 seconds; B1 ran separately under different shared-host conditions. These are workflow observations, not paired compiler timings, and no speed ratio is claimed here.

## Full-source evidence and packaging

The independent [four-observation sanity review](private-frontend-final-evidence/full-source-sanity-review.json) agrees with the root-owned [full-source audit](private-full-final-evidence/comparison.json): candidate/control pairs improve process wall by 3.91% and 0.75%; two-sample mean reduction is 2.28%, with mean maximum-child RSS 3.16% higher. Decoded validated Base books match across all four observations. These small shared-host samples support a modest opt-in benefit, not an 11.3% whole-compiler improvement inferred from the earlier core-only median.

The six staged packaging files were applied after these gates with exact pre/post hash checks. Default specialization stays selectable. Canonical rebuild, 25 package tests and seven guards await the reserved multicore timing window; results will be appended before integration is ready. The 59 Bend source modules remain unchanged.

## Reproduction and preservation

From the repository root, with the recorded Node version:

```sh
node selfhost/tools/performance/phase4/private-frontend-audit.mjs \
  selfhost/build/phase4/frontend-private-final \
  selfhost/build/phase4/frontend-combined NEW_ARCHIVE
```

This audits metadata and replay histories without rerunning compiler probes. It requires historical absolute inputs, refuses an existing output directory and retains a failure report if a later check fails. Content-addressed gzip objects preserve raw reports, histories and consumed tool bytes; the report maps original paths to hashes and identifies the preserved objects. Prerequisites verified without an object remain identified by hash. Final images are separately preserved in the [source](final-source-capsule/README.md) and [private image](private-final-images/README.md) capsules. No historical paths or proof records were rewritten.
