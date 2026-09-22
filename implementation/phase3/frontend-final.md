The final phase 3 compiler introduced **no observable frontend regressions** across all 1,378 pinned upstream fixtures. Its 2,756 parse/check observations—including exact diagnostics—match the final phase 2 report. A new live TypeScript run over the identical probes also matches the historical pinned reference. No mismatch was added or resolved.

All **1,378 final check accept/reject statuses agree with live TypeScript**: both accept 921 fixtures and reject 457. Exact compatibility remains incomplete. There are 560 existing cross-compiler observation differences: 20 parse-stage acceptance differences, 30 rejection-phase differences, and 510 diagnostic/report differences. They span 185 parse probes and 375 check probes. The fixture judge records 377 candidate check failures versus three TypeScript check failures; some fixture expectations concern later execution, so check-only acceptance cannot establish full fixture behavior.

| Current run | Parse observations | Check passes | Check failures | Workflow elapsed |
| --- | --- | --- | --- | --- |
| Bend compiler B1 | 919 pass, 459 observed | 1,001 | 377 | 1,228.644 s (20m 28.6s) |
| Pinned TypeScript | 919 pass, 459 observed | 1,375 | 3 | 237.196 s (3m 57.2s) |

These are single workflow observations, **not a repeated paired performance benchmark**. The candidate ran first, followed serially by TypeScript, on CPU 2. Both used the same frozen harness, a persistent worker, one job, 4 MiB stack, 4 GiB heap/RSS limit, and recycling every 64 requests. The per-probe deadline remained the established phase 2 value of 300 seconds. The candidate used a previously generated, validated Base cache; TypeScript constructed a fresh book per request while retaining its loaded compiler modules. Neither cache preparation nor candidate rebuild time is included. No cold-start or self-emitted-H performance claim follows from this run.

Both runs completed 44 worker sessions and 43 recycles with no worker failures, crashes or timeouts. Maximum observed RSS was 787,996,672 bytes for the candidate and 478,343,168 bytes for TypeScript. All consumed input and artifact hashes remained unchanged. The source/API identities were explicitly verified from the real checked integration report before launch; no bootstrap metadata was fabricated.

The candidate identities are API `8787894920cc8959ab0abec28ddae0ea0dc05ad7665dc6f4d43f845445e60923`, assembled source `936266643e95973709bac4b567289c5792decadbb3297f90018ed5052582d772`, runtime `26f5eee2f54b194b64f768df6ff505c67bf7a5df2159aa06caf53ecba54e910b`, and frozen host directory `2b692463e833d36a96edba2adf3ceb53b7f1432dbcb42803ddebb779d7df1749`. Upstream remained clean at `6018e28ecc67cf1fffc0c20c64b11023474c2df8`, with its canonical Base path shared by both runs.

[The summary](evidence/frontend-final-summary.json) records resources, identities, worker statistics, all mismatch IDs and archive hashes. Full exact [candidate observations](evidence/frontend-final-candidate.json.gz), [live TypeScript observations](evidence/frontend-final-upstream.json.gz), and [four-way comparison](evidence/frontend-final-comparison.json.gz) are gzip-compressed JSON; decompression preserves each original report byte-for-byte. [Launch provenance](evidence/frontend-final-launch.json), [execution records](evidence/frontend-final-execution.json), and [cache observation](evidence/frontend-final-cache-observation.json) retain the workflow details. The adjacent runner and comparison source snapshots document the exact orchestration.

To reproduce, select the proven API/runtime and canonical pinned Base with `BEND_TYPED_API`, `BEND_TYPED_RUNTIME`, `BEND_BASE`, and `BEND_UPSTREAM`, then invoke the frozen `tools/conformance/run.mjs` with the recorded adapter and:

```sh
--lanes parse,check --jobs 1 --worker-mode persistent \
--recycle-after 64 --rss-limit-mb 4096 --stack-kb 4096 \
--heap-mb 4096 --timeout 300000 --retain failed --output NEW_REPORT.json
```

Run the frozen typed adapter and pinned upstream adapter serially on the same available isolated core. Preserve nonzero conformance exits and exact failure reports. This is broad frontend validation; it does not cover all execution/backend lanes or establish whole-language conformance.
