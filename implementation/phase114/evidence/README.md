# Phase114 retained evidence

This directory contains the final receipt plan and capsule companions:

- `plan01.json`: source/config identities, scoped receipt inventory, limits and
  historical-reference dispositions.
- `receipts01.tar.gz`: bounded exact receipts/logs and explicitly labeled excerpts.
- `receipts01.tar.gz.manifest.json` and `receipts01.tar.gz.summary.json`: the
  original gate's verification and restored-byte index. A completed verified
  summary establishes sealing; preparation alone does not.

The broad and native qualification decisions are in [the report](../README.md),
[runtime results](../results.json) and [native results](../native-results.json).
Archive completeness is not a new correctness or promotion gate.

Use the [Phase114 evidence adapter](../../../selfhost/tools/performance/phase114/evidence/README.md)
after targets and report edits finish. It invokes the exact pinned Phase112 gate
unchanged, with Phase114 build scope and `p114-*` directories in phases111–113.
Exact receipts and bounded logs are archived; source/API/IR/native products are
not. The archive index maps captured bytes to `blobs/sha256/HASH`, labels
excerpts, and records both original gate and Phase114 adapter provenance.

Original gate schema names remain Phase112; `index.json.adapter` and `roots`
identify the actual Phase114 scope. Historical failures remain evidence, and
overlapping clocks do not become totals or successful-test counts. Only exact
captures restore complete files; hashes and excerpts authorize no cleanup.

Actual compiler sources, APIs, QBE, objects and executables remain external local
dependencies. Three lossless superseded-intermediate archives under
`selfhost/build/phase114/` retain actual gzip bytes and round-trip verification:
`catalogue-machine-archive01`, `catalogue-qbe-archive01` and
`superseded-code-archive01`. Their receipt JSON belongs in this capsule, but their
gzip payloads do not. Restore from those actual archives and verify the original
size/SHA256; a hash-only capsule entry cannot restore a machine product.
