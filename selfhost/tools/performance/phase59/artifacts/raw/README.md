# Closed Phase59 evidence

The [capsule](raw-campaign.tar.gz) contains all 518 files of the closed
`selfhost/build/phase59/` campaign, including original profiles, source-operation
counts, per-process output checks, private diagnostic images, derivations,
preservation receipts, the CPU timestamp refusal and data-analysis parser failure.

- Uncompressed: 86,059,319 bytes.
- Gzip: 5,330,436 bytes.
- SHA256: `711cde7dc2d8576b1a39d37efe5195c8ec7836f9c639a9f4c474cc79b0989673`.
- [Member inventory and verified hashes](archive.json).
- [Publication receipt](publication.json).

The archive producer streamed every member, reopened and verified its hash, and
verified the source inventory/content stayed unchanged. No members are omitted.
No splitting was needed. This is diagnostic evidence, not a compiler release.

Extract into a new empty directory to inspect it; never overwrite an existing
closed campaign. Member names are relative to `selfhost/build/phase59/`. Links in
the reports into that build directory refer to these archived members rather
than loose files committed to Git. Exact receipts also reference the unchanged
Phase58 campaign and pinned upstream checkout. Replaying measurements requires
those dependencies; the report and committed diagrams can be read independently.

All campaign raw writers are closed. Future runs must use fresh output paths.
