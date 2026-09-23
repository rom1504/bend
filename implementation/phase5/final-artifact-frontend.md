# Final generated-artifact frontend validation

**Both final artifacts passed the complete frontend equivalence gate.** Public H and the maintained equality-derived B1 each produced all 2,756 parse/check observations for 1,378 pinned fixtures, exactly matching final genuine checked B1. There were zero differences in result objects, diagnostics, verdicts or evidence. All input identities and closed worker histories passed verification. The wrapper exited zero at **2026-09-23 02:30:30.693 UTC**.

| Artifact | Observations | Differences | Closed histories | Harness process wall |
|---|---:|---:|---:|---:|
| Public H | 2,756 | 0 | 45 | 862.369 s |
| Equality-derived B1 | 2,756 | 0 | 46 | 192.166 s |

These are validation workflow observations, **not a controlled performance comparison**. Other agents performed bounded setup, review and archival work concurrently. Base preparation was outside those harness walls: H 13.939 s, derivative 3.993 s. Each used four persistent workers on CPUs 0–3, 4 MiB Node stack, 4 GiB heap/RSS limits, 300-second per-request timeout and recycling after 64 requests. Every observation mapped uniquely to an actual closed history; request IDs, lanes, result digests and replay-prefix checks passed.

The unchanged maintained self-host proof completed at 02:10:22.188 UTC. Its byte-identical stage2/stage3 H has SHA-256 `5043267732f5178b12d14708e7dc07e3aa1a71b9d1d5949ef279af23c4297edd`. The final derivative has SHA-256 `e2b5463678a26558e8fea1d585782e0863f1046067949a374f0469080281b15a`; its maintained derivation references genuine final B1 `5969c53d34a088bc9630eb2c065c2eea7fd260294cf3fefb14dffb305b7e4667`. Actual proof stages, P5-023 emitted bytes, canonical Base, assembled source and runtime identities were checked. No bootstrap metadata was fabricated for either artifact.

This establishes artifact parity, not full-language conformance. Both retain the exact B1 summary: 1,979 passing verdicts, 459 parse observations without strict verdicts, and **318 strict check failures**. Their raw full-conformance flags remain false. No failure was normalized away, reclassified or excluded.

The prospective [plan](final-artifact-validation-plan.md) reduced H’s outer cap from 30 to 25 minutes before launch, preserving all coverage and the 02:45 UTC global deadline. H began at 02:12:48.118 and finished its full audit at 02:27:11.361. The derivative finished its audit at 02:30:27.764. Neither cap nor the global deadline was reached; there were no retries or reduced inventories.

Actual configuration and consumed wrapper snapshot: `selfhost/build/phase5/final-artifact-frontend-launch/`. Raw results: `selfhost/build/phase5/final-artifact-frontend-01/`. The [durable archive](final-artifact-frontend-evidence/README.md) preserves the actual reports, all histories and retained failures, source/API/proof/tool inputs, canonical fixture bytes and cache records with member hashes. Historical paths remain unchanged; restoring bytes does not create a new checked build or relocatable protocol.
