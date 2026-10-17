# Corrected default: incremental evidence

The [receipt](receipt.json) and [manifest](manifest.json) describe 11,200 added
files, 423,480,864 raw bytes and 41,654,344 compressed bytes. Every member was
verified. The single compressed part has SHA256
`cb98cc85662ad41380cff5fbc793c5304cb8bea767073bfd4ded9937eda16d8f`.

This supplements the immutable [original Phase102 archive](../evidence/receipt.json).
Its 34,940 baseline files still match, with no missing paths. No old archive,
sample, failed attempt or qualified source was replaced. Only explicitly named
new CLI/default request directories were included from request history.

From the repository root, verify this archive without running a compiler:

```sh
python3 -B selfhost/tools/performance/phase102/archive-incremental.py verify implementation/phase102/evidence04/receipt.json
```

For ordinary compiler use or missing request assets, follow the
[native default guide](../../../docs/self_hosted/NATIVE_PHASE102.md). Its stable
request capsule is distinct from this experiment archive. The
[promotion report](../default-promotion.md) records the release decision and
remaining performance and support limits.
